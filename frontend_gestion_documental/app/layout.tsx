import type { Metadata } from "next";
import { Inter, Poppins } from "next/font/google";
import { ProveedorNotificaciones } from "@/components/ui/notificaciones";
import "./globals.css";

const inter = Inter({
  variable: "--font-inter",
  subsets: ["latin"],
});

const poppins = Poppins({
  variable: "--font-poppins",
  subsets: ["latin"],
  weight: ["500", "600", "700", "800"],
});

export const metadata: Metadata = {
  title: {
    default: "Sistema de Gestión Documental",
    template: "%s · SGD",
  },
  description:
    "Radicación, seguimiento y respuesta de la correspondencia de la Universidad Autónoma del Cauca.",
};

export default function RootLayout({ children }: LayoutProps<"/">) {
  return (
    <html lang="es" className={`${inter.variable} ${poppins.variable} h-full`}>
      <body className="flex min-h-full flex-col">
        {children}
        <ProveedorNotificaciones />
      </body>
    </html>
  );
}
