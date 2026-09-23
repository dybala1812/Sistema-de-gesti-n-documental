"use client";

import { ArrowLeft, Check, Copy, KeyRound, LogIn } from "lucide-react";
import Link from "next/link";
import { useRouter } from "next/navigation";
import { useState, type FormEvent } from "react";
import { CLAVE_DEMO, CUENTAS_DEMO, iniciarSesionDemo } from "@/components/panel/sesion-demo";
import { Aparecer } from "@/components/ui/aparecer";
import { Antetitulo, Aviso } from "@/components/ui/bloques";
import { Boton } from "@/components/ui/boton";
import { Campo, Entrada } from "@/components/ui/campos";
import { notificar } from "@/components/ui/notificaciones";
import { ETIQUETA_ROL, USUARIO_DEMO } from "@/lib/navegacion";
import { copiarTexto } from "@/lib/utils";

export default function Login() {
  const router = useRouter();
  const [usuario, setUsuario] = useState("");
  const [clave, setClave] = useState("");
  const [error, setError] = useState("");
  const [entrando, setEntrando] = useState(false);

  function entrar(e: FormEvent) {
    e.preventDefault();
    const rol = iniciarSesionDemo(usuario, clave);
    if (!rol) {
      // Mensaje genérico a propósito: no revela cuál dato falló (RF-013).
      setError("Usuario o contraseña incorrectos.");
      return;
    }
    setError("");
    setEntrando(true);
    notificar.exito("Sesión iniciada", `Bienvenido, ${USUARIO_DEMO[rol].nombre}.`);
    router.push("/panel");
  }

  async function usarCuenta(correo: string) {
    setUsuario(correo);
    setClave(CLAVE_DEMO);
    setError("");
    if (await copiarTexto(correo)) {
      notificar.exito("Correo copiado", correo);
    } else {
      // El formulario igual queda lleno aunque el navegador no permita copiar.
      notificar.info("Formulario listo", "No se pudo copiar al portapapeles, pero ya puedes entrar.");
    }
  }

  return (
    <div className="grid min-h-screen md:grid-cols-2">
      <div className="flex flex-col justify-center border-b border-borde bg-fondo-alt px-6 py-12 md:border-r md:border-b-0 md:px-12">
        <Aparecer>
          <span
            data-aparecer
            aria-hidden
            className="mb-9 grid size-24 place-items-center bg-marca font-display text-2xl font-extrabold tracking-wider text-white md:size-40 md:text-4xl"
          >
            SGD
          </span>
          <div data-aparecer>
            <Antetitulo className="mb-4">Panel interno</Antetitulo>
          </div>
          <h1 data-aparecer className="mb-4 font-display text-3xl leading-tight font-extrabold tracking-tight text-marca md:text-[34px]">
            Sistema de Gestión Documental
          </h1>
          <p data-aparecer className="max-w-[380px] text-sm leading-relaxed text-tinta-suave">
            Acceso para Recepción, dependencias, Archivo Central y administración. Cada usuario ve solo los módulos que
            su rol permite.
          </p>
        </Aparecer>
      </div>

      <div className="flex items-center justify-center px-6 py-12 md:px-12">
        <div className="w-full max-w-[380px]">
          <form onSubmit={entrar} noValidate>
            <h2 className="mb-1.5 font-display text-xl font-bold text-marca">Inicia sesión</h2>
            <p className="mb-6 text-[13px] leading-relaxed text-tinta-suave">Usa el usuario institucional asignado por TIC.</p>

            <Campo etiqueta="Usuario institucional" htmlFor="usuario" className="mb-4">
              <Entrada
                id="usuario"
                type="email"
                autoComplete="username"
                placeholder="usuario@uniautonoma.edu.co"
                value={usuario}
                onChange={(e) => setUsuario(e.target.value)}
              />
            </Campo>
            <Campo etiqueta="Contraseña" htmlFor="clave" className="mb-5">
              <Entrada
                id="clave"
                type="password"
                autoComplete="current-password"
                value={clave}
                onChange={(e) => setClave(e.target.value)}
              />
            </Campo>

            {error && (
              <Aviso tono="peligro" className="mb-4">
                {error}
              </Aviso>
            )}

            <Boton type="submit" tamano="lg" ancho="completo" disabled={entrando}>
              <LogIn aria-hidden />
              {entrando ? "Entrando…" : "Entrar"}
            </Boton>
          </form>

          <section aria-labelledby="cuentas-demo" className="mt-6 border border-dashed border-borde-campo p-4">
            <h3 id="cuentas-demo" className="mb-1 flex items-center gap-2 font-display text-xs font-bold text-tinta">
              <KeyRound className="size-3.5" aria-hidden />
              Cuentas de demostración
            </h3>
            <p className="mb-3 text-[11px] text-tinta-suave">
              Contraseña: <code className="bg-fondo-sutil px-1 font-mono text-tinta">{CLAVE_DEMO}</code> · Elige una para
              llenar el formulario y copiar el correo.
            </p>
            <ul className="flex flex-col gap-1.5">
              {CUENTAS_DEMO.map((c) => (
                <li key={c.correo}>
                  <button
                    type="button"
                    onClick={() => usarCuenta(c.correo)}
                    aria-pressed={usuario === c.correo}
                    aria-label={`Usar la cuenta de ${ETIQUETA_ROL[c.rol]} y copiar ${c.correo}`}
                    className="group flex w-full items-center gap-3 border border-borde px-3 py-2 text-left text-xs transition-colors hover:border-acento hover:bg-acento-claro aria-pressed:border-acento aria-pressed:bg-acento-claro"
                  >
                    <span className="font-semibold text-tinta">{ETIQUETA_ROL[c.rol]}</span>
                    <span className="ml-auto truncate text-tinta-suave">{c.correo}</span>
                    {usuario === c.correo ? (
                      <Check className="size-3.5 shrink-0 text-exito" aria-hidden />
                    ) : (
                      <Copy className="size-3.5 shrink-0 text-tinta-suave group-hover:text-tinta" aria-hidden />
                    )}
                  </button>
                </li>
              ))}
            </ul>
          </section>

          <div className="mt-5 flex items-center justify-between border-t border-borde pt-4 text-xs text-tinta-suave">
            <span>¿Olvidaste tu contraseña? Escribe a TIC.</span>
            <Link href="/" className="inline-flex items-center gap-1 font-semibold text-marca hover:underline">
              <ArrowLeft className="size-3.5" aria-hidden />
              Portal
            </Link>
          </div>
        </div>
      </div>
    </div>
  );
}
