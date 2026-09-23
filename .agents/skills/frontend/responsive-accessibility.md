# Responsive y Accesibilidad

## Responsive (F-02 §5.1, RNF-005)

Ambas experiencias deben funcionar en computador y en el navegador del celular, en las dos
últimas versiones de Chrome y Edge.

- Mobile-first con los breakpoints de Tailwind (`sm`, `md`, `lg`, `xl`).
- Portal público: diseñado primero para celular, una columna.
- Panel interno: pensado para escritorio, pero usable en celular:
  - la barra lateral se vuelve menú desplegable;
  - las tablas se convierten en tarjetas o permiten desplazamiento horizontal **dentro**
    de la tabla, nunca de la página;
  - los filtros combinados se agrupan en un panel plegable.
- Áreas táctiles de al menos 44 × 44 px.
- Nada depende de hover para funcionar.

## Accesibilidad

- Todo campo con `<label>` visible asociado; campos obligatorios marcados con texto, no
  solo con asterisco rojo.
- Errores anunciados (`aria-live` o `aria-describedby`) y junto al campo.
- Foco visible en todos los controles; orden de tabulación lógico.
- Botones de solo icono con `aria-label`.
- Estados del radicado y del vencimiento nunca solo por color.
- Tablas con `<th scope>` y leyenda.
- Línea de tiempo como lista ordenada (`<ol>`) con fechas legibles por lectores de pantalla.
- Respetar `prefers-reduced-motion`.
- El CAPTCHA del portal debe tener alternativa accesible.

## Formularios de radicación

- Campos agrupados con `<fieldset>`/`<legend>` (documento, remitente, destino).
- Autocompletar navegador en datos de contacto del portal (`autocomplete="email"`,
  `name`, `tel`).
- Cédula con `inputmode="numeric"` pero guardada como texto.
- No borrar la entrada del usuario ante un error.
