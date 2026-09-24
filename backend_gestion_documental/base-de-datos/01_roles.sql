-- =============================================================================
-- SGD · 01 · Roles de base de datos (MODELO §9.1)
--
-- sgd_migraciones: en Supabase es el propio usuario "postgres" (dueño de todo). No se crea aquí.
-- sgd_auth: módulo de autenticación de la API. Único con acceso a contraseñas y sesiones.
-- sgd_api:  resto de la API. Sin acceso a contraseñas ni sesiones y sin DELETE.
--
-- Se crean SIN contraseña y SIN permiso de conexión. La contraseña se pone a mano,
-- fuera del repositorio (ver README.md, paso 3). Nunca escribir contraseñas en este archivo.
-- =============================================================================

DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'sgd_api') THEN
    CREATE ROLE sgd_api NOLOGIN NOSUPERUSER NOCREATEDB NOCREATEROLE NOINHERIT NOBYPASSRLS;
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'sgd_auth') THEN
    CREATE ROLE sgd_auth NOLOGIN NOSUPERUSER NOCREATEDB NOCREATEROLE NOINHERIT NOBYPASSRLS;
  END IF;
END
$$;

COMMENT ON ROLE sgd_api  IS 'SGD: API general. RLS siempre aplica. Sin DELETE.';
COMMENT ON ROLE sgd_auth IS 'SGD: módulo de autenticación. Único con acceso a credenciales_usuario y sesiones.';
