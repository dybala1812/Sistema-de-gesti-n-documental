-- =============================================================================
-- SGD · 05 · Funciones (MODELO §9.2 y §9.4)
-- =============================================================================

SET search_path = sgd, extensions, public;

-- -----------------------------------------------------------------------------
-- Contexto de la petición (MODELO §9.2)
-- La API fija app.usuario_id, app.rol y app.dependencia_id con set_config(..., true)
-- al inicio de cada transacción. Sin contexto, todo devuelve NULL y RLS no deja pasar nada.
-- -----------------------------------------------------------------------------

CREATE FUNCTION sgd.rol_actual() RETURNS text
  LANGUAGE sql STABLE
  AS $$ SELECT nullif(current_setting('app.rol', true), '') $$;

CREATE FUNCTION sgd.usuario_actual() RETURNS integer
  LANGUAGE sql STABLE
  AS $$ SELECT nullif(current_setting('app.usuario_id', true), '')::integer $$;

CREATE FUNCTION sgd.dependencia_actual() RETURNS integer
  LANGUAGE sql STABLE
  AS $$ SELECT nullif(current_setting('app.dependencia_id', true), '')::integer $$;

-- true si el rol de la petición está en la lista. Sin rol, false.
CREATE FUNCTION sgd.rol_en(VARIADIC p_roles text[]) RETURNS boolean
  LANGUAGE sql STABLE
  AS $$ SELECT coalesce(sgd.rol_actual() = ANY (p_roles), false) $$;

-- -----------------------------------------------------------------------------
-- Visibilidad para las políticas RLS.
-- Son SECURITY DEFINER para consultar otras tablas sin volver a pasar por RLS
-- (si no, la política de radicados consultaría asignaciones y viceversa, sin fin).
-- -----------------------------------------------------------------------------

-- ¿Puede quien hace la petición ver este radicado?
CREATE FUNCTION sgd.radicado_visible(p_radicado_id integer) RETURNS boolean
  LANGUAGE sql STABLE SECURITY DEFINER
  SET search_path = sgd, extensions, pg_temp
  AS $$
    SELECT CASE
      WHEN sgd.rol_en('recepcion', 'archivo_central', 'administrador', 'sistema', 'n8n') THEN true
      WHEN sgd.rol_actual() = 'dependencia' AND sgd.dependencia_actual() IS NOT NULL THEN
        EXISTS (
          SELECT 1 FROM sgd.radicados r
          WHERE r.id_radicado = p_radicado_id
            AND (r.dependencia_id = sgd.dependencia_actual()
                 OR r.dependencia_emisora_id = sgd.dependencia_actual())
        )
        OR EXISTS (
          SELECT 1 FROM sgd.asignaciones a
          WHERE a.radicado_id = p_radicado_id
            AND a.dependencia_id = sgd.dependencia_actual()
        )
      ELSE false
    END
  $$;

CREATE FUNCTION sgd.respuesta_visible(p_respuesta_id integer) RETURNS boolean
  LANGUAGE sql STABLE SECURITY DEFINER
  SET search_path = sgd, extensions, pg_temp
  AS $$
    SELECT CASE
      WHEN sgd.rol_en('recepcion', 'archivo_central', 'administrador', 'sistema', 'n8n') THEN true
      WHEN sgd.rol_actual() = 'dependencia' AND sgd.dependencia_actual() IS NOT NULL THEN
        EXISTS (
          SELECT 1 FROM sgd.respuestas re
          WHERE re.id_respuesta = p_respuesta_id
            AND re.dependencia_id = sgd.dependencia_actual()
        )
      ELSE false
    END
  $$;

-- Una dependencia solo ve las personas de sus radicados.
CREATE FUNCTION sgd.persona_visible(p_persona_id integer) RETURNS boolean
  LANGUAGE sql STABLE SECURITY DEFINER
  SET search_path = sgd, extensions, pg_temp
  AS $$
    SELECT CASE
      WHEN sgd.rol_en('recepcion', 'archivo_central', 'administrador', 'sistema', 'n8n') THEN true
      WHEN sgd.rol_actual() = 'dependencia' AND sgd.dependencia_actual() IS NOT NULL THEN
        EXISTS (
          SELECT 1 FROM sgd.radicados r
          WHERE r.persona_id = p_persona_id
            AND (r.dependencia_id = sgd.dependencia_actual()
                 OR r.dependencia_emisora_id = sgd.dependencia_actual()
                 OR EXISTS (SELECT 1 FROM sgd.asignaciones a
                            WHERE a.radicado_id = r.id_radicado
                              AND a.dependencia_id = sgd.dependencia_actual()))
        )
      ELSE false
    END
  $$;

