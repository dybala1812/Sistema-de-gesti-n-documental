-- =============================================================================
-- SGD · 08 · Row-Level Security (MODELO §9.3)
--
-- RLS activado en las 28 tablas. Con RLS activo y sin política, un rol no ve NADA:
-- por eso cada tabla tiene políticas explícitas para los roles que sí deben entrar.
--
-- Roles de la petición (app.rol): recepcion, dependencia, archivo_central, administrador,
-- portal, n8n, sistema. Ver 05_funciones.sql.
--
-- Nota sobre "creado_en = now()": now() es la hora de inicio de la transacción, así que esa
-- condición solo es cierta para filas creadas en la MISMA transacción. Permite que el
-- INSERT ... RETURNING de Prisma funcione sin abrir la lectura de filas ajenas.
-- =============================================================================

SET search_path = sgd, extensions, public;

DO $$
DECLARE
  t text;
BEGIN
  FOR t IN SELECT tablename FROM pg_tables WHERE schemaname = 'sgd' LOOP
    EXECUTE format('ALTER TABLE sgd.%I ENABLE ROW LEVEL SECURITY', t);
  END LOOP;
END
$$;

-- =============================================================================
-- GRUPO B · Catálogos: leen los roles internos; escribe solo el Administrador
-- =============================================================================

-- roles (fijos: sin escritura desde la API)
CREATE POLICY roles_leer_api ON sgd.roles FOR SELECT TO sgd_api
  USING (sgd.rol_en('recepcion', 'dependencia', 'archivo_central', 'administrador', 'sistema', 'n8n'));
CREATE POLICY roles_leer_auth ON sgd.roles FOR SELECT TO sgd_auth
  USING (true);

-- tipos_documento
CREATE POLICY tipos_documento_leer ON sgd.tipos_documento FOR SELECT TO sgd_api
  USING (sgd.rol_en('recepcion', 'dependencia', 'archivo_central', 'administrador', 'sistema', 'n8n', 'portal'));
CREATE POLICY tipos_documento_modificar ON sgd.tipos_documento FOR UPDATE TO sgd_api
  USING (sgd.rol_en('administrador')) WITH CHECK (sgd.rol_en('administrador'));

-- dependencias
CREATE POLICY dependencias_leer ON sgd.dependencias FOR SELECT TO sgd_api
  USING (sgd.rol_en('recepcion', 'dependencia', 'archivo_central', 'administrador', 'sistema', 'n8n'));
CREATE POLICY dependencias_crear ON sgd.dependencias FOR INSERT TO sgd_api
  WITH CHECK (sgd.rol_en('administrador'));
CREATE POLICY dependencias_modificar ON sgd.dependencias FOR UPDATE TO sgd_api
  USING (sgd.rol_en('administrador')) WITH CHECK (sgd.rol_en('administrador'));

-- programas (el portal los lista en el formulario)
CREATE POLICY programas_leer ON sgd.programas FOR SELECT TO sgd_api
  USING (sgd.rol_en('recepcion', 'dependencia', 'archivo_central', 'administrador', 'sistema', 'n8n')
         OR (sgd.rol_en('portal') AND activo));
CREATE POLICY programas_crear ON sgd.programas FOR INSERT TO sgd_api
  WITH CHECK (sgd.rol_en('administrador'));
CREATE POLICY programas_modificar ON sgd.programas FOR UPDATE TO sgd_api
  USING (sgd.rol_en('administrador')) WITH CHECK (sgd.rol_en('administrador'));

-- tipos_tramite (RF-019; el portal solo ve los activos y visibles)
CREATE POLICY tipos_tramite_leer ON sgd.tipos_tramite FOR SELECT TO sgd_api
  USING (sgd.rol_en('recepcion', 'dependencia', 'archivo_central', 'administrador', 'sistema', 'n8n')
         OR (sgd.rol_en('portal') AND activo AND visible_en_portal));
