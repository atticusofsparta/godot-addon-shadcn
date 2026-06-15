'use client';
import type { ReactNode } from 'react';
import { RootProvider } from 'fumadocs-ui/provider/waku';

export function Provider({ children }: { children: ReactNode }) {
  // Search is disabled because GitHub Pages is fully static (no /api/search).
  return <RootProvider search={{ enabled: false }}>{children}</RootProvider>;
}
