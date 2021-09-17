import { defineConfig } from "vite";
import solidPlugin from "vite-plugin-solid";

export default defineConfig({
  plugins: [solidPlugin()],
  cacheDir: "/tmp/vite/cache",
  build: {
    target: "esnext",
    polyfillDynamicImport: false,
  },
});
