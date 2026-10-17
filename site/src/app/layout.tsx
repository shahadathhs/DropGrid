import type { Metadata } from "next";
import localFont from "next/font/local";
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

export const metadata: Metadata = {
  title: "DropGrid — a falling-block puzzle for Android",
  description:
    "A portrait falling-block puzzle. Offline first, no ads, no purchases. Optional account for a global leaderboard.",
  icons: [{ rel: "icon", url: "/icon.svg", type: "image/svg+xml" }],
};

export default function RootLayout({ children }: { children: React.ReactNode }) {
  return (
    <html lang="en" className={`${martianMono.variable} ${departureMono.variable}`}>
      <body className="min-h-screen bg-background font-mono text-text antialiased">{children}</body>
    </html>
  );
}
