# Requisitos

Fuente: F-02 §3–4. Cada RF conserva su ID; los criterios Dado/Cuando/Entonces derivan del
flujo principal, los alternativos y el caso de prueba de la matriz (§8).

---

## RF-001

**Registrar y radicar una comunicación de entrada** · Recepción · Alta · Sprint 1 · HU-004

Datos: fecha, hora, tipo de comunicación, asunto, remitente, cédula/NIT, dependencia
destinataria, descripción/observaciones, medio de recepción.

- Dado un usuario de Recepción con sesión, cuando registra una comunicación con datos
  completos, entonces se genera un consecutivo (RF-003) y el radicado queda en estado
  `recibido`.
- Dado un remitente existente por cédula, cuando se digita la cédula, entonces se prellenan
  nombre y datos de contacto; si no existe, se permite crearlo.

## RF-002

**Registrar una comunicación de salida relacionada con un radicado de entrada** ·
Dependencia, Recepción · Alta · Sprint 2 · HU-007

- Dado un radicado de entrada, cuando se genera la respuesta (destinatario, asunto,
  descripción, adjunto), entonces se crea un consecutivo de tipo `enviada`, queda
  relacionado con la entrada, y la entrada pasa a `respondido`.
- Entonces se envía copia a Recepción, a Registro Académico y al solicitante cuando aplique.
- También se puede registrar una salida independiente, sin radicado de entrada.

## RF-003

**Generar el consecutivo automático según su tipo** · Sistema · Alta · Sprint 1 · HU-003

Tipos: recibida, enviada, circular, resolución, convenio.

- Dado un tipo y el año en curso, cuando se confirma un registro, entonces se asigna el
  siguiente consecutivo de ese tipo y año, de forma atómica.
- Dado registros simultáneos del mismo tipo, entonces no hay duplicados (RN-001, RNF-006).
- El 1 de enero cada contador reinicia en 1; los consecutivos anteriores no se reutilizan.

## RF-004

**Adjuntar el documento digital al radicado** · Recepción, Dependencia · Alta · Sprint 2 · HU-005

- Dado un radicado, cuando se cargan uno o más PDF o imágenes, entonces quedan asociados y
  consultables en cualquier momento.
- Si el archivo excede tamaño o formato permitido, se rechaza e informa el motivo.

## RF-005

**Asignar/enviar el radicado a la dependencia responsable** · Recepción · Alta · Sprint 2 · HU-006

- Dado un radicado registrado, cuando se envía a una dependencia, entonces se registra quién,
  a qué dependencia, fecha y hora; se notifica a la dependencia; estado `enviado`.
- Un usuario autorizado puede reasignarlo; se conserva el historial de reasignaciones.

## RF-006

**Consultar la trazabilidad y el estado de un radicado** · Todos los roles internos · Media ·
Sprint 3 · HU-010

- Dado un radicado, cuando se consulta, entonces se muestra su línea de tiempo con fecha,
  hora y usuario de cada evento (recibido, radicado, enviado, recibido por la dependencia,
  respondido, y estados de comité).

## RF-007

**Consultar el historial documental de una persona por cédula** · Recepción, Dependencia ·
Alta · Sprint 2 · HU-008

- Dada una cédula existente, cuando se busca, entonces se muestran nombre, programa, correo,
  celular, estado y la lista de radicados (radicado, fecha, tipo, asunto, estado).
- Si la cédula no existe, se ofrece registrar a la persona (RF-008).

## RF-008

**Registrar y editar datos de una persona con auditoría** · Recepción · Media · Sprint 2 · HU-009

- Dado un usuario con permiso, cuando edita celular, correo, dirección, programa o estado,
  entonces se guarda el valor y se registra usuario y fecha/hora del cambio (RN-003).

## RF-009

**Consultar y filtrar radicados por múltiples criterios** · Todos los roles internos · Alta ·
Sprint 3 · HU-011

Criterios: número, cédula, nombre, fecha, año, mes, tipo, dependencia, programa, estado,
asunto, remitente.

- Dados varios filtros, cuando se aplican, entonces todos los resultados cumplen todos los
  criterios.
- Sin resultados, se informa que no se encontraron radicados.

## RF-010

**Gestionar expedientes y clasificación documental** · Archivo Central · Media · Sprint 3 · HU-013

