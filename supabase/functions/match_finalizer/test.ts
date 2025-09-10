import { assertEquals } from "https://deno.land/std@0.224.0/assert/mod.ts";
import { handler } from "./index.ts";

Deno.test("match_finalizer responds ok", async () => {
  const resp = await handler(new Request("http://localhost"));
  const body = await resp.json();
  assertEquals(body.ok, true);
});

