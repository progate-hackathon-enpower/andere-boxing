import js from "@eslint/js";
import tseslint from "typescript-eslint";
import reactPlugin from "eslint-plugin-react";
import reactHooksPlugin from "eslint-plugin-react-hooks";
import prettierConfig from "eslint-config-prettier";

export default tseslint.config(
  { ignores: ["dist", "node_modules"] },
  js.configs.recommended,
  tseslint.configs.recommended,
  {
    plugins: {
      react: reactPlugin,
      "react-hooks": reactHooksPlugin,
    },
    rules: {
      ...reactPlugin.configs.recommended.rules,
      ...reactHooksPlugin.configs.recommended.rules,
      "react/react-in-jsx-scope": "off",
      // @pixi/react の extend() で定義されたカスタム要素のプロパティを許可
      "react/no-unknown-property": ["error", { ignore: ["texture"] }],
      // SSR マウント検出パターン (useEffect + setState) を許可
      "react-hooks/set-state-in-effect": "off",
    },
    settings: {
      react: { version: "detect" },
    },
  },
  prettierConfig,
);
