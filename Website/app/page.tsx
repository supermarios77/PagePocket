import { FileText, Lock } from "lucide-react";

import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";

export default function Home() {
  return (
    <main className="flex min-h-screen items-center justify-center bg-black px-6 py-16 text-white">
      <div className="flex w-full max-w-6xl flex-col items-center gap-16 lg:flex-row lg:items-center lg:justify-between">
        <div className="flex w-full max-w-xl flex-col items-start gap-10">
          <div className="flex items-center gap-3">
            <div className="relative flex h-12 w-12 items-center justify-center">
              <div className="absolute inset-0 rounded-2xl bg-gradient-to-br from-[#9f72ff] to-[#6d28d9] shadow-[0px_20px_60px_rgba(109,40,217,0.55)]" />
              <FileText className="relative h-6 w-6 text-white" strokeWidth={1.8} />
              <div className="absolute -bottom-1 -right-1 flex h-5 w-5 items-center justify-center rounded-full bg-white text-black shadow-[0_4px_12px_rgba(0,0,0,0.35)]">
                <Lock className="h-3 w-3" strokeWidth={2.1} />
              </div>
            </div>
            <span className="text-2xl font-semibold tracking-tight">PagePocket</span>
          </div>

          <h1 className="text-left text-4xl font-bold leading-[1.05] tracking-tight sm:text-5xl md:text-6xl">
            Save web pages.
            <br />
            Read offline.
            <br />
            Anytime, anywhere.
          </h1>

          <form
            className="flex w-full max-w-md flex-col gap-3 sm:flex-row sm:items-center"
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
              placeholder="name@email.com"
              autoComplete="email"
              required
              className="h-14 flex-1 rounded-full border-none bg-white/10 text-base text-white placeholder:text-white/50 focus-visible:ring-2 focus-visible:ring-[#8b5cf6] focus-visible:ring-offset-0"
            />
            <Button
              type="submit"
              className="h-14 w-full rounded-full bg-[#8053ff] px-8 text-base font-semibold text-white shadow-[0px_22px_60px_rgba(128,83,255,0.5)] transition-transform hover:-translate-y-0.5 hover:bg-[#6f3cff] sm:w-auto"
            >
              Join Waitlist
            </Button>
          </form>
        </div>

        <div className="flex w-full max-w-sm justify-center lg:max-w-lg lg:justify-end">
          <div className="relative aspect-[9/19] w-60 sm:w-72 lg:w-[22rem]">
            <div className="absolute inset-0 rounded-[46px] border border-white/10 bg-gradient-to-b from-white/10 via-white/5 to-transparent shadow-[0_50px_140px_-40px_rgba(128,83,255,0.65)]" />
            <div className="absolute inset-[12px] rounded-[38px] bg-black" />
            <div className="absolute left-1/2 top-6 h-6 w-28 -translate-x-1/2 rounded-full bg-white/15" />
            <div className="absolute left-1/2 top-6 h-2 w-14 -translate-x-1/2 rounded-full bg-white/40" />
          </div>
        </div>
      </div>
    </main>
  );
}