CREATE POLICY tipos_tramite_crear ON sgd.tipos_tramite FOR INSERT TO sgd_api
  WITH CHECK (sgd.rol_en('administrador'));
CREATE POLICY tipos_tramite_modificar ON sgd.tipos_tramite FOR UPDATE TO sgd_api
  USING (sgd.rol_en('administrador')) WITH CHECK (sgd.rol_en('administrador'));

-- festivos (el portal los necesita para calcular la fecha límite)
CREATE POLICY festivos_leer ON sgd.festivos FOR SELECT TO sgd_api
  USING (sgd.rol_en('recepcion', 'dependencia', 'archivo_central', 'administrador', 'sistema', 'n8n', 'portal'));
CREATE POLICY festivos_crear ON sgd.festivos FOR INSERT TO sgd_api
  WITH CHECK (sgd.rol_en('administrador'));
CREATE POLICY festivos_modificar ON sgd.festivos FOR UPDATE TO sgd_api
  USING (sgd.rol_en('administrador')) WITH CHECK (sgd.rol_en('administrador'));

-- parametros_sistema
CREATE POLICY parametros_leer ON sgd.parametros_sistema FOR SELECT TO sgd_api
  USING (sgd.rol_en('recepcion', 'dependencia', 'archivo_central', 'administrador', 'sistema', 'n8n', 'portal'));
CREATE POLICY parametros_crear ON sgd.parametros_sistema FOR INSERT TO sgd_api
  WITH CHECK (sgd.rol_en('administrador'));
CREATE POLICY parametros_modificar ON sgd.parametros_sistema FOR UPDATE TO sgd_api
  USING (sgd.rol_en('administrador'))
  WITH CHECK (sgd.rol_en('administrador') AND actualizado_por = sgd.usuario_actual());

-- =============================================================================
-- Seguridad
-- =============================================================================

-- usuarios: todos los internos leen (autores, responsables); solo el Administrador escribe (RN-004)
CREATE POLICY usuarios_leer ON sgd.usuarios FOR SELECT TO sgd_api
  USING (sgd.rol_en('recepcion', 'dependencia', 'archivo_central', 'administrador', 'sistema'));
CREATE POLICY usuarios_crear ON sgd.usuarios FOR INSERT TO sgd_api
  WITH CHECK (sgd.rol_en('administrador') AND creado_por = sgd.usuario_actual());
CREATE POLICY usuarios_modificar ON sgd.usuarios FOR UPDATE TO sgd_api
  USING (sgd.rol_en('administrador')) WITH CHECK (sgd.rol_en('administrador'));
-- El módulo de autenticación lee el perfil y actualiza ultimo_acceso (GRANT por columna en 07).
CREATE POLICY usuarios_leer_auth ON sgd.usuarios FOR SELECT TO sgd_auth
  USING (true);
CREATE POLICY usuarios_acceso_auth ON sgd.usuarios FOR UPDATE TO sgd_auth
  USING (true) WITH CHECK (true);

-- GRUPO C · credenciales_usuario y sesiones: solo sgd_auth (sgd_api ni siquiera tiene GRANT)
CREATE POLICY credenciales_auth ON sgd.credenciales_usuario FOR ALL TO sgd_auth
  USING (true) WITH CHECK (true);
CREATE POLICY sesiones_auth ON sgd.sesiones FOR ALL TO sgd_auth
  USING (true) WITH CHECK (true);

-- GRUPO C · contadores_consecutivo: SIN políticas a propósito.
-- Solo sgd.siguiente_consecutivo() (SECURITY DEFINER) la modifica.

-- =============================================================================
-- GRUPO A · Filtro por fila
-- =============================================================================

-- personas: la dependencia solo ve las de sus radicados. El portal no lee: usa
-- sgd.registrar_persona_portal().
CREATE POLICY personas_leer ON sgd.personas FOR SELECT TO sgd_api
  USING (sgd.persona_visible(id_persona)
         OR (sgd.rol_en('recepcion', 'dependencia') AND creado_por = sgd.usuario_actual() AND creado_en = now()));
