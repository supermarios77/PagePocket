"use client";

import * as React from "react";

import { cn } from "@/lib/utils";

export type InputProps = React.InputHTMLAttributes<HTMLInputElement>;

export const Input = React.forwardRef<HTMLInputElement, InputProps>(
  ({ className, type = "text", ...props }, ref) => {
    return (
      <input
        ref={ref}
        type={type}
        className={cn(
          "flex h-12 w-full rounded-full border border-white/10 bg-white/10/50 px-5 text-base text-white placeholder:text-white/60 transition focus-visible:border-white/20 focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-[#8b5cf6] focus-visible:ring-offset-2 focus-visible:ring-offset-black",
          className,
        )}
        {...props}
      />
    );
  },
);

Input.displayName = "Input";
