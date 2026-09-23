"use client";

import { ArrowRight } from "lucide-react";
import Link from "next/link";
import { EncabezadoPantalla } from "@/components/panel/marco-panel";
import { useRolDemo } from "@/components/panel/sesion-demo";
import { Aparecer } from "@/components/ui/aparecer";
import { ETIQUETA_ROL, MENUS, USUARIO_DEMO } from "@/lib/navegacion";

export default function InicioPanel() {
  const rol = useRolDemo();
  const usuario = USUARIO_DEMO[rol];

  return (
    <>
      <EncabezadoPantalla
        titulo={`Hola, ${usuario.nombre.split(" ")[0]}`}
        objetivo={`${ETIQUETA_ROL[rol]} · ${usuario.detalle}. Estas son las secciones de tu rol.`}
      />
      {MENUS[rol].map((grupo, gi) => (
        <section key={grupo.titulo ?? gi} aria-labelledby={`grupo-inicio-${gi}`} className="mb-8">
          <h2
            id={`grupo-inicio-${gi}`}
            className="mb-3 font-display text-[11px] font-bold tracking-[0.12em] text-tinta-suave uppercase"
          >
            {grupo.titulo ?? "Secciones"}
          </h2>
          <Aparecer key={rol} como="ul" className="grid gap-3 sm:grid-cols-2 xl:grid-cols-3">
            {grupo.items.map((item) => (
              <li key={item.href} data-aparecer>
                <Link
                  href={item.href}
                  className="group flex h-full items-start gap-4 border border-borde bg-fondo px-5 py-5 transition-[border-color,box-shadow] hover:border-acento hover:shadow-flotante"
                >
                  <span className="grid size-10 shrink-0 place-items-center bg-fondo-sutil text-marca transition-colors group-hover:bg-acento group-hover:text-sobre-acento">
                    <item.icono className="size-5" aria-hidden />
                  </span>
                  <span className="min-w-0 flex-1">
                    <span className="block font-display text-[15px] font-semibold text-marca">{item.etiqueta}</span>
                    <span className="mt-1 block text-[13px] leading-relaxed text-tinta-suave">{item.descripcion}</span>
                  </span>
                  <ArrowRight
                    className="mt-1 size-4 shrink-0 text-tinta-suave transition-transform group-hover:translate-x-1 group-hover:text-marca"
                    aria-hidden
                  />
                </Link>
              </li>
            ))}
          </Aparecer>
        </section>
      ))}
    </>
  );
}
