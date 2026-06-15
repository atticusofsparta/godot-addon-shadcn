import type { BaseLayoutProps } from 'fumadocs-ui/layouts/shared';
import { appName } from './shared';

export function baseOptions(): BaseLayoutProps {
  return {
    nav: {
      title: appName,
    },
    // No `githubUrl` here on purpose: the docs sidebar renders a labeled
    // GitHub footer (see docs/_layout.tsx) so we don't want a second bare icon.
  };
}