-- -----------------------------------------------------------------------------
-- Funciones de negocio SECURITY DEFINER (MODELO §9.4)
-- Única puerta a datos que ningún rol toca directo. Validan el rol de la petición.
-- -----------------------------------------------------------------------------

-- RF-003 / RN-001: siguiente consecutivo por tipo de documento y año, sin duplicados.
-- Llamarla DENTRO de la transacción que crea el radicado.
CREATE FUNCTION sgd.siguiente_consecutivo(p_tipo_documento_id integer, p_anio integer) RETURNS integer
  LANGUAGE plpgsql VOLATILE SECURITY DEFINER
  SET search_path = sgd, extensions, pg_temp
  AS $$
  DECLARE
    v_numero integer;
  BEGIN
    IF NOT sgd.rol_en('recepcion', 'dependencia', 'portal') THEN
      RAISE EXCEPTION 'No autorizado para generar consecutivos' USING ERRCODE = '42501';
    END IF;

    -- El ON CONFLICT bloquea la fila del contador: dos llamadas simultáneas nunca obtienen el mismo número.
    INSERT INTO sgd.contadores_consecutivo AS c (tipo_documento_id, anio, ultimo_numero)
    VALUES (p_tipo_documento_id::smallint, p_anio::smallint, 1)
    ON CONFLICT (tipo_documento_id, anio)
    DO UPDATE SET ultimo_numero = c.ultimo_numero + 1
    RETURNING c.ultimo_numero INTO v_numero;

    RETURN v_numero;
  END
  $$;

-- RF-018 / HU-018: consulta pública. Solo devuelve datos si número Y documento coinciden.
-- No revela cuál de los dos falló: sin coincidencia, cero filas.
CREATE FUNCTION sgd.consultar_estado_publico(p_numero_radicado text, p_numero_identificacion text)
  RETURNS TABLE (
    numero_radicado   varchar,
    tipo_tramite      varchar,
    estado            sgd.estado_radicado,
    semaforo          sgd.semaforo,
    fecha_limite      date,
    fecha_radicacion  timestamptz
  )
  LANGUAGE plpgsql STABLE SECURITY DEFINER
  SET search_path = sgd, extensions, pg_temp
  AS $$
  BEGIN
    IF sgd.rol_actual() IS DISTINCT FROM 'portal' THEN
      RAISE EXCEPTION 'Solo para el portal público' USING ERRCODE = '42501';
    END IF;

    RETURN QUERY
      SELECT r.numero_radicado, t.nombre, r.estado, r.semaforo, r.fecha_limite, r.fecha_radicacion
      FROM sgd.radicados r
      JOIN sgd.personas p ON p.id_persona = r.persona_id
      LEFT JOIN sgd.tipos_tramite t ON t.id_tipo_tramite = r.tipo_tramite_id
      WHERE r.numero_radicado = upper(btrim(p_numero_radicado))
        AND p.numero_identificacion = regexp_replace(p_numero_identificacion, '[^0-9A-Za-z-]', '', 'g');
  END
  $$;

-- RF-017: el portal obtiene el id de la persona sin poder leer sus datos (P-01).
-- Si ya existe, NO modifica sus datos: el correo de respuesta va en radicados.correo_notificacion.
CREATE FUNCTION sgd.registrar_persona_portal(p_tipo_identificacion text, p_numero_identificacion text, p_nombre_completo text)
  RETURNS integer
  LANGUAGE plpgsql VOLATILE SECURITY DEFINER
  SET search_path = sgd, extensions, pg_temp
  AS $$
  DECLARE
    v_tipo   sgd.tipo_identificacion := p_tipo_identificacion::sgd.tipo_identificacion;
    v_numero text := regexp_replace(p_numero_identificacion, '[^0-9A-Za-z-]', '', 'g');
    v_id     integer;
  BEGIN
    IF sgd.rol_actual() IS DISTINCT FROM 'portal' THEN
      RAISE EXCEPTION 'Solo para el portal público' USING ERRCODE = '42501';
    END IF;

    SELECT id_persona INTO v_id
    FROM sgd.personas
    WHERE tipo_identificacion = v_tipo AND numero_identificacion = v_numero;

    IF v_id IS NULL THEN
      INSERT INTO sgd.personas (tipo_identificacion, numero_identificacion, nombre_completo, estado)
      VALUES (v_tipo, v_numero, btrim(p_nombre_completo), 'externo')
      ON CONFLICT (tipo_identificacion, numero_identificacion) DO NOTHING
      RETURNING id_persona INTO v_id;

      -- Otra petición la creó al mismo tiempo.
      IF v_id IS NULL THEN
        SELECT id_persona INTO v_id
        FROM sgd.personas
        WHERE tipo_identificacion = v_tipo AND numero_identificacion = v_numero;
      END IF;
    END IF;

    RETURN v_id;
  END
  $$;

