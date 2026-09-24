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
-- =============================================================================
-- SGD · 03 · Tablas (MODELO §5)
-- 28 tablas en orden de dependencias entre llaves foráneas.
-- Convenciones: PK id_<entidad>, FK <entidad>_id, fechas timestamptz, nada se borra (RN-002).
-- =============================================================================

SET search_path = sgd, extensions, public;

-- -----------------------------------------------------------------------------
-- 5.1 Catálogos
-- -----------------------------------------------------------------------------

-- 1. roles
CREATE TABLE sgd.roles (
  id_rol       smallint     GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  codigo       varchar(30)  NOT NULL,
  nombre       varchar(60)  NOT NULL,
  descripcion  text,
  CONSTRAINT uk_roles_codigo UNIQUE (codigo),
  CONSTRAINT ck_roles_codigo CHECK (codigo ~ '^[a-z_]+$')
);
COMMENT ON TABLE sgd.roles IS 'Los 4 roles del panel interno. Fijos: no hay pantalla para crearlos (RF-012).';

-- 2. dependencias
CREATE TABLE sgd.dependencias (
  id_dependencia        integer       GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  codigo                varchar(20)   NOT NULL,
  nombre                varchar(150)  NOT NULL,
  tipo                  sgd.tipo_dependencia NOT NULL,
  correo                citext        NOT NULL,
  dependencia_padre_id  integer       REFERENCES sgd.dependencias (id_dependencia),
  categoria_n8n         varchar(60),
  activa                boolean       NOT NULL DEFAULT true,
  creado_en             timestamptz   NOT NULL DEFAULT now(),
  actualizado_en        timestamptz   NOT NULL DEFAULT now(),
  CONSTRAINT uk_dependencias_codigo        UNIQUE (codigo),
  CONSTRAINT uk_dependencias_nombre        UNIQUE (nombre),
  CONSTRAINT uk_dependencias_categoria_n8n UNIQUE (categoria_n8n),
  CONSTRAINT ck_dependencias_codigo CHECK (codigo ~ '^[A-Z0-9_]+$'),
  CONSTRAINT ck_dependencias_correo CHECK (correo ~ '^[^@[:space:]]+@[^@[:space:]]+\.[^@[:space:]]+$'),
  CONSTRAINT ck_dependencias_padre  CHECK (dependencia_padre_id IS DISTINCT FROM id_dependencia)
);

-- 3. programas
CREATE TABLE sgd.programas (
  id_programa     integer       GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  nombre          varchar(150)  NOT NULL,
  dependencia_id  integer       NOT NULL REFERENCES sgd.dependencias (id_dependencia),
  activo          boolean       NOT NULL DEFAULT true,
  CONSTRAINT uk_programas_nombre UNIQUE (nombre)
);

-- 4. tipos_documento
CREATE TABLE sgd.tipos_documento (
  id_tipo_documento  smallint     GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  codigo             varchar(20)  NOT NULL,
  nombre             varchar(60)  NOT NULL,
  prefijo            varchar(4)   NOT NULL,
  es_entrada         boolean      NOT NULL,
  permite_anulacion  boolean      NOT NULL DEFAULT true,
  CONSTRAINT uk_tipos_documento_codigo  UNIQUE (codigo),
  CONSTRAINT uk_tipos_documento_prefijo UNIQUE (prefijo),
  CONSTRAINT ck_tipos_documento_codigo  CHECK (codigo ~ '^[a-z_]+$'),
  CONSTRAINT ck_tipos_documento_prefijo CHECK (prefijo ~ '^[A-Z]{2,4}$')
);
COMMENT ON TABLE sgd.tipos_documento IS 'Cada tipo lleva su propio consecutivo anual (RF-003).';

-- 5. tipos_tramite
CREATE TABLE sgd.tipos_tramite (
  id_tipo_tramite          integer       GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  codigo                   varchar(40)   NOT NULL,
  nombre                   varchar(100)  NOT NULL,
  descripcion              text,
  plazo_dias_habiles       smallint      NOT NULL,
  requiere_comite          boolean       NOT NULL DEFAULT false,
  dependencia_sugerida_id  integer       REFERENCES sgd.dependencias (id_dependencia),
  visible_en_portal        boolean       NOT NULL DEFAULT true,
  activo                   boolean       NOT NULL DEFAULT true,
  creado_en                timestamptz   NOT NULL DEFAULT now(),
  actualizado_en           timestamptz   NOT NULL DEFAULT now(),
  CONSTRAINT uk_tipos_tramite_codigo UNIQUE (codigo),
  CONSTRAINT uk_tipos_tramite_nombre UNIQUE (nombre),
  CONSTRAINT ck_tipos_tramite_codigo CHECK (codigo ~ '^[a-z_]+$'),
  -- RN-010: nunca más de 15 días hábiles (derecho de petición).
  CONSTRAINT ck_tipos_tramite_plazo  CHECK (plazo_dias_habiles BETWEEN 1 AND 15)
);

