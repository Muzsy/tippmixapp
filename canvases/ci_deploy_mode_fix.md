# Cél

A `deploy.yml` jelenleg fixen `MODE=dev`-vel fut, ezért `main` branchről is a *dev* projektbe deployol. A feladat az, hogy a MODE automatikusan a branch (dev→dev, main→prod), illetve a `workflow_dispatch` input (`target`) alapján álljon be.

# Kontextus

* Repo: `tippmixapp-main`
* Érintett fájl: `.github/workflows/deploy.yml`
* Jelenlegi viselkedés: `env.MODE: dev` a job szintjén → minden futás dev-re céloz.
* Elvárt viselkedés:

  * `push` esetén: `main` → `prod`, minden más → `dev`
  * `workflow_dispatch` esetén: a `target` input értéke határozza meg (dev/prod)
  * A további lépések a `MODE` változót használják (már most is `$MODE` szerint választ projektet).

# Megoldás röviden

* **Eltávolítjuk** a job-szintű `env.MODE: dev` beállítást.
* **Bevezetünk** egy korai lépést (checkout után) ami beírja a döntött `MODE` értéket a `$GITHUB_ENV`-be.
* A meglévő deploy lépések változatlanul a `$MODE`-ot használják a projekt kiválasztásához.

# Elfogadási kritériumok

* `dev` branch push → `tippmix-dev` projektbe deployol.
* `main` branch push → `tippmix-prod` projektbe deployol.
* Kézi `workflow_dispatch` indításkor a `target` választás (dev/prod) érvényesül.
* A workflow továbbra is non‑interactive módon fut (ADC beállítva `google-github-actions/auth@v2`-vel).

# Hivatkozás

* Ennek a vászonnak a címe szerepeljen a Codex YAML `references` mezőjében kiegészítő információként.

# Megjegyzés

A többi CI lépés (Flutter analyze, emulatoros integration test, Firestore rules teszt, Functions build) a jelenlegi zip alapján rendben van, nem igényel módosítást ehhez a feladathoz.
