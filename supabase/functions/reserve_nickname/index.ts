import { serve } from "https://deno.land/std@0.224.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

type Body = { nickname: string };

serve(async (req) => {
  try {
    const auth = req.headers.get("authorization") ?? req.headers.get("Authorization");
    if (!auth?.startsWith("Bearer ")) return new Response(JSON.stringify({ error: "missing_bearer" }), { status: 401 });
    const token = auth.slice("Bearer ".length);
    const url = Deno.env.get("SUPABASE_URL")!;
    const anon = Deno.env.get("SUPABASE_ANON_KEY")!;
    const supabase = createClient(url, anon, { global: { headers: { Authorization: `Bearer ${token}` } } });
    const { data: userData, error: userErr } = await supabase.auth.getUser(token);
    if (userErr || !userData?.user) return new Response(JSON.stringify({ error: "invalid_jwt" }), { status: 401 });
    const uid = userData.user.id;

    const body: Body = await req.json();
    const nickname = (body?.nickname ?? '').trim().toLowerCase();
    if (!nickname || nickname.length < 3) return new Response(JSON.stringify({ error: "invalid_nickname" }), { status: 400 });

    // Ellenőrizzük foglalt-e máshoz
    const { data: taken } = await supabase.from('profiles').select('id').eq('nickname', nickname).limit(1);
    if (taken && taken.length > 0 && taken[0].id !== uid) {
      return new Response(JSON.stringify({ error: 'nickname_taken' }), { status: 409 });
    }

    // Upsert saját profilom
    const { error: upErr } = await supabase.from('profiles').upsert({ id: uid, nickname }, { onConflict: 'id' });
    if (upErr) return new Response(JSON.stringify({ error: upErr.message }), { status: 400 });

    return new Response(JSON.stringify({ ok: true }), { headers: { 'content-type': 'application/json' } });
  } catch (e) {
    return new Response(JSON.stringify({ error: String(e?.message ?? e) }), { status: 500 });
  }
});