CREATE POLICY personas_crear ON sgd.personas FOR INSERT TO sgd_api
  WITH CHECK (sgd.rol_en('recepcion', 'dependencia') AND creado_por = sgd.usuario_actual());
CREATE POLICY personas_modificar ON sgd.personas FOR UPDATE TO sgd_api
  USING (sgd.rol_en('recepcion', 'administrador')) WITH CHECK (sgd.rol_en('recepcion', 'administrador'));

-- radicados
CREATE POLICY radicados_leer ON sgd.radicados FOR SELECT TO sgd_api
  USING (
    sgd.rol_en('recepcion', 'archivo_central', 'administrador', 'sistema', 'n8n')
    OR (sgd.rol_en('dependencia')
        AND (dependencia_id = sgd.dependencia_actual()
             OR dependencia_emisora_id = sgd.dependencia_actual()
             OR sgd.radicado_visible(id_radicado)))
    -- El portal solo ve lo que acaba de radicar en esta transacción (para el comprobante).
    OR (sgd.rol_en('portal') AND canal = 'portal_publico' AND creado_en = now())
  );
CREATE POLICY radicados_crear ON sgd.radicados FOR INSERT TO sgd_api
  WITH CHECK (
    (sgd.rol_en('recepcion')
       AND canal <> 'portal_publico' AND registrado_por = sgd.usuario_actual())
    OR (sgd.rol_en('dependencia')
       AND canal <> 'portal_publico' AND registrado_por = sgd.usuario_actual()
       AND dependencia_emisora_id = sgd.dependencia_actual())
    OR (sgd.rol_en('portal')
       AND canal = 'portal_publico' AND registrado_por IS NULL)
  );
CREATE POLICY radicados_modificar ON sgd.radicados FOR UPDATE TO sgd_api
  USING (
    sgd.rol_en('recepcion', 'administrador', 'sistema', 'n8n')
    OR (sgd.rol_en('dependencia') AND dependencia_id = sgd.dependencia_actual())
  )
  WITH CHECK (
    sgd.rol_en('recepcion', 'administrador', 'sistema', 'n8n')
    OR (sgd.rol_en('dependencia') AND dependencia_id = sgd.dependencia_actual())
  );

-- asignaciones (RF-005)
CREATE POLICY asignaciones_leer ON sgd.asignaciones FOR SELECT TO sgd_api
  USING (sgd.radicado_visible(radicado_id));
CREATE POLICY asignaciones_crear ON sgd.asignaciones FOR INSERT TO sgd_api
  WITH CHECK (
    (sgd.rol_en('recepcion') AND origen = 'usuario' AND asignado_por = sgd.usuario_actual())
    OR (sgd.rol_en('n8n') AND origen = 'n8n' AND asignado_por IS NULL)
  );
CREATE POLICY asignaciones_modificar ON sgd.asignaciones FOR UPDATE TO sgd_api
  USING (sgd.rol_en('recepcion', 'n8n')
         OR (sgd.rol_en('dependencia') AND dependencia_id = sgd.dependencia_actual()))
  WITH CHECK (sgd.rol_en('recepcion', 'n8n')
              OR (sgd.rol_en('dependencia') AND dependencia_id = sgd.dependencia_actual()));

-- respuestas (RF-002, RN-008): la dependencia responde; Recepción verifica
CREATE POLICY respuestas_leer ON sgd.respuestas FOR SELECT TO sgd_api
  USING (sgd.rol_en('recepcion', 'archivo_central', 'administrador', 'sistema', 'n8n')
         OR (sgd.rol_en('dependencia') AND dependencia_id = sgd.dependencia_actual()));
