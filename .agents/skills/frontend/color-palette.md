# Paleta de Colores

Fuente: maquetación de interfaz SGD v1.0 (`ia_contexto/spec/Interfaz del documento/`).
Los tokens viven en `frontend_gestion_documental/app/globals.css` dentro de `@theme` (Tailwind 4)
y se usan como clases: `bg-marca`, `text-tinta-suave`, `border-borde-campo`, etc.
**No escribir hexadecimales sueltos en componentes.**

Si la universidad entrega manual de identidad, se ajustan los valores aquí y en `globals.css`.

## Marca y acción

| Token | Valor | Uso |
|---|---|---|
| `marca` | `#243b8e` | Títulos, logo, texto de marca, navegación activa del portal |
| `acento` | `#f4b400` | Botón primario, ítem activo del menú, pasos completados |
| `acento-hover` | `#e0a500` | Hover del primario |
| `acento-oscuro` | `#b07c00` | Antetítulos, texto sobre fondo claro con acento |
| `acento-texto` | `#7a5a00` | Texto de insignias ámbar (contraste AA) |
| `acento-claro` | `#fffbeb` | Fondo de avisos de plazo |
| `sobre-acento` | `#0b1020` | Texto sobre el botón dorado (nunca blanco) |
| `info` | `#0047cc` | Avisos informativos, enlaces dentro de texto, botón de contorno |

## Tinta y superficies

| Token | Valor | Uso |
|---|---|---|
| `tinta` | `#1e293b` | Texto principal |
| `tinta-suave` | `#64748b` | Etiquetas, metadatos, texto secundario |
| `tinta-profunda` | `#0f172a` | Bloque del número de radicado en la confirmación |
| `fondo` | `#ffffff` | Fondo principal y tarjetas |
| `fondo-alt` | `#f8fafc` | Menú lateral, cabecera de tablas, secciones alternas |
| `fondo-sutil` | `#f1f5f9` | Encabezado del panel, línea de tiempo, campos de solo lectura |
| `borde` | `#e2e8f0` | Bordes de tarjetas y separadores |
| `borde-campo` | `#cbd5e1` | Bordes de campos de formulario |

## Estados del radicado (`components/ui/insignia.tsx`)

Siempre texto + color, nunca solo color.

| Estado | Estilo |
|---|---|
| Radicado, Pendiente, Por verificar | `bg-info-claro text-info` |
| En trámite, En revisión, Por clasificar | `bg-acento/20 text-acento-texto` |
| En comité | violeta (`bg-violet-100 text-violet-800`) |
| Respondido, Activo, Clasificado | `bg-exito-claro text-exito` |
| Vencido | `bg-peligro-claro text-peligro` |
| Anulado, Deshabilitado | `bg-fondo-sutil text-tinta-suave` (anulado además tachado) |

## Semáforo de vencimiento (`IndicadorSemaforo`)

verde (`exito`) · amarillo (`acento`) · naranja (`orange-500`) · rojo (`peligro`), siempre con
su texto. Los umbrales siguen pendientes (I-05).

## Contraste

- Texto sobre `acento` → `sobre-acento`. Texto sobre `marca` o `tinta-profunda` → blanco.
- El dorado nunca se usa como color de texto sobre blanco: usar `acento-oscuro` o `acento-texto`.
- Foco visible: contorno de 2 px en `info` (definido globalmente en `:focus-visible`).

## Forma

Esquinas rectas en todo el sistema. Única excepción: la barra de navegación del portal
(píldora de vidrio, `rounded-full` con `backdrop-blur`).
