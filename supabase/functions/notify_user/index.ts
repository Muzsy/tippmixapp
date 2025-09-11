// Minimal Edge Function to acknowledge notifications (stub)
// JWT is verified by default in Supabase deploy; keep logic simple for now.
import { serve } from "https://deno.land/std@0.224.0/http/server.ts";

export async function handler(req: Request): Promise<Response> {
  try {
    // In a real implementation, parse payload and send email/push.
    // We just log and return OK for now.
    const body = await req.text();
    console.log("notify_user payload:", body);
    return new Response("OK", { status: 200 });
  } catch (e) {
    console.error("notify_user error", e);
    return new Response("ERR", { status: 500 });
  }
}

serve(handler);