CREATE POLICY respuestas_crear ON sgd.respuestas FOR INSERT TO sgd_api
  WITH CHECK (sgd.rol_en('dependencia')
              AND dependencia_id = sgd.dependencia_actual()
              AND respondido_por = sgd.usuario_actual()
              AND estado_verificacion = 'pendiente'
              AND sgd.radicado_visible(radicado_id));
CREATE POLICY respuestas_verificar ON sgd.respuestas FOR UPDATE TO sgd_api
  USING (sgd.rol_en('recepcion', 'administrador'))
  WITH CHECK (sgd.rol_en('recepcion', 'administrador'));

-- documentos (RF-004)
CREATE POLICY documentos_leer ON sgd.documentos FOR SELECT TO sgd_api
  USING (
    (radicado_id IS NOT NULL AND sgd.radicado_visible(radicado_id))
    OR (respuesta_id IS NOT NULL AND sgd.respuesta_visible(respuesta_id))
    OR (expediente_id IS NOT NULL AND sgd.rol_en('recepcion', 'archivo_central', 'administrador'))
    OR (sgd.rol_en('portal') AND subido_por IS NULL AND subido_en = now())
  );
CREATE POLICY documentos_crear ON sgd.documentos FOR INSERT TO sgd_api
  WITH CHECK (
    (sgd.rol_en('recepcion', 'archivo_central') AND subido_por = sgd.usuario_actual()
       AND (radicado_id IS NOT NULL OR expediente_id IS NOT NULL))
    OR (sgd.rol_en('dependencia') AND subido_por = sgd.usuario_actual()
       AND ((radicado_id IS NOT NULL AND sgd.radicado_visible(radicado_id))
            OR (respuesta_id IS NOT NULL AND sgd.respuesta_visible(respuesta_id))))
    OR (sgd.rol_en('portal') AND subido_por IS NULL AND origen = 'portal' AND radicado_id IS NOT NULL)
  );
CREATE POLICY documentos_anular ON sgd.documentos FOR UPDATE TO sgd_api
  USING (sgd.rol_en('administrador')) WITH CHECK (sgd.rol_en('administrador'));

-- correspondencia_sin_consecutivo (RF-014)
CREATE POLICY correspondencia_leer ON sgd.correspondencia_sin_consecutivo FOR SELECT TO sgd_api
  USING (sgd.rol_en('recepcion', 'administrador')
         OR (sgd.rol_en('dependencia') AND dependencia_destino_id = sgd.dependencia_actual()));
CREATE POLICY correspondencia_crear ON sgd.correspondencia_sin_consecutivo FOR INSERT TO sgd_api
  WITH CHECK (sgd.rol_en('recepcion') AND registrado_por = sgd.usuario_actual());
CREATE POLICY correspondencia_modificar ON sgd.correspondencia_sin_consecutivo FOR UPDATE TO sgd_api
  USING (sgd.rol_en('recepcion')) WITH CHECK (sgd.rol_en('recepcion'));

-- sesiones_comite
CREATE POLICY sesiones_comite_leer ON sgd.sesiones_comite FOR SELECT TO sgd_api
  USING (sgd.rol_en('recepcion', 'dependencia', 'archivo_central', 'administrador', 'sistema'));
CREATE POLICY sesiones_comite_crear ON sgd.sesiones_comite FOR INSERT TO sgd_api
  WITH CHECK ((sgd.rol_en('dependencia') AND dependencia_id = sgd.dependencia_actual()
               OR sgd.rol_en('administrador'))
              AND creado_por = sgd.usuario_actual());
CREATE POLICY sesiones_comite_modificar ON sgd.sesiones_comite FOR UPDATE TO sgd_api
  USING ((sgd.rol_en('dependencia') AND dependencia_id = sgd.dependencia_actual()) OR sgd.rol_en('administrador'))
  WITH CHECK ((sgd.rol_en('dependencia') AND dependencia_id = sgd.dependencia_actual()) OR sgd.rol_en('administrador'));