- Dado un expediente, cuando se asocian documentos y se clasifica por serie/subserie,
  entonces se guardan la clasificación y la fecha de organización, y los documentos son
  ubicables dentro del expediente.
- **Pendiente**: definición exacta de "expediente" y series/subseries (segunda entrevista).

## RF-011

**Anular un documento de forma controlada** · Administrador · Media · Sprint 3 · HU-012

- Dado un documento anulable, cuando se anula con motivo, entonces pasa a `anulado`, se
  registran usuario, fecha/hora y motivo; sigue visible en consultas pero no editable.
- Si no es anulable (p. ej. resolución ya notificada), se rechaza.

## RF-012

**Administrar usuarios y permisos por rol** · Administrador · Alta · Sprint 1 · HU-002

- Crear, editar y deshabilitar usuarios de cualquier dependencia y asignar un rol.
- Deshabilitar no elimina: se conserva la trazabilidad.

## RF-013

**Autenticarse en el sistema** · Todos los roles internos · Alta · Sprint 1 · HU-001

- Credenciales válidas: se crea sesión y se muestran las opciones del rol.
- Credenciales inválidas: se rechaza sin indicar cuál dato es incorrecto.

## RF-014

**Registrar correspondencia sin consecutivo** · Recepción · Baja · Sprint 2 · HU-014

- Datos mínimos: fecha, hora, tipo de elemento, remitente si se conoce, dependencia
  destinataria. No consume consecutivo (RN-006).
- Si se determina que sí debe radicarse, se continúa con RF-001.

## RF-015

**Generar alertas de vencimiento del plazo de respuesta** · Sistema · Alta · Sprint 3 · HU-015

- La fecha límite se calcula desde la fecha de radicación y el plazo del tipo de trámite.
- El sistema verifica periódicamente y notifica al responsable (y a Recepción si aplica)
  cuando un radicado está próximo a vencer o vencido.
- Si depende de un comité que no se ha reunido, la alerta indica que el retraso es por la
  espera del comité.

## RF-016

**Gestionar el flujo de aprobación por comité** · Dependencia · Media · Sprint 3 · HU-016

- Estados: `en_revision_requisitos` → `en_comite` → decisión → respuesta (RF-002).
- Si no cumple requisitos: `rechazado_requisitos`, sin pasar por comité.
- Cada cambio queda en la trazabilidad (RF-006).

## RF-017

**Radicar una solicitud desde el portal público** · Solicitante externo · Alta · Sprint 3 · HU-017

- Sin sesión ni cuenta. Tipo de trámite, nombre, cédula, correo, descripción y adjuntos.
- Genera consecutivo (RF-003) y se asigna a la dependencia responsable (RF-005), con el mismo
  tratamiento que en Recepción (RN-009).
- Muestra comprobante con el número de radicado; la respuesta llega solo por correo (RN-008).
- El F-02 indica prellenar datos si la cédula existe: **en revisión por riesgo de fuga de
  datos personales**, ver `decisiones.md` (P-01).

---

## Requisitos no funcionales

| ID | Característica | Métrica |
|---|---|---|
| RNF-001 | Rendimiento | Listado de hasta 500 radicados en < 3 s (cifra tentativa) |
| RNF-002 | Seguridad | 0 contraseñas en texto plano; 100 % de accesos sin permiso denegados |
| RNF-003 | Usabilidad | Radicar en < 5 min sin capacitación, con un usuario real |
| RNF-004 | Mantenibilidad | Módulos por dominio documentados; cobertura ≥ 60 % en consecutivos y permisos |
| RNF-005 | Compatibilidad | 2 últimas versiones de Chrome y Edge, escritorio y celular |
| RNF-006 | Fiabilidad | 0 consecutivos duplicados en concurrencia; 100 % de anulados consultables |
| RNF-007 | Capacidad | Paquete de ≥ 100 MB en < 30 s sin degradar otras operaciones |

## Interfaces con otros sistemas

| Sistema | Propósito | Estado |
|---|---|---|
| Sistema académico | Validar datos de estudiantes | Por confirmar; fuera de alcance hasta entonces |
| Correo institucional | Notificaciones y respuestas del portal | SMTP o API de correo, por definir |
