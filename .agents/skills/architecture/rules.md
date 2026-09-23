# Reglas de Arquitectura

Resumen operativo; el detalle está en `../desarrollo/SKILL.md`.

## Principios

- Cliente web (Next.js) separado de la API (Express). El navegador nunca accede a la base de
  datos ni al almacén de archivos.
- Backend organizado en **módulos por dominio** (RNF-004): autenticación, usuarios,
  radicación, consecutivos, trazabilidad, personas, consultas, trámites, alertas, archivo
  central, portal público. Cada uno: rutas → servicio → repositorio.
- Las reglas de negocio viven en la capa de servicio del backend y se prueban sin HTTP.
- Autorización en el backend en cada endpoint, incluida la pertenencia del objeto a la
  dependencia del usuario.
- Portal público con endpoints propios y mínimos (`/api/publico/…`).

## Datos

- Base de datos relacional con transacciones y bloqueo de fila (necesario para RN-001).
- Consecutivo: contador por `(tipo, anio)` + restricción `UNIQUE`; nunca `MAX()+1`.
- Nada se borra (RN-002): estados `anulado` / usuario `deshabilitado`.
- Cada cambio relevante escribe su evento de trazabilidad o auditoría en la misma
  transacción (RF-006, RN-003).
- Migraciones versionadas; nunca editar una migración aplicada.
- Listados paginados y filtrados en SQL con índices (RNF-001).

## Archivos

- Subida en streaming, nombre interno generado, hash guardado, descarga por endpoint con
  permisos (RF-004, RNF-007).

## Procesos en segundo plano

- Alertas de vencimiento (RF-015): tarea periódica que detecta radicados próximos a vencer
  o vencidos y notifica por correo y en el panel. "Vencido" se calcula, no se guarda.

## Integraciones

- Correo institucional: notificaciones (creado, asignado, próximo a vencer) y respuesta al
  solicitante del portal.
- Sistema académico: **no** se integra hasta que se confirme (F-02 §5.2).

## Next.js 16

- Leer `frontend_gestion_documental/node_modules/next/dist/docs/` antes de usar APIs.
- `proxy.ts` (antes `middleware.ts`) solo para redirecciones optimistas.

## Calidad

- Frontend: `npm run lint` y `npm run build` antes de cerrar cambios.
- Backend: pruebas del módulo tocado (cuando exista el framework).
- Cuando una tarea revele una decisión permanente, anotarla en
  `ia_contexto/spec/decisiones.md` y, si afecta a cómo se programa, en la skill que
  corresponda.
