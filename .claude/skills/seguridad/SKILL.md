---
name: seguridad
description: Autenticación, permisos por rol, datos personales (Ley 1581), portal público sin sesión, adjuntos y secretos del Sistema de Gestión Documental. Úsala antes de tocar login, endpoints, portal público, archivos o correo.
allowed-tools: Read, Write, Edit, Glob, Grep, Bash
---

# Seguridad — Sistema de Gestión Documental

La guía completa vive en `.agents/skills/seguridad/SKILL.md`. Este archivo solo existe para
que la skill sea **invocable** desde Claude Code. Hay un único original: no dupliques el
contenido aquí.

## Qué hacer al invocarla

1. Lee `.agents/skills/seguridad/SKILL.md` completo y sigue lo que dice.
2. Revisa `ia_contexto/spec/decisiones.md`: hay preguntas abiertas de seguridad (prellenado
   por cédula en el portal público) que no se deben resolver sin el cliente.
