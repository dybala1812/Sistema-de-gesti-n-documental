-- =============================================================================
-- SGD · Pruebas de seguridad y reglas de negocio
--
-- SOLO PARA UNA BASE LOCAL O DE PRUEBAS. Todo corre dentro de una transacción que
-- termina en ROLLBACK: no deja datos. Ejecutar como dueño de la base, después de 00…09:
--   psql -v ON_ERROR_STOP=1 -f pruebas/pruebas_seguridad.sql
-- Cada prueba imprime "OK ..." o detiene el script con "FALLO ...".
-- =============================================================================

\set ON_ERROR_STOP 1
SET client_min_messages = notice;
BEGIN;

-- -----------------------------------------------------------------------------
-- Preparación (como dueño, sin RLS)
-- -----------------------------------------------------------------------------
INSERT INTO sgd.dependencias (codigo, nombre, tipo, correo) VALUES
  ('FING', 'Facultad de Ingeniería', 'academica', 'ingenieria@uniautonoma.edu.co'),
  ('DERE', 'Facultad de Derecho',    'academica', 'derecho@uniautonoma.edu.co');

INSERT INTO sgd.usuarios (nombre_completo, correo, rol_id, dependencia_id)
SELECT 'Recepción Prueba', 'recepcion.prueba@uniautonoma.edu.co', r.id_rol, d.id_dependencia
FROM sgd.roles r, sgd.dependencias d WHERE r.codigo = 'recepcion' AND d.codigo = 'RECEPCION';
INSERT INTO sgd.usuarios (nombre_completo, correo, rol_id, dependencia_id)
SELECT 'Ingeniería Prueba', 'ing.prueba@uniautonoma.edu.co', r.id_rol, d.id_dependencia
FROM sgd.roles r, sgd.dependencias d WHERE r.codigo = 'dependencia' AND d.codigo = 'FING';
INSERT INTO sgd.usuarios (nombre_completo, correo, rol_id, dependencia_id)
SELECT 'Derecho Prueba', 'der.prueba@uniautonoma.edu.co', r.id_rol, d.id_dependencia
FROM sgd.roles r, sgd.dependencias d WHERE r.codigo = 'dependencia' AND d.codigo = 'DERE';

SELECT id_usuario AS u_recepcion FROM sgd.usuarios WHERE correo = 'recepcion.prueba@uniautonoma.edu.co' \gset
SELECT id_usuario AS u_ing       FROM sgd.usuarios WHERE correo = 'ing.prueba@uniautonoma.edu.co' \gset
SELECT id_usuario AS u_der       FROM sgd.usuarios WHERE correo = 'der.prueba@uniautonoma.edu.co' \gset
SELECT id_usuario AS u_admin     FROM sgd.usuarios WHERE correo = 'admin@uniautonoma.edu.co' \gset
SELECT id_dependencia AS d_ing   FROM sgd.dependencias WHERE codigo = 'FING' \gset
SELECT id_dependencia AS d_der   FROM sgd.dependencias WHERE codigo = 'DERE' \gset
SELECT id_dependencia AS d_rec   FROM sgd.dependencias WHERE codigo = 'RECEPCION' \gset
SELECT id_tipo_documento AS td_recibida FROM sgd.tipos_documento WHERE codigo = 'recibida' \gset
SELECT id_tipo_tramite AS tt_homologacion FROM sgd.tipos_tramite WHERE codigo = 'homologacion' \gset

-- -----------------------------------------------------------------------------
-- P01 · RNF-002: una contraseña en texto plano no entra ni siquiera como dueño
-- -----------------------------------------------------------------------------
DO $$ BEGIN
  INSERT INTO sgd.credenciales_usuario (usuario_id, password_hash)
  SELECT id_usuario, 'MiClave123' FROM sgd.usuarios WHERE correo = 'admin@uniautonoma.edu.co';
  RAISE EXCEPTION 'FALLO P01: aceptó una contraseña en texto plano';
EXCEPTION WHEN check_violation THEN RAISE NOTICE 'OK P01 · contraseña en texto plano rechazada';
END $$;

-- -----------------------------------------------------------------------------
-- P02 · RN-002: nada se borra, ni siquiera como dueño
-- -----------------------------------------------------------------------------
DO $$ BEGIN
  DELETE FROM sgd.dependencias WHERE codigo = 'DERE';
  RAISE EXCEPTION 'FALLO P02: permitió borrar';
