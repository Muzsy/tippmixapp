# Fórum modul – Moderátori vezérlés és szerver aggregáció (HU)

## Moderátori munkafolyamat
- Az AppBar menüben a moderátorok rögzíthetik vagy feloldhatják, zárolhatják vagy feloldhatják a szálakat.
- A műveletek optimistán frissülnek és siker/hiba üzenetet jelenítenek meg.

## Zárolt szálak
- A kompozitor azonnal letilt, amikor a szál zárolt lesz.
- Szalag jelenik meg, a posztolás nem engedélyezett.

## Szerver oldali szavazat aggregáció
- A Cloud Functions a `posts/{postId}.votesCount` mezőt frissíti szavazat hozzáadásakor vagy törlésekor.
- A kliens a szerver értékét jeleníti meg, könnyű lokális deltával.
