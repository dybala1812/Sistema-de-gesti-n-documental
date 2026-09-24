-- =============================================================================
-- SGD · 07 · Permisos (MODELO §9.1 y §9.5)
-- Los GRANT dicen QUÉ tablas puede tocar cada rol; RLS (08) dice QUÉ FILAS.
-- =============================================================================

SET search_path = sgd, extensions, public;

-- -----------------------------------------------------------------------------
-- Cerrar todo por defecto
-- -----------------------------------------------------------------------------
REVOKE ALL ON SCHEMA sgd FROM PUBLIC;
REVOKE ALL ON ALL TABLES    IN SCHEMA sgd FROM PUBLIC;
REVOKE ALL ON ALL SEQUENCES IN SCHEMA sgd FROM PUBLIC;
REVOKE ALL ON ALL FUNCTIONS IN SCHEMA sgd FROM PUBLIC;

-- Supabase: los roles de su API REST (anon, authenticated) no ven nada del sistema.
-- En una base local estos roles no existen y el bloque no hace nada.
DO $$
DECLARE
  r text;
BEGIN
  FOREACH r IN ARRAY ARRAY['anon', 'authenticated'] LOOP
    IF EXISTS (SELECT 1 FROM pg_roles WHERE rolname = r) THEN
      EXECUTE format('REVOKE ALL ON SCHEMA sgd FROM %I', r);
      EXECUTE format('REVOKE ALL ON ALL TABLES IN SCHEMA sgd FROM %I', r);
      EXECUTE format('REVOKE ALL ON ALL SEQUENCES IN SCHEMA sgd FROM %I', r);
      EXECUTE format('REVOKE ALL ON ALL FUNCTIONS IN SCHEMA sgd FROM %I', r);
    END IF;
  END LOOP;
END
$$;

-- Objetos que se creen después en sgd tampoco quedan abiertos.
ALTER DEFAULT PRIVILEGES IN SCHEMA sgd REVOKE ALL ON TABLES    FROM PUBLIC;
ALTER DEFAULT PRIVILEGES IN SCHEMA sgd REVOKE ALL ON SEQUENCES FROM PUBLIC;
ALTER DEFAULT PRIVILEGES IN SCHEMA sgd REVOKE ALL ON FUNCTIONS FROM PUBLIC;

GRANT USAGE ON SCHEMA sgd TO sgd_api, sgd_auth;
GRANT USAGE ON SCHEMA extensions TO sgd_api, sgd_auth;  -- tipo citext y funciones de pg_trgm

-- -----------------------------------------------------------------------------
-- sgd_api: API general. SELECT/INSERT/UPDATE, nunca DELETE (RN-002).
-- -----------------------------------------------------------------------------
GRANT SELECT, INSERT, UPDATE ON ALL TABLES IN SCHEMA sgd TO sgd_api;

-- Sin acceso a datos sensibles de las cuentas (D-BD-12).
REVOKE ALL ON sgd.credenciales_usuario FROM sgd_api;
REVOKE ALL ON sgd.sesiones             FROM sgd_api;
-- El contador solo se toca con sgd.siguiente_consecutivo() (D-BD-14).
REVOKE ALL ON sgd.contadores_consecutivo FROM sgd_api;
-- Bitácoras: solo leer e insertar.
REVOKE UPDATE ON sgd.eventos_trazabilidad FROM sgd_api;
REVOKE UPDATE ON sgd.auditoria_cambios    FROM sgd_api;
-- Roles fijos: solo lectura.
REVOKE INSERT, UPDATE ON sgd.roles FROM sgd_api;

GRANT USAGE ON ALL SEQUENCES IN SCHEMA sgd TO sgd_api;

GRANT EXECUTE ON FUNCTION
  sgd.rol_actual(), sgd.usuario_actual(), sgd.dependencia_actual(), sgd.rol_en(text[]),
  sgd.radicado_visible(integer), sgd.respuesta_visible(integer), sgd.persona_visible(integer),
  sgd.siguiente_consecutivo(integer, integer),
  sgd.consultar_estado_publico(text, text),
  sgd.registrar_persona_portal(text, text, text),
  sgd.establecer_clave_temporal(integer, text),
  sgd.revocar_sesiones(integer),
  sgd.sumar_dias_habiles(date, integer)
TO sgd_api;

-- -----------------------------------------------------------------------------
-- sgd_auth: solo lo necesario para iniciar sesión, refrescar y cambiar contraseña.
-- -----------------------------------------------------------------------------
GRANT SELECT ON sgd.usuarios, sgd.roles TO sgd_auth;
GRANT UPDATE (ultimo_acceso) ON sgd.usuarios TO sgd_auth;
GRANT SELECT, INSERT, UPDATE ON sgd.credenciales_usuario, sgd.sesiones TO sgd_auth;
GRANT SELECT, INSERT ON sgd.auditoria_cambios TO sgd_auth;
GRANT USAGE ON ALL SEQUENCES IN SCHEMA sgd TO sgd_auth;

GRANT EXECUTE ON FUNCTION
  sgd.rol_actual(), sgd.usuario_actual(), sgd.dependencia_actual(), sgd.rol_en(text[])
TO sgd_auth;
