import type { Metadata } from "next";
import { Geist, Geist_Mono } from "next/font/google";

import { ThemeProvider } from "@/components/theme-provider";
import { cn } from "@/lib/utils";

import "./globals.css";

const geistSans = Geist({
  variable: "--font-geist-sans",
  subsets: ["latin"],
});

const geistMono = Geist_Mono({
  variable: "--font-geist-mono",
  subsets: ["latin"],
});

const siteUrl = "https://pagepocket.app";

export const metadata: Metadata = {
  metadataBase: new URL(siteUrl),
  title: {
    default: "PagePocket",
    template: "%s · PagePocket",
  },
  description: "Save the web to your pocket. Join the PagePocket waitlist.",
  openGraph: {
    title: "PagePocket",
    description: "Save the web to your pocket. Join the PagePocket waitlist.",
    url: siteUrl,
    siteName: "PagePocket",
    locale: "en_US",
    type: "website",
  },
  twitter: {
    card: "summary_large_image",
    title: "PagePocket",
    description: "Save the web to your pocket. Join the PagePocket waitlist.",
  },
};

export default function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode;
}>) {
  return (
    <html lang="en">
      <body
        className={cn(
          "min-h-screen bg-[var(--background)] text-[var(--foreground)] antialiased",
          geistSans.variable,
          geistMono.variable,
        )}
      >
        <ThemeProvider>{children}</ThemeProvider>
      </body>
    </html>
  );
}
