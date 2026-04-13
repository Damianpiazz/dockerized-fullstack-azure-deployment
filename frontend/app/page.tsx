import Link from "next/link";
import Image from "next/image";

export default function Home() {
  return (
    <div className="flex flex-col flex-1 items-center justify-center bg-zinc-50 font-sans dark:bg-black">
      <main className="flex flex-1 w-full max-w-3xl flex-col items-center justify-center gap-8 py-32 px-16 bg-white dark:bg-black">
        <Image
          className="dark:invert"
          src="/next.svg"
          alt="Next.js logo"
          width={100}
          height={20}
          priority
        />
        <div className="flex flex-col items-center gap-4 text-center">
          <h1 className="text-4xl font-bold tracking-tight text-black dark:text-zinc-50">
            Sistema de gestión de clientes
          </h1>
          <p className="max-w-md text-lg text-zinc-600 dark:text-zinc-400">
            Administrá tus clientes de forma simple y rápida.
          </p>
        </div>
        <Link
          href="/clients"
          className="flex h-12 items-center justify-center gap-2 rounded-full bg-foreground px-8 text-base font-medium text-background transition-colors hover:bg-[#383838] dark:hover:bg-[#ccc]"
        >
          Ver clientes
        </Link>
      </main>
    </div>
  );
}