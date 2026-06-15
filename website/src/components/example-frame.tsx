'use client';
import { useRef } from 'react';

export function ExampleFrame({ src }: { src: string }) {
  const ref = useRef<HTMLIFrameElement>(null);

  function goFullscreen() {
    const el = ref.current;
    if (el?.requestFullscreen) void el.requestFullscreen();
  }

  return (
    <div className="not-prose relative my-4">
      <button
        type="button"
        onClick={goFullscreen}
        className="absolute right-2 top-2 z-10 inline-flex items-center gap-1.5 rounded-md border bg-fd-card/80 px-2.5 py-1 text-xs font-medium backdrop-blur-sm hover:bg-fd-accent"
      >
        ⛶ Fullscreen
      </button>
      <iframe
        ref={ref}
        src={src}
        title="shadcn-godot showcase"
        allow="fullscreen; cross-origin-isolated"
        className="w-full rounded-lg border bg-black"
        style={{ aspectRatio: '16 / 10' }}
      />
    </div>
  );
}
