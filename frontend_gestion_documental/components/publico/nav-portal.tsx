"use client";

import { FilePenLine, Home, Layers, ShieldCheck } from "lucide-react";
import Link from "next/link";
import { usePathname } from "next/navigation";
import { cn } from "@/lib/utils";

const ENLACES = [
  { href: "/", etiqueta: "Inicio", icono: Home },
  { href: "/radicar", etiqueta: "Nueva solicitud", icono: FilePenLine },
  { href: "/mis-tramites", etiqueta: "Mis trámites", icono: Layers },
];

export function NavPortal() {
  const ruta = usePathname();

  return (
    <div className="sticky top-0 z-30 px-3 pt-4 pb-2 sm:px-8">
      <nav
        aria-label="Portal de estudiantes"
        className="mx-auto flex max-w-[1180px] items-center gap-2 rounded-full border border-white/85 bg-white/60 py-2 pr-2 pl-3 shadow-cristal backdrop-blur-[22px] backdrop-saturate-[1.8] sm:gap-4 sm:pl-4"
      >
        <Link href="/" aria-label="Inicio del portal" className="grid size-9 shrink-0 place-items-center rounded-full bg-marca font-display text-[10px] font-extrabold text-white">
          SGD
        </Link>
        <ul className="flex flex-1 justify-center gap-0.5 sm:gap-1.5">
          {ENLACES.map(({ href, etiqueta, icono: Icono }) => {
            const activo = href === "/" ? ruta === "/" : ruta.startsWith(href);
            return (
              <li key={href}>
                <Link
                  href={href}
                  aria-current={activo ? "page" : undefined}
                  className={cn(
                    "flex items-center gap-2 rounded-full px-3 py-2.5 font-display text-[13px] font-semibold whitespace-nowrap transition-all sm:px-4",
                    activo ? "bg-white/90 text-marca shadow-[0_2px_8px_rgb(15_23_42/0.1)]" : "text-slate-700 hover:bg-white/60",
                  )}
                >
                  <Icono className="size-4 shrink-0" aria-hidden />
                  <span className="hidden sm:inline">{etiqueta}</span>
                  <span className="sr-only sm:hidden">{etiqueta}</span>
                </Link>
              </li>
            );
          })}
        </ul>
        <Link
          href="/login"
          className="inline-flex shrink-0 items-center gap-2 rounded-full bg-acento px-3.5 py-2.5 font-display text-[13px] font-bold text-sobre-acento transition-colors hover:bg-acento-hover sm:px-5"
        >
          <ShieldCheck className="size-4" aria-hidden />
          <span className="hidden sm:inline">Iniciar sesión</span>
          <span className="sr-only sm:hidden">Iniciar sesión (panel interno)</span>
        </Link>
      </nav>
    </div>
  );
}
