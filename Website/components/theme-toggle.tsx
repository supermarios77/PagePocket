"use client";

import { Moon, Sun } from "lucide-react";

import { useTheme } from "@/components/theme-provider";
import { Button } from "@/components/ui/button";

export function ThemeToggle() {
  const { theme, toggleTheme } = useTheme();
  const Icon = theme === "light" ? Moon : Sun;

  return (
    <Button
      variant="ghost"
      className="h-11 w-11 rounded-full border border-[var(--border)] bg-[var(--surface)] p-0 text-[var(--foreground)] shadow-[var(--shadow-soft)] hover:bg-[var(--surface-muted)]"
      aria-label="Toggle theme"
      onClick={toggleTheme}
    >
      <Icon className="h-5 w-5" strokeWidth={1.8} />
    </Button>
  );
}