-- 6. festivos
CREATE TABLE sgd.festivos (
  fecha        date          PRIMARY KEY,
  descripcion  varchar(100)  NOT NULL
);
COMMENT ON TABLE sgd.festivos IS 'Días no hábiles además de sábados y domingos (P-03).';

-- -----------------------------------------------------------------------------
-- 5.2 Seguridad
-- -----------------------------------------------------------------------------

-- 8. usuarios (perfil)
CREATE TABLE sgd.usuarios (
  id_usuario         integer       GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  nombre_completo    varchar(150)  NOT NULL,
  correo             citext        NOT NULL,
  rol_id             smallint      NOT NULL REFERENCES sgd.roles (id_rol),
  dependencia_id     integer       NOT NULL REFERENCES sgd.dependencias (id_dependencia),
  activo             boolean       NOT NULL DEFAULT true,
  deshabilitado_en   timestamptz,
  deshabilitado_por  integer       REFERENCES sgd.usuarios (id_usuario),
  ultimo_acceso      timestamptz,
  creado_por         integer       REFERENCES sgd.usuarios (id_usuario),
  creado_en          timestamptz   NOT NULL DEFAULT now(),
  actualizado_en     timestamptz   NOT NULL DEFAULT now(),
  CONSTRAINT uk_usuarios_correo UNIQUE (correo),
  CONSTRAINT ck_usuarios_correo CHECK (correo ~ '^[^@[:space:]]+@[^@[:space:]]+\.[^@[:space:]]+$'),
  CONSTRAINT ck_usuarios_deshabilitado CHECK (
    (activo AND deshabilitado_en IS NULL AND deshabilitado_por IS NULL)
    OR (NOT activo AND deshabilitado_en IS NOT NULL AND deshabilitado_por IS NOT NULL)
  )
);
COMMENT ON TABLE sgd.usuarios IS 'Perfil de las cuentas del panel interno. Los datos sensibles están en credenciales_usuario (D-BD-12).';

-- 9. credenciales_usuario (datos sensibles, 1 a 1 con usuarios)
CREATE TABLE sgd.credenciales_usuario (
  usuario_id            integer       PRIMARY KEY REFERENCES sgd.usuarios (id_usuario),
  password_hash         varchar(255)  NOT NULL,
  debe_cambiar_clave    boolean       NOT NULL DEFAULT true,
  clave_actualizada_en  timestamptz   NOT NULL DEFAULT now(),
  intentos_fallidos     smallint      NOT NULL DEFAULT 0,
  bloqueado_hasta       timestamptz,
  actualizado_en        timestamptz   NOT NULL DEFAULT now(),
  -- RNF-002: solo hashes bcrypt. Una contraseña en texto plano no cumple el formato.
  CONSTRAINT ck_credenciales_bcrypt   CHECK (password_hash ~ '^\$2[aby]\$[0-9]{2}\$[./A-Za-z0-9]{53}$'),
  CONSTRAINT ck_credenciales_intentos CHECK (intentos_fallidos >= 0)
);
COMMENT ON TABLE sgd.credenciales_usuario IS 'Solo accesible por el rol sgd_auth (MODELO §9.1).';

-- 10. sesiones (refresh tokens)
CREATE TABLE sgd.sesiones (
  id_sesion           integer       GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  usuario_id          integer       NOT NULL REFERENCES sgd.usuarios (id_usuario),
  refresh_token_hash  char(64)      NOT NULL,
  creado_en           timestamptz   NOT NULL DEFAULT now(),
  expira_en           timestamptz   NOT NULL,
  revocada_en         timestamptz,
  ip                  inet,
  agente_usuario      varchar(300),
  CONSTRAINT uk_sesiones_token  UNIQUE (refresh_token_hash),
  CONSTRAINT ck_sesiones_token  CHECK (refresh_token_hash ~ '^[0-9a-f]{64}$'),
  CONSTRAINT ck_sesiones_expira CHECK (expira_en > creado_en)
);

-- 7. parametros_sistema (después de usuarios por la FK actualizado_por)
CREATE TABLE sgd.parametros_sistema (
  clave            varchar(60)  PRIMARY KEY,
  valor            jsonb        NOT NULL,
  descripcion      text         NOT NULL,
  actualizado_por  integer      REFERENCES sgd.usuarios (id_usuario),
  actualizado_en   timestamptz  NOT NULL DEFAULT now(),
  CONSTRAINT ck_parametros_clave CHECK (clave ~ '^[a-z0-9_.]+$')
);

-- -----------------------------------------------------------------------------
-- 5.3 Personas
-- -----------------------------------------------------------------------------

