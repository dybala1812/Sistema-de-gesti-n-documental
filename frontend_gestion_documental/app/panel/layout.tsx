import { MarcoPanel } from "@/components/panel/marco-panel";

export default function LayoutPanel({ children }: LayoutProps<"/panel">) {
  return <MarcoPanel>{children}</MarcoPanel>;
}