-- decisiones_comite (RF-016)
CREATE POLICY decisiones_leer ON sgd.decisiones_comite FOR SELECT TO sgd_api
  USING (sgd.radicado_visible(radicado_id));
CREATE POLICY decisiones_crear ON sgd.decisiones_comite FOR INSERT TO sgd_api
  WITH CHECK (sgd.rol_en('dependencia')
              AND registrado_por = sgd.usuario_actual()
              AND sgd.radicado_visible(radicado_id));

-- eventos_trazabilidad (RF-006): solo inserción, y el origen debe coincidir con quién lo inserta
CREATE POLICY eventos_leer ON sgd.eventos_trazabilidad FOR SELECT TO sgd_api
  USING (sgd.radicado_visible(radicado_id)
         OR (sgd.rol_en('portal') AND origen = 'portal' AND ocurrido_en = now()));
CREATE POLICY eventos_crear ON sgd.eventos_trazabilidad FOR INSERT TO sgd_api
  WITH CHECK (
    (sgd.rol_en('recepcion', 'dependencia', 'archivo_central', 'administrador')
       AND origen = 'usuario' AND usuario_id = sgd.usuario_actual()
       AND sgd.radicado_visible(radicado_id))
    OR (sgd.rol_en('portal')  AND origen = 'portal')
    OR (sgd.rol_en('n8n')     AND origen = 'n8n')
    OR (sgd.rol_en('sistema') AND origen = 'sistema')
  );

-- alertas_vencimiento (RF-015): las genera la tarea periódica
CREATE POLICY alertas_leer ON sgd.alertas_vencimiento FOR SELECT TO sgd_api
  USING (sgd.radicado_visible(radicado_id));
CREATE POLICY alertas_crear ON sgd.alertas_vencimiento FOR INSERT TO sgd_api
  WITH CHECK (sgd.rol_en('sistema'));
CREATE POLICY alertas_atender ON sgd.alertas_vencimiento FOR UPDATE TO sgd_api
  USING (sgd.rol_en('sistema', 'recepcion', 'administrador')
         OR (sgd.rol_en('dependencia') AND sgd.radicado_visible(radicado_id)))
  WITH CHECK (sgd.rol_en('sistema', 'recepcion', 'administrador')
              OR (sgd.rol_en('dependencia') AND sgd.radicado_visible(radicado_id)));

-- =============================================================================
-- GRUPO B · Archivo Central, auditoría e integraciones
-- =============================================================================

CREATE POLICY series_leer ON sgd.series_documentales FOR SELECT TO sgd_api
  USING (sgd.rol_en('recepcion', 'archivo_central', 'administrador'));
CREATE POLICY series_crear ON sgd.series_documentales FOR INSERT TO sgd_api
  WITH CHECK (sgd.rol_en('archivo_central', 'administrador'));
CREATE POLICY series_modificar ON sgd.series_documentales FOR UPDATE TO sgd_api
  USING (sgd.rol_en('archivo_central', 'administrador')) WITH CHECK (sgd.rol_en('archivo_central', 'administrador'));

CREATE POLICY subseries_leer ON sgd.subseries_documentales FOR SELECT TO sgd_api
  USING (sgd.rol_en('recepcion', 'archivo_central', 'administrador'));
CREATE POLICY subseries_crear ON sgd.subseries_documentales FOR INSERT TO sgd_api
  WITH CHECK (sgd.rol_en('archivo_central', 'administrador'));
CREATE POLICY subseries_modificar ON sgd.subseries_documentales FOR UPDATE TO sgd_api
  USING (sgd.rol_en('archivo_central', 'administrador')) WITH CHECK (sgd.rol_en('archivo_central', 'administrador'));

-- expedientes y clasificaciones (RF-010). Recepción también maneja Archivo Central en la maquetación.
CREATE POLICY expedientes_leer ON sgd.expedientes FOR SELECT TO sgd_api
  USING (sgd.rol_en('recepcion', 'archivo_central', 'administrador'));
