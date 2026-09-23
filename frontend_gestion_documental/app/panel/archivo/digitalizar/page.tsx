import { Flag } from "lucide-react";
import type { Metadata } from "next";
import { FormularioArchivo } from "@/components/panel/formulario-archivo";
import { EncabezadoPantalla } from "@/components/panel/marco-panel";
import { Aparecer } from "@/components/ui/aparecer";
import { Aviso } from "@/components/ui/bloques";
import { Campo, Entrada } from "@/components/ui/campos";
import { ZonaArchivos } from "@/components/ui/zona-archivos";

export const metadata: Metadata = { title: "Digitalizar documentos físicos" };

export default function Digitalizar() {
  return (
    <>
      <EncabezadoPantalla
        titulo="Digitalizar documentos físicos"
        objetivo="Subir documentos que hoy solo existen en papel y vincularlos a su expediente."
      />
      <Aviso tono="acento" icono={Flag} className="mb-5 max-w-[740px]">
        Propuesta de la maquetación a confirmar: la migración masiva del archivo histórico está fuera del alcance del F-02.
      </Aviso>
      <Aparecer>
        <FormularioArchivo
          nota="Los archivos escaneados quedan vinculados al expediente y se registra dónde está guardado el original en papel."
          textoGuardar="Subir y clasificar"
          mensajeExito="Documentos digitalizados"
          volver="/panel/archivo/expedientes"
        >
          <div className="sm:col-span-2">
            <ZonaArchivos etiqueta="Documentos escaneados" ayuda="PDF o imagen · puedes subir varios archivos a la vez" />
          </div>
          <Campo etiqueta="Fecha del documento original" htmlFor="fecha-original">
            <Entrada id="fecha-original" type="date" />
          </Campo>
          <Campo etiqueta="Ubicación física del original" htmlFor="ubicacion" ayuda="Para encontrar el papel si se necesita.">
            <Entrada id="ubicacion" placeholder="Caja 14 · Carpeta 3 · Estante B" />
          </Campo>
        </FormularioArchivo>
      </Aparecer>
    </>
  );
}
