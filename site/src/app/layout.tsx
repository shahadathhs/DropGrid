import type { Metadata } from "next";
import localFont from "next/font/local";
import { siteUrl } from "@/lib/links";
import "./globals.css";

const martianMono = localFont({
  src: "../fonts/MartianMono.ttf",
  variable: "--font-martian-mono",
  display: "swap",
});

const departureMono = localFont({
  src: "../fonts/DepartureMono-Regular.otf",
  weight: "400",
  variable: "--font-departure-mono",
  display: "swap",
});

const description =
  "A portrait falling-block puzzle for Android. Offline first, no ads, no purchases. Five modes and an optional global leaderboard.";

export const metadata: Metadata = {
  metadataBase: new URL(siteUrl),
  title: {
    default: "DropGrid, a falling-block puzzle for Android",
    template: "%s · DropGrid",
  },
  description,
  alternates: { canonical: "/" },
  openGraph: {
    title: "DropGrid, a falling-block puzzle for Android",
    description,
    url: siteUrl,
    siteName: "DropGrid",
    type: "website",
  },
  twitter: {
    card: "summary_large_image",
    title: "DropGrid, a falling-block puzzle for Android",
    description,
  },
  icons: [{ rel: "icon", url: "/icon.svg", type: "image/svg+xml" }],
};

export default function RootLayout({ children }: { children: React.ReactNode }) {
  return (
    <html lang="en" className={`${martianMono.variable} ${departureMono.variable}`}>
      <body className="min-h-screen bg-background font-mono text-text antialiased">{children}</body>
    </html>
  );
}
