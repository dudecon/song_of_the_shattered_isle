# Song of the Shattered Isle — Design Bible

**Project:** Song of the Shattered Isle (working titles: *Animal Rage*, *Symphony of the Seas*)  
**Format:** Living design document (companion to the master spreadsheet `Song of the Shattered Isle.xlsx`)  
**Purpose:** Narrative, systems, and world reference. The spreadsheet remains the best tool for side-by-side comparison, formulas, and matrix views.

\---

## 1\. Core Concept

A shattered, broken archipelago adventure game where **animals and people** start divided across fragmented islands.

* The world is literally broken apart.
* Animals begin wild and angry ("Animal Rage" phase).
* People are low-tech thatched-roof natives living among the ruins of lost high technology.
* Progression involves reuniting islands, taming/domesticating animals, advancing technology, and awakening ancient forces (especially the **Octopus** and **Eel**).
* A sophisticated **faction/actor simulation** (Island, Animals, People, Structures, Octopus, Eel) with trait-based arbitration drives conflict, cooperation, and world state changes.

**Central Fantasy:** Animals evolve through eating and interaction. The Special Animal (a unique rainbow protector) sits at the center. Everything is trying to reach or protect the middle.

**Key Animal Notes (from Game Overview):**

* Start in eggs
* Start on the broken island
* Trying to get to the special animal in the middle
* Upgrade by eating
* Really angry at being hunted at the start
* People are thatched-roof natives, but lost technology abounds

**The Deep Structure (from the design map):**  
The game is not a simple linear progression. There are **three paths** to the true ending:

1. The **narrow gate** of near-perfect balance between opposing forces (the "true" path).
2. A path of **excessive Order** (too much Octopus influence) — walls, division, coastal cities, control.
3. A path of **excessive Openness/Chaos** (too much Eel influence) — interconnectedness, bridges, fluidity, loss of boundaries.

Both "failure" paths can still reach the goal, and they can even flip into each other through a cataclysmic Kaiju-scale battle. The ideal ending — **Symphony of the Seas** — is a fugue state of harmony between all animals, humans, and the restored island itself.

\---

## 2\. The Islands

There are 14 islands (indexed 0–13). Most start with specific native "inhabitants" (resources + creatures).

|Index|Name|Native Inhabitants|Notes|
|-|-|-|-|
|0|Ocean|Fish, Clog Fish, Blob Fish, Blade Fish, Octopus, Furball|—|
|1|Meadows|Grass|—|
|2|Peaks|Frost, Fur|—|
|3|Wetland|Scales|—|
|4|Forest|Wood|—|
|5|Volcano|Metal, Wind Bird, Stove|Volcano mountain in the middle|
|6|Caves|Rock|—|
|7|Karst Pillars|Song Bird|—|
|8|Central Spire|Special Animal|The heart / goal|
|9|Deepest Place (ocean)|Eel, Rory|Eel lives here; last of its kind|
|10|Waterfalls|squirm, Squid|—|
|11|Human|Flame, Construct, Hider|Becomes adventure ports around the "perfect Island"|
|12|Gulley|Finder, Core|Becomes adventure islands nearby the perfect Island|
|13|Thornbush|Dragon, Cleanerbird|Becomes boss islands far from the perfect Island|

Later islands (11–13) appear to represent transformed or "human-adjacent" zones.

\---

## 3\. The Three Paths to Symphony of the Seas

This is the **core narrative architecture** of the game, as mapped out in the design diagram. It is more important than any individual phase or spreadsheet matrix.

### The Overall Shape

Progression begins at the **Foundational Level** (bottom left of the map) in a state of brokenness and Animal Rage.

From there, three routes lead toward the true ending in the top-right:

* The **narrow gate** of near-perfect balance (the "true" or hardest path).
* A path of **excessive Order / Control** (top route).
* A path of **excessive Openness / Chaos** (bottom route).

Crucially, **all three routes can still reach the Symphony of the Seas**. There is no hard "game over" for imbalance — only different flavors of struggle and different ways to arrive at harmony.

### The Two Partial Failure States

**Path of Excessive Order (Octopus of Order)**

* Dominated by structure, walls, coastal cities, hierarchy, and control.
* The Octopus becomes a force of rigid order ("the Octopus of Order").
* People attempt to repair and then lock down the Eel to prevent chaos.
* The world becomes more "civilized" but divided — walls between people and animals, between islands, between classes.
* Leads to a kind of beautiful but sterile or oppressive order.
* Can end in a **Partial Reset**.

**Path of Excessive Openness / Chaos (Eel Unbound)**

* Dominated by interconnection, bridges, gates, fluidity, and the breaking of boundaries.
* The Eel becomes a force of wild interconnectedness and "long tangled" structures.
* Leads to flooding, loss of distinct places, "Drowning of Atlantis" energy, and chaotic megastructures.
* Everything bleeds into everything else.
* Can also end in a **Partial Reset**.

