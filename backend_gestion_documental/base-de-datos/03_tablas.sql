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