EXCEPTION WHEN insufficient_privilege THEN RAISE NOTICE 'OK P02 · DELETE bloqueado por disparador';
END $$;

-- -----------------------------------------------------------------------------
-- P03 · RN-010: ningún trámite con más de 15 días hábiles
-- -----------------------------------------------------------------------------
DO $$ BEGIN
  UPDATE sgd.tipos_tramite SET plazo_dias_habiles = 20 WHERE codigo = 'homologacion';
  RAISE EXCEPTION 'FALLO P03: aceptó 20 días';
EXCEPTION WHEN check_violation THEN RAISE NOTICE 'OK P03 · plazo de 20 días rechazado';
END $$;

-- -----------------------------------------------------------------------------
-- P04 · Días hábiles: 23-dic-2026 + 3 = 29-dic (salta 25-dic festivo, sábado y domingo)
-- -----------------------------------------------------------------------------
DO $$ BEGIN
  IF sgd.sumar_dias_habiles('2026-12-23', 3) <> DATE '2026-12-29' THEN
    RAISE EXCEPTION 'FALLO P04: %', sgd.sumar_dias_habiles('2026-12-23', 3);
  END IF;
  RAISE NOTICE 'OK P04 · días hábiles con festivo y fin de semana';
END $$;

-- =============================================================================
-- Desde aquí, como la API (sgd_api), con RLS aplicando
-- =============================================================================
SET LOCAL ROLE sgd_api;

-- P05 · sgd_api no puede leer contraseñas ni sesiones (D-BD-12)
DO $$ BEGIN
  PERFORM 1 FROM sgd.credenciales_usuario;
  RAISE EXCEPTION 'FALLO P05: sgd_api leyó credenciales';
EXCEPTION WHEN insufficient_privilege THEN RAISE NOTICE 'OK P05 · sgd_api sin acceso a credenciales_usuario';
END $$;

-- P06 · sgd_api no puede tocar el contador directo (D-BD-14)
DO $$ BEGIN
  UPDATE sgd.contadores_consecutivo SET ultimo_numero = 0;
  RAISE EXCEPTION 'FALLO P06: sgd_api modificó el contador';
EXCEPTION WHEN insufficient_privilege THEN RAISE NOTICE 'OK P06 · contador solo por función';
END $$;

-- P07 · Sin contexto, RLS no deja ver nada (falla cerrada)
DO $$ DECLARE n integer; BEGIN
  SELECT count(*) INTO n FROM sgd.dependencias;
  IF n <> 0 THEN RAISE EXCEPTION 'FALLO P07: sin contexto vio % dependencias', n; END IF;
  RAISE NOTICE 'OK P07 · sin contexto no se ve ninguna fila';
END $$;

-- P08 · Sin contexto no se puede generar consecutivo
DO $$ BEGIN
  PERFORM sgd.siguiente_consecutivo(1, 2026);
  RAISE EXCEPTION 'FALLO P08: generó consecutivo sin contexto';
EXCEPTION WHEN insufficient_privilege THEN RAISE NOTICE 'OK P08 · consecutivo exige rol';
END $$;

-- -----------------------------------------------------------------------------
-- Recepción radica y asigna a Ingeniería
-- -----------------------------------------------------------------------------
SELECT set_config('app.rol', 'recepcion', true) AS ctx_rol,
       set_config('app.usuario_id', :'u_recepcion', true) AS ctx_usuario,
       set_config('app.dependencia_id', :'d_rec', true) AS ctx_dependencia \gset

SELECT sgd.siguiente_consecutivo(:td_recibida, 2026) AS n1 \gset
INSERT INTO sgd.personas (tipo_identificacion, numero_identificacion, nombre_completo, correo, creado_por)
VALUES ('CC', '1061784220', 'Laura Camila Chicangana', 'laura@correo.com', :u_recepcion)
RETURNING id_persona AS p_laura \gset

INSERT INTO sgd.radicados (numero_radicado, tipo_documento_id, anio, consecutivo, tipo_tramite_id, canal, estado,
                           asunto, persona_id, registrado_por, plazo_dias_habiles, fecha_limite, semaforo)
