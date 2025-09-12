// deno-lint-ignore-file no-explicit-any
import { serve } from "https://deno.land/std@0.224.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2.46.1";

const url = Deno.env.get("SUPABASE_URL")!;
const anon = Deno.env.get("SUPABASE_ANON_KEY")!;
const service = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;

serve(async (req: Request) => {
  try {
    const { delta, reason, meta } = await req.json();
    const authHeader = req.headers.get("Authorization");
    const token = authHeader?.replace("Bearer ", "");
    if (!token) return new Response(JSON.stringify({ error: "missing token" }), { status: 401 });

    const supaAuth = createClient(url, anon, { global: { headers: { Authorization: `Bearer ${token}` } } });
    const { data: userData, error: userErr } = await supaAuth.auth.getUser();
    if (userErr || !userData?.user) return new Response(JSON.stringify({ error: "unauthorized" }), { status: 401 });
    const uid = userData.user.id;

    // RLS bypass az íráshoz
    const admin = createClient(url, service);
    const { error: insErr } = await admin.from("coins_ledger").insert({ user_id: uid, delta, reason, meta });
    if (insErr) throw insErr;

    return new Response(JSON.stringify({ ok: true }), { status: 200 });
  } catch (e: any) {
    return new Response(JSON.stringify({ error: e?.message ?? "internal" }), { status: 500 });
  }
});
