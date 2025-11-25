"use client";

import * as React from "react";

import { cn } from "@/lib/utils";

const baseStyles =
  "inline-flex items-center justify-center whitespace-nowrap rounded-full border border-transparent text-sm font-semibold transition-all duration-200 focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-[var(--accent)] focus-visible:ring-offset-2 focus-visible:ring-offset-[var(--background)] disabled:pointer-events-none disabled:opacity-40";

const variantStyles = {
  primary:
    "bg-[var(--accent)] text-[var(--accent-contrast)] shadow-[var(--shadow-soft)] hover:-translate-y-0.5 hover:shadow-[0_22px_60px_-28px_rgba(72,55,255,0.65)]",
        secondary:
    "border-[var(--border)] bg-[var(--surface)] text-[var(--foreground)] shadow-[var(--shadow-soft)] hover:-translate-y-0.5 hover:bg-[var(--surface-muted)]",
        ghost:
    "border-transparent bg-transparent text-[var(--foreground)] hover:bg-[var(--surface-muted)]",
} as const;

type Variant = keyof typeof variantStyles;

export type ButtonProps = React.ButtonHTMLAttributes<HTMLButtonElement> & {
  variant?: Variant;
};

export const Button = React.forwardRef<HTMLButtonElement, ButtonProps>(
  ({ className, variant = "primary", type = "button", ...props }, ref) => {
  return (
      <button
        ref={ref}
        type={type}
        className={cn(baseStyles, variantStyles[variant], className)}
      {...props}
    />
    );
  },
);

Button.displayName = "Button";
