T3.8 – Canvas + Codex YAML véglegesítése, review
🎯 Funkció
A cél, hogy a Sprint3-hoz tartozó összes Codex vászon és YAML lépéslista teljesen lefedje az összes fejlesztési, tesztelési és auditálási lépést, egységes, visszakereshető formában. A végleges canvas és YAML a /canvases és /codex/goals mappában elérhető, ez alapján a Codex és a fejlesztői csapat minden további workflow-t automatizálni, ellenőrizni tud.

🧠 Fejlesztési részletek
A vászon (sprint3_dark_dynamic.md) és a YAML lépéslista (fill_canvas_sprint3_dark_dynamic.yaml) minden T3.1–T3.7 feladatot, elvárást, kapcsolódást és checklistet tartalmaz.

Tartalmazza a teljes sprint Definition of Done-t, a kockázatokat, coverage-igazolást, manuális workflow-részeket is (pl. golden/a11y manuális commit, Codex tilalom).

Minden elágazás, platformfüggő viselkedés, hibakezelés, perzisztencia, visszatöltés, CI pipeline, linter, audit workflow dokumentálva.

Review/checklist: minden output, coverage, dokumentum, commit naprakészen elérhető-e.

Végső jóváhagyás után a canvas és a YAML a projekt állandó dokumentációjának részévé válik.

🧪 Tesztállapot
Minden canvas, yaml, workflow lépés duplán ellenőrizve.

Teszt: minden fejlesztési lépéshez tartozik checklist és coverage.

CI pipeline a kapcsolódó unit/widget teszteket zölden futtatja.

🌍 Lokalizáció
A teljes vászon és yaml magyarul készült, megfelel a projekt szabványainak.

Minden felhasználói és fejlesztői dokumentáció lokalizálható.

📎 Kapcsolódások
T3.1–T3.7: Minden korábbi sprint3 feladat dokumentációja.

/canvases, /codex/goals: Dokumentumok helye.

QA, fejlesztői review: Stakeholder-ellenőrzés, végső jóváhagyás.

CI pipeline, Codex engine: Workflow, audit és coverage validáció.