import { ArrowLeft } from "lucide-react";
import type { Metadata } from "next";
import { notFound } from "next/navigation";
import { FlujoComite } from "@/components/panel/flujo-comite";
import { EncabezadoPantalla } from "@/components/panel/marco-panel";
import { Aparecer } from "@/components/ui/aparecer";
import { BotonEnlace } from "@/components/ui/boton";
import { buscarRadicado } from "@/lib/datos-demo";

export const metadata: Metadata = { title: "Flujo de comité" };

export default async function Comite({ params }: PageProps<"/panel/radicados/[id]/comite">) {
  const { id } = await params;
  const radicado = buscarRadicado(decodeURIComponent(id));
  if (!radicado || !radicado.requiereComite) notFound();

  return (
    <>
      <EncabezadoPantalla
        titulo="Flujo de comité"
        objetivo="Trámites que dependen de la reunión mensual del comité, como el trabajo de grado."
        acciones={
          <BotonEnlace href={`/panel/radicados/${radicado.id}`} variante="fantasma" tamano="sm">
            <ArrowLeft aria-hidden />
            Volver
          </BotonEnlace>
        }
      />
      <Aparecer>
        <FlujoComite radicado={radicado} />
      </Aparecer>
    </>
  );
}
