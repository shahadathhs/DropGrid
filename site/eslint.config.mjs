import js from "@eslint/js";
import eslintPluginPrettierRecommended from "eslint-plugin-prettier/recommended";
import { defineConfig, globalIgnores } from "eslint/config";
import globals from "globals";

// TypeScript is linted by oxlint (.oxlintrc.json); typescript-eslint cannot
// parse TS without the compiler API, which TypeScript 7 dropped. ESLint here
// covers plain JS config files only; TS formatting is `prettier --check`.
export default defineConfig([
  globalIgnores(["node_modules/*", ".next/*", "**/*.ts", "**/*.tsx"]),

  {
    files: ["**/*.{js,cjs,mjs}"],
    plugins: { js },
    extends: ["js/recommended"],
    languageOptions: { globals: { ...globals.browser, ...globals.node } },
    rules: {
      "no-console": ["warn", { allow: ["warn", "error", "info", "group", "groupEnd"] }],
      "no-unused-vars": ["error", { argsIgnorePattern: "^_" }],
      "no-unused-expressions": "error",
    },
  },

  // Run Prettier as an ESLint rule (and disable conflicting formatting rules).
  eslintPluginPrettierRecommended,
]);
