import { defineConfig } from "vite";
import { devtools } from "@tanstack/devtools-vite";
import { tanstackStart } from "@tanstack/react-start/plugin/vite";
import viteReact from "@vitejs/plugin-react";
import viteTsConfigPaths from "vite-tsconfig-paths";
import { fileURLToPath, URL } from "url";
import { nitro } from "nitro/vite";
import tailwindcss from "@tailwindcss/vite";

const config = defineConfig({
  resolve: {
    alias: {
      "@": fileURLToPath(new URL("./src", import.meta.url)),
    },
  },
  ssr: {
    // PixiJS はブラウザ専用のため、Vite に直接バンドルさせて
    // Node.js の ESM 拡張子解決エラーを回避する
    noExternal: ["@pixi/react", "pixi.js"],
  },
  plugins: [
    devtools(),
    nitro({
      preset: process.env.NITRO_PRESET || "node-server",
    }),
    viteTsConfigPaths({
      projects: ["./tsconfig.json"],
    }),
    tanstackStart(),
    viteReact(),
    tailwindcss(),
  ],
});

export default config;
