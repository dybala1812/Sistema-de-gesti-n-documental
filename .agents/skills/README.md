# Skills del proyecto — Sistema de Gestión Documental

Contexto operativo para agentes IA que trabajen en el **Sistema de Gestión Documental** de la
Universidad Autónoma (práctica profesional, Ingeniería de Software y Computación). Fuente de
requisitos: **F-02 Especificación de requisitos v1.0** (25-ago-2026), traducida a
`ia_contexto/spec/`.

## Skills invocables

| Skill | Para qué |
|---|---|
| `desarrollo/` | Stack, módulos por dominio, reglas de negocio, convenciones, commits |
| `seguridad/` | Login, permisos por rol, Ley 1581, portal público, adjuntos, secretos |
| `testing/` | Comandos, metas RNF medibles, casos de prueba del F-02 |
| `project-manager/` | Tablero de tareas e historial en `ia_contexto/` |
| `frontend-design/`, `tailwind-css-patterns/`, `typescript-advanced-types/` | Skills genéricas de apoyo |

`.claude/skills/` contiene envoltorios cortos de las cuatro skills del proyecto para que
Claude Code las descubra; el original siempre es el de `.agents/skills/`.

## Documentación de apoyo

- `context/`: resumen del producto, usuarios, stack y análisis de skills genéricas.
- `architecture/`: reglas técnicas y límites entre módulos.
- `frontend/`: instrucciones de UI, sistema de diseño, paleta, responsive y accesibilidad.
- `agents/`: especialización sugerida de agentes por tipo de tarea.
- `memory/`: decisiones, riesgos y pendientes vivos del proyecto.
- `tools/`: comandos y herramientas.
- `workflows/`: flujos repetibles (desarrollo, mantenimiento de skills).

## Prioridades para agentes

1. Cumplir el F-02: cada cambio se rastrea a un RF/RNF/RN.
2. Consecutivos sin duplicados, nada se borra, todo queda auditado.
3. Permisos comprobados en el backend; portal público sin fugas de datos personales.
4. Interfaz usable sin capacitación (RNF-003) y responsiva en Chrome/Edge escritorio y celular.
5. Verificar con ejecución real (lint, build, pruebas) antes de cerrar una tarea.

## Mantenimiento

Si una instrucción, decisión o corrección se repite más de una vez, se documenta en el
archivo correspondiente de `.agents/skills/` (ver `workflows/skill-maintenance.md`).
