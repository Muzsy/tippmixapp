 import path from "path";
 import fs from "fs";
 import type { ScoreResult } from "../ApiFootballResultProvider";

 /**
  * Mock implementation of ApiFootballResultProvider used in tests/dev.
  * Reads static JSON from cloud_functions/mock_apifootball/fixtures_sample.json
  * and returns the same shape as the real provider's getScores().
  */
 export class ApiFootballResultProvider {
   async getScores(ids: string[]): Promise<ScoreResult[]> {
     const p = path.resolve(
       __dirname,
       "../../../mock_apifootball/fixtures_sample.json"
     );
     const raw = JSON.parse(fs.readFileSync(p, "utf8"));
     const map: Record<string, any> = {};
     for (const f of raw.fixtures) map[String(f.fixture.id)] = f;

     const results: ScoreResult[] = [];
     for (const id of ids) {
       const f = map[String(id)];
       if (!f) {
         results.push({ id: String(id), sport_key: "soccer", completed: false });
         continue;
       }
       const goalsHome = f.goals?.home ?? null;
       const goalsAway = f.goals?.away ?? null;
       const statusShort = f.fixture?.status?.short || "FT";

       results.push({
         id: String(id),
         sport_key: "soccer",
         completed: statusShort === "FT",
         scores:
           goalsHome !== null && goalsAway !== null
             ? { home: goalsHome, away: goalsAway }
             : undefined,
         home_team: f?.teams?.home?.name,
         away_team: f?.teams?.away?.name,
       });
     }
     return results;
   }
}
export default ApiFootballResultProvider;
