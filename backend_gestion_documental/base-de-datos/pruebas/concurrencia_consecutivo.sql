-- =============================================================================
-- SGD · Prueba de concurrencia del consecutivo (T-HU003-02, RN-001, RNF-006)
--
-- SOLO EN UNA BASE LOCAL O DE PRUEBAS. Se ejecuta con pgbench, que viene con PostgreSQL:
--
-- 1) Preparar (como dueño):
--      CREATE TABLE public.prueba_concurrencia (numero integer NOT NULL);
--      GRANT USAGE ON SCHEMA public TO sgd_api;
--      GRANT INSERT ON public.prueba_concurrencia TO sgd_api;
--
-- 2) Correr 8 conexiones simultáneas, 250 transacciones cada una (2.000 consecutivos):
--      pgbench -n -c 8 -j 4 -t 250 -f pruebas/concurrencia_consecutivo.sql <base>
--
-- 3) Verificar: generados = distintos = max = contador = 2000
--      SELECT count(*), count(DISTINCT numero), min(numero), max(numero),
--             (SELECT ultimo_numero FROM sgd.contadores_consecutivo
--              WHERE tipo_documento_id = 2 AND anio = 2030)
--      FROM public.prueba_concurrencia;
--
-- 4) Limpiar (como dueño):
--      DROP TABLE public.prueba_concurrencia;
--      DELETE FROM sgd.contadores_consecutivo WHERE anio = 2030;
--      REVOKE USAGE ON SCHEMA public FROM sgd_api;
--
-- Resultado obtenido el 24-sep-2026 (PostgreSQL 18.3 local): 2000/2000 transacciones,
-- 0 fallidas, 2000 números distintos del 1 al 2000, contador = 2000.
-- Se usa el año 2030 para no tocar los contadores reales.
-- =============================================================================

BEGIN;
SET LOCAL ROLE sgd_api;
SELECT set_config('app.rol', 'recepcion', true);
INSERT INTO public.prueba_concurrencia (numero) SELECT sgd.siguiente_consecutivo(2, 2030);
COMMIT;