-- RF-012: el Administrador asigna o restablece la contraseña temporal de un usuario.
-- sgd_api no puede leer ni escribir credenciales_usuario; solo por aquí.
CREATE FUNCTION sgd.establecer_clave_temporal(p_usuario_id integer, p_password_hash text) RETURNS void
  LANGUAGE plpgsql VOLATILE SECURITY DEFINER
  SET search_path = sgd, extensions, pg_temp
  AS $$
  BEGIN
    IF NOT sgd.rol_en('administrador') THEN
      RAISE EXCEPTION 'Solo el Administrador puede asignar contraseñas' USING ERRCODE = '42501';
    END IF;
    IF NOT EXISTS (SELECT 1 FROM sgd.usuarios WHERE id_usuario = p_usuario_id) THEN
      RAISE EXCEPTION 'El usuario % no existe', p_usuario_id USING ERRCODE = 'P0002';
    END IF;

    INSERT INTO sgd.credenciales_usuario (usuario_id, password_hash, debe_cambiar_clave)
    VALUES (p_usuario_id, p_password_hash, true)
    ON CONFLICT (usuario_id) DO UPDATE
      SET password_hash        = EXCLUDED.password_hash,
          debe_cambiar_clave   = true,
          clave_actualizada_en = now(),
          intentos_fallidos    = 0,
          bloqueado_hasta      = NULL;

    -- Una contraseña nueva cierra todas las sesiones abiertas.
    UPDATE sgd.sesiones SET revocada_en = now()
    WHERE usuario_id = p_usuario_id AND revocada_en IS NULL;
  END
  $$;

-- RF-012: al deshabilitar un usuario se cierran sus sesiones de inmediato.
CREATE FUNCTION sgd.revocar_sesiones(p_usuario_id integer) RETURNS integer
  LANGUAGE plpgsql VOLATILE SECURITY DEFINER
  SET search_path = sgd, extensions, pg_temp
  AS $$
  DECLARE
    v_total integer;
  BEGIN
    IF NOT sgd.rol_en('administrador') THEN
      RAISE EXCEPTION 'Solo el Administrador puede revocar sesiones' USING ERRCODE = '42501';
    END IF;

    UPDATE sgd.sesiones SET revocada_en = now()
    WHERE usuario_id = p_usuario_id AND revocada_en IS NULL;
    GET DIAGNOSTICS v_total = ROW_COUNT;
    RETURN v_total;
  END
  $$;

-- -----------------------------------------------------------------------------
-- Cálculo de plazos (RF-015)
-- -----------------------------------------------------------------------------

-- Fecha límite: cuenta p_dias días hábiles DESPUÉS de p_desde, sin sábados, domingos ni festivos.
CREATE FUNCTION sgd.sumar_dias_habiles(p_desde date, p_dias integer) RETURNS date
  LANGUAGE plpgsql STABLE
  AS $$
  DECLARE
    v_fecha   date := p_desde;
    v_contados integer := 0;
  BEGIN
    IF p_dias IS NULL OR p_dias < 0 THEN
      RAISE EXCEPTION 'Los días hábiles deben ser un número positivo';
    END IF;
    WHILE v_contados < p_dias LOOP
      v_fecha := v_fecha + 1;
      IF extract(isodow FROM v_fecha) < 6
         AND NOT EXISTS (SELECT 1 FROM sgd.festivos f WHERE f.fecha = v_fecha) THEN
        v_contados := v_contados + 1;
      END IF;
    END LOOP;
    RETURN v_fecha;
  END
  $$;

-- -----------------------------------------------------------------------------
-- Funciones de los disparadores (se enlazan en 06_disparadores.sql)
-- -----------------------------------------------------------------------------

CREATE FUNCTION sgd.fn_actualizado_en() RETURNS trigger
  LANGUAGE plpgsql
  AS $$
  BEGIN
    NEW.actualizado_en := now();
    RETURN NEW;
  END
  $$;

-- Bitácoras inmutables: eventos_trazabilidad y auditoria_cambios.
CREATE FUNCTION sgd.fn_solo_insercion() RETURNS trigger
  LANGUAGE plpgsql
  AS $$
  BEGIN
    RAISE EXCEPTION 'La tabla % es de solo inserción: no se puede %', TG_TABLE_NAME, lower(TG_OP)
      USING ERRCODE = '42501';
  END
  $$;

-- RN-002: nada se borra. Se anula, se deshabilita o se desactiva.
CREATE FUNCTION sgd.fn_sin_borrado() RETURNS trigger
  LANGUAGE plpgsql
  AS $$
  BEGIN
    RAISE EXCEPTION 'En % no se borran filas: se anulan, deshabilitan o desactivan (RN-002)', TG_TABLE_NAME
      USING ERRCODE = '42501';
  END
  $$;
