import { useTick } from "@pixi/react";
import { useRef } from "react";
import { andere_boxing } from "../generated/event_pb";
import { GAME_CONFIG } from "../game/config";
import type {
  GamePhase,
  GameState,
  PlayerAction,
  PlayerState,
} from "../game/types";

const { UserAction } = andere_boxing;

type UseGameLoopArgs = {
  getAction: (playerIndex: 0 | 1) => PlayerAction;
  flushActions: () => void;
};

function createInitialState(): GameState {
  const player = (): PlayerState => ({
    hp: GAME_CONFIG.hp.initial,
    stamina: GAME_CONFIG.stamina.initial,
    animState: "idle",
    animFrame: 0,
  });
  return {
    players: [player(), player()],
    timer: GAME_CONFIG.roundDuration,
    phase: "fighting",
  };
}

export function useGameLoop({ getAction, flushActions }: UseGameLoopArgs) {
  const stateRef = useRef<GameState>(createInitialState());

  useTick((ticker) => {
    const prev = stateRef.current;
    if (prev.phase !== "fighting") {
      flushActions();
      return;
    }

    const players: [PlayerState, PlayerState] = [
      { ...prev.players[0] },
      { ...prev.players[1] },
    ];

    // 1. アニメーションフレーム進行
    for (let i = 0; i < 2; i++) {
      const p = players[i];
      if (p.animState === "idle") continue;
      if (p.animState === "ko") {
        // ko は idle に戻らない。フェーズ遷移の判定のためフレームだけ進める
        if (p.animFrame < GAME_CONFIG.animDuration.ko) {
          p.animFrame++;
        }
        continue;
      }
      p.animFrame++;
      if (p.animFrame >= GAME_CONFIG.animDuration[p.animState]) {
        p.animState = "idle";
        p.animFrame = 0;
      }
    }

    // 2. スタミナ自然回復
    for (let i = 0; i < 2; i++) {
      const p = players[i];
      if (p.animState !== "ko") {
        p.stamina = Math.min(
          GAME_CONFIG.stamina.max,
          p.stamina + GAME_CONFIG.stamina.regenPerFrame,
        );
      }
    }

    // 3. アクション入力の収集
    //    同時解決のため、両者の意図を先に確定してからまとめて適用する
    const actions: [PlayerAction, PlayerAction] = [getAction(0), getAction(1)];
    const intendedPunch: [boolean, boolean] = [false, false];
    const intendedDefend: [boolean, boolean] = [false, false];

    for (let i = 0; i < 2; i++) {
      const p = players[i];
      const action = actions[i];
      // idle のときのみ新しいアクションを受け付ける
      if (p.animState !== "idle") continue;

      if (
        action === UserAction.USER_ACTION_PUNCH &&
        p.stamina >= GAME_CONFIG.stamina.punchCost
      ) {
        intendedPunch[i] = true;
      } else if (
        action === UserAction.USER_ACTION_DEFEND &&
        p.stamina >= GAME_CONFIG.stamina.defendCost
      ) {
        intendedDefend[i] = true;
      }
    }

    // 4. アクションを適用（スタミナ消費・アニメーション状態遷移）
    for (let i = 0; i < 2; i++) {
      if (intendedPunch[i]) {
        players[i].animState = "punch";
        players[i].animFrame = 0;
        players[i].stamina -= GAME_CONFIG.stamina.punchCost;
      } else if (intendedDefend[i]) {
        players[i].animState = "defend";
        players[i].animFrame = 0;
        players[i].stamina -= GAME_CONFIG.stamina.defendCost;
      }
    }

    // 5. ヒット判定
    //    パンチを打った側が相手を確認。
    //    相手が defend 中 → ダメージなし・相手の精神力を回復
    //    相手が ko 中    → 追加ダメージなし
    for (let i = 0; i < 2; i++) {
      if (!intendedPunch[i]) continue;
      const j = (1 - i) as 0 | 1;
      const target = players[j];
      if (target.animState === "ko") continue;
      if (target.animState === "defend") {
        target.stamina = Math.min(
          GAME_CONFIG.stamina.max,
          target.stamina + GAME_CONFIG.stamina.blockRegenOnDefend,
        );
        continue;
      }

      target.hp = Math.max(0, target.hp - GAME_CONFIG.hp.punchDamage);
      if (target.hp <= 0) {
        target.animState = "ko";
        target.animFrame = 0;
      } else {
        target.animState = "hurt";
        target.animFrame = 0;
      }
    }

    // 6. タイマー更新とフェーズ遷移
    const newTimer = Math.max(0, prev.timer - ticker.deltaTime / 60);
    let newPhase: GamePhase = prev.phase;

    if (newTimer <= 0) {
      newPhase = "result";
    }
    for (let i = 0; i < 2; i++) {
      if (
        players[i].animState === "ko" &&
        players[i].animFrame >= GAME_CONFIG.animDuration.ko
      ) {
        newPhase = "result";
      }
    }

    stateRef.current = { players, timer: newTimer, phase: newPhase };
    flushActions();
  });

  return stateRef;
}
