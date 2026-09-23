# Historial

## 2026-09-23 — Inicialización del contexto del proyecto

Cambio: skills de `.agents/skills/` y `.claude/skills/` reescritas para el Sistema de
Gestión Documental a partir del F-02 v1.0; eliminado todo el contenido de proyectos
anteriores. Creada `ia_contexto/spec/` (product, requirements, business-rules,
trazabilidad, decisiones) y el backlog GD-001…GD-044 por sprint.
Tests: no aplica (solo documentación).
Seguridad: `.claude/settings.local.json` limpiado de permisos que apuntaban a otro proyecto.
Commit: ninguno.

## 2026-09-23 — Historias de Juan Manuel documentadas

Cambio: `ia_contexto/spec/historias-juan-manuel.md` con las 9 HU asignadas a Juan Manuel
Arteaga Flores en `REQUISITOS_DESARROLLO_SGD.md` §1.1 (HU-002, 003, 006, 007, 019, 010,
015, 016, 018; 54 puntos), agrupadas por sprint, con reglas, criterios Dado/Cuando/Entonces,
contratos y pruebas. Registradas 11 inconsistencias (I-01…I-11) para el equipo.
Tests: no aplica (solo documentación).
Commit: ninguno.

## 2026-09-23 — Backlog reorganizado por sprint

Cambio: `tareas-faltantes.md` reorganizado según REQUISITOS_DESARROLLO_SGD §1.1, con responsable
(JM/JD) y puntos. Historias de JM divididas en subtareas backend/frontend/pruebas. Nuevas
tareas GD-026 (HU-019) y GD-037 (HU-018). GD-006 pasa a revisión.
Commit: ninguno.

## 2026-09-23 — GD-006 en revisión: maquetación del frontend

Cambio: la maqueta "Interfaz SGD v1.0" pasada a Next.js 16 en `frontend_gestion_documental/`:
tokens en `app/globals.css`, componentes en `components/ui`, portal público (4 pantallas),
login y panel interno (18 pantallas) con menú por rol. Librerías: lucide-react, sileo, gsap,
Radix dialog/popover, cva + clsx + tailwind-merge, jspdf. Se desinstalaron sonner y motion
(duplicaban sileo y gsap, que ya estaban instaladas).
Tests: `npm run lint` sin errores; `npm run build` compila 23 rutas; recorrido en navegador:
24 rutas 200, 404 para radicado inexistente, login → bandeja por rol, validaciones y flujo
de radicación del portal. Capturas visuales no estables en el navegador integrado.
Seguridad: la consulta pública exige número + cédula; la confirmación no pone datos
personales en la URL; el rol simulado está marcado como solo demostración.
Commit: ninguno.

## 2026-09-23 — Login de demostración conectado a las secciones (GD-006)

Cambio: cuentas de prueba por rol (correo + contraseña `Demo2026*`) en lugar del selector
de rol; el login redirige a `/panel`, un inicio con tarjetas de las secciones del rol;
el panel sin sesión redirige a `/login`; secciones ajenas al rol muestran aviso; cerrar
sesión borra la sesión. Al elegir una cuenta de demostración se llena el formulario y se
copia el correo al portapapeles (con respaldo para navegadores que bloquean la API).
Tests: lint sin errores; build de 23 rutas; en navegador: /panel sin sesión → /login,
contraseña incorrecta → error genérico, dependencia → inicio con 2 secciones, /panel/admin
bloqueado, ficha accesible, cerrar sesión → /login, copia del correo con aviso.
Commit: ninguno.
