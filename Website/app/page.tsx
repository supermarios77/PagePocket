import {
  Clock,
  Cloud,
  FileText,
  Lock,
  ShieldCheck,
  WifiOff,
} from "lucide-react";

import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";

const features = [
  {
    icon: WifiOff,
    title: "Offline-ready",
    description:
      "Capture full pages with one tap and keep them readable wherever you are.",
  },
  {
    icon: Cloud,
    title: "iCloud sync",
    description: "Your highlights and notes stay private and in sync automatically.",
  },
  {
    icon: Clock,
    title: "Time aware",
    description: "Smart read-time estimates help you queue the perfect article for later.",
  },
];

const stats = [
  { label: "Early readers", value: "3.6k" },
  { label: "Pages saved", value: "82k+" },
  { label: "Countries", value: "42" },
];

export default function Home() {
  return (
    <main className="relative flex min-h-screen items-center justify-center overflow-hidden bg-[#050505] px-6 py-24 text-white">
      <div className="pointer-events-none absolute inset-0 bg-[radial-gradient(circle_at_top,_rgba(128,83,255,0.18),_transparent_60%)]" />

      <div className="relative z-10 flex w-full max-w-6xl flex-col gap-24">
        <div className="grid gap-16 lg:grid-cols-[minmax(0,1fr)_minmax(320px,420px)] lg:items-center">
          <div className="flex flex-col items-start gap-8">
            <div className="flex items-center gap-3 rounded-full border border-white/10 bg-white/5 px-4 py-2 text-sm text-white/70">
              <div className="flex h-9 w-9 items-center justify-center rounded-full bg-[#7f5bff]/90">
                <FileText className="h-4 w-4 text-white" strokeWidth={1.8} />
              </div>
              <span className="font-medium">PagePocket · Private offline reader</span>
            </div>

            <div className="space-y-6">
              <h1 className="text-left text-4xl font-semibold leading-[1.05] tracking-tight sm:text-5xl md:text-[3.6rem]">
                A calmer way to save, sync, and finish the web.
              </h1>
              <p className="max-w-xl text-lg text-white/65">
                Collect articles, PDFs, and research in seconds. PagePocket cleans the clutter, stores everything offline, and keeps your reads synced across devices.
              </p>
            </div>

            <form
              className="flex w-full max-w-xl flex-col gap-3 rounded-2xl border border-white/12 bg-white/5 p-4 backdrop-blur-sm sm:flex-row sm:items-center"
              action="#"
              method="post"
              noValidate
            >
              <label className="sr-only" htmlFor="email">
                Email address
              </label>
              <Input
                id="email"
                name="email"
                type="email"
                placeholder="you@example.com"
                autoComplete="email"
                required
                className="h-12 flex-1"
              />
              <Button type="submit" className="h-12 w-full sm:w-auto">
                Join the waitlist
              </Button>
            </form>

            <div className="flex flex-wrap items-center gap-6 text-sm text-white/55">
              <div className="flex items-center gap-2">
                <ShieldCheck className="h-4 w-4 text-[#b7a7ff]" />
                <span>Beta invites ship this month</span>
              </div>
              <div className="flex items-center gap-2">
                <Lock className="h-4 w-4 text-[#b7a7ff]" />
                <span>No spam—unsubscribe anytime</span>
              </div>
            </div>
          </div>

          <div className="flex justify-center lg:justify-end">
            <div className="relative aspect-[9/19] w-[280px] sm:w-[320px]">
              <div className="absolute inset-0 rounded-[44px] border border-white/12 bg-white/8 shadow-[0_40px_120px_-50px_rgba(128,83,255,0.7)]" />
              <div className="absolute inset-[12px] overflow-hidden rounded-[36px] border border-white/10 bg-black/75">
                <div className="relative h-full w-full overflow-hidden">
                  <video
                    className="h-full w-full object-cover"
                    src="/Preview.mp4"
                    autoPlay
                    muted
                    loop
                    playsInline
                    aria-label="Preview of PagePocket saving and reading experience"
                  />
                  <div className="pointer-events-none absolute inset-x-0 top-0 h-24 bg-gradient-to-b from-black/60 via-black/20 to-transparent" />
                  <div className="pointer-events-none absolute inset-x-0 bottom-0 h-32 bg-gradient-to-t from-black/70 via-black/30 to-transparent" />
                  <div className="absolute inset-x-0 bottom-0 flex flex-col gap-3 px-6 pb-8">
                    <p className="text-xs uppercase tracking-[0.25em] text-white/55">Live preview</p>
                    <div className="rounded-2xl border border-white/12 bg-white/10 px-4 py-3 text-xs text-white/85">
                      Auto-cleaned articles, synced instantly to your offline library.
                    </div>
                  </div>
                </div>
              </div>
              <div className="absolute left-1/2 top-5 h-6 w-28 -translate-x-1/2 rounded-full bg-white/15" />
              <div className="absolute left-1/2 top-5 h-2 w-14 -translate-x-1/2 rounded-full bg-white/40" />
            </div>
          </div>
        </div>

        <section className="grid gap-6 rounded-[30px] border border-white/12 bg-white/5 p-8 backdrop-blur-sm md:grid-cols-3">
          {features.map(({ icon: Icon, title, description }) => (
            <div key={title} className="flex flex-col gap-4">
              <div className="flex h-10 w-10 items-center justify-center rounded-full bg-white/10 text-[#cec0ff]">
                <Icon className="h-5 w-5" strokeWidth={1.7} />
              </div>
              <div className="space-y-2">
                <h3 className="text-lg font-semibold text-white">{title}</h3>
                <p className="text-sm text-white/65">{description}</p>
              </div>
            </div>
          ))}
        </section>

        <section className="grid gap-4 text-center sm:grid-cols-3">
          {stats.map((stat) => (
            <div
              key={stat.label}
              className="rounded-2xl border border-white/10 bg-white/5 px-6 py-6 text-white/70 backdrop-blur-sm"
            >
              <p className="text-3xl font-semibold text-white">{stat.value}</p>
              <p className="mt-1 text-xs uppercase tracking-[0.3em]">{stat.label}</p>
            </div>
          ))}
        </section>
      </div>
    </main>
  );
}
