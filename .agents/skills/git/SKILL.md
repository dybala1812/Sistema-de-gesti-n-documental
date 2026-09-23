---
name: git
description: Comandos y flujo de trabajo Git para el proyecto. Conventional Commits y ramas definidas.
allowed-tools: Read, Write, Edit, Glob, Grep, Bash
---

# Git — Flujo de trabajo y Convencional Commits

## Ramas

| Rama | Descripción | Regla |
|---|---|---|
| `main` | Código desplegado y funcionando en producción. | **Nadie hace commit directo jamás.** Solo merges desde `develop` tras release. |
| `develop` | Integración de todas las historias terminadas. Es la base para nuevas historias. | Cada historia se fusiona aquí antes de considerarse lista. |
| `feature/HU-XXX-descripcion` | Una rama por historia de usuario. Ejemplo: `feature/HU-001-login-jwt`. | Se crea desde `develop`, se trabaja y se fusiona de vuelta a `develop` vía pull request. |
| `hotfix/descripción` | Solo para correcciones urgentes en producción sobre `main`. | No usar para desarrollo normal. Flujo: hacer commit en `main`, crear etiqueta, fusionar a `develop`. |

### Flujo típico para una historia

1. Estar en `develop`
2. Crear `feature/HU-XXX-descripcion`
3. Trabajar y hacer commits en la rama
4. Subir la rama y abrir pull request hacia `develop`
5. Un compañero la revisa
6. Cuando aprueba, se fusiona a `develop`

## Convencional Commits

Cada commit debe seguir este formato:

```
<tipo>(<módulo>): <descripción> (HU-XXX)
```

| Tipo | Cuándo se usa | Ejemplo |
|---|---|---|
| `feat` | Nueva funcionalidad | `feat(auth): login con JWT (HU-001)` |
| `fix` | Corrección de defecto | `fix(api): valida email duplicado (DEF-004)` |
| `docs` | Documentación | `docs(readme): instrucciones de despliegue` |
| `test` | Pruebas | `test(usuarios): casos de valores límite` |
| `refactor` | Cambio interno sin alterar comportamiento | `refactor(repo): extrae consulta a método` |
| `chore` | Configuración, dependencias | `chore(deps): actualiza framework` |

### Regla importante

- **Cada commit debe referenciar la historia que atiende** (`HU-XXX`).
- El mensaje debe explicar **qué cambió** sin que alguien tenga que abrir el código.
- Commits como `"cambios"`, `"avance"`, `"update"` o `"asdf"` **no se aceptan** como evidencia — se detectan de inmediato al revisar el historial.

### Commits prohibidos como evidencia

- `cambios`
- `avance`
- `update`
- `asdf`
- Cualquier mensaje sin tipo y descripción clara

## Comandos útiles

### Configuración inicial

```bash
# Configurar nombre y email (solo una vez)
git config --global user.name "Tu Nombre"
git config --global user.email "tu@email.com"

# Configurar convencional commits (opcional, con hook)
npm install --save-dev commitizen
npx cz install
```

### Flujo de trabajo normal

```bash
# 1. Actualizar develop y crear feature
git checkout develop
git pull origin develop
git checkout -b feature/HU-005-adjuntar-documento

# 2. Trabajar, hacer commits con mensaje convencional
git add .
git commit -m "feat(documentos): permite adjuntar PDF (HU-005)"

# 3. Subir y crear pull request
git push origin feature/HU-005-adjuntar-documento

# 4. Fusionar después de approval
git checkout develop
git pull origin develop
git merge --ff-only feature/HU-005-adjuntar-documento
git push origin develop

# 5. Borrar ramafeature
git branch -d feature/HU-005-adjuntar-documento
git push origin --delete feature/HU-005-adjuntar-documento
```

### Hotfix

```bash
# 1. Crear hotfix sobre main
git checkout main
git pull origin main
git checkout -b hotfix/bug-crash
# ... hacer commits con fix(api): ...
git commit -m "fix(core): arregla error de crash en inicio (HOTFIX-001)"

# 2. Fusionar a main y etiquetar
git checkout main
git merge --no-ff hotfix/bug-crash
git tag -a v1.0.1 -m "Hotfix para bug de crash"
git push origin main --tags

# 3. Fusionar a develop (con los mismos cambios)
git checkout develop
git merge --no-ff main
```

### Revertir un commit

```bash
# Revertir por mensaje (busca el commit)
git revert --no-edit <hash-del-commit>

# O revertir el último commit manteniendo cambios
git reset --soft HEAD~1
git reset HEAD~1
# Volver a hacer commit con mensaje correcto
```

## Verificación

Después de cada sesión de trabajo, ejecuta:

```bash
npm run lint
npm run build
```

Si hay errores de tipos (`tsc -b`), se deben corregir antes de considerar el commit como evidencia válida.