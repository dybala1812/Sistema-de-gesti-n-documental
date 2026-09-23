# Análisis de Skills Genéricas Cargadas

## frontend-design

Estado: útil, con matiz.

- Sirve para dar calidad visual al portal público y al panel interno.
- El panel es una **herramienta de trabajo diaria** para personal con nivel técnico básico:
  prima claridad, densidad de información legible y velocidad sobre lo decorativo.
- El portal público debe ser simple y confiable (institucional), usable desde el celular.

## tailwind-css-patterns

Estado: activa. Tailwind CSS 4 está instalado (`@import "tailwindcss"` en
`app/globals.css`, tokens con `@theme`).

- Tailwind 4 se configura en CSS (`@theme`), no en `tailwind.config.js`.
- Usar patrones mobile-first, foco visible y `prefers-reduced-motion`.

## typescript-advanced-types

Estado: activa en el frontend (TypeScript estricto).

- Uniones de literales para estados del radicado, roles, tipos de documento y canales.
- Tipos de contrato para las respuestas de la API.
- El backend es CommonJS en JavaScript: si se migra a TypeScript debe decidirse y anotarse
  en `ia_contexto/spec/decisiones.md`.

## Conclusión

Las tres skills genéricas aplican. Las reglas propias del proyecto (`desarrollo`,
`seguridad`, `testing`) tienen prioridad sobre cualquier consejo genérico.
