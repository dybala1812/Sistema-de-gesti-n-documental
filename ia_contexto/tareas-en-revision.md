- [ ] GD-006: Maquetación del frontend adaptada desde "Interfaz del documento" (portal público + panel interno por rol)
  Spec: ia_contexto/spec/Interfaz del documento/ · .agents/skills/frontend/

- [ ] GD-005: Base de datos en SQL (esquema, 28 tablas, RLS, funciones, semilla), incluidos los campos faltantes de I-10
  Spec: backend_gestion_documental/base-de-datos/MODELO_DE_DATOS.md · README.md
  Evidencia: 00…09 y sgd_completo.sql sin errores en PostgreSQL 18.3 local; pruebas/pruebas_seguridad.sql
  26/26 OK; pgbench 2.000 consecutivos simultáneos, 0 duplicados.
  Pendiente: ejecutarlo en Supabase (README, pasos 1–7); el ORM (Prisma) queda para GD-003 según I-01.

- [ ] GD-001: Obtener la firma del F-02 (numeral 9) y resolver las preguntas P-01…P-14
  Spec: ia_contexto/spec/decisiones.md
  Prioridad: alta