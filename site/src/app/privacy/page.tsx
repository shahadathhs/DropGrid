import type { Metadata } from "next";
import { PageShell } from "@/components/page-shell";
import { contactEmail } from "@/lib/links";

export const metadata: Metadata = {
  title: "Privacy",
};

const sections: { title: string; body: string }[] = [
  {
    title: "Guest play",
    body: "If you play as a guest, the game sends nothing to our servers. Your progress stays on your phone.",
  },
  {
    title: "Account data",
    body: "Only if you create an account: your email address, a username, and three game numbers (best score, total lines, games played). Passwords are stored as bcrypt hashes, never in plain text.",
  },
  {
    title: "What it is used for",
    body: "To run your account: signing in and carrying your progress to a new phone. Your username and best score appear on the public leaderboard. Your email is never shown and never shared.",
  },
  {
    title: "No tracking",
    body: "No ads, no analytics, no third-party SDKs. We do not sell or share your data.",
  },
  {
    title: "Deletion",
    body: "We keep your data until you delete your account. Delete it inside the game (Profile > Delete account). Deletion is immediate and permanent.",
  },
  {
    title: "One limitation",
    body: "There is no password reset yet. If you lose your password, your synced copy cannot be recovered — you can create a new account and start over.",
  },
];

export default function Privacy() {
  return (
    <PageShell current="/privacy">
      <div className="wrap flex flex-1 flex-col gap-8 pt-6 pb-20">
        <h1 className="font-display text-3xl lg:text-4xl">Privacy</h1>
        <div className="measure flex flex-col gap-6">
          {sections.map((s) => (
            <section key={s.title} className="flex flex-col gap-1">
              <h2 className="text-sm font-semibold tracking-wide text-text-muted">
                {s.title.toUpperCase()}
              </h2>
              <p className="text-text-muted">{s.body}</p>
            </section>
          ))}
        </div>
        <p className="measure text-sm text-text-faint">
          Questions about your data:{" "}
          <a
            className="underline underline-offset-4 hover:text-text"
            href={`mailto:${contactEmail}`}
          >
            {contactEmail}
          </a>
        </p>
      </div>
    </PageShell>
  );
}
