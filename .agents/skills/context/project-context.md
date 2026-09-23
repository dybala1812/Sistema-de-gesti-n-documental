# Contexto del Proyecto

## Producto

Sistema de Gestión Documental para la dependencia de Gestión Documental de la **Universidad
Autónoma**. Sustituye el registro en Excel, carpetas físicas y búsqueda manual.

Cubre: recepción y radicación de correspondencia (recibida, enviada, circulares,
resoluciones, convenios, solicitudes de estudiantes y terceros), consecutivos automáticos por
tipo reiniciados cada año, envío a la dependencia responsable, seguimiento hasta la
respuesta, alertas de vencimiento por tipo de trámite, historial documental por cédula,
apoyo a Archivo Central (expedientes y clasificación) y un **portal público** de
autorradicación sin inicio de sesión (respuesta solo por correo).

Marco normativo: Ley 594 de 2000, Decreto 1080 de 2015 (AGN, TRD) y Ley 1581 de 2012.

**Fuera de alcance**: PQRS (mesa de ayuda institucional), migración/digitalización masiva del
archivo histórico, integración con el sistema académico (no confirmada), firma electrónica
certificada, soporte posterior a la entrega.

## Equipo y cliente

- Desarrolladores: Juan Manuel Arteaga Flores y Juan David Burbano Manquillo.
- Responsable designada por el cliente: Magdali Certuche (valida y aprueba requisitos).
- 16 semanas, 3 sprints. El F-02 debe estar firmado (numeral 9) antes de construir.

## Usuarios

| Rol | Nivel | Qué hace |
|---|---|---|
| Administrador (TIC) | Medio | Configura, crea usuarios de todas las dependencias, anula documentos |
| Recepción / Ventanilla | Básico | Registra, radica, adjunta, envía, consulta; busca personas por cédula |
| Dependencia destinataria | Básico | Tramita y responde lo asignado a su dependencia; flujo de comité |
| Archivo Central | Básico | Expedientes, clasificación por serie/subserie, consulta del archivo |
| Estudiante / solicitante externo | Básico, ocasional | Solo radica su solicitud en el portal público, sin cuenta |

## Stack

- Frontend: `frontend_gestion_documental/` — Next.js 16.3 (App Router), React 19.2,
  TypeScript 5 estricto, Tailwind CSS 4, ESLint 9.
- Backend: `backend_gestion_documental/` — Node, Express 5 (CommonJS), nodemon. Sin código aún.
- Base de datos, almacenamiento de archivos, correo y hosting: por decidir
  (`ia_contexto/spec/decisiones.md`).

## Documentos del proyecto

- F-00 Acta de constitución (alcance, riesgos).
- F-01 Propuesta técnica preliminar.
- F-02 Especificación de requisitos (base de `ia_contexto/spec/`).
- F-05 Documento de pruebas (cierra la matriz de trazabilidad).

## Guías relacionadas

- `../desarrollo/SKILL.md`, `../seguridad/SKILL.md`, `../testing/SKILL.md`
- `../frontend/`
