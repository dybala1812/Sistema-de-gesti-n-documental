# Especialización de Agentes

## Agente de Backend / Dominio

Módulos de Express, reglas de negocio, base de datos, transacciones y consecutivos.

- `backend_gestion_documental/src/modulos/`
- `ia_contexto/spec/requirements.md`, `business-rules.md`
- Skills: `desarrollo`, `testing`, `seguridad`.

Foco crítico: RF-003 (consecutivos concurrentes), RF-006 (trazabilidad), RN-002/RN-003.

## Agente de Frontend — Panel interno

Pantallas por rol: radicación, bandeja de la dependencia, consultas con filtros, línea de
tiempo, personas por cédula, expedientes, usuarios.

- `frontend_gestion_documental/app/(panel)/`
- `.agents/skills/frontend/`
- Skills: `frontend-design`, `tailwind-css-patterns`, `typescript-advanced-types`.

Foco crítico: RNF-003 (radicar en < 5 min sin capacitación), RNF-005 (Chrome/Edge,
escritorio y celular).

## Agente de Frontend — Portal público

Formulario de autorradicación sin sesión (RF-017).

- `frontend_gestion_documental/app/(publico)/`
- Skills: `seguridad` (CAPTCHA, Ley 1581, sin fuga de datos), `frontend-design`.

## Agente de Seguridad / QA

Matriz rol × endpoint, pruebas de concurrencia, carga de adjuntos, pruebas RNF.

- Skills: `seguridad`, `testing`.
- Cierra casos en la matriz de trazabilidad (`ia_contexto/spec/trazabilidad.md` → F-05).

## Agente de Gestión

Tablero, historial, control de cambios respecto al F-02.

- Skill: `project-manager`.
