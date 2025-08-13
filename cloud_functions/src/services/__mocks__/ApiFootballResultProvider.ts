import { IResultProvider } from "../ResultProvider";
import path from "path";
import fs from "fs";
export class ApiFootballResultProvider implements IResultProvider {
  async getScoresByFixtureIds(ids: string[]) {
    const p = path.resolve(__dirname, "../../../mock_apifootball/fixtures_sample.json");
    const raw = JSON.parse(fs.readFileSync(p, "utf8"));
    const map: Record<string, any> = {};
    for (const f of raw.fixtures) map[String(f.fixture.id)] = f;
    return ids.map((id) => {
      const f = map[String(id)];
      if (!f) return { id, status: "pending" } as any;
      const home = f.goals?.home ?? 0, away = f.goals?.away ?? 0;
      const status = f.fixture?.status?.short || "FT";
      let outcome: "won"|"lost"|"void"|"pending" = "pending";
      if (status === "FT") outcome = home === away ? "void" : (home > away ? "home" : "away") as any;
      return { id, status, goals: { home, away }, outcome } as any;
    });
  }
}
export default ApiFootballResultProvider;
