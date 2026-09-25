# Base de datos — SGD

PostgreSQL para Supabase. El diseño completo y sus decisiones están en
[MODELO_DE_DATOS.md](MODELO_DE_DATOS.md).

## Archivos

| Archivo | Contenido |
|---|---|
| `00_esquema.sql` | Extensiones (`citext`, `pg_trgm`) y esquema `sgd` |
| `01_roles.sql` | Roles `sgd_api` y `sgd_auth`, sin contraseña |
| `02_tipos.sql` | 22 tipos enumerados |
| `03_tablas.sql` | 28 tablas con PK, FK, UNIQUE y CHECK |
| `04_indices.sql` | Índices y restricciones únicas parciales |
| `05_funciones.sql` | Contexto de la petición, visibilidad para RLS, consecutivo, consulta pública, días hábiles |
| `06_disparadores.sql` | `actualizado_en`, bitácoras inmutables, prohibición de borrar |
| `07_permisos.sql` | Qué tablas toca cada rol; cierra `anon` y `authenticated` |
| `08_rls.sql` | RLS en las 28 tablas y sus políticas |
| `09_semilla.sql` | Roles, tipos de documento, trámites, festivos 2026–2027, parámetros, administrador inicial |
| `sgd_completo.sql` | Los archivos 00 a 09 en uno solo, para pegar en el editor SQL de Supabase |
| `pruebas/pruebas_seguridad.sql` | 26 pruebas de seguridad y reglas de negocio (terminan en `ROLLBACK`) |
| `pruebas/concurrencia_consecutivo.sql` | Prueba de 2.000 consecutivos simultáneos con `pgbench` |

`sgd_completo.sql` se genera a partir de los demás. Si cambias alguno, vuelve a generarlo:

```bash
cat 00_esquema.sql 01_roles.sql 02_tipos.sql 03_tablas.sql 04_indices.sql 05_funciones.sql 06_disparadores.sql 07_permisos.sql 08_rls.sql 09_semilla.sql > sgd_completo.sql
```

## Subirlo a Supabase

Se ejecuta **una sola vez**, sobre un proyecto sin el esquema `sgd`.

1. **Crear el esquema.** Supabase → *SQL Editor* → *New query*. Pega el contenido de
   `sgd_completo.sql` y ejecútalo (o los archivos 00 a 09 en orden). Debe terminar sin errores.

2. **No exponer el esquema.** *Project Settings* → *Data API* → *Exposed schemas*: deja solo los
   que ya están (`public`, `graphql_public`). **No agregues `sgd`.**

3. **Dar contraseña a los roles de la API.** Genera dos contraseñas largas y distintas (32+
   caracteres) y ejecuta en el *SQL Editor*, cambiando los valores:

   ```sql
   ALTER ROLE sgd_api  WITH LOGIN PASSWORD 'CAMBIAR-contraseña-larga-api';
   ALTER ROLE sgd_auth WITH LOGIN PASSWORD 'CAMBIAR-contraseña-larga-auth';
   ```

   Las contraseñas van **solo** en el `.env` del backend (que está en `.gitignore`), nunca en el
   repositorio ni en este archivo.

4. **Cadenas de conexión del backend.** Copia `backend_gestion_documental/.env.example` a
   `.env` y completa `DATABASE_URL_API`, `DATABASE_URL_AUTH` y `DIRECT_URL` (esta última con la
   conexión directa al puerto 5432, como el rol `postgres`, para `prisma db pull` y los scripts de
   `pruebas/`). En Supabase, *Connect* → *Connection pooling* da el host del pooler; el usuario
   lleva el id del proyecto como sufijo (`sgd_api.<id-proyecto>`). El `.env.example` completo trae
   además JWT, cookies, adjuntos, correo y CAPTCHA — ver la plantilla para el resto de variables
   que necesita el backend, no solo la base de datos.

   El puerto 6543 (modo transacción) funciona con RLS porque el contexto se fija con
   `set_config(..., true)`, que solo dura la transacción. La API **nunca** usa la clave
   `service_role` ni el usuario `postgres`.

5. **Contraseña del administrador inicial.** Genera el hash bcrypt en tu equipo (la contraseña no
   sale de tu máquina):

   ```bash
   cd backend_gestion_documental
   npm install bcryptjs
   node -e "console.log(require('bcryptjs').hashSync(process.argv[1], 12))" "ContraseñaTemporalLarga"
   ```

   Y en el *SQL Editor*, pegando el hash obtenido:

   ```sql
   BEGIN;
   SELECT set_config('app.rol', 'administrador', true);
   SELECT sgd.establecer_clave_temporal(
     (SELECT id_usuario FROM sgd.usuarios WHERE correo = 'admin@uniautonoma.edu.co'),
     '$2a$12$...hash...'
   );
   COMMIT;
   ```

   Queda con `debe_cambiar_clave = true`: el primer ingreso obliga a cambiarla.

6. **Completar los datos pendientes** marcados `CONFIRMAR` en `09_semilla.sql` (correos de
   dependencias, plazos, umbrales). Son `UPDATE`, no cambian tablas.

7. **Verificar.** En el *SQL Editor* ejecuta `pruebas/pruebas_seguridad.sql`: todas las líneas deben
   decir `OK`. Termina en `ROLLBACK`, así que no deja datos. (En el editor de Supabase los comandos
   `\gset` y `\echo` de psql no funcionan: esta prueba se corre con `psql` apuntando a la conexión
   directa de Supabase.)

## Probar en local

Con PostgreSQL 15 o superior instalado:

```bash
createdb sgd_local
psql -d sgd_local -c "CREATE ROLE anon NOLOGIN; CREATE ROLE authenticated NOLOGIN;"   # imitan a Supabase
psql -d sgd_local -v ON_ERROR_STOP=1 -f sgd_completo.sql
psql -d sgd_local -f pruebas/pruebas_seguridad.sql
```

## Cómo usa la API esta base

En cada petición, dentro de una transacción, antes de cualquier consulta:

```sql
SELECT set_config('app.usuario_id', '12', true),
       set_config('app.rol', 'dependencia', true),        -- recepcion | dependencia | archivo_central | administrador | portal | n8n | sistema
       set_config('app.dependencia_id', '4', true);
```

Sin ese contexto, RLS no devuelve ninguna fila. Funciones que la API llama:

| Función | Para qué |
|---|---|
| `sgd.siguiente_consecutivo(tipo_documento_id, anio)` | Número del radicado, dentro de la transacción que lo crea |
| `sgd.sumar_dias_habiles(fecha, dias)` | Fecha límite según `festivos` |
| `sgd.registrar_persona_portal(tipo, numero, nombre)` | El portal obtiene el id de la persona sin leer sus datos |
| `sgd.consultar_estado_publico(numero_radicado, identificacion)` | Consulta pública (RF-018) |
| `sgd.establecer_clave_temporal(usuario_id, hash)` | El Administrador asigna o restablece una contraseña |
| `sgd.revocar_sesiones(usuario_id)` | Cierra las sesiones al deshabilitar un usuario |
