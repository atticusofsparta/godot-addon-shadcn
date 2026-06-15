import { Link } from 'waku';

export default function Home() {
  return (
    <main className="flex-1 flex flex-col items-center justify-center text-center gap-6 px-6 py-24">
      <div className="inline-flex items-center rounded-full border px-3 py-1 text-xs text-fd-muted-foreground">
        Godot 4 · MIT
      </div>
      <h1 className="font-bold text-4xl sm:text-5xl max-w-3xl tracking-tight">
        shadcn/ui for Godot
      </h1>
      <p className="text-fd-muted-foreground max-w-xl text-lg">
        A drop-in theme that restyles Godot&apos;s controls to look like
        shadcn/ui, plus the components Godot is missing — charts, dialogs,
        calendar, command palette and more. Light/dark and every shadcn color
        scheme.
      </p>
      <div className="flex flex-wrap gap-3 justify-center">
        <Link
          to="/docs"
          className="px-4 py-2 rounded-lg bg-fd-primary text-fd-primary-foreground font-medium text-sm"
        >
          Get started
        </Link>
        <Link
          to="/docs/live-example"
          className="px-4 py-2 rounded-lg border font-medium text-sm hover:bg-fd-accent"
        >
          Live demo
        </Link>
        <a
          href="https://github.com/atticusofsparta/godot-addon-shadcn"
          className="px-4 py-2 rounded-lg border font-medium text-sm hover:bg-fd-accent"
        >
          GitHub
        </a>
      </div>
    </main>
  );
}

export async function getConfig() {
  return {
    render: 'static',
  };
}
