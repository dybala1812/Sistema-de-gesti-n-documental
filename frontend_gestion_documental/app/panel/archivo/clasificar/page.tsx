import type { Metadata } from "next";
import { FormularioArchivo } from "@/components/panel/formulario-archivo";
import { EncabezadoPantalla } from "@/components/panel/marco-panel";
import { Aparecer } from "@/components/ui/aparecer";
import { Campo, Entrada } from "@/components/ui/campos";
import { POR_CLASIFICAR } from "@/lib/datos-demo";

export const metadata: Metadata = { title: "Clasificación de expediente" };

export default async function Clasificar({ searchParams }: PageProps<"/panel/archivo/clasificar">) {
  const { doc } = await searchParams;
  const documento = POR_CLASIFICAR.find((d) => d.numero === doc) ?? POR_CLASIFICAR[0];

  return (
    <>
      <EncabezadoPantalla titulo="Clasificación de expediente" objetivo="Aplicar la Tabla de Retención Documental (TRD) a un documento." />
      <Aparecer>
        <FormularioArchivo
          nota="Las series y subseries provienen de la Tabla de Retención Documental vigente."
          textoGuardar="Guardar clasificación"
          mensajeExito="Clasificación guardada"
          volver="/panel/archivo/por-clasificar"
        >
          <Campo etiqueta="Documento" htmlFor="documento" className="sm:col-span-2">
            <Entrada id="documento" readOnly value={`${documento.numero} · ${documento.tipo} · ${documento.dependencia}`} />
          </Campo>
        </FormularioArchivo>
      </Aparecer>
    </>
  );
}
