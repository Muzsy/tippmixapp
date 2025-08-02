# AppColors Baseline (Sprint 0)

A TippmixApp jelenlegi kódbázisában **nincs központi `AppColors` osztály vagy paletta**. Az UI‑komponensek kizárólag a `Material` alapszíneit (`Colors.<name>`) hívják meg közvetlenül, hard‑coded módon.

Az automata szín‑audit (Sprint 0 T0.2‑T0.3) szerint a `lib/` könyvtárban összesen **17** ilyen kézi hivatkozás található.

| Material szín | Előfordulás száma | Megjegyzés |
|--------------|------------------|-----------|
| `Colors.red` | 7 | Hibajelzés / kiemelés |
| `Colors.black` | 3 | Szöveg / ikon alapszín |
| `Colors.grey` | 3 | Neutrális háttér / divider |
| `Colors.white` | 3 | Kontrasztos szöveg / ikon |
| `Colors.yellow` | 2 | Figyelmeztetés |
| `Colors.blue` | 1 | Primer link / CTA |
| `Colors.green` | 1 | Siker‑státusz |

> **Megjegyzés:** Egyetlen fájl sem definiál saját szín‑konstansokat, minden előfordulás közvetlen `Colors.*` használat. A szórványos, kevert használat miatt a refaktor (Sprint 1–2) első lépése ezeknek a hivatkozásoknak a cseréje `Theme.of(context).colorScheme.*` vagy `ThemeExtension` referenciákra.

## Következő lépések

1. **ThemeBuilder + ThemeService** (Sprint 1): központi paletta létrehozása FlexColorScheme‑mel.
2. **Widget Refactor** (Sprint 2): minden fenti `Colors.*` referencia cseréje a központi theme‑re.
3. **Lint gate**: `avoid‑hard‑coded‑colors` szabály aktiválása, hogy ne kerüljön vissza manuális color.
