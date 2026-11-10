# CLAUDE.md

Dit is **Nook**, een 3D companion-diorama in Godot. Lees `PLAN.md` voor de visie, architectuur en fases.

## Over de gebruiker
- Ervaren webdeveloper (PHP/Laravel, JavaScript), maar **nieuw met Godot en GDScript**.
- Communiceer in het Nederlands. Code, bestandsnamen en comments in het Engels.
- Leg Godot-concepten kort uit als ze voor het eerst voorkomen (nodes, scenes, signals, autoloads, resources).
- Als iets in de editor moet gebeuren, geef exacte stappen: welk menu, welke node, welke property.

## Techniek
- **Godot 4.x**, nieuwste stabiele versie. Gebruik uitsluitend Godot 4-API. Geen Godot 3-syntax (dus `@export`, `@onready`, `Node3D`, `CharacterBody3D`, `create_tween()`, `signal.connect(callable)`, `super()`).
- **GDScript met statische types** overal (`var speed: float = 2.0`, `func foo() -> void:`).
- Eén klasse per bestand, gebruik `class_name` waar zinvol.

## Werkafspraken
- Werk **één fase uit PLAN.md tegelijk** af. Begin niet aan de volgende fase zonder akkoord.
- Sluit elke fase af met: wat er gebouwd is, hoe je het test, en wat de gebruiker visueel moet controleren.
- **Logica en presentatie strikt gescheiden.** Simulatiecode (`sim/`, `core/`) mag geen meshes, materialen of animaties aanraken.
- Bouw visuele dingen bij voorkeur **in code** op. Houd `.tscn`-bestanden simpel en bewerk ze voorzichtig (geen UID's verzinnen).
- Objectdefinities zijn data (`Resource`), niet hardcoded in het brein.
- Tunable getallen als `@export` of in resources, zodat ze zonder codewijziging aan te passen zijn.

## Controleren
- De gebruiker werkt op Windows. Gebruik in de terminal **`godot_console`** (niet `godot`), anders komt de output niet in de terminal terecht.
- Draai na wijzigingen het project headless om laad- en scriptfouten te vangen, bijvoorbeeld:
  `godot_console --headless --path . --quit-after 120`
- Je kunt de editor niet zien. Vraag de gebruiker om visuele feedback of een screenshot als iets er goed uit moet zien.