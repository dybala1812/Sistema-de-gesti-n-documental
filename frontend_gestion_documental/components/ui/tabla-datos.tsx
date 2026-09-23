"use client";

import { SearchX } from "lucide-react";
import { useRouter } from "next/navigation";
import { useMemo, useState, type ReactNode } from "react";
import { cn } from "@/lib/utils";
import { Aparecer } from "./aparecer";
import { Boton } from "./boton";
import { EstadoVacio } from "./bloques";

export interface Columna<T> {
  titulo: string;
  celda: (fila: T) => ReactNode;
  clase?: string;
}

export interface Filtro<T> {
  etiqueta: string;
  opciones: string[];
  valor: (fila: T) => string;
}

const POR_PAGINA = 8;

/**
 * Tabla del panel interno con buscador, filtros combinados y paginación.
 * Con datos reales, búsqueda, filtros y paginación los resuelve la API (RNF-001).
 */
export function TablaDatos<T>({
  filas,
  columnas,
  clave,
  enlace,
  buscador,
  textoBusqueda,
  filtros = [],
  sustantivo = "registros",
  encabezado,
}: {
  filas: T[];
  columnas: Columna<T>[];
  clave: (fila: T) => string;
  enlace?: (fila: T) => string | undefined;
  buscador?: string;
  textoBusqueda?: (fila: T) => string;
  filtros?: Filtro<T>[];
  sustantivo?: string;
  encabezado?: ReactNode;
}) {
  const router = useRouter();
  const [busqueda, setBusqueda] = useState("");
  const [seleccion, setSeleccion] = useState<Record<string, string>>({});
  const [pagina, setPagina] = useState(0);

  const visibles = useMemo(() => {
    const q = busqueda.trim().toLowerCase();
    return filas.filter((f) => {
      if (q && textoBusqueda && !textoBusqueda(f).toLowerCase().includes(q)) return false;
      return filtros.every((flt) => !seleccion[flt.etiqueta] || flt.valor(f) === seleccion[flt.etiqueta]);
    });
  }, [filas, busqueda, seleccion, filtros, textoBusqueda]);

  const totalPaginas = Math.max(1, Math.ceil(visibles.length / POR_PAGINA));
  const paginaActual = Math.min(pagina, totalPaginas - 1);
  const desde = paginaActual * POR_PAGINA;
  const pagFilas = visibles.slice(desde, desde + POR_PAGINA);

  return (
    <div className="border border-borde bg-fondo">
      {(buscador || filtros.length > 0 || encabezado) && (
        <div className="flex flex-wrap items-center gap-2 border-b border-borde px-4 py-4">
          {buscador && (
            <input
              type="search"
              aria-label={buscador}
              placeholder={buscador}
              value={busqueda}
              onChange={(e) => {
                setBusqueda(e.target.value);
                setPagina(0);
              }}
              className="min-w-50 flex-[1_1_240px] border border-borde-campo px-3 py-2.5 text-[13px] placeholder:text-tinta-suave"
            />
          )}
          {filtros.map((flt) => (
            <select
              key={flt.etiqueta}
              aria-label={flt.etiqueta}
              value={seleccion[flt.etiqueta] ?? ""}
              onChange={(e) => {
                setSeleccion((s) => ({ ...s, [flt.etiqueta]: e.target.value }));
                setPagina(0);
              }}
              className="cursor-pointer border border-borde-campo bg-fondo px-2.5 py-2.5 text-xs text-tinta-suave"
            >
              <option value="">{flt.etiqueta}: todos</option>
              {flt.opciones.map((o) => (
                <option key={o}>{o}</option>
              ))}
            </select>
          ))}
          {encabezado}
        </div>
      )}

      {pagFilas.length === 0 ? (
        <div className="p-4">
          <EstadoVacio
            icono={SearchX}
            titulo={`No se encontraron ${sustantivo}`}
            descripcion="Prueba con otros filtros o revisa lo que escribiste."
          />
        </div>
      ) : (
        <div className="overflow-x-auto">
          <table className="w-full border-collapse text-[13px]">
            <thead>
              <tr>
                {columnas.map((c) => (
                  <th
                    key={c.titulo}
                    scope="col"
                    className="whitespace-nowrap border-b border-borde bg-fondo-alt px-4 py-3 text-left font-display text-[11px] font-semibold uppercase tracking-[0.09em] text-tinta-suave"
                  >
                    {c.titulo}
                  </th>
                ))}
              </tr>
            </thead>
            <Aparecer como="tbody" key={`${paginaActual}-${visibles.length}`}>
                {pagFilas.map((f) => {
                  const destino = enlace?.(f);
                  return (
                    <tr
                      key={clave(f)}
                      data-aparecer
                      onClick={destino ? () => router.push(destino) : undefined}
                      className={cn(
                        "border-b border-fondo-sutil",
                        destino && "cursor-pointer transition-colors hover:bg-fondo-alt",
                      )}
                    >
                      {columnas.map((c) => (
                        <td key={c.titulo} className={cn("px-4 py-3 text-tinta", c.clase)}>
                          {c.celda(f)}
                        </td>
                      ))}
                    </tr>
                  );
                })}
            </Aparecer>
          </table>
        </div>
      )}

      <div className="flex flex-wrap items-center justify-between gap-3 border-t border-borde px-4 py-3 text-xs text-tinta-suave">
        <span>
          {visibles.length === 0
            ? `0 ${sustantivo}`
            : `${desde + 1}–${desde + pagFilas.length} de ${visibles.length} ${sustantivo}`}
        </span>
        <div className="flex gap-1.5">
          <Boton variante="secundario" tamano="sm" disabled={paginaActual === 0} onClick={() => setPagina(paginaActual - 1)}>
            Anterior
          </Boton>
          <Boton
            variante="secundario"
            tamano="sm"
            disabled={paginaActual >= totalPaginas - 1}
            onClick={() => setPagina(paginaActual + 1)}
          >
            Siguiente
          </Boton>
        </div>
      </div>
    </div>
  );
}

/** Celda del consecutivo: enlace real para que la fila sea navegable con teclado. */
export function CeldaConsecutivo({ texto, href }: { texto: string; href?: string }) {
  const clase = "whitespace-nowrap font-display font-bold text-tinta";
  if (!href) return <span className={clase}>{texto}</span>;
  return (
    <a href={href} onClick={(e) => e.stopPropagation()} className={cn(clase, "hover:text-info hover:underline")}>
      {texto}
    </a>
  );
}
