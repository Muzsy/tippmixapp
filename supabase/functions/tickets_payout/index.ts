import { serve } from "https://deno.land/std@0.224.0/http/server.ts";

export async function handler(_req: Request): Promise<Response> {
  return new Response(
    JSON.stringify({ ok: true, message: "tickets_payout placeholder" }),
    { headers: { "content-type": "application/json" } },
  );
}

serve(handler);