-- 11. personas
CREATE TABLE sgd.personas (
  id_persona             integer       GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  tipo_identificacion    sgd.tipo_identificacion NOT NULL,
  numero_identificacion  varchar(20)   NOT NULL,
  tipo_persona           sgd.tipo_persona   NOT NULL DEFAULT 'natural',
  nombre_completo        varchar(200)  NOT NULL,
  correo                 citext,
  celular                varchar(20),
  direccion              varchar(200),
  programa_id            integer       REFERENCES sgd.programas (id_programa),
  estado                 sgd.estado_persona NOT NULL DEFAULT 'externo',
  creado_por             integer       REFERENCES sgd.usuarios (id_usuario),
  creado_en              timestamptz   NOT NULL DEFAULT now(),
  actualizado_en         timestamptz   NOT NULL DEFAULT now(),
  CONSTRAINT uk_personas_identificacion UNIQUE (tipo_identificacion, numero_identificacion),
  -- Texto sin puntos: conserva ceros a la izquierda.
  CONSTRAINT ck_personas_numero  CHECK (numero_identificacion ~ '^[0-9A-Za-z-]{3,20}$'),
  CONSTRAINT ck_personas_correo  CHECK (correo IS NULL OR correo ~ '^[^@[:space:]]+@[^@[:space:]]+\.[^@[:space:]]+$'),
  CONSTRAINT ck_personas_celular CHECK (celular IS NULL OR celular ~ '^[0-9+ -]{7,20}$')
);

-- -----------------------------------------------------------------------------
-- 5.4 Radicación
-- -----------------------------------------------------------------------------

-- 12. contadores_consecutivo
CREATE TABLE sgd.contadores_consecutivo (
  tipo_documento_id  smallint  NOT NULL REFERENCES sgd.tipos_documento (id_tipo_documento),
  anio               smallint  NOT NULL,
  ultimo_numero      integer   NOT NULL DEFAULT 0,
  -- El año es parte de la llave: el consecutivo "reinicia" cada 1 de enero sin ningún proceso.
  PRIMARY KEY (tipo_documento_id, anio),
  CONSTRAINT ck_contadores_anio   CHECK (anio BETWEEN 2020 AND 2100),
  CONSTRAINT ck_contadores_numero CHECK (ultimo_numero >= 0)
);
COMMENT ON TABLE sgd.contadores_consecutivo IS 'Solo se modifica con sgd.siguiente_consecutivo() (RN-001).';

-- 13. radicados (tabla central)
CREATE TABLE sgd.radicados (
  id_radicado                 integer       GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  numero_radicado             varchar(30)   NOT NULL,
  tipo_documento_id           smallint      NOT NULL REFERENCES sgd.tipos_documento (id_tipo_documento),
  anio                        smallint      NOT NULL,
  consecutivo                 integer       NOT NULL,
  tipo_tramite_id             integer       REFERENCES sgd.tipos_tramite (id_tipo_tramite),
  canal                       sgd.canal_entrada   NOT NULL,
  estado                      sgd.estado_radicado NOT NULL,
  asunto                      varchar(300)  NOT NULL,
  descripcion                 text,
  observaciones               text,
  persona_id                  integer       REFERENCES sgd.personas (id_persona),
  dependencia_id              integer       REFERENCES sgd.dependencias (id_dependencia),
  dependencia_emisora_id      integer       REFERENCES sgd.dependencias (id_dependencia),
  correo_notificacion         citext,
  autoriza_tratamiento_datos  boolean       NOT NULL DEFAULT false,
  fecha_autorizacion_datos    timestamptz,
  fecha_radicacion            timestamptz   NOT NULL DEFAULT now(),
  fecha_documento             date,
  numero_folios               integer,
  plazo_dias_habiles          smallint,
  fecha_limite                date,
  semaforo                    sgd.semaforo,
  fecha_respuesta             timestamptz,
  notificado_en               timestamptz,
  anulado_en                  timestamptz,
  anulado_por                 integer       REFERENCES sgd.usuarios (id_usuario),
  motivo_anulacion            text,
  registrado_por              integer       REFERENCES sgd.usuarios (id_usuario),
  ip_origen                   inet,
  creado_en                   timestamptz   NOT NULL DEFAULT now(),
  actualizado_en              timestamptz   NOT NULL DEFAULT now(),
  CONSTRAINT uk_radicados_numero      UNIQUE (numero_radicado),
  -- Segunda barrera contra duplicados (RN-001, RNF-006).
  CONSTRAINT uk_radicados_consecutivo UNIQUE (tipo_documento_id, anio, consecutivo),
  CONSTRAINT ck_radicados_numero      CHECK (numero_radicado ~ '^[0-9]{4}-[A-Z]{2,4}-[0-9]{3,}$'),
  CONSTRAINT ck_radicados_anio        CHECK (anio BETWEEN 2020 AND 2100),
  CONSTRAINT ck_radicados_consecutivo CHECK (consecutivo > 0),
  CONSTRAINT ck_radicados_folios      CHECK (numero_folios IS NULL OR numero_folios > 0),
  CONSTRAINT ck_radicados_plazo_rango CHECK (plazo_dias_habiles IS NULL OR plazo_dias_habiles BETWEEN 1 AND 15),
  CONSTRAINT ck_radicados_plazo       CHECK ((fecha_limite IS NULL) = (plazo_dias_habiles IS NULL)),
  CONSTRAINT ck_radicados_semaforo    CHECK ((semaforo IS NULL) = (fecha_limite IS NULL)),
  CONSTRAINT ck_radicados_correo      CHECK (correo_notificacion IS NULL
                                             OR correo_notificacion ~ '^[^@[:space:]]+@[^@[:space:]]+\.[^@[:space:]]+$'),
  -- RF-011, RN-002: anulado siempre con quién, cuándo y por qué.
  CONSTRAINT ck_radicados_anulacion   CHECK (
    (estado = 'anulado') = (anulado_en IS NOT NULL AND anulado_por IS NOT NULL AND motivo_anulacion IS NOT NULL)
  ),
  -- RN-008 y Ley 1581: lo que entra por el portal trae correo y autorización, y no tiene usuario.
  CONSTRAINT ck_radicados_portal      CHECK (
    canal <> 'portal_publico'
    OR (autoriza_tratamiento_datos AND correo_notificacion IS NOT NULL AND registrado_por IS NULL)
  ),
  CONSTRAINT ck_radicados_autorizacion CHECK (NOT autoriza_tratamiento_datos OR fecha_autorizacion_datos IS NOT NULL)
);
COMMENT ON COLUMN sgd.radicados.plazo_dias_habiles IS 'Copia del plazo del trámite al radicar (D-BD-02).';
COMMENT ON COLUMN sgd.radicados.semaforo IS 'Caché que recalcula la tarea de alertas (D-BD-03). No editar a mano.';

