"use client";

import { useRef, useState, useEffect, FormEvent } from "react";
import {
  BookMarked,
  Clock,
  Cloud,
  FileText,
  Lock,
  Send,
  Sparkles,
  WifiOff,
  Check,
  Loader2,
} from "lucide-react";

import { ThemeToggle } from "@/components/theme-toggle";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";

const features = [
  {
    icon: WifiOff,
    title: "Always available",
    description:
      "Capture the full page so you can keep reading when the connection cuts out.",
  },
  {
    icon: Cloud,
    title: "Private sync",
    description:
      "Your library mirrors across devices using your encrypted iCloud account only.",
  },
  {
    icon: Clock,
    title: "Time aware",
    description:
      "Smart read-time estimates help you choose the perfect article for every break.",
  },
];

const stats = [
  { label: "Readers waiting", value: "3.6k" },
  { label: "Offline pages", value: "82k" },
  { label: "Beta countries", value: "42" },
];

export default function Home() {
  const [email, setEmail] = useState("");
  const [isSubmitting, setIsSubmitting] = useState(false);
  const [submitStatus, setSubmitStatus] = useState<"idle" | "success" | "error">("idle");
  const [errorMessage, setErrorMessage] = useState("");
  const [prefersReducedMotion, setPrefersReducedMotion] = useState(false);
  const videoRef = useRef<HTMLVideoElement>(null);
  const videoContainerRef = useRef<HTMLDivElement>(null);
  const successTimeoutRef = useRef<NodeJS.Timeout | null>(null);

  // Check for reduced motion preference
  useEffect(() => {
    const mediaQuery = window.matchMedia("(prefers-reduced-motion: reduce)");
    setPrefersReducedMotion(mediaQuery.matches);

    const handleChange = (e: MediaQueryListEvent) => {
      setPrefersReducedMotion(e.matches);
    };

    mediaQuery.addEventListener("change", handleChange);

    return () => {
      mediaQuery.removeEventListener("change", handleChange);
    };
  }, []);

  // Handle video autoplay based on reduced motion preference
  useEffect(() => {
    const video = videoRef.current;
    if (!video) return;

    if (prefersReducedMotion) {
      video.pause();
      video.removeAttribute("autoplay");
    } else {
      video.play().catch((error) => {
        // Autoplay was prevented, user interaction required
        console.debug("Video autoplay prevented:", error);
      });
    }
  }, [prefersReducedMotion]);

  // Cleanup function to prevent memory leaks
  useEffect(() => {
    return () => {
      // Cleanup any ongoing async operations
      if (isSubmitting) {
        setIsSubmitting(false);
      }
      // Clear success timeout if component unmounts
      if (successTimeoutRef.current) {
        clearTimeout(successTimeoutRef.current);
      }
    };
  }, [isSubmitting]);

  const handleSubmit = async (e: FormEvent<HTMLFormElement>) => {
    e.preventDefault();
    
    if (isSubmitting) return;

    // Reset previous status
    setSubmitStatus("idle");
    setErrorMessage("");

    // Client-side validation
    if (!email.trim()) {
      setSubmitStatus("error");
      setErrorMessage("Please enter your email address");
      return;
    }

    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    if (!emailRegex.test(email)) {
      setSubmitStatus("error");
      setErrorMessage("Please enter a valid email address");
      return;
    }

    setIsSubmitting(true);

    try {
      const response = await fetch("/api/waitlist", {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
        },
        body: JSON.stringify({ email: email.trim() }),
      });

      const data = await response.json();

      if (!response.ok) {
        throw new Error(data.error || "Failed to join waitlist");
      }

      setSubmitStatus("success");
      setEmail("");
      
      // Clear any existing timeout
      if (successTimeoutRef.current) {
        clearTimeout(successTimeoutRef.current);
      }
      
      // Reset success message after 5 seconds
      successTimeoutRef.current = setTimeout(() => {
        setSubmitStatus("idle");
        successTimeoutRef.current = null;
      }, 5000);
    } catch (error) {
      setSubmitStatus("error");
      setErrorMessage(
        error instanceof Error
          ? error.message
          : "Something went wrong. Please try again."
      );
    } finally {
      setIsSubmitting(false);
    }
  };

  const scrollToVideo = () => {
    videoContainerRef.current?.scrollIntoView({
      behavior: prefersReducedMotion ? "auto" : "smooth",
      block: "center",
    });
  };

  return (
    <main className="relative overflow-hidden bg-[var(--background)] text-[var(--foreground)]">
      <div className="pointer-events-none absolute inset-x-0 top-[-45%] h-[520px] bg-[radial-gradient(circle_at_top,_rgba(91,75,255,0.18),_transparent_60%)] dark:bg-[radial-gradient(circle_at_top,_rgba(141,123,255,0.22),_transparent_55%)]" />
      <div className="pointer-events-none absolute inset-x-0 bottom-[-50%] h-[520px] bg-[radial-gradient(circle_at_bottom,_rgba(15,15,30,0.12),_transparent_60%)] dark:bg-[radial-gradient(circle_at_bottom,_rgba(255,255,255,0.08),_transparent_65%)]" />

      <div className="relative mx-auto flex min-h-screen w-full max-w-6xl flex-col gap-16 px-6 pb-24 pt-12 md:px-10">
        <header className="flex items-center justify-between">
          <div className="flex items-center gap-3">
            <div className="flex h-11 w-11 items-center justify-center rounded-2xl border border-[var(--border)] bg-[var(--surface)] shadow-[var(--shadow-soft)]">
              <FileText className="h-5 w-5" strokeWidth={1.8} />
            </div>
            <div className="flex flex-col">
              <span className="text-sm uppercase tracking-[0.35em] text-[var(--muted)]">
                PagePocket
              </span>
              <span className="text-lg font-semibold tracking-tight text-[var(--foreground)]">
                Offline made effortless
              </span>
            </div>
          </div>
          <ThemeToggle />
        </header>

        <div className="grid gap-16 lg:grid-cols-[minmax(0,1fr)_minmax(320px,400px)] lg:items-center">
          <div className="flex flex-col gap-10">
            <div className="space-y-6">
              <h1 className="max-w-xl text-4xl font-semibold leading-[1.08] tracking-tight sm:text-5xl md:text-6xl">
                Save a page once.
                <br />
                Read it wherever life takes you.
              </h1>
              <p className="max-w-xl text-lg text-[var(--muted)]">
                PagePocket turns any link into a clean, offline-perfect
                experience. No loading spinners, no cookie popups—just your
                focused reading list, ready whenever you are.
              </p>
            </div>

            <form
              className="flex w-full max-w-xl flex-col gap-3 rounded-[28px] border border-[var(--border)] bg-[var(--surface)]/90 p-4 shadow-[var(--shadow-soft)] backdrop-blur-sm sm:flex-row sm:items-center"
              onSubmit={handleSubmit}
              noValidate
            >
              <label className="sr-only" htmlFor="email">
                Email address
              </label>
              <div className="flex-1">
                <Input
                  id="email"
                  name="email"
                  type="email"
                  placeholder="you@example.com"
                  autoComplete="email"
                  value={email}
                  onChange={(e) => {
                    setEmail(e.target.value);
                    // Clear error when user starts typing
                    if (submitStatus === "error") {
                      setSubmitStatus("idle");
                      setErrorMessage("");
                    }
                  }}
                  required
                  className="h-12 w-full"
                  aria-invalid={submitStatus === "error"}
                  aria-describedby={
                    submitStatus === "error" ? "email-error" : undefined
                  }
                  disabled={isSubmitting || submitStatus === "success"}
                />
                {submitStatus === "error" && errorMessage && (
                  <p
                    id="email-error"
                    className="mt-2 text-sm text-red-500"
                    role="alert"
                  >
                    {errorMessage}
                  </p>
                )}
              </div>
              <Button
                type="submit"
                className="h-12 gap-2 px-6"
                disabled={isSubmitting || submitStatus === "success"}
              >
                {isSubmitting ? (
                  <>
                    <Loader2 className="h-4 w-4 animate-spin" strokeWidth={1.8} />
                    Joining...
                  </>
                ) : submitStatus === "success" ? (
                  <>
                    <Check className="h-4 w-4" strokeWidth={1.8} />
                    Joined!
                  </>
                ) : (
                  <>
                    <Send className="h-4 w-4" strokeWidth={1.8} />
                    Join waitlist
                  </>
                )}
              </Button>
            </form>

            {submitStatus === "success" && (
              <p className="text-sm text-green-600 dark:text-green-400" role="alert">
                Thanks for joining! We&apos;ll send you an invite soon.
              </p>
            )}

            <div className="flex flex-wrap items-center gap-4 text-sm text-[var(--muted)]">
              <div className="flex items-center gap-2">
                <Lock className="h-4 w-4" strokeWidth={1.8} />
                <span>No spam, unsubscribe anytime</span>
              </div>
              <div className="flex items-center gap-2">
                <Sparkles className="h-4 w-4" strokeWidth={1.8} />
                <span>Private beta invite ships this month</span>
              </div>
            </div>
          </div>

          <div
            ref={videoContainerRef}
            className="flex justify-center lg:justify-end"
          >
            <div className="relative aspect-[9/19] w-[260px] sm:w-[320px]">
              <div className="absolute inset-0 rounded-[44px] border border-[var(--border)] bg-[var(--surface)] shadow-[var(--shadow-soft)]" />
              <div className="absolute inset-[12px] overflow-hidden rounded-[36px] border border-[var(--border)] bg-black">
                <video
                  ref={videoRef}
                  className="h-full w-full object-cover"
                  src="/Preview.mp4"
                  autoPlay={!prefersReducedMotion}
                  muted
                  loop
                  playsInline
                  controls={prefersReducedMotion}
                  aria-label="Preview of PagePocket saving and reading experience"
                />
                <div className="pointer-events-none absolute inset-x-0 bottom-0 bg-gradient-to-t from-black/85 via-black/45 to-transparent" />
                <div className="absolute inset-x-0 bottom-0 flex flex-col gap-3 px-5 pb-6">
                  <div className="flex items-center gap-2 text-xs uppercase tracking-[0.35em] text-white/60">
                    <BookMarked className="h-3.5 w-3.5" strokeWidth={1.8} />
                    Live capture
                  </div>
                  <div className="rounded-[18px] border border-white/10 bg-white/12 px-4 py-3 text-xs text-white/85 shadow-[0_18px_40px_rgba(0,0,0,0.55)]">
                    Watch PagePocket tidy an article, estimate reading time, and
                    store it for offline in seconds.
                  </div>
                </div>
              </div>
              <div className="absolute left-1/2 top-4 h-6 w-28 -translate-x-1/2 rounded-full bg-black" />
              <div className="absolute left-1/2 top-4 h-2 w-14 -translate-x-1/2 rounded-full bg-black/60" />
            </div>
          </div>
        </div>

        <section className="grid gap-8 rounded-[32px] border border-[var(--border)] bg-[var(--surface)]/80 p-10 shadow-[var(--shadow-soft)] backdrop-blur-sm md:grid-cols-3">
          {features.map(({ icon: Icon, title, description }) => (
            <div key={title} className="flex flex-col gap-4">
              <div className="flex h-12 w-12 items-center justify-center rounded-2xl border border-[var(--border)] bg-[var(--surface-muted)] text-[var(--foreground)]">
                <Icon className="h-6 w-6" strokeWidth={1.7} />
              </div>
              <div className="space-y-2">
                <h3 className="text-lg font-semibold tracking-tight">{title}</h3>
                <p className="text-sm text-[var(--muted)]">{description}</p>
              </div>
            </div>
          ))}
        </section>

        <section className="flex flex-col gap-6 rounded-[28px] border border-[var(--border)] bg-[var(--surface)]/60 px-8 py-10 shadow-[var(--shadow-soft)] backdrop-blur-sm lg:flex-row lg:items-center lg:justify-between">
          <div className="space-y-3 max-lg:text-center lg:max-w-2xl">
            <h2 className="text-2xl font-semibold tracking-tight md:text-3xl">
              Pack a reading list before your next commute, flight, or focus
              block.
            </h2>
            <p className="text-base text-[var(--muted)]">
              Drop in links, PDFs, or research tabs and let PagePocket clean,
              organise, and surface them when you have the time to read.
            </p>
          </div>
          <Button
            variant="secondary"
            className="h-12 px-8 text-sm font-semibold"
            onClick={scrollToVideo}
          >
            See how it works
          </Button>
        </section>

        <section className="grid gap-6 text-center sm:grid-cols-3">
          {stats.map((stat) => (
            <div
              key={stat.label}
              className="rounded-[24px] border border-[var(--border)] bg-[var(--surface)]/70 px-6 py-8 shadow-[var(--shadow-soft)]"
            >
              <p className="text-3xl font-semibold tracking-tight">{stat.value}</p>
              <p className="mt-1 text-xs uppercase tracking-[0.35em] text-[var(--muted)]">
                {stat.label}
              </p>
            </div>
          ))}
        </section>
      </div>
    </main>
  );
}
