# Flujo de Mantenimiento de Skills

Usar este flujo cuando una instrucción se repite, una decisión se vuelve permanente o aparece
una regla que ayudará a futuras sesiones.

## Cuándo actualizar

- el usuario repite una preferencia de diseño, arquitectura o flujo;
- el cliente confirma o cambia un requisito (y queda en el control de cambios del F-02);
- se descubre una convención importante del proyecto;
- una corrección probablemente se repetirá;
- se agrega una herramienta, dependencia o proceso nuevo (BD, correo, pruebas, despliegue).

## Dónde documentar

| Tema | Archivo |
|---|---|
| Stack, módulos, convenciones, commits | `desarrollo/SKILL.md` |
| Login, permisos, datos personales, adjuntos, secretos | `seguridad/SKILL.md` |
| Comandos de prueba, metas RNF, casos | `testing/SKILL.md` |
| UI, diseño, paleta, responsive, accesibilidad | `frontend/` |
| Límites entre módulos | `architecture/rules.md` |
| Producto, usuarios, alcance | `context/project-context.md` |
| Decisiones, riesgos, pendientes | `memory/project-memory.md` e `ia_contexto/spec/decisiones.md` |
| Comandos y variables | `tools/project-tools.md` |

Si cambias una skill del proyecto, revisa que su envoltorio en `.claude/skills/` siga
describiéndola bien (nombre y `description`).

## Cómo escribir una actualización

- Concreta y accionable, con rutas cuando dependa de archivos.
- Sin duplicar lo ya documentado: enlaza.
- Separar reglas permanentes de notas temporales.
- Citar el RF/RN/RNF de origen cuando exista.

## Frase guía

"Si esto me va a servir otra vez, debe vivir en una skill de `.agents/skills/`."
