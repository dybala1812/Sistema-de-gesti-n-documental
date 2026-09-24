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
