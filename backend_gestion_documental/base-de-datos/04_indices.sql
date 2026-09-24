-- =============================================================================
-- SGD · 04 · Índices (MODELO §5)
-- PostgreSQL no crea índices para las FK: aquí van los que usan las consultas y las políticas RLS.
-- RNF-001: listado de 500 radicados en menos de 3 s.
-- =============================================================================

SET search_path = sgd, extensions, public;

-- Restricciones únicas parciales (reglas de negocio)
-- Una sola dependencia a cargo de cada radicado.
CREATE UNIQUE INDEX uk_asignaciones_vigente ON sgd.asignaciones (radicado_id) WHERE vigente;
-- Una sola respuesta válida por radicado.
CREATE UNIQUE INDEX uk_respuestas_verificada ON sgd.respuestas (radicado_id) WHERE estado_verificacion = 'verificada';

-- Catálogos y seguridad
CREATE INDEX ix_dependencias_padre     ON sgd.dependencias (dependencia_padre_id);
CREATE INDEX ix_programas_dependencia  ON sgd.programas (dependencia_id);
CREATE INDEX ix_usuarios_rol           ON sgd.usuarios (rol_id);
CREATE INDEX ix_usuarios_dependencia   ON sgd.usuarios (dependencia_id);
CREATE INDEX ix_sesiones_activas       ON sgd.sesiones (usuario_id) WHERE revocada_en IS NULL;

-- Personas (RF-007: búsqueda por cédula sin importar el tipo de documento)
CREATE INDEX ix_personas_numero        ON sgd.personas (numero_identificacion);
CREATE INDEX ix_personas_nombre_trgm   ON sgd.personas USING gin (nombre_completo gin_trgm_ops);
CREATE INDEX ix_personas_programa      ON sgd.personas (programa_id);

-- Radicados
CREATE INDEX ix_radicados_bandeja      ON sgd.radicados (dependencia_id, estado, fecha_limite);
CREATE INDEX ix_radicados_emisora      ON sgd.radicados (dependencia_emisora_id);
CREATE INDEX ix_radicados_estado       ON sgd.radicados (estado, semaforo);
CREATE INDEX ix_radicados_persona      ON sgd.radicados (persona_id, fecha_radicacion DESC);
CREATE INDEX ix_radicados_fecha        ON sgd.radicados (fecha_radicacion DESC);
CREATE INDEX ix_radicados_tramite      ON sgd.radicados (tipo_tramite_id);
CREATE INDEX ix_radicados_tipo_anio    ON sgd.radicados (tipo_documento_id, anio);
CREATE INDEX ix_radicados_asunto_trgm  ON sgd.radicados USING gin (asunto gin_trgm_ops);

-- Radicación
CREATE INDEX ix_asignaciones_radicado  ON sgd.asignaciones (radicado_id, dependencia_id);
CREATE INDEX ix_asignaciones_dependencia ON sgd.asignaciones (dependencia_id);
CREATE INDEX ix_respuestas_radicado    ON sgd.respuestas (radicado_id);
CREATE INDEX ix_respuestas_pendientes  ON sgd.respuestas (estado_verificacion) WHERE estado_verificacion = 'pendiente';
CREATE INDEX ix_documentos_radicado    ON sgd.documentos (radicado_id);
CREATE INDEX ix_documentos_respuesta   ON sgd.documentos (respuesta_id);
CREATE INDEX ix_documentos_expediente  ON sgd.documentos (expediente_id);
CREATE INDEX ix_documentos_hash        ON sgd.documentos (hash_sha256);
CREATE INDEX ix_correspondencia_dependencia ON sgd.correspondencia_sin_consecutivo (dependencia_destino_id, fecha_recepcion DESC);

-- Comité
CREATE INDEX ix_decisiones_radicado    ON sgd.decisiones_comite (radicado_id);

-- Seguimiento
CREATE INDEX ix_eventos_radicado       ON sgd.eventos_trazabilidad (radicado_id, ocurrido_en);
CREATE INDEX ix_alertas_pendientes     ON sgd.alertas_vencimiento (atendida, generada_en DESC);
CREATE INDEX ix_notificaciones_estado  ON sgd.notificaciones (estado, creado_en);
CREATE INDEX ix_notificaciones_radicado ON sgd.notificaciones (radicado_id);
CREATE INDEX ix_ejecuciones_radicado   ON sgd.ejecuciones_n8n (radicado_id);
CREATE INDEX ix_auditoria_registro     ON sgd.auditoria_cambios (tabla_afectada, id_registro);
CREATE INDEX ix_auditoria_usuario      ON sgd.auditoria_cambios (usuario_id, ocurrido_en DESC);
CREATE INDEX ix_auditoria_fecha        ON sgd.auditoria_cambios (ocurrido_en DESC);

-- Archivo Central
CREATE INDEX ix_subseries_serie        ON sgd.subseries_documentales (serie_id);
CREATE INDEX ix_expedientes_subserie   ON sgd.expedientes (subserie_id);
CREATE INDEX ix_expedientes_persona    ON sgd.expedientes (persona_id);
CREATE INDEX ix_clasificaciones_expediente ON sgd.clasificaciones (expediente_id);
