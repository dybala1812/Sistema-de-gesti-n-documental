# Sistema de Diseño Frontend

## Dirección visual

Institucional, sobria y confiable: una herramienta administrativa de una universidad.
Los usuarios internos tienen nivel técnico básico y la usan todo el día; el solicitante
externo la usa una vez y sin ayuda. La sensación debe ser:

- orden y claridad;
- confianza (datos personales y documentos con valor legal);
- rapidez para tareas repetitivas;
- cero ambigüedad sobre el estado de un radicado.

Si la universidad entrega manual de identidad (logo, colores, tipografía), manda sobre esta
guía; anotarlo en `color-palette.md`.

## Portal público (RF-017)

- Una sola tarea: radicar una solicitud. Sin menús del panel ni enlaces internos.
- Flujo en pasos cortos: tipo de trámite → datos → descripción y adjuntos → aviso de datos
  personales y CAPTCHA → enviar.
- Comprobante final con el número de radicado muy visible y el aviso de que la respuesta
  llegará al correo indicado (RN-008).
- Pensado primero para celular.

## Panel interno

- Barra lateral con las secciones permitidas por el rol; encabezado con usuario, rol,
  dependencia y cierre de sesión.
- Página de inicio por rol:
  - Recepción: botones grandes "Nueva comunicación recibida", "Registrar sin consecutivo",
    y últimos radicados.
  - Dependencia: bandeja de radicados asignados ordenada por fecha límite, con los próximos
    a vencer arriba (RF-015).
  - Archivo Central: expedientes recientes y pendientes de clasificar.
  - Administrador: usuarios y configuración.
- **Tablero de radicados** (RF-009): tabla con filtros combinados arriba, columnas
  consecutivo, fecha, tipo, asunto, remitente, dependencia, estado y vencimiento; paginación.
- **Detalle del radicado**: datos, adjuntos, acciones según estado y rol, y la **línea de
  tiempo** (RF-006) con fecha, hora, usuario y evento.
- **Persona por cédula** (RF-007): ficha con datos de contacto editables (auditados) y lista
  de radicados.

## Componentes

- Tablas densas pero legibles; en celular se convierten en tarjetas.
- Insignia de estado (texto + color, nunca solo color) para cada estado del radicado.
- Indicador de vencimiento: al día / próximo a vencer / vencido / en espera de comité
  (RF-015, RF-016).
- Botones: una acción primaria por pantalla; acciones destructivas en rojo y con
  confirmación.
- Estados vacíos que explican qué hacer ("No hay radicados con esos filtros").

## Tipografía

- Una familia sans legible (por ejemplo Geist, ya disponible en la plantilla de Next, o
  la institucional si existe). Números tabulares para consecutivos y fechas.
- Consecutivos en fuente monoespaciada o tabular para leerlos y dictarlos sin error.

## Interacciones

- Transiciones breves (≤ 200 ms), sin animaciones decorativas.
- Mensajes de éxito que confirman qué pasó ("Radicado REC-2026-0042 enviado a Talento
  Humano").
- Errores que dicen cómo corregir.

## Evitar

- Estética de landing o de marketing en el panel.
- Información crítica solo en tooltips.
- Modales encadenados.
- Colores de estado que no coincidan con `color-palette.md`.
