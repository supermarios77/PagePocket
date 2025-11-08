"use client";

import * as React from "react";

import { cn } from "@/lib/utils";

const baseStyles =
  "inline-flex items-center justify-center whitespace-nowrap rounded-full text-sm font-semibold transition-transform duration-200 focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-offset-2 focus-visible:ring-offset-black disabled:pointer-events-none disabled:opacity-40";

const variantStyles = {
  primary:
    "bg-[#8053ff] text-white shadow-[0px_16px_50px_rgba(128,83,255,0.45)] hover:-translate-y-0.5 hover:bg-[#6f3cff]",
  ghost:
    "bg-white/10 text-white hover:bg-white/15 shadow-[0px_12px_30px_rgba(0,0,0,0.35)]",
};

export type ButtonProps = React.ButtonHTMLAttributes<HTMLButtonElement> & {
  variant?: keyof typeof variantStyles;
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