-- 22. ejecuciones_n8n (antes de asignaciones y notificaciones, que la referencian)
CREATE TABLE sgd.ejecuciones_n8n (
  id_ejecucion          integer       GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  radicado_id           integer       REFERENCES sgd.radicados (id_radicado),
  flujo                 varchar(80)   NOT NULL,
  id_ejecucion_externa  varchar(80),
  estado                sgd.estado_ejecucion NOT NULL DEFAULT 'iniciado',
  resultado             jsonb,
  error                 text,
  iniciado_en           timestamptz   NOT NULL DEFAULT now(),
  finalizado_en         timestamptz,
  CONSTRAINT ck_ejecuciones_fin CHECK (estado = 'iniciado' OR finalizado_en IS NOT NULL)
);

-- 14. asignaciones
CREATE TABLE sgd.asignaciones (
  id_asignacion     integer       GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  radicado_id       integer       NOT NULL REFERENCES sgd.radicados (id_radicado),
  dependencia_id    integer       NOT NULL REFERENCES sgd.dependencias (id_dependencia),
  origen            sgd.origen_accion NOT NULL,
  asignado_por      integer       REFERENCES sgd.usuarios (id_usuario),
  ejecucion_n8n_id  integer       REFERENCES sgd.ejecuciones_n8n (id_ejecucion),
  motivo            text,
  asignado_en       timestamptz   NOT NULL DEFAULT now(),
  recibido_en       timestamptz,
  recibido_por      integer       REFERENCES sgd.usuarios (id_usuario),
  vigente           boolean       NOT NULL DEFAULT true,
  CONSTRAINT ck_asignaciones_origen   CHECK (origen IN ('usuario', 'n8n')),
  CONSTRAINT ck_asignaciones_usuario  CHECK (origen <> 'usuario' OR asignado_por IS NOT NULL),
  CONSTRAINT ck_asignaciones_n8n      CHECK (origen <> 'n8n' OR ejecucion_n8n_id IS NOT NULL),
  CONSTRAINT ck_asignaciones_recibido CHECK ((recibido_en IS NULL) = (recibido_por IS NULL))
);

-- 15. respuestas
CREATE TABLE sgd.respuestas (
  id_respuesta              integer       GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  radicado_id               integer       NOT NULL REFERENCES sgd.radicados (id_radicado),
  dependencia_id            integer       NOT NULL REFERENCES sgd.dependencias (id_dependencia),
  sentido                   sgd.sentido_respuesta NOT NULL,
  contenido                 text          NOT NULL,
  respondido_por            integer       NOT NULL REFERENCES sgd.usuarios (id_usuario),
  respondido_en             timestamptz   NOT NULL DEFAULT now(),
  estado_verificacion       sgd.estado_verificacion NOT NULL DEFAULT 'pendiente',
  verificado_por            integer       REFERENCES sgd.usuarios (id_usuario),
  verificado_en             timestamptz,
  observacion_verificacion  text,
  radicado_salida_id        integer       REFERENCES sgd.radicados (id_radicado),
  CONSTRAINT uk_respuestas_salida UNIQUE (radicado_salida_id),
  CONSTRAINT ck_respuestas_salida_distinta CHECK (radicado_salida_id IS DISTINCT FROM radicado_id),
  -- RN-008: verificada = con quién, cuándo y la comunicación de salida creada.
  CONSTRAINT ck_respuestas_verificada CHECK (
    estado_verificacion <> 'verificada'
    OR (verificado_por IS NOT NULL AND verificado_en IS NOT NULL AND radicado_salida_id IS NOT NULL)
  ),
  CONSTRAINT ck_respuestas_devuelta CHECK (
    estado_verificacion <> 'devuelta'
    OR (verificado_por IS NOT NULL AND verificado_en IS NOT NULL AND observacion_verificacion IS NOT NULL)
  ),
  CONSTRAINT ck_respuestas_pendiente CHECK (
    estado_verificacion <> 'pendiente'
    OR (verificado_por IS NULL AND verificado_en IS NULL AND radicado_salida_id IS NULL)
  )
);