VALUES ('2026-CR-' || lpad(:'n1', 5, '0'), :td_recibida, 2026, :n1, :tt_homologacion, 'ventanilla', 'recibido',
        'Homologación de Cálculo Diferencial', :p_laura, :u_recepcion, 15,
        sgd.sumar_dias_habiles(current_date, 15), 'verde')
RETURNING id_radicado AS r1, numero_radicado AS num_r1 \gset

INSERT INTO sgd.eventos_trazabilidad (radicado_id, tipo_evento, estado_nuevo, origen, usuario_id)
VALUES (:r1, 'radicado', 'recibido', 'usuario', :u_recepcion);
INSERT INTO sgd.asignaciones (radicado_id, dependencia_id, origen, asignado_por)
VALUES (:r1, :d_ing, 'usuario', :u_recepcion);
UPDATE sgd.radicados SET dependencia_id = :d_ing, estado = 'enviado' WHERE id_radicado = :r1;
\echo 'OK P09 · Recepción radicó' :num_r1 'y lo envió a Ingeniería'

-- Ids que usan las pruebas dentro de bloques DO (que no ven variables de psql)
SELECT set_config('prueba.r1', :'r1', true) AS c1,
       set_config('prueba.num_r1', :'num_r1', true) AS c2,
       set_config('prueba.u_admin', :'u_admin', true) AS c3 \gset

-- P10 · Recepción no puede registrar a nombre de otro usuario
DO $$ BEGIN
  INSERT INTO sgd.radicados (numero_radicado, tipo_documento_id, anio, consecutivo, canal, estado, asunto, registrado_por)
  VALUES ('2026-CR-99999', 1, 2026, 99999, 'ventanilla', 'recibido', 'Suplantación',
          current_setting('prueba.u_admin')::integer);
  RAISE EXCEPTION 'FALLO P10: registró a nombre de otro';
EXCEPTION WHEN insufficient_privilege THEN RAISE NOTICE 'OK P10 · registrado_por debe ser quien hace la petición';
END $$;

-- P11 · sgd_api no tiene DELETE
DO $$ BEGIN
  EXECUTE 'DELETE FROM sgd.radicados';
  RAISE EXCEPTION 'FALLO P11: sgd_api pudo borrar';
EXCEPTION WHEN insufficient_privilege THEN RAISE NOTICE 'OK P11 · sgd_api sin DELETE';
END $$;

-- P12 · La trazabilidad no se modifica (RF-006)
DO $$ BEGIN
  UPDATE sgd.eventos_trazabilidad SET detalle = 'alterado';
  RAISE EXCEPTION 'FALLO P12: modificó la trazabilidad';
EXCEPTION WHEN insufficient_privilege THEN RAISE NOTICE 'OK P12 · trazabilidad inmutable';
END $$;

-- P13 · Recepción no puede asignar contraseñas (solo Administrador)
DO $$ BEGIN
  PERFORM sgd.establecer_clave_temporal(1, '$2b$12$abcdefghijklmnopqrstuuv6XJ2nq0J5l0v7m5Qe4k1r3Tn8Wq1eC');
  RAISE EXCEPTION 'FALLO P13: Recepción asignó una contraseña';
EXCEPTION WHEN insufficient_privilege THEN RAISE NOTICE 'OK P13 · solo el Administrador asigna contraseñas';
END $$;

-- -----------------------------------------------------------------------------
-- IDOR: Ingeniería ve el radicado; Derecho no (T-HU006-05)
-- -----------------------------------------------------------------------------
SELECT set_config('app.rol', 'dependencia', true) AS ctx_rol,
       set_config('app.usuario_id', :'u_ing', true) AS ctx_usuario,
       set_config('app.dependencia_id', :'d_ing', true) AS ctx_dependencia \gset
DO $$ DECLARE n integer; p integer; BEGIN
  SELECT count(*) INTO n FROM sgd.radicados;
  SELECT count(*) INTO p FROM sgd.personas;
  IF n <> 1 OR p <> 1 THEN RAISE EXCEPTION 'FALLO P14: Ingeniería vio % radicados y % personas', n, p; END IF;
  RAISE NOTICE 'OK P14 · Ingeniería ve su radicado y su solicitante';
END $$;

