# Nook: projectplan

Nook is een klein 3D-kamertje (diorama) waarin een wezentje zijn eigen dag leeft. Je zet het aan, laat het de hele dag openstaan op een (tweede) scherm, en het voelt alsof het leeft: het slaapt, eet, speelt, kijkt uit het raam, merkt het als je weg bent en is blij als je terugkomt.

Het "leven" komt uit gedrag, niet uit techniek. Eerst moet het met simpele vormen al levend aanvoelen. Pas daarna maken we het mooi.

## Uitgangspunten

- **Engine:** Godot 4.x (nieuwste stabiele versie), GDScript met statische types.
- **Weergave:** 3D diorama met een vaste camera, schuin van bovenaf. Eén kamer.
- **Art:** alles opgebouwd uit primitieve vormen in code (bollen, capsules, boxen) met toon shading. Geen externe modellen nodig. Animatie is procedureel (in code).
- **Draait de hele dag:** framerate begrensd op 30 fps, zuinig met CPU en GPU.
- **Logica los van presentatie:** het brein weet niets van meshes of animaties. De presentatielaag luistert naar de toestand en laat die zien.

## Architectuur

### Simulatie (logica)
- **SimClock:** vaste tick (10 per seconde) los van de framerate. Bevat een `time_scale` voor debuggen (bijv. 1x, 10x, 60x).
- **Needs:** behoeftes van 0 tot 100 die per tick veranderen: `energy`, `hunger`, `fun`, `social`. Elke behoefte heeft een vervalsnelheid, gedefinieerd als data.
- **SmartObject:** een object in de kamer dat adverteert wat het oplevert. Bijvoorbeeld het bed: `energy +X per minuut`, duur, animatie, interactiepunt. Objecten zijn data-gedreven via een `Resource` (`ObjectDefinition`), zodat een nieuw object toevoegen geen code in het brein vereist.
- **Brain (utility AI):** kiest periodiek de beste actie. Score per kandidaat:
  `score = Σ (urgentie van behoefte × winst voor die behoefte) × afstandsfactor × kleine willekeurige factor`
  Urgentie loopt niet-lineair op (een bijna lege behoefte weegt veel zwaarder). Er is ook altijd een "niets doen / rondkijken / rondlopen"-optie met een basisscore, zodat het wezentje niet de hele dag efficiënt bezig is.
- **Actions:** een queue van stappen, bijvoorbeeld `WalkTo(bed) → Play("lie_down") → Sleep(until energy > 95) → Play("get_up")`. Acties kunnen onderbroken worden (bijv. als jij terugkomt).
- **Mood:** afgeleid uit de behoeftes. Stuurt houding, tempo en gezichtsuitdrukking aan.

### Wereld en tijd
- **TimeOfDay:** gekoppeld aan de echte klok. Bepaalt licht en slaapritme (slaperig 's avonds, slaapt 's nachts, traag in de ochtend).
- **PresenceDetector:** detecteert of de gebruiker er is. Godot ziet invoer alleen als het venster focus heeft, dus we pollen de globale muispositie met `DisplayServer.mouse_get_position()`. Geen beweging gedurende X minuten betekent afk. Toetsenbord buiten het venster detecteren is voor later.

### Presentatie
- **CreatureView:** het wezentje als samengestelde 3D-vormen: lijfje, ogen, pootjes/voetjes. Procedurele animatie met tweens en sinusgolven.
- **RoomView:** vloer, twee muren, raam, meubels. Alles uit primitieve vormen.
- **Lighting:** zonlicht via het raam dat van kleur en hoek verandert met de tijd van de dag, plus een lampje voor de avond.

### Opslag
- **SaveSystem:** slaat behoeftes, positie, huidige actie en geheugen op als JSON in `user://`. Bij opstarten wordt de offline tijd uitgerekend en verwerkt.

## Mapstructuur