-- -----------------------------------------------------------------------------
-- 5.7 Archivo Central (antes de documentos, que puede pertenecer a un expediente)
-- -----------------------------------------------------------------------------

-- 25. series_documentales
CREATE TABLE sgd.series_documentales (
  id_serie        integer       GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  codigo          varchar(20)   NOT NULL,
  nombre          varchar(150)  NOT NULL,
  dependencia_id  integer       REFERENCES sgd.dependencias (id_dependencia),
  activa          boolean       NOT NULL DEFAULT true,
  CONSTRAINT uk_series_codigo UNIQUE (codigo)
);

-- 26. subseries_documentales
CREATE TABLE sgd.subseries_documentales (
  id_subserie              integer       GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  serie_id                 integer       NOT NULL REFERENCES sgd.series_documentales (id_serie),
  codigo                   varchar(20)   NOT NULL,
  nombre                   varchar(150)  NOT NULL,
  retencion_gestion_anios  smallint      NOT NULL,
  retencion_central_anios  smallint      NOT NULL,
  disposicion_final        sgd.disposicion_final NOT NULL,
  activa                   boolean       NOT NULL DEFAULT true,
  CONSTRAINT uk_subseries_codigo UNIQUE (serie_id, codigo),
  CONSTRAINT ck_subseries_retencion CHECK (retencion_gestion_anios >= 0 AND retencion_central_anios >= 0)
);

-- 27. expedientes
CREATE TABLE sgd.expedientes (
  id_expediente     integer       GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  codigo            varchar(30)   NOT NULL,
  nombre            varchar(200)  NOT NULL,
  subserie_id       integer       NOT NULL REFERENCES sgd.subseries_documentales (id_subserie),
  dependencia_id    integer       NOT NULL REFERENCES sgd.dependencias (id_dependencia),
  persona_id        integer       REFERENCES sgd.personas (id_persona),
  estado            sgd.estado_expediente NOT NULL DEFAULT 'abierto',
  fecha_apertura    date          NOT NULL DEFAULT current_date,
  fecha_cierre      date,
  ubicacion_fisica  varchar(200),
  creado_por        integer       NOT NULL REFERENCES sgd.usuarios (id_usuario),
  creado_en         timestamptz   NOT NULL DEFAULT now(),
  actualizado_en    timestamptz   NOT NULL DEFAULT now(),
  CONSTRAINT uk_expedientes_codigo UNIQUE (codigo),
  CONSTRAINT ck_expedientes_cierre CHECK ((estado = 'cerrado') = (fecha_cierre IS NOT NULL)),
  CONSTRAINT ck_expedientes_fechas CHECK (fecha_cierre IS NULL OR fecha_cierre >= fecha_apertura)
);

-- 28. clasificaciones
CREATE TABLE sgd.clasificaciones (
  id_clasificacion     integer      GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  radicado_id          integer      NOT NULL REFERENCES sgd.radicados (id_radicado),
  expediente_id        integer      NOT NULL REFERENCES sgd.expedientes (id_expediente),
  orden_en_expediente  integer      NOT NULL,
  observaciones        text,
  clasificado_por      integer      NOT NULL REFERENCES sgd.usuarios (id_usuario),
  clasificado_en       timestamptz  NOT NULL DEFAULT now(),
  -- Un radicado se archiva en un solo expediente (MODELO §12: confirmar con Archivo Central).
  CONSTRAINT uk_clasificaciones_radicado UNIQUE (radicado_id),
  CONSTRAINT uk_clasificaciones_orden    UNIQUE (expediente_id, orden_en_expediente),
  CONSTRAINT ck_clasificaciones_orden    CHECK (orden_en_expediente > 0)
);

-- 16. documentos
CREATE TABLE sgd.documentos (
  id_documento              integer       GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  radicado_id               integer       REFERENCES sgd.radicados (id_radicado),
  respuesta_id              integer       REFERENCES sgd.respuestas (id_respuesta),
  expediente_id             integer       REFERENCES sgd.expedientes (id_expediente),
  nombre_original           varchar(255)  NOT NULL,
  clave_almacenamiento      varchar(300)  NOT NULL,
  tipo_mime                 varchar(100)  NOT NULL,
  tamano_bytes              bigint        NOT NULL,
  hash_sha256               char(64)      NOT NULL,
  paginas                   integer,
  origen                    sgd.origen_documento NOT NULL,
  fecha_documento_original  date,
  ubicacion_fisica          varchar(200),
  subido_por                integer       REFERENCES sgd.usuarios (id_usuario),
  subido_en                 timestamptz   NOT NULL DEFAULT now(),
  anulado_en                timestamptz,
  anulado_por               integer       REFERENCES sgd.usuarios (id_usuario),
  motivo_anulacion          text,
  CONSTRAINT uk_documentos_clave  UNIQUE (clave_almacenamiento),
  CONSTRAINT ck_documentos_padre  CHECK (num_nonnulls(radicado_id, respuesta_id, expediente_id) = 1),
  CONSTRAINT ck_documentos_mime   CHECK (tipo_mime IN ('application/pdf', 'image/png', 'image/jpeg', 'image/tiff')),
  CONSTRAINT ck_documentos_tamano CHECK (tamano_bytes > 0),
  CONSTRAINT ck_documentos_hash   CHECK (hash_sha256 ~ '^[0-9a-f]{64}$'),
  CONSTRAINT ck_documentos_paginas CHECK (paginas IS NULL OR paginas > 0),
  CONSTRAINT ck_documentos_anulacion CHECK (
    num_nonnulls(anulado_en, anulado_por, motivo_anulacion) IN (0, 3)
  )
);
COMMENT ON COLUMN sgd.documentos.nombre_original IS 'Solo para mostrar. Nunca se usa para construir rutas.';