CREATE POLICY expedientes_crear ON sgd.expedientes FOR INSERT TO sgd_api
  WITH CHECK (sgd.rol_en('recepcion', 'archivo_central') AND creado_por = sgd.usuario_actual());
CREATE POLICY expedientes_modificar ON sgd.expedientes FOR UPDATE TO sgd_api
  USING (sgd.rol_en('recepcion', 'archivo_central', 'administrador'))
  WITH CHECK (sgd.rol_en('recepcion', 'archivo_central', 'administrador'));

CREATE POLICY clasificaciones_leer ON sgd.clasificaciones FOR SELECT TO sgd_api
  USING (sgd.rol_en('recepcion', 'archivo_central', 'administrador'));
CREATE POLICY clasificaciones_crear ON sgd.clasificaciones FOR INSERT TO sgd_api
  WITH CHECK (sgd.rol_en('recepcion', 'archivo_central') AND clasificado_por = sgd.usuario_actual());
CREATE POLICY clasificaciones_modificar ON sgd.clasificaciones FOR UPDATE TO sgd_api
  USING (sgd.rol_en('recepcion', 'archivo_central', 'administrador'))
  WITH CHECK (sgd.rol_en('recepcion', 'archivo_central', 'administrador'));

-- auditoria_cambios: solo el Administrador la consulta; cualquiera registra lo que hace
CREATE POLICY auditoria_leer ON sgd.auditoria_cambios FOR SELECT TO sgd_api
  USING (sgd.rol_en('administrador') OR ocurrido_en = now());
CREATE POLICY auditoria_crear ON sgd.auditoria_cambios FOR INSERT TO sgd_api
  WITH CHECK (sgd.rol_en('recepcion', 'dependencia', 'archivo_central', 'administrador', 'portal', 'n8n', 'sistema')
              AND (usuario_id IS NULL OR usuario_id = sgd.usuario_actual()));
CREATE POLICY auditoria_leer_auth ON sgd.auditoria_cambios FOR SELECT TO sgd_auth
  USING (ocurrido_en = now());
CREATE POLICY auditoria_crear_auth ON sgd.auditoria_cambios FOR INSERT TO sgd_auth
  WITH CHECK (tabla_afectada IN ('usuarios', 'credenciales_usuario', 'sesiones')
              AND accion IN ('iniciar_sesion', 'inicio_sesion_fallido', 'cerrar_sesion', 'actualizar'));

-- notificaciones: cualquier rol de la API las encola; las envían n8n o la tarea del sistema
CREATE POLICY notificaciones_leer ON sgd.notificaciones FOR SELECT TO sgd_api
  USING (sgd.rol_en('recepcion', 'administrador', 'sistema', 'n8n') OR creado_en = now());
CREATE POLICY notificaciones_crear ON sgd.notificaciones FOR INSERT TO sgd_api
  WITH CHECK (sgd.rol_en('recepcion', 'dependencia', 'archivo_central', 'administrador', 'portal', 'n8n', 'sistema'));
CREATE POLICY notificaciones_modificar ON sgd.notificaciones FOR UPDATE TO sgd_api
  USING (sgd.rol_en('sistema', 'n8n')) WITH CHECK (sgd.rol_en('sistema', 'n8n'));

-- ejecuciones_n8n
CREATE POLICY ejecuciones_leer ON sgd.ejecuciones_n8n FOR SELECT TO sgd_api
  USING (sgd.rol_en('administrador', 'sistema', 'n8n'));
CREATE POLICY ejecuciones_crear ON sgd.ejecuciones_n8n FOR INSERT TO sgd_api
  WITH CHECK (sgd.rol_en('sistema', 'n8n'));
CREATE POLICY ejecuciones_modificar ON sgd.ejecuciones_n8n FOR UPDATE TO sgd_api
  USING (sgd.rol_en('sistema', 'n8n')) WITH CHECK (sgd.rol_en('sistema', 'n8n'));
