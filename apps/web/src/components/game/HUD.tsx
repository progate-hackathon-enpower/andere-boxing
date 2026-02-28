import { useEffect, useState } from "react";
import { useGameState } from "../../contexts/GameContext";
import { GAME_CONFIG } from "../../game/config";

type HudState = {
  p0Hp: number;
  p0MaxHp: number;
  p0Stamina: number;
  p1Hp: number;
  p1MaxHp: number;
  p1Stamina: number;
  timer: number;
};

const INITIAL: HudState = {
  p0Hp: GAME_CONFIG.hp.initial,
  p0MaxHp: GAME_CONFIG.hp.initial,
  p0Stamina: GAME_CONFIG.stamina.initial,
  p1Hp: GAME_CONFIG.hp.initial,
  p1MaxHp: GAME_CONFIG.hp.initial,
  p1Stamina: GAME_CONFIG.stamina.initial,
  timer: GAME_CONFIG.roundDuration,
};

type BarProps = {
  value: number;
  max: number;
  color: string;
  reverse?: boolean;
};

function Bar({ value, max, color, reverse = false }: BarProps) {
  const pct = Math.max(0, Math.min(100, (value / max) * 100));
  return (
    <div className="h-full w-full overflow-hidden rounded-full bg-black/40">
      <div
        className={`h-full rounded-full transition-none ${color} ${reverse ? "ml-auto" : ""}`}
        style={{ width: `${pct}%` }}
      />
    </div>
  );
}

export function HUD() {
  const { gameStateRef } = useGameState();
  const [hud, setHud] = useState<HudState>(INITIAL);
  const [barHeights, setBarHeights] = useState({ hp: 20, stamina: 12 });

  useEffect(() => {
    const updateHeights = () => {
      const height = window.innerHeight;
      // 1080p を基準に、相対的にバーの高さを計算
      const scale = height / 1080;
      const hpHeight = Math.max(16, Math.min(48, 20 * scale));
      const staminaHeight = Math.max(12, Math.min(36, 12 * scale));

      setBarHeights({
        hp: hpHeight,
        stamina: staminaHeight,
      });
    };

    const resizeObserver = new ResizeObserver(updateHeights);
    resizeObserver.observe(document.documentElement);
    // 初期計算
    updateHeights();

    return () => resizeObserver.disconnect();
  }, []);

  useEffect(() => {
    let prev = { ...INITIAL };
    let rafId: number;

    const poll = () => {
      const state = gameStateRef.current;
      if (state) {
        const next: HudState = {
          p0Hp: Math.floor(state.players[0].hp),
          p0MaxHp: Math.floor(state.players[0].maxHp),
          p0Stamina: Math.floor(state.players[0].stamina),
          p1Hp: Math.floor(state.players[1].hp),
          p1MaxHp: Math.floor(state.players[1].maxHp),
          p1Stamina: Math.floor(state.players[1].stamina),
          timer: Math.ceil(state.timer),
        };
        if (
          next.p0Hp !== prev.p0Hp ||
          next.p0MaxHp !== prev.p0MaxHp ||
          next.p0Stamina !== prev.p0Stamina ||
          next.p1Hp !== prev.p1Hp ||
          next.p1MaxHp !== prev.p1MaxHp ||
          next.p1Stamina !== prev.p1Stamina ||
          next.timer !== prev.timer
        ) {
          setHud(next);
          prev = next;
        }
      }
      rafId = requestAnimationFrame(poll);
    };

    rafId = requestAnimationFrame(poll);
    return () => cancelAnimationFrame(rafId);
  }, [gameStateRef]);

  return (
    <div className="pointer-events-none absolute inset-x-0 top-0 flex items-start gap-4 p-4">
      {/* 左プレイヤー */}
      <div className="flex flex-1 flex-col gap-1.5">
        <div style={{ height: `${barHeights.hp}px` }}>
          <Bar value={hud.p0Hp} max={hud.p0MaxHp} color="bg-green-400" />
        </div>
        <div style={{ height: `${barHeights.stamina}px` }}>
          <Bar
            value={hud.p0Stamina}
            max={GAME_CONFIG.stamina.max}
            color="bg-yellow-400"
          />
        </div>
      </div>

      {/* タイマー（中央） */}
      <div
        className="shrink-0 text-center font-bold text-white drop-shadow-lg"
        style={{ fontSize: `${2 * (window.innerHeight / 1080)}rem` }}
      >
        {hud.timer}
      </div>

      {/* 右プレイヤー（バーを右端から伸ばす） */}
      <div className="flex flex-1 flex-col gap-1.5">
        <div style={{ height: `${barHeights.hp}px` }}>
          <Bar
            value={hud.p1Hp}
            max={hud.p1MaxHp}
            color="bg-green-400"
            reverse
          />
        </div>
        <div style={{ height: `${barHeights.stamina}px` }}>
          <Bar
            value={hud.p1Stamina}
            max={GAME_CONFIG.stamina.max}
            color="bg-yellow-400"
            reverse
          />
        </div>
      </div>
    </div>
  );
}
