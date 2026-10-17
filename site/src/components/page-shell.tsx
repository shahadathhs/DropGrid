import { SiteFooter } from "@/components/site-footer";
import { SiteHeader } from "@/components/site-header";

/**
 * Header, main and footer for every page. Pass `current` (the page's path) to
 * mark it in the nav. `main` is full width; sections place their own .wrap.
 */
export function PageShell({ children, current }: { children: React.ReactNode; current?: string }) {
  return (
    <div className="flex min-h-screen flex-col">
      <SiteHeader current={current} />
      <main className="flex flex-1 flex-col">{children}</main>
      <SiteFooter />
    </div>
  );
}
