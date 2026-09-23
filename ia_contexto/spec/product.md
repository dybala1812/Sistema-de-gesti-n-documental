# Producto — Sistema de Gestión Documental

Fuente: F-02 Especificación de requisitos v1.0 (25-ago-2026), §1–2. Si este archivo y el F-02
difieren, manda el F-02 firmado; la diferencia se corrige aquí.

## Objetivo

Registrar, radicar, enviar, seguir, responder y consultar la correspondencia general de la
Universidad Autónoma, reemplazando Excel, carpetas físicas y búsqueda manual, en
cumplimiento de la Ley 594 de 2000 y el Decreto 1080 de 2015.

## Incluye

- Radicación de comunicaciones de entrada y salida con consecutivo automático por tipo
  (recibida, enviada, circular, resolución, convenio), reiniciado cada año.
- Registro sin consecutivo de correspondencia que no se radica (revistas, facturas,
  paquetes, documentos sin firma).
- Adjuntos: escaneos (incluidos paquetes grandes como homologaciones) y documentos digitales.
- Envío a cualquier dependencia y seguimiento hasta la respuesta, incluido el paso por comité.
- Alertas de vencimiento parametrizables por tipo de trámite.
- Relación respuesta ↔ radicado de entrada, con copia a Recepción, Registro Académico y
  solicitante.
- Historial documental por cédula, con edición auditada de datos de contacto.
- Consultas con filtros combinados.
- Apoyo a Archivo Central: expedientes y clasificación documental.
- Anulación controlada, sin borrado físico.
- Usuarios, roles y permisos para todas las dependencias.
- Portal público de autorradicación sin inicio de sesión; respuesta solo por correo.

## No incluye

- PQRS (mesa de ayuda institucional).
- Migración o digitalización masiva del archivo histórico físico.
- Integración con el sistema académico (salvo que se confirme y delimite).
- Firma electrónica certificada.
- Soporte o mantenimiento posteriores a la entrega.

## Usuarios

| Rol | Permisos |
|---|---|
| Administrador | Acceso total: configuración, usuarios, todos los módulos |
| Recepción / Ventanilla | Registrar, radicar, adjuntar, enviar y consultar; buscar personas por cédula |
| Dependencia destinataria | Consultar y gestionar lo asignado a su dependencia; responder; flujo de comité |
| Archivo Central | Gestionar expedientes, clasificar, consultar el archivo |
| Estudiante / solicitante externo | Solo radicar su propia solicitud en el portal público, sin cuenta ni acceso a datos de otros |

## Restricciones

- Ley 1581 de 2012 (datos personales: cédulas, correos, celulares).
- Despliegue en infraestructura autorizada por la universidad o nube gratuita / bajo costo.
- Navegadores de la dependencia (por confirmar); RNF-005 fija Chrome y Edge.
- Equipo de dos personas, 16 semanas.
- Portal público sin verificación de identidad: medidas anti-abuso (CAPTCHA).

## Supuestos

- La responsable designada (Magdali Certuche) valida y aprueba.
- La universidad autorizará servidor o plan en la nube.
- Dependencia y Archivo Central definirán el listado de dependencias/programas y las reglas
  de la TRD.
- El solicitante externo indica un correo válido.
