import type { Metadata } from "next";
import { PageShell } from "@/components/page-shell";
import { contactEmail, repo } from "@/lib/links";

export const metadata: Metadata = {
  title: "Contact",
};

export default function Contact() {
  return (
    <PageShell current="/contact">
      <div className="wrap flex flex-1 flex-col gap-8 pt-6 pb-20">
        <h1 className="font-display text-3xl lg:text-4xl">Contact</h1>
        <ul className="measure flex flex-col divide-y divide-line">
          <li className="flex flex-col gap-1 py-4 sm:flex-row sm:gap-6">
            <span className="w-48 shrink-0 text-sm font-semibold">Bugs and crashes</span>
            <span className="text-text-muted">
              Open an issue on{" "}
              <a
                className="underline underline-offset-4 hover:text-text"
                href={`${repo}/issues/new`}
              >
                GitHub
              </a>
              . A screenshot and the steps help.
            </span>
          </li>
          <li className="flex flex-col gap-1 py-4 sm:flex-row sm:gap-6">
            <span className="w-48 shrink-0 text-sm font-semibold">Everything else</span>
            <span className="text-text-muted">
              <a
                className="underline underline-offset-4 hover:text-text"
                href={`mailto:${contactEmail}`}
              >
                {contactEmail}
              </a>
            </span>
          </li>
        </ul>
      </div>
    </PageShell>
  );
}
