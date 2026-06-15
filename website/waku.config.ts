import { defineConfig } from 'waku/config';
import mdx from 'fumadocs-mdx/vite';
import tailwindcss from '@tailwindcss/vite';

// On GitHub Pages the site is served under /godot-addon-shadcn/.
// CI sets BASE_PATH; local dev/build defaults to "/".
const basePath = process.env.BASE_PATH ?? '/';

export default defineConfig({
  basePath,
  vite: {
    resolve: {
      tsconfigPaths: true,
      dedupe: ['waku'],
    },
    plugins: [tailwindcss(), mdx()],
  },
});