-- 17. correspondencia_sin_consecutivo
CREATE TABLE sgd.correspondencia_sin_consecutivo (
  id_correspondencia      integer       GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  tipo_elemento           sgd.tipo_elemento NOT NULL,
  remitente               varchar(200),
  persona_id              integer       REFERENCES sgd.personas (id_persona),
  dependencia_destino_id  integer       NOT NULL REFERENCES sgd.dependencias (id_dependencia),
  fecha_recepcion         timestamptz   NOT NULL DEFAULT now(),
  observaciones           text,
  registrado_por          integer       NOT NULL REFERENCES sgd.usuarios (id_usuario),
  entregado_en            timestamptz,
  radicado_id             integer       REFERENCES sgd.radicados (id_radicado),
  CONSTRAINT uk_correspondencia_radicado UNIQUE (radicado_id)
);
COMMENT ON TABLE sgd.correspondencia_sin_consecutivo IS 'RN-006: no toca contadores_consecutivo.';

-- -----------------------------------------------------------------------------
-- 5.5 Comité
-- -----------------------------------------------------------------------------

-- 18. sesiones_comite
CREATE TABLE sgd.sesiones_comite (
  id_sesion_comite  integer       GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  dependencia_id    integer       NOT NULL REFERENCES sgd.dependencias (id_dependencia),
  fecha             date          NOT NULL,
  estado            sgd.estado_sesion_comite NOT NULL DEFAULT 'programada',
  acta_numero       varchar(40),
  observaciones     text,
  creado_por        integer       NOT NULL REFERENCES sgd.usuarios (id_usuario),
  creado_en         timestamptz   NOT NULL DEFAULT now(),
  CONSTRAINT uk_sesiones_comite UNIQUE (dependencia_id, fecha)
);

-- 19. decisiones_comite
CREATE TABLE sgd.decisiones_comite (
  id_decision       integer       GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  radicado_id       integer       NOT NULL REFERENCES sgd.radicados (id_radicado),
  sesion_comite_id  integer       NOT NULL REFERENCES sgd.sesiones_comite (id_sesion_comite),
  decision          sgd.decision_comite NOT NULL,
  observacion       text,
  registrado_por    integer       NOT NULL REFERENCES sgd.usuarios (id_usuario),
  registrado_en     timestamptz   NOT NULL DEFAULT now(),
  CONSTRAINT uk_decisiones_comite UNIQUE (radicado_id, sesion_comite_id)
);

-- -----------------------------------------------------------------------------
-- 5.6 Seguimiento
-- -----------------------------------------------------------------------------

-- 20. eventos_trazabilidad (solo inserción)
CREATE TABLE sgd.eventos_trazabilidad (
  id_evento        bigint        GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  radicado_id      integer       NOT NULL REFERENCES sgd.radicados (id_radicado),
  tipo_evento      sgd.tipo_evento NOT NULL,
  estado_anterior  sgd.estado_radicado,
  estado_nuevo     sgd.estado_radicado,
  origen           sgd.origen_accion NOT NULL,
  usuario_id       integer       REFERENCES sgd.usuarios (id_usuario),
  dependencia_id   integer       REFERENCES sgd.dependencias (id_dependencia),
  detalle          text,
  ocurrido_en      timestamptz   NOT NULL DEFAULT now(),
  CONSTRAINT ck_eventos_usuario CHECK ((origen = 'usuario') = (usuario_id IS NOT NULL))
);
COMMENT ON TABLE sgd.eventos_trazabilidad IS 'Línea de tiempo inmutable (RF-006). Un disparador rechaza UPDATE y DELETE.';

-- 21. alertas_vencimiento
CREATE TABLE sgd.alertas_vencimiento (
  id_alerta          integer       GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  radicado_id        integer       NOT NULL REFERENCES sgd.radicados (id_radicado),
  nivel              sgd.nivel_alerta NOT NULL,
  por_espera_comite  boolean       NOT NULL DEFAULT false,
  mensaje            varchar(300)  NOT NULL,
  generada_en        timestamptz   NOT NULL DEFAULT now(),
  atendida           boolean       NOT NULL DEFAULT false,
  atendida_por       integer       REFERENCES sgd.usuarios (id_usuario),
  atendida_en        timestamptz,
  -- HU-015: la tarea periódica no repite la misma alerta.
  CONSTRAINT uk_alertas_nivel    UNIQUE (radicado_id, nivel),
  CONSTRAINT ck_alertas_atendida CHECK (atendida = (atendida_en IS NOT NULL)),
  CONSTRAINT ck_alertas_por      CHECK (atendida_por IS NULL OR atendida)
);