```
res://
  core/          # SimClock, TimeOfDay, PresenceDetector, SaveSystem (autoloads)
  sim/           # Needs, Brain, Actions, Mood
  objects/       # ObjectDefinition resource + definities (.tres)
  creature/      # Creature (logica) + CreatureView (presentatie)
  room/          # RoomView, meubels
  ui/            # Debug-overlay
  shaders/       # Toon shader
  main.tscn
```

## Fases

Werk één fase tegelijk af. Elke fase eindigt met een werkend, opgestart project en een korte lijst van wat de gebruiker in de editor of het spel moet controleren.

### Fase 0: Fundament
- Godot 4-project opzetten met de mapstructuur hierboven.
- `main.tscn` met vaste camera, vloer, twee muren, een gat voor het raam, basisbelichting.
- Framerate begrensd op 30 fps.
- **Klaar als:** het project opstart en je een leeg kamertje ziet.

### Fase 1: Wezentje en beweging
- Wezentje als placeholder (capsule met twee ogen).
- Kan naar een willekeurig punt op de vloer lopen: aanlopen, uitlopen, draaien richting looprichting.
- Simpele idle: ademen (zachte schaalverandering) en knipperen op willekeurige momenten.
- **Klaar als:** het wezentje rustig rondloopt en stilstaat zonder schokken.

### Fase 2: Brein
- Needs, SmartObject, Brain en Actions zoals hierboven.
- Vier objecten als blokken: bed (`energy`), voerbak (`hunger`), speeltje (`fun`), raam (`fun`, licht `social`).
- **Debug-overlay** (toggle met F1): alle behoeftes, huidige actie, en de scores van alle kandidaten bij de laatste keuze. Dit is essentieel om het gedrag te kunnen tunen.
- Toetsen om `time_scale` te wisselen (1x / 10x / 60x).
- **Klaar als:** het wezentje op 60x snelheid een geloofwaardige dag doorloopt en je in de overlay kunt zien waarom het kiest wat het kiest.

### Fase 3: Tijd en aanwezigheid
- TimeOfDay op de echte klok, dag-nachtlicht via het raam.
- Slaapritme beïnvloedt de energiebehoefte en de keuzes.
- PresenceDetector: bij afk gaat het wezentje na een tijdje zitten wachten of dutten. Bij terugkomst een korte blije reactie (opkijken, huppeltje).
- **Klaar als:** het licht klopt met de echte tijd en het wezentje merkbaar reageert op weggaan en terugkomen.

### Fase 4: Levensechtheid
- Toon shader en zachte schaduwen.
- Squash and stretch bij springen en landen.
- Meerdere idle-varianten: rekken, gapen, rondkijken, krabben.
- Ogen en hoofd volgen af en toe de muiscursor (geprojecteerd op de scène).
- Gezichtsuitdrukking afhankelijk van mood.
- Meubels mooier maken, nog steeds uit primitieve vormen.
- **Klaar als:** het wezentje er af en toe iets onverwachts doet en je het minutenlang wilt blijven bekijken.

### Fase 5: Opslag en offline tijd
- Automatisch opslaan elke paar minuten en bij afsluiten.
- Bij opstarten offline tijd verwerken: hoe lang was het dicht, wat is er in de tussentijd "gebeurd" (bijv. geslapen, nu honger).
- **Klaar als:** afsluiten en opnieuw openen een logische toestand oplevert.

### Fase 6: Extra's (later, in overleg)
- Geheugen: dingen onthouden zoals hoe lang je weg was of zijn favoriete plek.
- Tekstballonnetjes met korte gedachtes.
- Meer objecten en kleine gebeurtenissen (een vlinder bij het raam, regen).
- Vensteropties: randloos, altijd bovenop, klein formaat.
- Eventueel een lokaal taalmodel voor af en toe een gedachte.

## Tuning-principes
- Liever te traag dan te druk. Echte dieren doen vaak een tijdje niks.
- Nooit perfect efficiënt: een beetje willekeur en "verkeerde" keuzes maken het geloofwaardig.
- Elke actie heeft een aanloop en een afronding (gaan liggen, opstaan), nooit direct wisselen.