-- =============================================================================
-- SGD · 02 · Tipos enumerados (MODELO §4)
-- Solo listas cerradas por norma o por el flujo. Lo configurable es tabla.
-- =============================================================================

SET search_path = sgd, extensions, public;

CREATE TYPE sgd.estado_radicado AS ENUM (
  'recibido', 'enviado', 'recibido_dependencia', 'en_revision_requisitos', 'en_comite',
  'rechazado_requisitos', 'pendiente_verificacion', 'requiere_correccion', 'respondido',
  'emitido', 'anulado'
);

CREATE TYPE sgd.canal_entrada AS ENUM (
  'ventanilla', 'correo_electronico', 'plataforma_web', 'comunicacion_interna', 'portal_publico'
);

CREATE TYPE sgd.semaforo            AS ENUM ('verde', 'amarillo', 'naranja', 'rojo');
CREATE TYPE sgd.nivel_alerta        AS ENUM ('amarillo', 'naranja', 'rojo');
CREATE TYPE sgd.tipo_identificacion AS ENUM ('CC', 'TI', 'CE', 'PA', 'PPT', 'NIT', 'OTRO');
CREATE TYPE sgd.tipo_persona        AS ENUM ('natural', 'juridica');
CREATE TYPE sgd.estado_persona      AS ENUM ('activo', 'inactivo', 'egresado', 'retirado', 'externo');
CREATE TYPE sgd.tipo_dependencia    AS ENUM ('academica', 'administrativa');
CREATE TYPE sgd.origen_accion       AS ENUM ('usuario', 'portal', 'n8n', 'sistema');

CREATE TYPE sgd.tipo_evento AS ENUM (
  'radicado', 'asignado', 'reasignado', 'recibido_dependencia', 'cambio_estado',
  'respuesta_registrada', 'respuesta_verificada', 'respuesta_devuelta', 'decision_comite',
  'documento_adjuntado', 'notificacion_enviada', 'clasificado', 'anulado'
);

CREATE TYPE sgd.estado_verificacion  AS ENUM ('pendiente', 'verificada', 'devuelta');
CREATE TYPE sgd.sentido_respuesta    AS ENUM ('aprobado', 'no_aprobado', 'informativa', 'rechazado_requisitos');
CREATE TYPE sgd.decision_comite      AS ENUM ('aprobado', 'no_aprobado', 'aplazado');
CREATE TYPE sgd.estado_sesion_comite AS ENUM ('programada', 'realizada', 'cancelada');
CREATE TYPE sgd.tipo_elemento        AS ENUM ('revista', 'factura', 'paquete', 'documento_sin_firma', 'otro');
CREATE TYPE sgd.origen_documento     AS ENUM ('escaneo', 'digital', 'portal', 'respuesta', 'digitalizacion');
CREATE TYPE sgd.estado_expediente    AS ENUM ('abierto', 'cerrado');
CREATE TYPE sgd.disposicion_final    AS ENUM ('conservacion_total', 'eliminacion', 'seleccion', 'digitalizacion');

CREATE TYPE sgd.tipo_notificacion AS ENUM (
  'radicado_creado', 'radicado_asignado', 'proximo_a_vencer', 'vencido',
  'respuesta_verificada', 'respuesta_devuelta', 'copia_registro_academico'
);

CREATE TYPE sgd.estado_notificacion AS ENUM ('pendiente', 'enviada', 'fallida');
CREATE TYPE sgd.estado_ejecucion    AS ENUM ('iniciado', 'finalizado', 'fallido');

CREATE TYPE sgd.accion_auditoria AS ENUM (
  'crear', 'actualizar', 'deshabilitar', 'habilitar', 'anular',
  'iniciar_sesion', 'inicio_sesion_fallido', 'cerrar_sesion'
);