**The Toggle Between Failures**
The two partial failure states are not permanent. A massive **Kaiju battle** — the overthrow of the currently dominant gigafauna (Octopus vs. Eel as world-shaping forces) — can flip one failure state into the other.

### The Goal State: Symphony of the Seas

The true ending, reachable from the balanced path or from either failure path (with enough work and wisdom):

* The physical island is **reunited** into a restored, whole atoll.
* Animals and humans enter a **fugue state** — a living, improvisational harmony where every creature's evolved abilities and every piece of human technology (and culture) play together like voices in a fugue.
* The old Human port island (Island 11) transforms into **adventure ship harbors** ringing the central atoll.
* Mixed crews of humans and highly evolved animals set sail from these harbors to **adventure islands** — the endless post-game content.

This is not a return to a pristine pre-shattering state. It is something new: a living, musical, collaborative world where the lessons of both Order and Chaos have been integrated — and where the Island itself has become an active voice in the fugue (see the Island faction section for its full geological and symphonic role).

### Thematic Resonance

This structure was developed with a 6-year-old's animal ideas at its heart and adult systems thinking around it. It beautifully expresses several deep ideas:

* Balance is difficult and "narrow," but extremes are not dead ends.
* Both too much control and too much dissolution are failures of relationship.
* Redemption and integration are always possible.
* The highest state is not dominance by any single force (even the Special Animal), but a **polyphonic harmony** — the Symphony of the Seas.

The spreadsheet's phase matrix and trait arbitration systems are mechanical tools intended to *support* this narrative shape, not replace it.

\---

## 4\. Phases \& Actor States (Mechanical Implementation)

The detailed phase matrix and actor states in the spreadsheet are a **mechanical implementation** of the three-path narrative described in the previous section. The Octopus-heavy and Eel-heavy routes roughly map to the two partial failure paths (Order vs. Openness/Chaos).

The game progresses through major phases. Each actor (Island, Animals, People, Structures, Octopus, Eel) has an **active / passive / dormant** state per phase.

### High-Level Phase Map

