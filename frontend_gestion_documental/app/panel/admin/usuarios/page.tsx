"use client";

import { UserMinus, UserPlus } from "lucide-react";
import { useState } from "react";
import { EncabezadoPantalla } from "@/components/panel/marco-panel";
import { Boton } from "@/components/ui/boton";
import { Campo, Entrada, Seleccion } from "@/components/ui/campos";
import { DialogoConfirmar } from "@/components/ui/dialogo";
import { InsigniaEstado } from "@/components/ui/insignia";
import { notificar } from "@/components/ui/notificaciones";
import { TablaDatos } from "@/components/ui/tabla-datos";
import { DEPENDENCIAS, USUARIOS } from "@/lib/datos-demo";
import type { Usuario } from "@/lib/tipos";

const ROLES = ["Recepción / Ventanilla", "Dependencia", "Archivo Central", "Administrador"];

export default function GestionUsuarios() {
  const [usuarios, setUsuarios] = useState<Usuario[]>(USUARIOS);
  const [nuevo, setNuevo] = useState({ nombre: "", correo: "", rol: ROLES[1], dependencia: DEPENDENCIAS[0] });

  function crear() {
    if (!nuevo.nombre.trim() || !nuevo.correo.includes("@")) {
      notificar.error("Faltan datos", "Nombre y correo institucional son obligatorios.");
      return;
    }
    setUsuarios((u) => [{ nombre: nuevo.nombre, dependencia: nuevo.dependencia, rol: nuevo.rol, estado: "Activo" }, ...u]);
    notificar.exito("Usuario creado", `${nuevo.nombre} · ${nuevo.rol}`);
    setNuevo((n) => ({ ...n, nombre: "", correo: "" }));
  }

  function deshabilitar(nombre: string) {
    setUsuarios((u) => u.map((x) => (x.nombre === nombre ? { ...x, estado: "Deshabilitado" } : x)));
    notificar.aviso("Usuario deshabilitado", `${nombre} ya no puede ingresar. Su historial se conserva.`);
  }

  return (
    <>
      <EncabezadoPantalla
        titulo="Gestión de usuarios"
        objetivo="Quién tiene acceso al sistema y con qué rol. Los usuarios se deshabilitan, nunca se eliminan."
        acciones={
          <DialogoConfirmar
            titulo="Crear usuario"
            descripcion="El usuario recibirá su acceso institucional. Solo el Administrador puede crear usuarios (RN-004)."
            textoConfirmar="Crear usuario"
            alConfirmar={crear}
            disparador={
              <Boton tamano="sm">
                <UserPlus aria-hidden />
                Crear usuario
              </Boton>
            }
          >
            <div className="mb-5 grid gap-4">
              <Campo etiqueta="Nombre completo" htmlFor="u-nombre">
                <Entrada id="u-nombre" value={nuevo.nombre} onChange={(e) => setNuevo({ ...nuevo, nombre: e.target.value })} />
              </Campo>
              <Campo etiqueta="Correo institucional" htmlFor="u-correo">
                <Entrada id="u-correo" type="email" value={nuevo.correo} onChange={(e) => setNuevo({ ...nuevo, correo: e.target.value })} />
              </Campo>
              <div className="grid gap-4 sm:grid-cols-2">
                <Campo etiqueta="Rol" htmlFor="u-rol">
                  <Seleccion id="u-rol" value={nuevo.rol} onChange={(e) => setNuevo({ ...nuevo, rol: e.target.value })} opciones={ROLES} />
                </Campo>
                <Campo etiqueta="Dependencia" htmlFor="u-dep">
                  <Seleccion
                    id="u-dep"
                    value={nuevo.dependencia}
                    onChange={(e) => setNuevo({ ...nuevo, dependencia: e.target.value })}
                    opciones={DEPENDENCIAS}
                  />
                </Campo>
              </div>
            </div>
          </DialogoConfirmar>
        }
      />
      <TablaDatos
        filas={usuarios}
        clave={(u) => u.nombre}
        buscador="Buscar usuario"
        textoBusqueda={(u) => `${u.nombre} ${u.dependencia}`}
        filtros={[
          { etiqueta: "Rol", opciones: ROLES, valor: (u) => u.rol },
          { etiqueta: "Estado", opciones: ["Activo", "Deshabilitado"], valor: (u) => u.estado },
        ]}
        sustantivo="usuarios"
        columnas={[
          { titulo: "Nombre", celda: (u) => <span className="font-semibold">{u.nombre}</span> },
          { titulo: "Dependencia", celda: (u) => u.dependencia },
          { titulo: "Rol", celda: (u) => u.rol },
          { titulo: "Estado", celda: (u) => <InsigniaEstado estado={u.estado} /> },
          {
            titulo: "Acción",
            celda: (u) =>
              u.estado === "Activo" ? (
                <DialogoConfirmar
                  titulo={`Deshabilitar a ${u.nombre}`}
                  descripcion="Pierde el acceso de inmediato. Sus acciones pasadas siguen en la trazabilidad."
                  textoConfirmar="Deshabilitar"
                  peligroso
                  alConfirmar={() => deshabilitar(u.nombre)}
                  disparador={
                    <Boton variante="fantasma" tamano="sm">
                      <UserMinus aria-hidden />
                      Deshabilitar
                    </Boton>
                  }
                />
              ) : (
                <span className="text-xs text-tinta-suave">—</span>
              ),
          },
        ]}
      />
    </>
  );
}
