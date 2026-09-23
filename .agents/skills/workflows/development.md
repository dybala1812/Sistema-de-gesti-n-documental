# Flujo de Desarrollo

1. Tomar la tarea del tablero (`project-manager`) y leer su RF en `ia_contexto/spec/`.
2. Revisar reglas en `../desarrollo/SKILL.md` y, si toca login, endpoints, portal o
   archivos, `../seguridad/SKILL.md`.
3. Si toca Next.js, leer la guía en `frontend_gestion_documental/node_modules/next/dist/docs/`.
4. Definir contrato (API / tipos) y criterio Dado/Cuando/Entonces antes del código.
5. Hacer cambios pequeños y coherentes con el estilo actual.
6. Verificar (ver `../testing/SKILL.md`).
7. Para cambios visuales, revisar escritorio y celular.
8. Cerrar la tarea con su entrada en `ia_contexto/historial.md`.
9. Si apareció una regla nueva o repetida, actualizar la skill correspondiente.

## Comandos

```bash
cd frontend_gestion_documental
npm run lint
npm run build
npm run dev
```
