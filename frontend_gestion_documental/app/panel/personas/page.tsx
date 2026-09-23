"use client";

import { Search, UserRound, UserX } from "lucide-react";
import { useState, type FormEvent } from "react";
import { EncabezadoPantalla } from "@/components/panel/marco-panel";
import { Aparecer } from "@/components/ui/aparecer";
import { EstadoVacio } from "@/components/ui/bloques";
import { Boton } from "@/components/ui/boton";
import { Entrada } from "@/components/ui/campos";
import { InsigniaEstado } from "@/components/ui/insignia";
import { CeldaConsecutivo, TablaDatos } from "@/components/ui/tabla-datos";
import { buscarRadicado, HISTORIAL_PERSONA } from "@/lib/datos-demo";
import { soloDigitos } from "@/lib/utils";

export default function BuscarPersona() {
  const [cedula, setCedula] = useState("");
  const [buscada, setBuscada] = useState<string | null>(null);
  const persona = buscada ? HISTORIAL_PERSONA[buscada] : undefined;

  function buscar(e: FormEvent) {
    e.preventDefault();
    setBuscada(soloDigitos(cedula));
  }

  return (
    <>
      <EncabezadoPantalla titulo="Buscar por cédula" objetivo="Historial documental completo de una persona." />
      {/* La cédula viaja en el cuerpo de la petición, nunca en la URL (Ley 1581). */}
      <form onSubmit={buscar} className="mb-5 flex max-w-[640px] flex-wrap gap-2" role="search">
        <label htmlFor="cedula-buscar" className="sr-only">
          Cédula
        </label>
        <Entrada
          id="cedula-buscar"
          inputMode="numeric"
          placeholder="Cédula — p. ej. 1.061.784.220"
          value={cedula}
          onChange={(e) => setCedula(e.target.value)}
          className="flex-[1_1_260px]"
        />
        <Boton type="submit" tamano="lg">
          <Search aria-hidden />
          Buscar
        </Boton>
      </form>

      <div aria-live="polite">
        {buscada === null && (
          <EstadoVacio punteado icono={Search} titulo="Escribe una cédula" descripcion="Prueba en la demo con 1061784220." />
        )}
        {buscada !== null && !persona && (
          <EstadoVacio
            icono={UserX}
            titulo="No hay una persona con esa cédula"
            descripcion="Puedes registrarla al radicar su primera comunicación."
          />
        )}
        {persona && (
          <Aparecer key={buscada}>
            <p data-aparecer className="mb-3 flex items-center gap-2 text-[13px] text-tinta-suave">
              <UserRound className="size-4" aria-hidden />
              <strong className="text-tinta">{persona.nombre}</strong> · {buscada} · {persona.radicados.length} radicados
            </p>
            <div data-aparecer>
              <TablaDatos
                filas={persona.radicados}
                clave={(r) => r.id}
                enlace={(r) => (buscarRadicado(r.id) ? `/panel/radicados/${r.id}` : undefined)}
                sustantivo="radicados"
                columnas={[
                  { titulo: "Consecutivo", celda: (r) => <CeldaConsecutivo texto={r.numero} /> },
                  { titulo: "Tipo", celda: (r) => r.tipoTramite },
                  { titulo: "Dependencia", celda: (r) => r.dependencia },
                  { titulo: "Estado", celda: (r) => <InsigniaEstado estado={r.estado} /> },
                  { titulo: "Fecha", celda: (r) => r.fecha, clase: "whitespace-nowrap" },
                ]}
              />
            </div>
          </Aparecer>
        )}
      </div>
    </>
  );
}
