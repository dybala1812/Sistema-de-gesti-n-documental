# Paleta de Colores

**Estado: propuesta.** La plantilla actual de `app/globals.css` solo define
`--background` y `--foreground`. Falta confirmar si la Universidad Autónoma tiene manual de
identidad; si lo tiene, sus colores reemplazan los de marca de esta tabla (no los de
estado).

Los tokens se definen en `app/globals.css` con `@theme` de Tailwind 4 y se usan como
clases (`bg-primario`, `text-texto-secundario`, …). No escribir colores hexadecimales
sueltos en componentes.

## Tokens base (propuestos)

| Token | Valor | Uso |
|---|---|---|
| `--color-primario` | `#1E3A8A` | Marca, navegación activa, botón primario |
| `--color-primario-hover` | `#1E40AF` | Hover del primario |
| `--color-fondo` | `#FFFFFF` | Fondo principal |
| `--color-fondo-alt` | `#F8FAFC` | Fondo del panel, filas alternas |
| `--color-borde` | `#E2E8F0` | Bordes y separadores |
| `--color-texto` | `#0F172A` | Texto principal |
| `--color-texto-secundario` | `#475569` | Etiquetas, metadatos |
| `--color-peligro` | `#B91C1C` | Anular, deshabilitar, errores |

## Colores de estado del radicado

Siempre acompañados de texto (accesibilidad). Fondo claro + texto oscuro del mismo tono.

| Estado | Tono |
|---|---|
| `recibido` | gris azulado |
| `enviado` / `recibido_dependencia` | azul |
| `en_revision_requisitos` / `en_comite` | violeta |
| `respondido` | verde |
| `rechazado_requisitos` | naranja |
| `anulado` | gris con texto tachado o etiqueta "Anulado" |

## Semáforo de vencimiento (RF-015)

| Situación | Tono |
|---|---|
| Al día | verde |
| Próximo a vencer | ámbar |
| Vencido | rojo |
| En espera de comité | violeta (el retraso no es de la dependencia) |

## Contraste

- Texto normal ≥ 4.5:1 y texto grande ≥ 3:1 (WCAG AA).
- Texto sobre `--color-primario`: blanco.
- Ámbar nunca como color de texto sobre blanco: usar fondo ámbar claro con texto oscuro.

## Modo oscuro

La plantilla trae `prefers-color-scheme: dark`. No es requisito del F-02; si se mantiene,
cada token debe tener su valor oscuro y los colores de estado deben conservar contraste.
