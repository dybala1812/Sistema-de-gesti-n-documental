"use client";

import * as Popover from "@radix-ui/react-popover";
import gsap from "gsap";
import { Bell, BellRing, LayoutGrid, List, LoaderCircle, LogOut, Menu, ShieldAlert, X } from "lucide-react";
import Link from "next/link";
import { usePathname, useRouter } from "next/navigation";
import { useEffect, useRef, useState, type ReactNode } from "react";
import { alertasDelRol, UNIVERSIDAD } from "@/lib/datos-demo";
import { ETIQUETA_ROL, MENUS, USUARIO_DEMO } from "@/lib/navegacion";
import { BotonEnlace } from "@/components/ui/boton";
import type { Alerta, Rol } from "@/lib/tipos";
import { cn } from "@/lib/utils";
import { notificar } from "@/components/ui/notificaciones";
import { cerrarSesionDemo, useSesionDemo } from "./sesion-demo";

const COLOR_GRUPO: Record<Alerta["grupo"], string> = {
  hoy: "bg-acento",
  semana: "bg-info",
  vencido: "bg-peligro",
};

const TEXTO_GRUPO: Record<Alerta["grupo"], string> = {
  hoy: "text-acento-oscuro",
  semana: "text-info",
  vencido: "text-peligro",
};

function Logo() {
  return (
    <span
      aria-hidden
      className="grid size-9 shrink-0 place-items-center bg-marca font-display text-xs font-extrabold tracking-wider text-white"
    >
      SGD
    </span>
  );
}

function PanelAlertas({ destino, alertas }: { destino: string; alertas: Alerta[] }) {
  const campana = useRef<SVGSVGElement>(null);

  useEffect(() => {
    if (!campana.current || window.matchMedia("(prefers-reduced-motion: reduce)").matches) return;
    const tween = gsap.fromTo(
      campana.current,
      { rotate: -14 },
      { rotate: 0, duration: 0.9, ease: "elastic.out(1.2, 0.25)", transformOrigin: "50% 0%", delay: 0.4 },
    );
    return () => {
      tween.kill();
    };
  }, []);

  return (
    <Popover.Root>
      <Popover.Trigger
        className="flex items-center gap-2 border border-transparent px-2.5 py-2 text-xs text-tinta-suave transition-colors hover:bg-fondo data-[state=open]:border-acento data-[state=open]:bg-acento-claro"
        aria-label={`Alertas de vencimiento: ${alertas.length}`}
      >
        <Bell ref={campana} className="size-4" aria-hidden />
        <span className="hidden sm:inline">Alertas</span>
        <span className="bg-acento/25 px-1.5 text-[11px] font-bold text-acento-oscuro">{alertas.length}</span>
      </Popover.Trigger>
      <Popover.Portal>
        <Popover.Content
          align="end"
          sideOffset={8}
          className="z-30 w-[min(400px,calc(100vw-32px))] border border-borde bg-fondo shadow-flotante data-[state=open]:animate-[emerger_160ms_ease-out]"
        >
          <div className="flex items-center gap-2.5 border-b border-borde px-4 py-3.5">
            <span className="inline-flex items-center gap-2 font-display text-[13px] font-bold text-marca">
              <BellRing className="size-4" aria-hidden />
              Panel de vencimientos
            </span>
            <span className="ml-auto text-[11px] text-tinta-suave">{alertas.length} radicados</span>
          </div>
          <ul>
            {alertas.map((a) => (
              <li key={a.numero}>
                <Popover.Close asChild>
                  <Link
                    href={`/panel/radicados/${a.radicadoId}`}
                    className="flex items-center gap-3 border-b border-fondo-sutil px-4 py-3 hover:bg-fondo-alt"
                  >
                    <span aria-hidden className={cn("size-2 shrink-0", COLOR_GRUPO[a.grupo])} />
                    <span className="min-w-0 flex-1">
                      <span className="block font-display text-[12.5px] font-bold text-tinta">{a.numero}</span>
                      <span className="mt-0.5 block text-[11.5px] text-tinta-suave">
                        {a.tipoTramite} · {a.dependencia}
                      </span>
                    </span>
                    <span className={cn("shrink-0 font-display text-[11.5px] font-bold", TEXTO_GRUPO[a.grupo])}>
                      {a.plazo}
                    </span>
                  </Link>
                </Popover.Close>
              </li>
            ))}
          </ul>
          <Popover.Close asChild>
            <Link
              href={destino}
              className="flex w-full items-center gap-2 border-t border-borde bg-fondo-alt px-4 py-3 font-display text-xs font-semibold text-marca hover:bg-fondo-sutil"
            >
              <List className="size-4" aria-hidden />
              Ver todas las alertas de vencimiento
            </Link>
          </Popover.Close>
        </Popover.Content>
      </Popover.Portal>
    </Popover.Root>
  );
}