-- 23. notificaciones
CREATE TABLE sgd.notificaciones (
  id_notificacion      integer       GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  tipo                 sgd.tipo_notificacion NOT NULL,
  radicado_id          integer       REFERENCES sgd.radicados (id_radicado),
  destinatario_correo  citext        NOT NULL,
  usuario_id           integer       REFERENCES sgd.usuarios (id_usuario),
  estado               sgd.estado_notificacion NOT NULL DEFAULT 'pendiente',
  intentos             smallint      NOT NULL DEFAULT 0,
  ultimo_error         text,
  ejecucion_n8n_id     integer       REFERENCES sgd.ejecuciones_n8n (id_ejecucion),
  creado_en            timestamptz   NOT NULL DEFAULT now(),
  enviada_en           timestamptz,
  CONSTRAINT ck_notificaciones_correo   CHECK (destinatario_correo ~ '^[^@[:space:]]+@[^@[:space:]]+\.[^@[:space:]]+$'),
  CONSTRAINT ck_notificaciones_intentos CHECK (intentos >= 0),
  CONSTRAINT ck_notificaciones_enviada  CHECK ((estado = 'enviada') = (enviada_en IS NOT NULL))
);

-- 24. auditoria_cambios (solo inserción)
CREATE TABLE sgd.auditoria_cambios (
  id_auditoria        bigint        GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  usuario_id          integer       REFERENCES sgd.usuarios (id_usuario),
  accion              sgd.accion_auditoria NOT NULL,
  tabla_afectada      varchar(60)   NOT NULL,
  id_registro         varchar(40)   NOT NULL,
  valores_anteriores  jsonb,
  valores_nuevos      jsonb,
  ip                  inet,
  ocurrido_en         timestamptz   NOT NULL DEFAULT now(),
  -- Defensa extra: nunca guardar contraseñas, hashes ni tokens.
  CONSTRAINT ck_auditoria_sin_secretos CHECK (
    NOT (coalesce(valores_anteriores, '{}'::jsonb) ?| ARRAY['password', 'password_hash', 'refresh_token', 'refresh_token_hash'])
    AND NOT (coalesce(valores_nuevos, '{}'::jsonb) ?| ARRAY['password', 'password_hash', 'refresh_token', 'refresh_token_hash'])
  )
);
COMMENT ON TABLE sgd.auditoria_cambios IS 'RN-003 y panel de auditoría. Un disparador rechaza UPDATE y DELETE.';
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
-- =============================================================================
-- SGD · 09 · Datos iniciales (MODELO §11)
-- Se ejecuta como dueño de la base (salta RLS). Idempotente: se puede correr de nuevo.
--
-- Valores marcados "CONFIRMAR" dependen de respuestas del cliente (MODELO §12).
-- Cambiarlos después es un UPDATE, no una migración.
-- No contiene contraseñas: la del Administrador se asigna aparte (README.md, paso 5).
-- =============================================================================

SET search_path = sgd, extensions, public;

-- Roles del panel interno (fijos)
INSERT INTO sgd.roles (codigo, nombre, descripcion) VALUES
  ('recepcion',       'Recepción / Ventanilla', 'Registra, radica, envía, verifica respuestas y consulta'),
  ('dependencia',     'Dependencia',            'Tramita y responde los radicados asignados a su dependencia'),
  ('archivo_central', 'Archivo Central',        'Clasifica documentos en expedientes según la TRD'),
  ('administrador',   'Administrador / TIC',    'Usuarios, tipos de trámite, configuración y anulaciones')
ON CONFLICT (codigo) DO NOTHING;

-- Tipos de documento con consecutivo propio (RF-003). Prefijo de la maquetación: 2026-CR-01487.
INSERT INTO sgd.tipos_documento (codigo, nombre, prefijo, es_entrada, permite_anulacion) VALUES
  ('recibida',   'Comunicación recibida', 'CR', true,  true),
  ('enviada',    'Comunicación enviada',  'CE', false, true),
  ('circular',   'Circular',              'CI', false, true),
  ('resolucion', 'Resolución',            'RE', false, true),  -- deja de ser anulable al notificarse (notificado_en)
  ('convenio',   'Convenio',              'CO', false, true)
ON CONFLICT (codigo) DO NOTHING;

-- Dependencias institucionales mínimas. CONFIRMAR correos y agregar el resto (P-06).
INSERT INTO sgd.dependencias (codigo, nombre, tipo, correo) VALUES
  ('RECEPCION', 'Recepción / Gestión Documental', 'administrativa', 'gestion.documental@uniautonoma.edu.co'),
  ('REGACAD',   'Registro Académico',             'administrativa', 'registro.academico@uniautonoma.edu.co'),
  ('ARCHIVO',   'Archivo Central',                'administrativa', 'archivo.central@uniautonoma.edu.co'),
  ('TIC',       'Tecnologías de la Información',  'administrativa', 'tic@uniautonoma.edu.co')
