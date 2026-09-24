-- =============================================================================
-- SGD · 00 · Esquema y extensiones
-- Modelo: base-de-datos/MODELO_DE_DATOS.md
-- Ejecutar como el dueño de la base (en Supabase: el usuario "postgres").
-- =============================================================================

-- Supabase instala las extensiones en el esquema "extensions"; en local se crea igual.
CREATE SCHEMA IF NOT EXISTS extensions;
CREATE EXTENSION IF NOT EXISTS citext  WITH SCHEMA extensions;  -- correos sin distinguir mayúsculas
CREATE EXTENSION IF NOT EXISTS pg_trgm WITH SCHEMA extensions;  -- búsqueda por nombre y asunto (RF-009)

-- Todo el sistema vive en "sgd", que NO se expone por la API REST de Supabase (MODELO §9.5).
CREATE SCHEMA IF NOT EXISTS sgd;
COMMENT ON SCHEMA sgd IS 'Sistema de Gestión Documental. No exponer en la API de Supabase.';