|Title|Phase|Island|Animals|People|Structures|Octopus|Eel|
|-|-|-|-|-|-|-|-|
|**Animal Rage**|1|active, shattered, one broken adventure island...|active, start on their own islands, grass/wood/scales/song/wind|active, very low tech, hunting animals|dormant (grass \& wood)|passive (prevents expedition boats, returns animals home)|dormant (eel-ball in the deepest place)|
|—|2A|passive|active, isolated, untamable|passive (can't use boats/gather sea/advance tech)|passive (add stone)|active|passive|
|—|2P|passive|—|passive|active|—|active|
|—|2I|active|—|active|—|—|—|
|**Symphony of the Seas**|3|active|active|active|active|passive (active on expedition islands)|active|

**Animal Notes (Phase context):**

* Animals are trying to reach the Special Animal in the center.
* Octopus and Eel have powerful, world-altering abilities that activate at different times.

\---

## 5\. The Animals

This is the heart of the document. Animals have:

* **Native Wildness** (domestication difficulty = wildness × individual level)
* Color, signature Fruit, Type, Home Island, Element
* Evolution path (Levels 0–5)
* Rich, flavorful notes

**Core Evolution Rule (from spreadsheet):**

> Animals eat lvl-1, create lvl+1 product (with lvl as \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\~10× byproduct).  
> lvl+1 and up are impassable. Shapes lvl and lvl-1. Sinks/passes through lvl-2 on contact. Excludes lvl-3 and lower in increasing radius.

### Animal Roster

|Animal|Wildness|Type / Element|Home Island|Signature Trait / Note|
|-|-|-|-|-|
|**Cleanerbird**|not-tamable (kill for fruit)|dino / Cleaning|13 (Thornbush)|Acorn black dragon scale fruit. Evolves into increasingly specialized cleaners.|
|**Wood**|2|dino / wood|4 (Forest)|Like an ostrich. Builds, makes, breaks wood. Irridescent apple-pear.|
|**Dragon**|not-tamable|dino / scales|13|Bittersweet fruit when young; eats fish when big. Aquatic + can fly. Black with glowing blue lines.|
|**Blade Fish**|123|fish / Water|0 (Ocean)|Evolves: Small fish → Thornfish → Daggerfish → Swordfish.|
|**Fish**|0|fish / water|0|Simple baseline fish line.|
|**Flame**|0|archaic living fossil / fire|11|Grass-fire → Tongue of flame → Campfire → Blaze → Inferno.|
|**Finder**|5|mammal / Fluff|12 (Gulley)|Opposite of Hider. Needs fluff to approach. Excellent vision but doesn't recognize food. Takes metal to people on island 11 when islands reunite.|
|**Core**|5|mammal / Food|12|Helps Finder find food. White eyes. Can't understand metal.|
|**Hider**|54|robot / technology|11|Stresses out and can make the moon disappear (covers it with a cloud ❓). Burrows, steals, and hides treasure.|
|**Rock**|5|robot / stone|6 (Caves)|Builds everything underground (except dirt). Stone → coal → flint → granite → diamond.|
|**Fur**|1|mammal / fur|2 (Peaks)|Hates water, loves cold, can't swim. Needs Scales for waterproof clothing.|
|**Frost**|0|mammal / ice|2|Natively tamed? Hunting partner. Fur → Pup → Fox → Wolf → Fox-Wolf.|
|**Clog Fish**|67|fish / Water|0|Helps Blob Fish move.|
|**Blob Fish**|89|worm / Decay slime|0|Attacks on its egg make it go CRAZY and kill things.|
|**Stove**|447|dino / Lava|5 (Volcano)|Lava → Stove → Oven → Furnace. Extremely high wildness.|
|**Metal**|8|robot / metal|5|Very slow, carries huge loads. Builds with metal (sometimes rock). Volcano island.|
|**squirm**|0|worm/tentacle / mushroom|10|Invented to root higher tentacle/worm lines (Maggot → Leech → Lamprey).|
|**Scales**|3|dino / scales|3 (Wetland)|For armor and shoes. Needs Fur for comfy clothes.|
|**Eel**|335|worm / luminescent stone|9 (Deepest Place)|Last of its kind. Doesn't know how to be friendly — animals must teach it. People's industry wakes it. Easily startled; bites things and makes them *long* (arms, roads, towers, etc.). Cousin of Octopus and Squid.|
|**Squid**|21|tentacle / ink|10 (Waterfalls)|Amphibious, swims up waterfalls. Loves decorations and color. Visits brother Octopus.|
|**Wind Bird**|34|dino / air|5|Brother of Song Bird. Very noisy and the fastest. Only high nests (wood). Can create solid-cloud sky islands?|
|**Construct**|0|robot / construction|11|Humans have natively tamed it. Can animate buildings into walking robots (especially with Eel).|
|**Grass**|1|dino / Grass|1 (Meadows)|Must stay wet. Makes plants grow faster. Flightless.|
|**Song Bird**|13|dino / music|7 (Karst Pillars)|Brother of Wind Bird. Musical. Fruit grows on cloud trees on green clouds.|
|**Octopus**|212|tentacle / coral|0 (Ocean)|Central mover: Moves Animals, boats, islands, tunnels \& Structures. Ancient Octopus at max level.|
|**Special Animal**|55|archaic living fossil / fire|8 (Central Spire)|**Unique**. Only one. Protects other animals and helps them upgrade. Can walk/hover/swim/float. Friends with Eel, Squid, Octopus. Rainbow/gold/silver.|
|**Furball**|0|mammal/fish|0|Fur + scales. Runs from everything. Very tasty.|
|**Rory**|547|worm / aether|9|**Boss fight monster?** Highest wildness in the game. Eel → Rorylet → Rory → Grand Rory.|

**Faction Mapping (from Animals sheet):**

* Island → fish
* Animals → dino (note: this includes the "plant" creatures Grass and Wood, who function as the wild, living, organic analogue of Structures — see the Structures faction section for the full exploration of this parallel)
* People → mammal
* Structures → robot
* Octopus → tentacle
* Eel → worm

\---

## 6\. People \& Technology (Peopletech)

People begin as low-tech thatched-roof natives with almost nothing, surrounded by the ruins of lost high technology. Advancement happens through many parallel, accumulating tracks. Most lines start from a "Native" or "Leaf Garb" baseline and branch into specialized upgrades. Higher tiers introduce "Ancient" materials (Ancient Palm, Ancient Metal, Ancient Diamond) that feel transcendent and are likely tied to the Special Animal and top-tier evolved creatures.

The spreadsheet tracks exact **accumulated requirements** (you keep the benefits of lower tiers when you unlock higher ones).

### 5.1 Resource Gathering

The foundation for almost everything else.

|Tier|Name|Requirements|Accumulated|
|-|-|-|-|
|Base|Gathering|Native|—|
|1|Gardens|Grass|Grass|
|2|Fields|Bamboo|Bamboo, Grass|
|3|Orchards|Wood|Wood, Bamboo, Grass|

### 5.2 Shelter \& Housing

Multiple parallel housing lines that improve living conditions, storage, and possibly morale or population capacity.

**Soft / Comfort Line**

* Huddle (Native)
* Tents (fur)
* Cushions (Bird + fur)

**Solid / Structural Line**

* Huddle (Native)
* Huts (Grass)
* Houses (Wood|Bamboo + Grass)
* **Towers** (Bird + Wood|Bamboo + Grass)

### 5.3 Heat \& Industry (Fire Line)

Progress from open fire to controlled high-heat industry.

|Tier|Name|Requirements|Accumulated|
|-|-|-|-|
|Base|Campfire|Native|—|
|1|Hearth|Rock|Rock|
|2|Chimney / Fireplace|Bird|Bird, Rock|
|3|Furnace|Brick|Brick, Bird, Rock|

This line is probably a prerequisite for metalworking, pottery, and advanced construction.

### 5.4 Clothing \& Personal Protection

Several parallel clothing tracks all starting from the humble **Leaf Garb**. Different environmental and combat needs branch from the same base.

**General Clothing**

* Leaf Garb (Native)
* Clothes (Fur)
* Storm Jackets (Scales + Fur)

**Hats**

* Leaf Garb (Native)
* Shade Hats (Grass)
* Feather Hats (Bird + Grass)

**Footwear**

* Leaf Garb (Native)
* Shoes (scales)
* Boots (Bronze + scales)

**Armor**

* Leaf Garb (Native)
* Armor (scales)
* Plate Armor (Bronze + scales)

**Swimwear** (explicitly noted as "Leaf Garb (and Swim)")

* Leaf Garb (and Swim) (Native)
* Swimsuit (scales)
* Diving Suit (Squid + scales)

### 5.5 Art, Writing \& Expression

A short but flavorful cultural track.

* **Charcoal Drawings** (Native)
* **Writing** (Squid)
* **Painting** (Special + Squid)

This line likely ties into Song, morale, record-keeping, or even magical/ritual effects.

### 5.6 Water Travel \& Boats

Essential for reconnecting the shattered islands and interacting with the Octopus/Eel.

* **Swim** (Native)
* **Canoes** (Wood)
* **Sailboats** (Fur + Wood)
* **Airships** (Special + Fur + Wood) — *questioned in the source data as possibly not fitting the game's tone*

Better boats are explicitly linked to waking the Eel and enabling expeditions.

### 5.7 Hunting \& Weapons

* **Hunt / Clubs** (Native) — requires Wood
* **Spear** (Bronze + Wood)
* **Arrows** (Bird + Bronze + Wood)

Simple but important for early animal interaction and defense.

### 5.8 Maritime Infrastructure

* **Shore** (Native)
* **Docks** (Wood)
* **Piers** (Stone + Wood)
* **Sea Platform** (Iron + Stone + Wood)

Progressively more ambitious structures for fishing, trade, and ocean access.

### 5.9 Mining, Caves \& Excavation

Two related but distinct underground development lines.

**Mining / Tunneling Line**

* Caves (Native)
* Mines (Stone)
* Tunnels (Wood + Stone)
* Drilling (Iron + Wood + Stone)

**Excavation / Water Management Line**

* Caves (Native)
* Excavation (Grass)
* Lakes (Blade Fish + Grass)
* Irrigation (Bamboo + Blade Fish + Grass)

### 5.10 Animal Husbandry \& Domestication

* **Frost** (Native)
* **Fenced Pasture** (Wood|Bamboo)
* **Domestication** (Special + Wood|Bamboo)

A major late-game system. The Special Animal is required for full domestication.

### 5.11 Land Travel \& Infrastructure

Two parallel development paths that eventually merge into something spectacular.

**Basic Overland**

* Path (Bird + Grass)
* Road (Stone + Scales + Bird + Grass)

**Bridge Line** (starts from the same Path base)

* Path (Bird + Grass)
* Bridge (Wood + fur + Bird + Grass)
* **Sky Causeway** (road + bridge) — requires **Ancient Diamond + Ancient Metal** plus the full accumulated lower materials (Wood, fur, Bird, Grass, Stone, Scales)

Sky Causeways represent a major "transcendent" infrastructure achievement.

### 5.12 Song, Music \& Cultural Expression (Deepest Track)

This is one of the richest and most distinctive systems in the document. Multiple instrument families develop in parallel, culminating in large-scale cultural events that require almost every resource in the game.

**Wind Instruments**

* Pipes (Bamboo)
* Woodwinds (Wood + Bamboo)

**String Instruments**

* Strings (Fur)
* Bass Strings (Oak + Fur)

**Percussion**

* Drums (Scales)
* Bass Drums (Ancient Palm + Scales)

**Bells**

* Bells (Bronze)
* Diamond Bells (Ancient Diamond + Bronze)

**Melodic / Vocal**

* Melody (Bird)
* Harmony (Special + Bird)

**Dance \& Procession**

* Dance (Rock)
* Procession (Grass + Rock)

**Major Cultural Events**

* **Festival** (lvl 1 instruments) — requires: Bamboo, Fur, Scales, Bronze, Bird, Rock
* **Grand Procession** (lvl 2 instruments) — massive requirement list: Wood, Bamboo, Oak, Fur, Ancient Palm, Scales, Ancient Diamond, Bronze, Special, Bird, Grass, Rock

Song is likely more than just flavor — it may influence animal behavior, morale, rituals, or even the big faction/arbitration systems.

\---

### Design Philosophy Notes (Peopletech)

* **Accumulation is core**: Upgrading never removes earlier benefits.
* **Parallel specialization**: Clothing, housing, and instruments all branch so players (or the simulation) can emphasize different cultural or practical identities.
* **"Ancient" tier** feels like a second game: once you start using materials from the highest-evolved animals and late-game mining, the technology jumps dramatically (Sky Causeways, Diamond Bells, Airships, Grand Procession, full Domestication).
* **Synergies with Animals \& Phases**: Better boats wake the Eel. Domestication requires the Special Animal. Mining and construction feed Structures. Song and Art may interact with the trait arbitration or animal taming systems.

The spreadsheet remains the best place to see the exact formulas and cross-track dependencies.

\---

## 7\. Factions / Actors System

Six primary actors interact across phases. All are intended to eventually be playable, each operating on its own natural timescale (from the Island's geological epochs to the faster generational and cultural rhythms of the others):

1. **Island** — the geological ground bass and world-shaper (detailed below)
2. **Animals**
3. **People**
4. **Structures** — the rhythm and scaffolding of the built world; essential yet dangerous when they erase identity (detailed below)
5. **Octopus**
6. **Eel**

Each phase defines whether an actor is **Active**, has a **Lower/Upper Range**, and specific influence values on other actors (positive, negative, or special tokens like "s" for self?).

The **Faction phases** sheet is a large matrix showing these state changes and influence flows.

The long-term goal is for all six factions to be playable. They operate on different timescales and with different "pieces":

* Most factions act on generational or cultural timescales (populations, herds, settlements, and evolving traditions).
* The **Island** operates on a true **geological timescale** — centuries and millennia are its "turns." Its pieces are not individuals but landforms, currents, sediment layers, and the slow revelation or concealment of possibility.

\---

### The Island as Playable Faction: The Geological Symphony

The Island is the **ground bass** and resonant body of the entire game. While Animals, People, Octopus, and Eel provide the faster melodic lines, counterpoint, and dramatic flourishes, the Island provides the slow harmonic foundation, the shifting stage, the acoustics of the world, and the very material from which life and culture arise.

When you play as the Island, you are not directing creatures or builders. You *are* the living land. Your actions reshape the board itself over vast spans of time. The other factions move *upon* you, *within* you, and sometimes *against* you.

#### Core Identity and Timescale

The Island faction maps to **Fish** in the faction system and carries strong **Might** with touches of **Wealth** and **Glory** (and a notable weakness in concentrated **Power**). This reflects its nature as an immense, diffuse, unstoppable force rather than a precise controller.

Its natural themes are:

* **Upwelling** — the slow, powerful bringing of hidden things from the deep (sunken high-tech ruins, nutrients, new minerals, ancient seeds or memories).
* **Currents and Eddies** — the movement of resources, populations, warmth, and opportunity around the archipelago.
* **Storms and Erosion** — dramatic, destructive, and creative events that carve the land and reset opportunities.
* **Reef-building and Sedimentation** — patient, accretive construction of new land, new habitats, and new possibilities.
* **Shelter and Bounty** — the quiet offering of harbors, soil, groves, and the fruits of the deep to those who live upon it.

Because it works on geological time, playing the Island feels different from the other factions. Your major decisions are "epochs." You do not micromanage. You set vast processes in motion and then watch (and subtly guide) how the faster factions dance upon the changing stage you have provided.

#### Signature Island Actions (Epoch-Scale)

These are not individual unit moves but world-shaping processes the Island player can initiate, nurture, or unleash:

**Upwelling**

* Periodically lift sunken high-technology from the ocean floor (powerful but risky boons for the People faction or new hybrid "magitek" paths).
* Bring up deep minerals or rare elements that feed late-game Peopletech and Structures.
* Reveal "seeds" or lost evolutionary lines that can dramatically alter animal populations on nearby islands.

**Sediment \& Soil Creation**

* Collect and deposit topsoil in high meadows, creating rich new grazing lands (massive boost to Fur and related animal lines).
* Build fertile shelves and terraces that shelter groves of fruit trees in stony clefts (supporting Wood and certain bird/fruit evolutions).

**Reef \& Land Shaping**

* Slowly raise coral reefs that create new land bridges, sheltered lagoons, or protective barriers.
* These reefs interact strongly with the Octopus faction (symbiotic growth or contested territory) and can eventually become new stable islands or adventure sites.

**Harbor Carving \& Coastal Gift**

* Erode and shape coastlines to create natural harbors perfectly suited to People's maritime ambitions.
* In the Symphony end-state, these become the adventure ship harbors encircling the restored atoll.

**Storm \& Dramatic Reset**

* Trigger (or suffer) powerful storms that erode old structures, redistribute resources, carve new coves, and reveal previously hidden caves and minerals.
* These events are double-edged: they can devastate current developments but open entirely new evolutionary and technological branches.

**Bounty of the Deep**

* Offer periodic "gifts" from the abyss — schools of fish in new locations, deep nutrients that accelerate plant and animal growth, or strange deep-sea creatures that interact with the Eel and Squid lines.

#### Relationship to the Other Factions

**With People**: The Island is both generous patron and occasional destroyer. It provides the literal ground, soil, harbors, and revealed resources that fuel the entire Peopletech tree. In return, People's industry and building can "irritate" the Island, provoking storms or withholding gentle upwellings. In the Order path, the Island becomes a controlled, armored coastline serving a rigid civilization. In the Chaos path, it becomes storm-lashed and unpredictable.

**With Animals**: The Island is the great habitat engineer. It constantly creates and destroys the conditions for different animal lines to thrive. New meadows for Fur, sheltered forests for Wood, exposed rock for Rock and Metal creatures, new deep places for Eel-line beings. In the Symphony state, the Island's geological rhythms are perfectly synchronized with animal migrations and evolutions.

**With Octopus and Eel**: This is the Island's central dramatic tension. The Octopus builds *upon* the Island — reefs, structures, orderly accretions. The Eel stirs the Island from below — powerful currents, upwellings from the abyss, the "long tangled" influence. The Island can lean toward one, resist both, or (in the true path) find a living balance where its slow power mediates between the two great oceanic forces.

**With Structures**: The Island decides what endures. Slow geological processes can preserve ancient structures for millennia or grind them to dust. In the Symphony, even the greatest human or animal constructions eventually become part of the Island's living geology.

#### The Island in the Three Paths and the Symphony

In the **narrow gate** of balance, the Island is a living, responsive participant in the fugue. Its upwellings, currents, and reef-building are perfectly timed with the needs and offerings of the other factions. It becomes the resonant chamber in which the Symphony of the Seas can truly ring.

In the **Octopus of Order** path, the Island's power is channeled into rigid coastlines, controlled upwellings, and heavily engineered harbors. Its Might is high, but its music becomes martial and constrained.

In the **Eel Unbound** path, the Island is wild and shifting. Storms are constant, coastlines dance, and the deep is constantly vomiting up strange gifts and dangers. The world feels alive but unstable.

The ultimate expression of the Island faction is not domination, but **participation in the fugue** — when its vast, slow geological music locks into perfect counterpoint with the faster voices of life, culture, and the oceanic powers.

#### Design Notes for Playable Island

* The Island player should feel powerful but *diffuse*. You rarely get precise control, but your influence is everywhere and long-lasting.
* Many of your actions should create opportunities (or crises) that the other factions can choose to seize or suffer.
* The Island has a special relationship with "revelation" mechanics — it is the faction most likely to surface lost knowledge, sunken technology, or forgotten evolutionary potential.
* In the endgame Symphony state, the Island's player may literally help design or reshape the final restored atoll and its surrounding adventure harbors.

This faction embodies one of the game's deepest themes: that the land itself has agency, memory, and a voice in the great symphony — and that the highest form of that voice is not control, but generous, patient, world-shaping participation.

#### The Structures Faction: The Lattice and the Rhythm

If the Island is the geological ground bass, the **Structures** faction is the **rhythm section and architectural scaffolding** of the symphony. They are the repeating ostinatos, the harmonic pillars, the bridges, frames, and resonant chambers that give shape and pulse to the faster melodies of Animals and People.

Structures are not merely tools of the People. They are a distinct, playable force with their own drives, timescales, and dramatic arc. The People *need* them to advance (housing, industry, defense, culture, maritime reach), but when Structures dominate unchecked, they summon the **Chaos Eel** through loss of identity and the dissolution of boundaries — the partial failure path of excess interconnection and anonymous megastructures.

**Core Identity and Timescale**

From the trait mapping, Structures carry high **Wealth** (accumulation, infrastructure, enduring value), moderate **Might** and **Honor**, and negative **Glory** (they are often cold, impersonal, or self-effacing in their highest expressions). This fits a faction that builds the stage but can erase the distinct voices upon it.

Their natural timescale is **project and generational infrastructure** — decades to centuries for major works. Faster than the Island’s epochs, slower than individual animal lives or short-term human decisions. Their "pieces" are not single creatures or people, but **foundations, networks, districts, and great works** that persist and evolve across generations.

Oldschool RTS base-building (Warcraft II echoes) is a strong intuitive fit: you establish resource nodes, lay supply lines, raise defensive and functional structures, upgrade them, and expand influence. But here the "buildings" are alive with the materials of the world.

**Signature Mechanics and "Moves"**

**Material Symbiosis \& Inheritance**
Structures are built from the living world and carry its traits forward:

* Fur-insulated longhouses or towers for extreme cold (boosting or protecting Fur-line animals and People in Peaks).
* Scale-plated fortifications or armor-like walls (durable, but potentially hostile to certain animals).
* Song-resonant halls, bell towers, or wooden amphitheaters that amplify cultural power and can influence animal behavior or morale across distances.
* Wood/Bamboo/Grass constructions that "breathe" with the Island’s soil and weather.
* Ancient-material megastructures (Sky Causeways, Diamond Bells, Grand cultural works) that feel like transcendent statements — powerful but arrogant against geological time.

**Network \& Lattice Effects**
Structures rarely stand alone. They form webs:

* Mines (Caves/Volcano) feed forges and smelters.
* Fields, Orchards, and Pastures create agricultural districts.
* Jetties, Wharves, Docks, Piers, and Sea Platforms create maritime lattices that interact with Island currents and Eel movements.
* Towers and fortified lines create zones of control or observation.
* Overbuilding creates "dissonant lattices" — dense, anonymous interconnections that erode the distinct identities of animals, people, and places, actively calling the Eel’s chaotic influence.

**Animate Architecture \& Hybridity**
The Construct animal (natively tamed on the Human island) is the bridge. Structures can "wake up":

* Buildings gain limited mobility or agency.
* Districts become semi-sentient complexes.
* This blurs the line between Structures, Animals, and People — a core source of both power and danger.

**Negotiation with the Island**
Structures are guests on geological time. The Island will eventually reclaim, erode, or upwell beneath them:

* Foundations can be strengthened by cooperating with Island sediment/reef actions or undermined by storms and erosion.
* Great works (especially ocean platforms or sky causeways) are direct challenges to the Island’s slow power and carry high risk/reward.

**Legacy \& Cultural Memory**
Major structures act as "slow memory." They can preserve knowledge, cultural patterns, or even animal behaviors across long timescales when faster factions might forget or lose them. In the Symphony state, the greatest works become resonant parts of the living fugue rather than monuments to dominance.

**The Dramatic Arc: Necessity, Excess, and the Eel**

Structures are essential. Without them, People remain scattered and low-tech, unable to fully participate in the world’s reunion.

But when the lattice grows too dense, too rigid, too totalizing:

* Distinct animal habitats are paved over or enclosed.
* People lose connection to the living materials and rhythms that birthed their tech.
* The world becomes a single, interconnected, anonymous megastructure.
* This loss of boundaries and identity is exactly what summons the **Chaos Eel** — the partial failure path of excess openness and dissolution ("Drowning of Atlantis" in built form, or labyrinthine flooded ruins where nothing remains distinct).

In the Order path, Structures become monumental, fortified, hierarchical expressions of control (often in tense alliance with Octopus order; see the Structures faction section for the full playable vision and Eel-risk mechanics).

In the true Symphony path, Structures become **living architecture** — buildings that grow with the animals and land, resonate with Song, are shaped by Island processes, and in turn shape the faster factions without erasing them. The lattice becomes part of the polyphonic harmony rather than its cage.

**Playable Faction Experience**

When playing as Structures, you feel the oldschool satisfaction of laying down infrastructure, optimizing networks, and watching your works endure and upgrade. But you also feel the growing tension: every new tower, every expanded minefield, every sea platform adds weight to the lattice. At some point, you must choose whether to keep building (risking Eel backlash) or to deliberately leave "breathing room" — gaps, wild zones, and material honesty that allow the other voices to remain distinct.

Your victory is not merely having the most or the biggest structures. It is creating an enduring, resonant built environment that lets the entire symphony flourish — one where the works of hands and Constructs sing with the animals, the land, and the sea rather than silencing them.

This faction carries one of the game’s central questions: What does it mean to build in a living world? When does structure become support, and when does it become a tomb?

**Flora as the Animal World's Living "Structures"**

Your intuition here is sharp and points to one of the game's most elegant symmetries.

In the faction mapping, **Structures map to "robot"** — the intentional, accumulated, often rigid lattice built by will and labor (or Construct-animated complexes).

By contrast, the plant-creatures in the Animals faction (explicitly classified as "dino" types) function as the **organic, wild, growing analogue of Structures**:

* **Wood** is described as "Like an ostrich. Builds, makes, breaks wood." It *is* both the material and the active builder. Its evolution line (bushes → trees → Ancient Wood / Giant Tree) is literally the creation of living architecture — natural towers, groves, and forests that provide shelter, resources, and habitat.
* **Grass** "makes things grow faster" and is used for roofs, hats, and soil stabilization. Its line (Dirt → Grass → Bamboo → Palm) creates living fields, thatched environments, and structural materials.

These are not "resources" in the traditional sense. They are **Animals that perform structural roles**. Groves of fruit trees sheltered in stony clefts (as the Island can provide) are the wild, Animal-faction equivalent of the towers, huts, and platforms that the Structures faction raises.

This creates a powerful thematic and mechanical spectrum:

* **Wild Flora (Animals faction)**: Organic, improvisational, self-replicating "architecture." Living walls, root networks, canopy cathedrals, growing shelters. They evolve, spread, and adapt like the other animals.
* **Built Structures (Structures faction)**: Intentional, accumulated, often "dead" or hybrid (using harvested materials + Constructs). They persist through will and maintenance rather than growth.
* **The Tension \& the Eel Risk**: When the Structures faction overbuilds with rigid, anonymous megastructures, it can suppress or pave over the wild flora. This replaces living, identity-rich organic structures with cold lattices — accelerating the loss of distinct boundaries and identities that summons the Chaos Eel.
* **Island Synergy**: The Island actively supports the *wild* flora version (collecting topsoil in high meadows for grazing, sheltering groves in stony clefts, raising land for new forests). It has a more ambivalent relationship with overbuilt rigid Structures.
* **Symphonic Resolution**: In the true Symphony of the Seas, the distinction softens into harmony. Living architecture emerges — Structures that incorporate growing Wood and Grass lines, or wild flora that have been gently shaped and "built with" rather than against. The organic rhythms of the plant-animals and the composed rhythms of built Structures interweave in the fugue.

So no — the Structures faction does **not** play as the flora. The flora *are* the Animals faction's version of Structures: wild, growing, self-sustaining architecture that stands in beautiful and sometimes tragic contrast to the accumulated works of hands and Constructs.

This parallel is one of the quiet strengths of the design. It means that even "resources" like wood and grass have personality, agency, and factional allegiance. When you harvest or build with them, you are negotiating with another faction's "structures" — not just chopping down anonymous trees. That single shift does enormous work for the game's thematic coherence and the feeling that everything is alive and singing in (or against) the symphony.

\---

## 8\. Traits \& Arbitration Mechanics

This is the deepest systems layer. Seven traits govern actor behavior and conflict resolution:

* **Might**
* **Wisdom**
* **Honor**
* **Wealth**
* **Power**
* **Glory**
* **Blessing**

### Faction Trait Mapping (summary)

|Faction|Might|Wisdom|Honor|Wealth|Power|Glory|Total|
|-|-|-|-|-|-|-|-|
|Island|3|—|—|1|-1|1|4|
|Animals|1|3|-1|—|1|—|4|
|People|—|-1|3|1|1|—|4|
|Structures|1|—|1|3|—|-1|4|
|Octopus|-1|1|—|—|3|1|4|
|Eel|—|1|1|-1|—|3|4|

### Arbitration Rules (from Trait Arbitration sheet)

* Each trait has an "Arbitration" timing: **past / present / future**.
* Resolution uses a multi-round voting system (a, b, c, d rounds).
* Values are vote weights.
* Ties iterate through already-evaluated traits.
* Max 4 rounds; round **d** is always odd (final tiebreaker).
* Round totals must be odd for the final; others even.
* Round halves define what combos produce a tie.

The system is designed so that full arbitration can play out with meaningful depth and re-evaluation.

\---

## 9\. Biological \& Lore Notes

The **Notes** sheet provides the "real biology + fantasy" grounding:

**Plants (Angiosperms)**

* **Grass** (Monocots): Builds roofs/hats, makes things grow faster, must stay wet. Evolves: Dirt → Grass → Bamboo → Palm.
* **Wood** (Dicots): Like an ostrich (doesn't fly). Breaks and builds with wood. Evolves to Giant Tree.

**Animals**

* **Fur** (Mammals): Cold-adapted, hates wet, needs Scales for waterproofing.
* **Scales** (Reptiles): Armor/shoes; needs Fur for comfort.
* **Bird**: Noisiest and fastest. High nests only. Long build time for solid cloud sky islands.
* **Eel** (Fish): Deepest Place, last of its kind, must be taught friendliness.
* **Squid** (amphibians): Amphibious, waterfall swimmer, loves decoration and color.

**Minerals / Others**

* Bronze \& Iron, Rock, Special Animal, Ice animal, etc.

Each entry includes a signature "Fruit" metaphor and clear mechanical/lore role.

\---

## 10\. Team

* **Andrew Kolb** — Nested maps and illustration (wonderland, Neverland, Oz sensibility) — https://www.kolbisneat.com
* **Fractal Philosophy** — Smart, simple procgen and simulation — https://www.patreon.com/FractalPhilosophy
* **Matthew VanDevander** — Puzzle games, general game design

\---

## How to Use This Document + The Spreadsheet Together

* **Use the spreadsheet** when you need:

  * Side-by-side actor comparison across phases
  * Exact formulas (Peopletech accumulation, Trait Arbitration weights)
  * Dense matrix views
  * Quick editing of numbers
* **Use this Design Bible** when you need:

  * Narrative flow and world flavor
  * Scannable animal lore and descriptions
  * Clear explanations of complex systems
  * Onboarding new team members or pitching the project

**Recommendation:** Keep both in sync. When major numbers or states change in the spreadsheet, update the corresponding sections here.

\---

*Generated from the master spreadsheet `Song of the Shattered Isle.xlsx` (9 sheets). This is a living document.*

**Last updated:** (auto-generated on creation)