SELECT set_config('app.rol', 'dependencia', true) AS ctx_rol,
       set_config('app.usuario_id', :'u_der', true) AS ctx_usuario,
       set_config('app.dependencia_id', :'d_der', true) AS ctx_dependencia \gset
DO $$ DECLARE n integer; p integer; e integer; BEGIN
  SELECT count(*) INTO n FROM sgd.radicados;
  SELECT count(*) INTO p FROM sgd.personas;
  SELECT count(*) INTO e FROM sgd.eventos_trazabilidad;
  IF n <> 0 OR p <> 0 OR e <> 0 THEN
    RAISE EXCEPTION 'FALLO P15: Derecho vio % radicados, % personas, % eventos ajenos', n, p, e;
  END IF;
  RAISE NOTICE 'OK P15 · Derecho no ve radicados, personas ni eventos de Ingeniería';
END $$;

-- P16 · Derecho no puede responder un radicado ajeno aunque conozca su id
DO $$ BEGIN
  INSERT INTO sgd.respuestas (radicado_id, dependencia_id, sentido, contenido, respondido_por)
  VALUES (current_setting('prueba.r1')::integer, sgd.dependencia_actual(), 'aprobado', 'Intento ajeno',
          sgd.usuario_actual());
  RAISE EXCEPTION 'FALLO P16: Derecho respondió un radicado ajeno';
EXCEPTION WHEN insufficient_privilege THEN RAISE NOTICE 'OK P16 · no se responde un radicado ajeno, aun con su id';
END $$;

-- P17b · Ni puede cambiarlo aunque conozca su id: el UPDATE no afecta filas
DO $$ DECLARE n integer; BEGIN
  UPDATE sgd.radicados SET asunto = 'alterado' WHERE id_radicado = current_setting('prueba.r1')::integer;
  GET DIAGNOSTICS n = ROW_COUNT;
  IF n <> 0 THEN RAISE EXCEPTION 'FALLO P17b: Derecho modificó un radicado ajeno'; END IF;
  RAISE NOTICE 'OK P17b · no se modifica un radicado ajeno, aun con su id';
END $$;

-- -----------------------------------------------------------------------------
-- Portal público (RF-017, RF-018)
-- -----------------------------------------------------------------------------
SELECT set_config('app.rol', 'portal', true) AS ctx_rol,
       set_config('app.usuario_id', '', true) AS ctx_usuario,
       set_config('app.dependencia_id', '', true) AS ctx_dependencia \gset

-- P17· El portal no puede leer personas ni radicados ajenos
DO $$ DECLARE n integer; p integer; BEGIN
  SELECT count(*) INTO n FROM sgd.radicados;
  SELECT count(*) INTO p FROM sgd.personas;
  IF n <> 0 OR p <> 0 THEN RAISE EXCEPTION 'FALLO P17: el portal vio % radicados y % personas', n, p; END IF;
  RAISE NOTICE 'OK P17 · el portal no lee datos de otras personas';
END $$;

-- P18 · El portal radica con el mismo consecutivo que Recepción (RN-009) y ve solo su comprobante
SELECT sgd.registrar_persona_portal('CC', '1.061.784.220', 'Otro Nombre') AS p_portal \gset
SELECT sgd.siguiente_consecutivo(:td_recibida, 2026) AS n2 \gset
INSERT INTO sgd.radicados (numero_radicado, tipo_documento_id, anio, consecutivo, tipo_tramite_id, canal, estado,
                           asunto, persona_id, correo_notificacion, autoriza_tratamiento_datos, fecha_autorizacion_datos,
                           plazo_dias_habiles, fecha_limite, semaforo)
VALUES ('2026-CR-' || lpad(:'n2', 5, '0'), :td_recibida, 2026, :n2, :tt_homologacion, 'portal_publico', 'recibido',
        'Solicitud desde el portal', :p_portal, 'laura@correo.com', true, now(),
        15, sgd.sumar_dias_habiles(current_date, 15), 'verde')
RETURNING numero_radicado AS num_r2 \gset
DO $$ DECLARE n integer; BEGIN
  SELECT count(*) INTO n FROM sgd.radicados;
  IF n <> 1 THEN RAISE EXCEPTION 'FALLO P18: el portal ve % radicados (debía ver solo el suyo)', n; END IF;
  RAISE NOTICE 'OK P18 · el portal radicó con el consecutivo siguiente y solo ve su propio comprobante';
