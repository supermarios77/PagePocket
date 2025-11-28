import { NextRequest, NextResponse } from "next/server";

export const runtime = "edge";

export async function POST(request: NextRequest) {
  try {
    const body = await request.json();
    const { email } = body;

    // Validate email format
    if (!email || typeof email !== "string") {
      return NextResponse.json(
        { error: "Email is required" },
        { status: 400 }
      );
    }

    // Basic email validation
    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    if (!emailRegex.test(email)) {
      return NextResponse.json(
        { error: "Invalid email format" },
        { status: 400 }
      );
    }

    // TODO: Integrate with your email service (e.g., Resend, SendGrid, ConvertKit, etc.)
    // For now, we'll just log it and return success
    // Example integration:
    // await resend.emails.send({
    //   from: "PagePocket <waitlist@pagepocket.app>",
    //   to: email,
    //   subject: "Welcome to PagePocket waitlist",
    //   html: "<p>Thanks for joining!</p>",
    // });

    console.log("Waitlist signup:", email);

    return NextResponse.json(
      { message: "Successfully joined waitlist" },
      { status: 200 }
    );
  } catch (error) {
    console.error("Waitlist submission error:", error);
    return NextResponse.json(
      { error: "Failed to process request" },
      { status: 500 }
    );
  }
}

