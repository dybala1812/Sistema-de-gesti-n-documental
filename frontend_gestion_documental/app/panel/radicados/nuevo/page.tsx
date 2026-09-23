"use client";

import { ArrowLeft, Stamp } from "lucide-react";
import { useRouter } from "next/navigation";
import { useState, type FormEvent } from "react";
import { EncabezadoPantalla } from "@/components/panel/marco-panel";
import { Aparecer } from "@/components/ui/aparecer";
import { Aviso } from "@/components/ui/bloques";
import { Boton, BotonEnlace } from "@/components/ui/boton";
import { AreaTexto, Campo, Entrada, Seleccion } from "@/components/ui/campos";
import { notificar } from "@/components/ui/notificaciones";
import { ZonaArchivos } from "@/components/ui/zona-archivos";
import { DEPENDENCIAS, HISTORIAL_PERSONA, TIPOS_CONSECUTIVO, TRAMITES_PORTAL } from "@/lib/datos-demo";
import { soloDigitos } from "@/lib/utils";

const MEDIOS = ["Ventanilla (físico)", "Correo electrónico", "Plataforma web", "Comunicación interna"];

function ahora() {
  return new Intl.DateTimeFormat("es-CO", { dateStyle: "medium", timeStyle: "short", timeZone: "America/Bogota" }).format(
    new Date(),
  );
}

export default function NuevaRadicacion() {
  const router = useRouter();
  const [nombre, setNombre] = useState("");
  const [fecha] = useState(ahora);
  const [errores, setErrores] = useState<Record<string, string>>({});

  // En el panel sí se prellenan los datos de una persona existente (RF-001).
  function buscarRemitente(cedula: string) {
    const persona = HISTORIAL_PERSONA[soloDigitos(cedula)];
    if (persona) {
      setNombre(persona.nombre);
      notificar.info("Remitente encontrado", `${persona.nombre} · ${persona.radicados.length} radicados anteriores`);
    }
  }

  function radicar(e: FormEvent<HTMLFormElement>) {
    e.preventDefault();
    const f = new FormData(e.currentTarget);
    const nuevos: Record<string, string> = {};
    if (!String(f.get("nombre")).trim()) nuevos.nombre = "Escribe el nombre del remitente.";
    if (soloDigitos(String(f.get("cedula"))).length < 6) nuevos.cedula = "Escribe una cédula o NIT válido.";
    if (!String(f.get("asunto")).trim()) nuevos.asunto = "Resume de qué trata la comunicación.";
    setErrores(nuevos);
    if (Object.keys(nuevos).length) return;

    notificar.exito("Radicado 2026-CR-01488 creado", "Se calculó el plazo según el tipo de trámite.");
    router.push("/panel/radicados/2026-CR-01487");
  }

  return (
    <>
      <EncabezadoPantalla
        titulo="Nueva radicación manual"
        objetivo="Radicar correspondencia física o digital que llega directo a ventanilla."
        acciones={
          <BotonEnlace href="/panel/radicados" variante="fantasma" tamano="sm">
            <ArrowLeft aria-hidden />
            Volver
          </BotonEnlace>
        }
      />
      <Aparecer>
        <form onSubmit={radicar} noValidate className="max-w-[740px] border border-borde bg-fondo px-5 py-7 sm:px-8">
          <Aviso icono={Stamp} className="mb-6">
            Al radicar, el sistema asigna el consecutivo automático y calcula el plazo de respuesta según el tipo de trámite.
          </Aviso>
          <div className="grid gap-5 sm:grid-cols-2">
            <Campo etiqueta="Tipo de consecutivo" htmlFor="consecutivo">
              <Seleccion id="consecutivo" name="consecutivo" opciones={TIPOS_CONSECUTIVO} />
            </Campo>
            <Campo etiqueta="Tipo de trámite" htmlFor="tramite">
              <Seleccion id="tramite" name="tramite" opciones={TRAMITES_PORTAL} />
            </Campo>
            <Campo etiqueta="Cédula / NIT" htmlFor="cedula" error={errores.cedula} ayuda="Si ya existe, se completan sus datos.">
              <Entrada id="cedula" name="cedula" inputMode="numeric" onBlur={(e) => buscarRemitente(e.target.value)} />
            </Campo>
            <Campo etiqueta="Nombre del remitente" htmlFor="nombre" error={errores.nombre}>
              <Entrada id="nombre" name="nombre" value={nombre} onChange={(e) => setNombre(e.target.value)} />
            </Campo>
            <Campo etiqueta="Dependencia destinataria" htmlFor="dependencia">
              <Seleccion id="dependencia" name="dependencia" opciones={DEPENDENCIAS} />
            </Campo>
            <Campo etiqueta="Medio de recepción" htmlFor="medio">
              <Seleccion id="medio" name="medio" opciones={MEDIOS} />
            </Campo>
            <Campo
              etiqueta="Fecha y hora de radicación"
              htmlFor="fecha"
              ayuda="Autogenerada; editable si es radicación tardía de un documento físico."
              className="sm:col-span-2"
            >
              <Entrada id="fecha" name="fecha" defaultValue={fecha} />
            </Campo>
            <div className="sm:col-span-2">
              <ZonaArchivos etiqueta="Documento" />
            </div>
            <Campo etiqueta="Asunto" htmlFor="asunto" error={errores.asunto} className="sm:col-span-2">
              <AreaTexto id="asunto" name="asunto" placeholder="Resumen de la comunicación" />
            </Campo>
          </div>
          <div className="mt-7 flex flex-wrap gap-2 border-t border-borde pt-5">
            <Boton type="submit">
              <Stamp aria-hidden />
              Radicar
            </Boton>
            <BotonEnlace href="/panel/radicados" variante="secundario">
              Cancelar
            </BotonEnlace>
          </div>
        </form>
      </Aparecer>
    </>
  );
}