END $$;

-- P19 · La persona existente se reutiliza sin que el portal le cambie los datos
SELECT set_config('prueba.p_laura', :'p_laura', true) AS c1,
       set_config('prueba.p_portal', :'p_portal', true) AS c2 \gset
DO $$ BEGIN
  IF current_setting('prueba.p_laura') <> current_setting('prueba.p_portal') THEN
    RAISE EXCEPTION 'FALLO P19: el portal creó una persona duplicada';
  END IF;
  RAISE NOTICE 'OK P19 · la cédula existente se reutilizó (sin duplicar ni modificar a la persona)';
END $$;

-- P20 · Consulta pública: número + cédula correctos → 1 fila; cédula ajena → 0
DO $$ DECLARE ok integer; mala integer; BEGIN
  SELECT count(*) INTO ok   FROM sgd.consultar_estado_publico(current_setting('prueba.num_r1'), '1.061.784.220');
  SELECT count(*) INTO mala FROM sgd.consultar_estado_publico(current_setting('prueba.num_r1'), '999999999');
  IF ok <> 1 OR mala <> 0 THEN RAISE EXCEPTION 'FALLO P20: correctos=% ajena=%', ok, mala; END IF;
  RAISE NOTICE 'OK P20 · la consulta pública exige número y cédula que coincidan';
END $$;

-- P21 · El portal no puede radicar como si fuera ventanilla
DO $$ BEGIN
  INSERT INTO sgd.radicados (numero_radicado, tipo_documento_id, anio, consecutivo, canal, estado, asunto)
  VALUES ('2026-CR-88888', 1, 2026, 88888, 'ventanilla', 'recibido', 'Canal falso');
  RAISE EXCEPTION 'FALLO P21: el portal radicó por ventanilla';
EXCEPTION WHEN insufficient_privilege THEN RAISE NOTICE 'OK P21 · el portal solo radica por el canal portal_publico';
END $$;

-- -----------------------------------------------------------------------------
-- Administrador y módulo de autenticación
-- -----------------------------------------------------------------------------
SELECT set_config('app.rol', 'administrador', true) AS ctx_rol,
       set_config('app.usuario_id', :'u_admin', true) AS ctx_usuario,
       set_config('app.dependencia_id', '', true) AS ctx_dependencia \gset
SELECT sgd.establecer_clave_temporal(:u_ing, '$2b$12$abcdefghijklmnopqrstuuv6XJ2nq0J5l0v7m5Qe4k1r3Tn8Wq1eC') AS clave_asignada \gset
\echo 'OK P22 · el Administrador asignó una contraseña temporal (hash bcrypt)'

RESET ROLE;
SET LOCAL ROLE sgd_auth;
DO $$ DECLARE n integer; BEGIN
  SELECT count(*) INTO n FROM sgd.credenciales_usuario WHERE debe_cambiar_clave;
  IF n <> 1 THEN RAISE EXCEPTION 'FALLO P23: sgd_auth vio % credenciales', n; END IF;
  RAISE NOTICE 'OK P23 · sgd_auth lee credenciales y exige cambio de clave';
END $$;
DO $$ BEGIN
  PERFORM 1 FROM sgd.radicados;
  RAISE EXCEPTION 'FALLO P24: sgd_auth leyó radicados';
EXCEPTION WHEN insufficient_privilege THEN RAISE NOTICE 'OK P24 · sgd_auth no ve radicados';
END $$;

-- -----------------------------------------------------------------------------
-- Supabase: la clave anónima no ve nada
-- -----------------------------------------------------------------------------
RESET ROLE;
DO $$ BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'anon') THEN
    RAISE NOTICE 'OMITIDA P25 · no existe el rol anon (base local)';
  END IF;
END $$;
SET LOCAL ROLE anon;
DO $$ BEGIN
  PERFORM 1 FROM sgd.radicados;
  RAISE EXCEPTION 'FALLO P25: anon leyó radicados';
EXCEPTION WHEN insufficient_privilege THEN RAISE NOTICE 'OK P25 · anon (clave pública de Supabase) no ve el esquema sgd';
END $$;

RESET ROLE;
ROLLBACK;
\echo 'Pruebas terminadas. Se hizo ROLLBACK: la base queda igual.'
