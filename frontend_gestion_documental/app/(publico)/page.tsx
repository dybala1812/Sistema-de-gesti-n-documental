import { ArrowRight, FilePenLine, Mail, Paperclip, Search, Stamp } from "lucide-react";
import { Contador } from "@/components/publico/contador";
import { Aparecer } from "@/components/ui/aparecer";
import { Antetitulo } from "@/components/ui/bloques";
import { BotonEnlace } from "@/components/ui/boton";
import { TRAMITES_PORTAL } from "@/lib/datos-demo";

const PASOS = [
  {
    n: 1,
    icono: FilePenLine,
    titulo: "Diligencia tu solicitud",
    texto: "Elige el tipo de trámite y escribe qué necesitas. No tienes que crear cuenta ni iniciar sesión.",
  },
  {
    n: 2,
    icono: Paperclip,
    titulo: "Adjunta tus soportes",
    texto: "Sube tus documentos en PDF o imagen. Paquetes grandes, como homologaciones, hasta 100 MB.",
  },
  {
    n: 3,
    icono: Stamp,
    titulo: "Recibe tu número de radicado",
    texto: "Queda registrado con consecutivo y plazo, igual que en ventanilla. La respuesta llega a tu correo.",
  },
];

export default function InicioPortal() {
  return (
    <>
      <section className="mx-auto grid max-w-[1180px] items-start gap-10 px-4 pt-12 pb-14 sm:px-11 md:grid-cols-[1.15fr_0.85fr] md:gap-14 md:pt-16">
        <Aparecer>
          <div data-aparecer>
            <Antetitulo className="mb-5">Portal de estudiantes</Antetitulo>
          </div>
          <h1
            data-aparecer
            className="mb-4 font-display text-4xl leading-[1.1] font-extrabold tracking-tight text-balance text-marca md:text-[46px]"
          >
            Radica tu solicitud sin ir a ventanilla
          </h1>
          <p data-aparecer className="mb-8 max-w-[520px] text-base leading-relaxed text-pretty text-tinta-suave">
            Reingreso, reintegro de dinero, homologación, trabajo de grado o tutela. Adjuntas tus documentos, recibes un
            número de radicado y la respuesta llega a tu correo.
          </p>
          <dl data-aparecer className="flex flex-wrap gap-7">
            <div className="flex flex-col-reverse border-l-2 border-acento pl-3.5">
              <dt className="mt-0.5 text-xs text-tinta-suave">para radicar tu solicitud</dt>
              <dd className="font-display text-[22px] font-extrabold text-tinta">
                <Contador valor={5} sufijo=" min" />
              </dd>
            </div>
            <div className="flex flex-col-reverse border-l-2 border-acento pl-3.5">
              <dt className="mt-0.5 text-xs text-tinta-suave">tamaño máximo por envío</dt>
              <dd className="font-display text-[22px] font-extrabold text-tinta">
                <Contador valor={100} sufijo=" MB" />
              </dd>
            </div>
            <div className="flex flex-col-reverse border-l-2 border-acento pl-3.5">
              <dt className="mt-0.5 text-xs text-tinta-suave">días hábiles como máximo para responder</dt>
              <dd className="font-display text-[22px] font-extrabold text-tinta">
                <Contador valor={15} />
              </dd>
            </div>
          </dl>
        </Aparecer>

        <Aparecer retardo={0.15} className="border border-borde bg-fondo">
          <div aria-hidden className="grid h-[150px] place-items-center bg-marca">
            <Stamp className="size-14 text-acento" strokeWidth={1.4} />
          </div>
          <div className="px-6 pt-6 pb-7 sm:px-8">
            <h2 className="mb-1.5 font-display text-lg font-bold text-marca">¿Qué necesitas hacer?</h2>
            <p className="mb-5 text-[13px] leading-relaxed text-tinta-suave">
              Radicar no requiere cuenta. Para consultar un trámite necesitas tu número de radicado y tu cédula.
            </p>
            <div className="flex flex-col gap-2.5">
              <BotonEnlace href="/radicar" tamano="lg" ancho="completo">
                <ArrowRight aria-hidden />
                Radicar una solicitud
              </BotonEnlace>
              <BotonEnlace href="/mis-tramites" variante="secundario" tamano="lg" ancho="completo">
                <Search aria-hidden />
                Consultar mi trámite
              </BotonEnlace>
            </div>
          </div>
        </Aparecer>
      </section>

      <section aria-labelledby="como-funciona" className="border-t border-tinta/12 bg-fondo-alt">
        <div className="mx-auto max-w-[1180px] px-4 py-12 sm:px-11">
          <h2 id="como-funciona" className="mb-6 font-display text-[11px] font-bold tracking-[0.16em] text-tinta-suave uppercase">
            Cómo funciona
          </h2>
          <Aparecer como="ol" className="grid gap-0.5 bg-tinta/12 md:grid-cols-3">
            {PASOS.map((p) => (
              <li key={p.n} data-aparecer className="bg-fondo-alt px-6 pt-6 pb-7">
                <div className="mb-4 flex items-center gap-3">
                  <span className="grid size-[26px] place-items-center bg-acento font-display text-[13px] font-extrabold text-sobre-acento">
                    {p.n}
                  </span>
                  <p.icono className="size-5 text-marca" aria-hidden />
                </div>
                <h3 className="mb-2 font-display text-[15px] font-semibold text-marca">{p.titulo}</h3>
                <p className="text-[13px] leading-relaxed text-pretty text-tinta-suave">{p.texto}</p>
              </li>
            ))}
          </Aparecer>
        </div>
      </section>

      <section className="border-t border-tinta/12">
        <div className="mx-auto grid max-w-[1180px] items-start gap-10 px-4 pt-12 pb-16 sm:px-11 md:grid-cols-2 md:gap-14">
          <div>
            <h2 className="mb-5 font-display text-[11px] font-bold tracking-[0.16em] text-tinta-suave uppercase">
              Trámites disponibles
            </h2>
            <ul className="flex flex-wrap gap-2">
              {TRAMITES_PORTAL.map((t) => (
                <li key={t} className="border border-tinta/18 px-3.5 py-2 text-[13px] text-tinta">
                  {t}
                </li>
              ))}
            </ul>
          </div>
          <div className="border-l-2 border-info bg-fondo-sutil px-6 py-6">
            <h2 className="mb-2.5 flex items-center gap-2 font-display text-[15px] font-semibold text-marca">
              <Mail className="size-4" aria-hidden />
              La respuesta llega por correo
            </h2>
            <p className="text-[13px] leading-relaxed text-pretty text-tinta-suave">
              El portal sirve para radicar y consultar el estado. Cuando la dependencia responde y Recepción verifica la
              respuesta, recibes el documento en el correo que indicaste.
            </p>
          </div>
        </div>
      </section>
    </>
  );
}
