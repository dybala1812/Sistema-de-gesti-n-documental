---
name: desarrollo
description: Stack (Next.js 16 + Express 5), convenciones de código, módulos por dominio y criterio de commits del Sistema de Gestión Documental. Úsala antes de escribir o revisar código en este repo.
allowed-tools: Read, Write, Edit, Glob, Grep, Bash
---

# Desarrollo — Sistema de Gestión Documental

La guía completa vive en `.agents/skills/desarrollo/SKILL.md`. Este archivo solo existe para
que la skill sea **invocable** desde Claude Code, que descubre skills en `.claude/skills/` y
no en `.agents/skills/`. Hay un único original: no dupliques el contenido aquí.

## Qué hacer al invocarla

1. Lee `.agents/skills/desarrollo/SKILL.md` completo y sigue lo que dice.
2. Antes de escribir código, lee la spec en `ia_contexto/spec/`. Las decisiones de
   `decisiones.md` son vinculantes.
3. Antes de usar una API de Next.js, lee la guía en
   `frontend_gestion_documental/node_modules/next/dist/docs/`.
