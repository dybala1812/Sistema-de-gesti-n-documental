# RF FOR IA — Formato de Especificación Verificable

Formato explícito y verificable para describir tareas de desarrollo, pensado para que un
agente de IA entienda exactamente qué construir sin tener que inferir intención. En este
proyecto la fuente es el **F-02 Especificación de requisitos** (ISO/IEC/IEEE 29148); las
specs de `ia_contexto/spec/` lo traducen a este formato y conservan sus IDs (`RF-xxx`,
`RNF-xxx`, `RN-xxx`, `HU-xxx`).

---

## 1. Especificación del producto

Qué se quiere construir, objetivo, usuarios involucrados.

```
Producto: Sistema de Gestión Documental — Universidad Autónoma

Objetivo:
Radicar, enviar, seguir, responder y consultar la correspondencia institucional,
con consecutivos automáticos por tipo y alertas de vencimiento.

Usuarios:
- Administrador
- Recepción / Ventanilla
- Dependencia destinataria
- Archivo Central
- Estudiante / solicitante externo (portal público, sin cuenta)
```

---

## 2. Reglas de negocio (RN)

Explícitas, numeradas, sin ambigüedad. Se usan los IDs del F-02.

```
RN-001
Un consecutivo de radicado nunca puede repetirse, incluso si dos usuarios radican
al mismo tiempo.

RN-002
Un documento no se borra físicamente: pasa a "anulado" y conserva quién y cuándo
lo anuló.

RN-004
Solo el rol Administrador puede crear, editar o deshabilitar usuarios y asignar roles.
```

---

## 3. Criterios de aceptación (Dado / Cuando / Entonces)

Escenarios concretos y verificables.

```
Escenario: Consecutivo sin duplicados (RF-003)

Dado que el último radicado "recibida" de 2026 es el 0041
Cuando dos usuarios de Recepción radican una comunicación recibida en el mismo instante
Entonces los radicados quedan con los consecutivos 0042 y 0043, sin repetirse
```

---

## 4. Contratos técnicos

Para que la IA sepa exactamente qué forma tienen las peticiones y respuestas.

```
POST /api/radicados

Request:
{
  "tipo": "recibida",
  "asunto": "Solicitud de reingreso",
  "remitenteCedula": "1061234567",
  "dependenciaDestinoId": 12,
  "canal": "ventanilla",
  "tipoTramiteId": 3
}

Response 201:
{
  "id": "…",
  "consecutivo": "REC-2026-0042",
  "estado": "recibido",
  "fechaLimite": "2026-10-02"
}
```

(El formato del consecutivo mostrado es ilustrativo: debe confirmarse con el cliente.)

---

## 5. Especificación ejecutable / tests

Requisitos comprobables mediante pruebas.

```
TEST-RF-003-01

Entrada:
contador(recibida, 2026) = 41
10 radicaciones concurrentes de tipo "recibida"

Resultado esperado:
consecutivos asignados = {42..51}, sin repetidos
contador(recibida, 2026) = 51
```

---

## Estructura de carpetas

```
ia_contexto/spec/
  ├── product.md
  ├── requirements.md
  ├── business-rules.md
  ├── decisiones.md
  ├── trazabilidad.md
  ├── architecture.md   (cuando exista)
  ├── api.md            (cuando exista)
  └── data-model.md     (cuando exista)
```

## Flujo de una feature

```
RF del F-02
  ↓
REGLAS DE NEGOCIO (RN)
  ↓
CRITERIOS DADO/CUANDO/ENTONCES
  ↓
CONTRATO API / MODELO DE DATOS
  ↓
PRUEBAS
  ↓
CÓDIGO
  ↓
CASO DE PRUEBA EN LA MATRIZ (F-05)
```

## Integración con el gestor de proyectos

Cada tarea del tablero referencia su RF (`Spec: ia_contexto/spec/requirements.md#rf-003`).
Así, cuando un agente toma la tarea, no solo lee su nombre sino su especificación completa.