ON CONFLICT (codigo) DO NOTHING;

-- Tipos de trámite (RF-019). CONFIRMAR plazos y cuáles pasan por comité (P-04).
INSERT INTO sgd.tipos_tramite (codigo, nombre, plazo_dias_habiles, requiere_comite) VALUES
  ('reingreso',        'Reingreso',           8,  false),
  ('reintegro_dinero', 'Reintegro de dinero', 15, false),
  ('homologacion',     'Homologación',        15, false),
  ('trabajo_grado',    'Trabajo de grado',    15, true),
  ('tutela',           'Tutela',              2,  false),
  ('otro',             'Otro',                15, false)
ON CONFLICT (codigo) DO NOTHING;

-- Festivos de Colombia (Ley 51 de 1983). Agregar los cierres propios de la universidad (P-03).
INSERT INTO sgd.festivos (fecha, descripcion) VALUES
  ('2026-01-01', 'Año Nuevo'),
  ('2026-01-12', 'Día de los Reyes Magos'),
  ('2026-03-23', 'Día de San José'),
  ('2026-04-02', 'Jueves Santo'),
  ('2026-04-03', 'Viernes Santo'),
  ('2026-05-01', 'Día del Trabajo'),
  ('2026-05-18', 'Ascensión del Señor'),
  ('2026-06-08', 'Corpus Christi'),
  ('2026-06-15', 'Sagrado Corazón de Jesús'),
  ('2026-06-29', 'San Pedro y San Pablo'),
  ('2026-07-20', 'Día de la Independencia'),
  ('2026-08-07', 'Batalla de Boyacá'),
  ('2026-08-17', 'Asunción de la Virgen'),
  ('2026-10-12', 'Día de la Raza'),
  ('2026-11-02', 'Todos los Santos'),
  ('2026-11-16', 'Independencia de Cartagena'),
  ('2026-12-08', 'Inmaculada Concepción'),
  ('2026-12-25', 'Navidad'),
  ('2027-01-01', 'Año Nuevo'),
  ('2027-01-11', 'Día de los Reyes Magos'),
  ('2027-03-22', 'Día de San José'),
  ('2027-03-25', 'Jueves Santo'),
  ('2027-03-26', 'Viernes Santo'),
  ('2027-05-01', 'Día del Trabajo'),
  ('2027-05-10', 'Ascensión del Señor'),
  ('2027-05-31', 'Corpus Christi'),
  ('2027-06-07', 'Sagrado Corazón de Jesús'),
  ('2027-07-05', 'San Pedro y San Pablo'),
  ('2027-07-20', 'Día de la Independencia'),
  ('2027-08-07', 'Batalla de Boyacá'),
  ('2027-08-16', 'Asunción de la Virgen'),
  ('2027-10-18', 'Día de la Raza'),
  ('2027-11-01', 'Todos los Santos'),
  ('2027-11-15', 'Independencia de Cartagena'),
  ('2027-12-08', 'Inmaculada Concepción'),
  ('2027-12-25', 'Navidad')
ON CONFLICT (fecha) DO NOTHING;

-- Parámetros configurables (MODELO §5.1 #7). null = pendiente de definir por el cliente.
INSERT INTO sgd.parametros_sistema (clave, valor, descripcion) VALUES
  ('semaforo.umbral_amarillo_pct', '50',   'Porcentaje del plazo consumido para pasar a amarillo (I-05, CONFIRMAR)'),
  ('semaforo.umbral_naranja_pct',  '80',   'Porcentaje del plazo consumido para pasar a naranja (I-05, CONFIRMAR)'),
  ('consecutivo.formato',          '"{anio}-{prefijo}-{numero:05}"', 'Formato del número visible del radicado (I-02)'),
  ('correo.registro_academico',    'null', 'Correo que recibe copia de las respuestas verificadas (P-14, CONFIRMAR)'),
  ('correo.recepcion',             'null', 'Correo de Recepción para copias y alertas (CONFIRMAR)'),
  ('portal.max_bytes_envio',       '104857600', 'Tamaño máximo por envío en bytes: 100 MB (RNF-007, P-08)'),
  ('alertas.anticipacion_dias',    '2',    'Días hábiles de anticipación para avisar el vencimiento (P-13, CONFIRMAR)')
ON CONFLICT (clave) DO NOTHING;

-- Administrador inicial. Sin credenciales: se asignan con sgd.establecer_clave_temporal (README, paso 5).
-- CONFIRMAR el correo real de TIC.
INSERT INTO sgd.usuarios (nombre_completo, correo, rol_id, dependencia_id)
SELECT 'Administrador del sistema', 'admin@uniautonoma.edu.co', r.id_rol, d.id_dependencia
FROM sgd.roles r, sgd.dependencias d
WHERE r.codigo = 'administrador' AND d.codigo = 'TIC'
ON CONFLICT (correo) DO NOTHING;
