-- =============================================================================
-- SGD · 06 · Disparadores (MODELO §7)
-- =============================================================================

SET search_path = sgd, extensions, public;

-- actualizado_en = now() en cada UPDATE
CREATE TRIGGER tg_actualizado_en BEFORE UPDATE ON sgd.dependencias         FOR EACH ROW EXECUTE FUNCTION sgd.fn_actualizado_en();
CREATE TRIGGER tg_actualizado_en BEFORE UPDATE ON sgd.tipos_tramite        FOR EACH ROW EXECUTE FUNCTION sgd.fn_actualizado_en();
CREATE TRIGGER tg_actualizado_en BEFORE UPDATE ON sgd.usuarios             FOR EACH ROW EXECUTE FUNCTION sgd.fn_actualizado_en();
CREATE TRIGGER tg_actualizado_en BEFORE UPDATE ON sgd.credenciales_usuario FOR EACH ROW EXECUTE FUNCTION sgd.fn_actualizado_en();
CREATE TRIGGER tg_actualizado_en BEFORE UPDATE ON sgd.parametros_sistema   FOR EACH ROW EXECUTE FUNCTION sgd.fn_actualizado_en();
CREATE TRIGGER tg_actualizado_en BEFORE UPDATE ON sgd.personas             FOR EACH ROW EXECUTE FUNCTION sgd.fn_actualizado_en();
CREATE TRIGGER tg_actualizado_en BEFORE UPDATE ON sgd.radicados            FOR EACH ROW EXECUTE FUNCTION sgd.fn_actualizado_en();
CREATE TRIGGER tg_actualizado_en BEFORE UPDATE ON sgd.expedientes          FOR EACH ROW EXECUTE FUNCTION sgd.fn_actualizado_en();

-- Bitácoras de solo inserción (RF-006, RN-003)
CREATE TRIGGER tg_solo_insercion BEFORE UPDATE OR DELETE ON sgd.eventos_trazabilidad FOR EACH ROW EXECUTE FUNCTION sgd.fn_solo_insercion();
CREATE TRIGGER tg_solo_insercion BEFORE UPDATE OR DELETE ON sgd.auditoria_cambios    FOR EACH ROW EXECUTE FUNCTION sgd.fn_solo_insercion();

-- Nada del dominio se borra (RN-002). Aplica incluso al dueño de las tablas.
CREATE TRIGGER tg_sin_borrado BEFORE DELETE ON sgd.radicados            FOR EACH ROW EXECUTE FUNCTION sgd.fn_sin_borrado();
CREATE TRIGGER tg_sin_borrado BEFORE DELETE ON sgd.personas             FOR EACH ROW EXECUTE FUNCTION sgd.fn_sin_borrado();
CREATE TRIGGER tg_sin_borrado BEFORE DELETE ON sgd.usuarios             FOR EACH ROW EXECUTE FUNCTION sgd.fn_sin_borrado();
CREATE TRIGGER tg_sin_borrado BEFORE DELETE ON sgd.credenciales_usuario FOR EACH ROW EXECUTE FUNCTION sgd.fn_sin_borrado();
CREATE TRIGGER tg_sin_borrado BEFORE DELETE ON sgd.documentos           FOR EACH ROW EXECUTE FUNCTION sgd.fn_sin_borrado();
CREATE TRIGGER tg_sin_borrado BEFORE DELETE ON sgd.respuestas           FOR EACH ROW EXECUTE FUNCTION sgd.fn_sin_borrado();
CREATE TRIGGER tg_sin_borrado BEFORE DELETE ON sgd.expedientes          FOR EACH ROW EXECUTE FUNCTION sgd.fn_sin_borrado();
CREATE TRIGGER tg_sin_borrado BEFORE DELETE ON sgd.dependencias         FOR EACH ROW EXECUTE FUNCTION sgd.fn_sin_borrado();
CREATE TRIGGER tg_sin_borrado BEFORE DELETE ON sgd.tipos_tramite        FOR EACH ROW EXECUTE FUNCTION sgd.fn_sin_borrado();
