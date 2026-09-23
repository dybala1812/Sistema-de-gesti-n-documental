import { NavPortal } from "@/components/publico/nav-portal";
import { UNIVERSIDAD } from "@/lib/datos-demo";

export default function LayoutPortal({ children }: { children: React.ReactNode }) {
  return (
    <div className="flex min-h-screen flex-col bg-fondo">
      <NavPortal />
      <main id="contenido" className="flex-1">
        {children}
      </main>
      <footer className="border-t border-tinta/12 bg-fondo-alt">
        <div className="mx-auto flex max-w-[1180px] flex-wrap items-center justify-between gap-2 px-4 py-6 text-xs text-tinta-suave sm:px-11">
          <span>{UNIVERSIDAD} · Sistema de Gestión Documental</span>
          <span>Tus datos se tratan conforme a la Ley 1581 de 2012.</span>
        </div>
      </footer>
    </div>
  );
}
