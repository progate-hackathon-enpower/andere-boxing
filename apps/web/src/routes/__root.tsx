import {
  HeadContent,
  Outlet,
  Scripts,
  createRootRoute,
} from "@tanstack/react-router";
import { TanStackRouterDevtoolsPanel } from "@tanstack/react-router-devtools";
import { TanStackDevtools } from "@tanstack/react-devtools";
import { useEffect, useState } from "react";
import { GameStage } from "../components/game/GameStage";
import { GameProvider } from "../contexts/GameContext";
import appCss from "../App.css?url";

export const Route = createRootRoute({
  head: () => ({
    meta: [
      { charSet: "utf-8" },
      { name: "viewport", content: "width=device-width, initial-scale=1" },
      { title: "RUSH BATTLE!!" },
    ],
    links: [
      { rel: "stylesheet", href: appCss },
      {
        rel: "stylesheet",
        href: "https://fonts.googleapis.com/css2?family=DotGothic16&family=Press+Start+2P&display=swap",
      },
    ],
  }),

  component: RootLayout,
  shellComponent: RootDocument,
});

function RootLayout() {
  // React 19 SSR は lazy() + Suspense でもコンポーネントを実行するため、
  // useEffect で確実にクライアント側のみレンダリングする
  const [mounted, setMounted] = useState(false);

  useEffect(() => {
    setMounted(true);
  }, []);

  return (
    <GameProvider>
      <div className="game-container">
        {/* PixiJS 背景レイヤー（クライアントマウント後のみ） */}
        <div className="pixi-layer">{mounted && <GameStage />}</div>
        {/* React UI オーバーレイ */}
        <div className="ui-layer">
          <Outlet />
        </div>
      </div>
    </GameProvider>
  );
}

function RootDocument({ children }: { children: React.ReactNode }) {
  return (
    <html lang="ja">
      <head>
        <HeadContent />
      </head>
      <body>
        {children}
        <TanStackDevtools
          config={{ position: "bottom-right" }}
          plugins={[
            {
              name: "Tanstack Router",
              render: <TanStackRouterDevtoolsPanel />,
            },
          ]}
        />
        <Scripts />
      </body>
    </html>
  );
}
