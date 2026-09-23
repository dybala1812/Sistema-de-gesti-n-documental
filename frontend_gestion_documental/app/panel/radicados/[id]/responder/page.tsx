import { ArrowLeft } from "lucide-react";
import type { Metadata } from "next";
import { notFound } from "next/navigation";
import { FormularioRespuesta } from "@/components/panel/formulario-respuesta";
import { EncabezadoPantalla } from "@/components/panel/marco-panel";
import { Aparecer } from "@/components/ui/aparecer";
import { BotonEnlace } from "@/components/ui/boton";
import { buscarRadicado } from "@/lib/datos-demo";

export const metadata: Metadata = { title: "Responder radicado" };

export default async function Responder({ params, searchParams }: PageProps<"/panel/radicados/[id]/responder">) {
  const { id } = await params;
  const { decision } = await searchParams;
  const radicado = buscarRadicado(decodeURIComponent(id));
  if (!radicado) notFound();

  return (
    <>
      <EncabezadoPantalla
        titulo="Formulario de respuesta"
        objetivo="Generar la respuesta y enviarla a verificación."
        acciones={
          <BotonEnlace href={`/panel/radicados/${radicado.id}`} variante="fantasma" tamano="sm">
            <ArrowLeft aria-hidden />
            Volver
          </BotonEnlace>
        }
      />
      <Aparecer>
        <FormularioRespuesta radicado={radicado} decision={typeof decision === "string" ? decision : undefined} />
      </Aparecer>
    </>
  );
}
