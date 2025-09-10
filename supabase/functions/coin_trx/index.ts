// deno-lint-ignore-file no-explicit-any
import { serve } from "https://deno.land/std@0.224.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

type Body = { type: string; delta: number; ref_id?: string };

serve(async (req) => {
  try {
    const auth = req.headers.get("authorization") ?? req.headers.get("Authorization");
    if (!auth?.startsWith("Bearer ")) {
      return new Response(JSON.stringify({ error: "missing_bearer" }), { status: 401 });
    }
    const token = auth.slice("Bearer ".length);
    const url = Deno.env.get("SUPABASE_URL")!;
    const anon = Deno.env.get("SUPABASE_ANON_KEY")!;
    const supabase = createClient(url, anon, { global: { headers: { Authorization: `Bearer ${token}` } } });

    const { data: userData, error: userErr } = await supabase.auth.getUser(token);
    if (userErr || !userData?.user) return new Response(JSON.stringify({ error: "invalid_jwt" }), { status: 401 });
    const uid = userData.user.id;

    const body: Body = await req.json();
    if (!body?.type || typeof body.delta !== "number") {
      return new Response(JSON.stringify({ error: "bad_request" }), { status: 400 });
    }

    // Idempotencia: ha már könyveltük ezt a ref_id-t, térjünk vissza
    if (body.ref_id) {
      const { data: dup } = await supabase
        .from("coins_ledger")
        .select("id")
        .eq("user_id", uid)
        .eq("ref_id", body.ref_id)
        .limit(1);
      if (dup && dup.length > 0) {
        return new Response(JSON.stringify({ ok: true, idempotent: true }), { status: 200 });
      }
    }

    // Legutóbbi egyenleg lekérdezése
    const { data: last } = await supabase
      .from("coins_ledger")
      .select("balance_after")
      .eq("user_id", uid)
      .order("created_at", { ascending: false })
      .limit(1);
    const current = last && last.length > 0 ? Number(last[0].balance_after) : 0;
    const balance_after = current + Number(body.delta);

    const { error: insErr } = await supabase.from("coins_ledger").insert({
      user_id: uid,
      type: body.type,
      delta: body.delta,
      balance_after,
      ref_id: body.ref_id ?? null,
    });
    if (insErr) return new Response(JSON.stringify({ error: insErr.message }), { status: 400 });

    return new Response(JSON.stringify({ ok: true, balance_after }), {
      headers: { "content-type": "application/json" },
    });
  } catch (e) {
    return new Response(JSON.stringify({ error: String(e?.message ?? e) }), { status: 500 });
  }
});
