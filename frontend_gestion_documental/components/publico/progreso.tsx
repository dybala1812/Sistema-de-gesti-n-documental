import { cn } from "@/lib/utils";

export function Progreso({ paso, total = 3 }: { paso: number; total?: number }) {
  return (
    <div
      role="progressbar"
      aria-label="Progreso de la radicación"
      aria-valuemin={1}
      aria-valuemax={total}
      aria-valuenow={paso}
      className="mb-7 flex gap-1.5"
    >
      {Array.from({ length: total }, (_, i) => (
        <span
          key={i}
          className={cn("h-[3px] flex-1 transition-colors duration-500", i < paso ? "bg-acento" : "bg-tinta/16")}
        />
      ))}
    </div>
  );
}
