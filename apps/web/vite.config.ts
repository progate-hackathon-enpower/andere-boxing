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
  optimizeDeps: {
    include: ["protobufjs/minimal"],
  },
  build: {
    rollupOptions: {
      external: [],
      output: {
        // CommonJS の module を ESM コンテキストで使用可能にする
        globals: {
          module: "undefined",
          require: "undefined",
        },
      },
    },
  },
  ssr: {
    // PixiJS はブラウザ専用のため、Vite に直接バンドルさせて
    // Node.js の ESM 拡張子解決エラーを回避する
    noExternal: ["@pixi/react", "pixi.js", "protobufjs"],
  },
  plugins: [
    devtools(),
    nitro({
      preset: process.env.NITRO_PRESET || "node-server",
      serveStatic: true,
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

