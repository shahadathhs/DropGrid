// TypeScript 7 (native) no longer resolves CSS side-effect imports through
// next-env.d.ts. Declare them explicitly so `import "./globals.css"` typechecks.
declare module "*.css";
