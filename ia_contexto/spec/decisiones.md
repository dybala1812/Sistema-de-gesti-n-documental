# Decisiones y preguntas abiertas

Las decisiones marcadas **Tomada** son vinculantes. Las **Propuesta** esperan aprobación del
equipo o del cliente antes de implementarse. Registrar aquí cada cambio con fecha.

## Decisiones

| ID | Decisión | Estado | Fecha |
|---|---|---|---|
| D-01 | Frontend Next.js 16 (App Router, TypeScript, Tailwind 4); backend Express 5 | Tomada (ya instalado) | 2026-09-23 |
| D-02 | Portal público sin inicio de sesión; respuesta solo por correo | Tomada por el cliente | 2026-09-01 |
| D-03 | Nada se borra físicamente: anulación y deshabilitación | Tomada (RN-002, RF-012) | 2026-08-25 |
| D-04 | Base de datos relacional con transacciones y bloqueo de fila; PostgreSQL recomendado | Propuesta | — |
| D-05 | Consecutivo como contador por `(tipo, anio)` con bloqueo de fila + `UNIQUE` | Propuesta | — |
| D-06 | Autenticación con sesión en cookie `HttpOnly` y hash `argon2id`/`bcrypt` | Propuesta | — |
| D-07 | Pruebas: Vitest/Jest + Supertest en backend, Playwright para flujos críticos | Propuesta | — |
| D-08 | Backend en JavaScript (CommonJS) o migrar a TypeScript | Por decidir | — |
| D-09 | Almacén de adjuntos (disco del servidor vs. almacenamiento de objetos) | Por decidir, depende del hosting | — |
| D-10 | Servicio de correo (SMTP institucional vs. API) | Por decidir | — |
| D-11 | CAPTCHA del portal (proveedor) | Por decidir | — |

## Preguntas abiertas (para el cliente / segunda entrevista)

| ID | Pregunta | Afecta |
|---|---|---|
| P-01 | El portal público "prellena" datos si la cédula existe. Eso permite a cualquiera obtener nombre, correo y celular de otra persona con solo su cédula (Ley 1581). ¿Se acepta **no** mostrar datos existentes en el portal y solo asociar internamente? | RF-017, seguridad |
| P-02 | Formato del consecutivo visible (¿prefijo por tipo, año, relleno con ceros?) | RF-003 |
| P-03 | ¿Los plazos son en días hábiles o calendario? ¿Qué festivos se consideran? | RF-015 |
| P-04 | Plazos definitivos por tipo de trámite y cuáles requieren comité; periodicidad del comité | RF-015, RF-016 |
| P-05 | ¿Qué documentos no son anulables además de resoluciones notificadas? | RF-011 |
| P-06 | Listado completo de dependencias y programas destinatarios | RF-005, RF-012 |
| P-07 | Definición de "expediente", series y subseries de la TRD | RF-010 |
| P-08 | Tamaño máximo por archivo y por paquete; formatos de imagen admitidos | RF-004, RNF-007 |
| P-09 | Volumen real de radicados por año | RNF-001 |
| P-10 | Navegadores institucionales | RNF-005 |
| P-11 | Infraestructura de despliegue autorizada (riesgo R-03) | D-04, D-09, D-10 |
| P-12 | ¿Quién puede reasignar un radicado enviado a la dependencia equivocada? | RF-005 |
| P-13 | ¿Las alertas son solo por correo, solo en el panel o ambas? ¿Con cuánta anticipación? | RF-015 |
| P-14 | ¿Cómo se identifica el correo de Registro Académico para las copias de respuesta? | RF-002 |