/** Sin sesión de demostración no se muestra el panel: se envía al login. */
export function MarcoPanel({ children }: { children: ReactNode }) {
  const sesion = useSesionDemo();
  const router = useRouter();

  useEffect(() => {
    if (sesion === "sin-sesion") router.replace("/login");
  }, [sesion, router]);

  if (sesion === "cargando" || sesion === "sin-sesion") {
    return (
      <div className="grid min-h-screen place-items-center bg-fondo-alt text-[13px] text-tinta-suave" role="status">
        <span className="inline-flex items-center gap-2">
          <LoaderCircle className="size-4 animate-spin" aria-hidden />
          {sesion === "cargando" ? "Cargando…" : "Redirigiendo al inicio de sesión…"}
        </span>
      </div>
    );
  }

  return <MarcoConSesion rol={sesion}>{children}</MarcoConSesion>;
}

function MarcoConSesion({ rol, children }: { rol: Rol; children: ReactNode }) {
  const ruta = usePathname();
  const router = useRouter();
  const [menuAbierto, setMenuAbierto] = useState(false);
  const usuario = USUARIO_DEMO[rol];
  const grupos = MENUS[rol];
  const todas = grupos.flatMap((g) => g.items.map((i) => i.href));
  // El ítem activo es el prefijo más largo que coincide con la ruta.
  const activo = todas.filter((h) => ruta === h || ruta.startsWith(`${h}/`)).sort((a, b) => b.length - a.length)[0];
  // Las fichas de radicado se abren desde bandejas, alertas y búsquedas de cualquier rol.
  const esFicha = /^\/panel\/radicados\/(?!nuevo$)[^/]+/.test(ruta);
  const permitido = ruta === "/panel" || activo !== undefined || esFicha;

  function salir() {
    cerrarSesionDemo();
    notificar.info("Sesión cerrada");
    router.push("/login");
  }

  const menu = (
    <nav aria-label="Módulos">
      <Link
        href="/panel"
        onClick={() => setMenuAbierto(false)}
        aria-current={ruta === "/panel" ? "page" : undefined}
        className={cn(
          "mb-3 flex items-center gap-2.5 border-l-2 px-3 py-2.5 text-[13px] transition-colors",
          ruta === "/panel"
            ? "border-acento bg-fondo-sutil font-semibold text-tinta"
            : "border-transparent text-tinta-suave hover:bg-fondo-sutil hover:text-tinta",
        )}
      >
        <LayoutGrid className="size-4 shrink-0" aria-hidden />
        Inicio
      </Link>
      {grupos.map((g, gi) => (
        <div key={g.titulo ?? gi} className="mt-3 border-t border-borde pt-3">
          {g.titulo && (
            <p className="px-2.5 pt-2 pb-2.5 font-display text-[11px] font-bold uppercase tracking-[0.12em] text-tinta-suave">
              {g.titulo}
            </p>
          )}
          <ul className="flex flex-col gap-0.5">
            {g.items.map((item) => {
              const esActivo = item.href === activo;
              return (
                <li key={item.href}>
                  <Link
                    href={item.href}
                    onClick={() => setMenuAbierto(false)}
                    aria-current={esActivo ? "page" : undefined}
                    className={cn(
                      "flex items-center gap-2.5 border-l-2 px-3 py-2.5 text-[13px] transition-colors",
                      esActivo
                        ? "border-acento bg-fondo-sutil font-semibold text-tinta"
                        : "border-transparent text-tinta-suave hover:bg-fondo-sutil hover:text-tinta",
                    )}
                  >
                    <item.icono className="size-4 shrink-0" aria-hidden />
                    {item.etiqueta}
                  </Link>
                </li>
              );
            })}
          </ul>
        </div>
      ))}
    </nav>
  );

  return (
    <div className="flex min-h-screen flex-col">
      <header className="sticky top-0 z-20 flex h-[62px] shrink-0 items-center gap-3 border-b border-tinta/12 bg-fondo-sutil px-4 md:px-6">
        <button
          type="button"
          className="p-1.5 text-tinta md:hidden"
          aria-label={menuAbierto ? "Cerrar menú" : "Abrir menú"}
          aria-expanded={menuAbierto}
          onClick={() => setMenuAbierto((v) => !v)}
        >
          {menuAbierto ? <X className="size-5" /> : <Menu className="size-5" />}
        </button>
        <Logo />
        <div className="hidden leading-tight sm:block">
          <p className="font-display text-[13px] font-semibold text-marca">{UNIVERSIDAD}</p>
          <p className="text-[11px] text-tinta-suave">Sistema de Gestión Documental</p>
        </div>
        <div className="ml-auto flex items-center gap-3 md:gap-4">
          {rol !== "administrador" && rol !== "archivo_central" && <PanelAlertas destino="/panel/alertas" alertas={alertasDelRol(rol)} />}
          <span aria-hidden className="hidden h-6 w-px bg-tinta/15 sm:block" />
          <div className="hidden text-right leading-tight sm:block">
            <p className="text-xs font-semibold text-tinta">{usuario.nombre}</p>
            <p className="text-[11px] text-tinta-suave">{usuario.detalle}</p>
          </div>
          <button
            type="button"
            onClick={salir}
            className="inline-flex items-center gap-2 border border-tinta/20 px-3 py-2 text-[11px] font-medium text-tinta-suave hover:bg-fondo hover:text-tinta"
          >
            <LogOut className="size-3.5" aria-hidden />
            <span className="hidden sm:inline">Cerrar sesión</span>
          </button>
        </div>
      </header>

      <div className="flex flex-1">
        <aside className="hidden w-[238px] shrink-0 border-r border-tinta/12 bg-fondo-alt px-3 py-5 md:block">{menu}</aside>
        {menuAbierto && (
          <div className="fixed inset-x-0 top-[62px] bottom-0 z-10 overflow-y-auto border-t border-borde bg-fondo-alt px-3 py-4 animate-[aparecer_150ms_ease-out] md:hidden">
            {menu}
          </div>
        )}
        <main id="contenido" className="min-w-0 flex-1 px-4 pt-6 pb-11 md:px-8">
          {permitido ? (
            children
          ) : (
            <div className="max-w-[560px] border border-borde bg-fondo px-6 py-8">
              <ShieldAlert className="mb-3 size-6 text-peligro" aria-hidden />
              <h1 className="mb-2 font-display text-lg font-bold text-marca">Esta sección no es de tu rol</h1>
              <p className="mb-5 text-[13px] leading-relaxed text-tinta-suave">
                {ETIQUETA_ROL[rol]} no tiene acceso a esta pantalla. En el sistema real, la API también la bloquea.
              </p>
              <BotonEnlace href="/panel">
                <LayoutGrid aria-hidden />
                Ir a mi inicio
              </BotonEnlace>
            </div>
          )}
        </main>
      </div>
    </div>
  );
}

export function EncabezadoPantalla({
  titulo,
  objetivo,
  acciones,
}: {
  titulo: string;
  objetivo?: string;
  acciones?: ReactNode;
}) {
  return (
    <div className="mb-5 flex flex-wrap items-end gap-4">
      <div className="min-w-0">
        <h1 className="font-display text-[22px] font-bold tracking-tight text-marca">{titulo}</h1>
        {objetivo && <p className="mt-1 text-[13px] text-tinta-suave">{objetivo}</p>}
      </div>
      {acciones && <div className="ml-auto flex flex-wrap gap-2">{acciones}</div>}
    </div>
  );
}
