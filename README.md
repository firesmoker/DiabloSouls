Things that are very missing:
	Pathfinding is non existent for both player and enemies
	Sound is not good and responsive
	no defend
	no way to use mana
	no ranged abilities
	no abilities in combat other than basic attack, parry, counter, dodge
	Enemy highlight makes them transparent and the highlight is not clear enough. I want outline.
	parry / counter is not optimized for multiple enemies
	no counter and parry animations (maybe in the meantime - knockback? reverse step?)
	Artstyle is lacking
	no music
	player light is a bit awkard, and the dark is not dark enough
	counter is immediate (maybe good?) and doesn't provide invulnerability (?)
	BUG: stun makes enemy's "teleport" forward after it
	enemy retaliation animations (lower priority)
	movement could be smoother using root motion, or better more consistent animations (lower priority)
	no movement accelaration (low priority)
	no indication for lack of stamina to parry on the highlight circles (very low priority, if parry actually uses atmina)
	no decals like blood and bones flying in the air (very very low priority)


abilities queue
if I press an enemy, I do several things.
I'm entering chasing mode on him.
if my left click ability:
If it's melee, I'll walk until he is the melee zone. Then I'll execute the attack.
If it's ranged, I'll walk until he is in range, then I'll execute the attack.
If it's self, I'll immediatly execute the ability. It might have a direction.

interruption could be a thing.
the same interruption when you hit an enemy.
the chance could be higher for some weapons
so interruption plus fast attack speed could be a psuedo stun, as it keeps interruping all the time

I need to think of some Shadowsoul creatures and bosses.

Artifacts

Artifacts should provide a very significant boost in power. Nothing sucks more than getting to the mythical item only to discover that your rare is better, or to have it for a very short while.
They should also be applicable to a wide variety of builds.
Maybe some more specialized artifacts from side bosses could be narrower and more build-enabling. But the "main quest" ones should be the widest.
AND NEVER LEVELED. THEY CAN HAVE ONE VERSION PER DIFFICULTY LEVEL. BUT NEVER LEVELED!
generlly with items, I prefer having more bases, and even if they have the same art, have them have different names and be consistent.

Raguel's Ring - Quest reward
* Health, Mana, Stamina
* Increased reputation gain from slain monsters (not bosses to not encourage switch before final blow, and not quests)
* Unlock ability based on Bless threshold
* Light Radius

___ of the Divine Order
* 

___ of Congregation
* 

Astaroth's ?
* Unlock ability based on Curse threshold

Abel's ?
* Unlocks abilities based on Bless/Curse thresholds?!

Gabriel's ?
* 

Kayne's ?
* 

Elite Guardian Bow
* 
* Light radius

Duriel's Sword - Slay Duriel
* Strength
* Versatile sword one handed or two?!
* Unlocks abilities based on ability thresholds?!
* Unlocks abilities based on Bless/Curse thresholds?!
* Light radius

Soulstone Core - Slay Death
* charm that provide overall powerful generic boost - all abilities, tiredness. Very strong
* gets stronger the more souls you slay
* maybe curse you with less light?
* maybe curse you with less resistences?


Weapon types?
Ranged
Bows
	Bows
	Composite Bows: requiring and using strength as well for damage. Higher base damage.

Melee
	Axes: High bleeding, high base damage (best with strength (little dex?), highest damage, lowest defence)
	Maces: No bleeding, Higher stun chance, high base damage (best with strength, defence with stun)
	Swords, Medium Bleeding? Higher critical chance? critical damage? something for counter? medium damage (best with dexterity, defence with counter/interruption)
	Daggers: Highest critical chance, low damage, lowest reach, highest attack speed (best with dexterity, defence with counter/interruption)

Shields
	Small shield medium defence, medium block reduction, no movement penalty
	Tower shield high defence, high block reduction, movement penalty

think about stats.

"medium" warrior?
strength and dex
should be the best at counters and balance, gets high damage by balancing crit and base damage.
swords?

battle mage equipment?
one that requires both strength / and magic?
the mana shield from D1 is pretty cool, but I think it would be cooler if it was a property of a battle mage armor.

Wand slinger equipment:
	wands getting bonuses from both dex and int

Strength could be:
	Damage:
		melee attack damage (and some ranged damaged?)
		higher bleeding damage?
		higher bleeding chance?
	Counter:
		counter stronger attacks (minimum required for some attacks)
	Block:
		Higher block damage reduction
	Stun:
		longer stun duration (bigger boink!)
		higher stun chance
	Stamina:
		Lower stamina cost for melee weapons
		lower heavy armor stamina modifier
	Tiredness:
		Lower tiredness from parrying and countering
		Lower tiredness from taking damage
		Lower tiredness from blocking
		Lower tiredness from melee attacks
	Equipment:
		equip heavier weapons and armor
	

Dexterity could be:
	Damage:
		ranged attack damage (and some melee?)
	Counter:
		counter faster attacks (minimum required for some attacks)
		bigger counter window
	Interruption:
		higher interruption chance
	Speed:
		Move Speed
		Attack (and Casting) speed
	Stamina:
		Lower stamina cost for ranged weapons
		Lower stamina cost for dodge
	Tiredness:
		Lower tiredness from parrying and countering
		Lower tiredness from dodging
		Lower tiredness from ranged attacks
	Equipment:
		equip better ranged weapons
		equip better "medium" armor
		

Intellect:
	Damage:
		spell damage
		elemental/magic damage?
	Counter:
		counter spell?
	Mana:
		higher mana
	Equipment:
		equip better magical weapons?
		equip better magical equipment
	Tiredness:
		Lower tiredness from casting spells


Constitution:
	Health:
		higher health
	Stamina:
		higher stamina
	Tiredness:
		Lower tiredness modifier

	

free thinking.

I now have a prototype that the player moves very good, enemies move pretty good. the player attacks the enemies and the enemies attack in melee.

strange bug when slime appears no counter highlight

Critical - how does it work?
	right now it seems to be mostly if not all gear-based.
	the only thing that's based on char abilities is attack speed, more chances to crit
	
Do I want attack rating?
It's not really fun, and not very "actiony"
I could do enemies that actually "dodge", using dodge abillity the moves them away.
Attack rating can be only related to crit chance. but let's just call it crit chance than. no?
the pro for attack rating is that it provides different chances for different opponents.
i don't know.

-----------------------
TO DO
-----------------------

A TIER
------------------------------------
* player - fix bug when walking too close to enemy and it keeps running
* PLAYER: PATHFINDING and NAVIGATION ZONES
* ENEMY:  PATHFINDING and NAVIGATION ZONES


B TIER
------------------------------------
* outline shader for highlighted enemy


C TIER
--------------------------
* Refactoring and cleaning
* move audio to gamemanager or seperate from player, audio listener etc.
* animation and sound when gets hit (animation only for enemy)
* Convert attack to ability
* Ability queue

Others:
should i remove the feature when he starts swinging he continues the swing?

abilities queue = attack and other abillities will inherit from ability class.
each time ability including normal attack is pressed it will be added to the queue
each time ability is executed it will be removed from the queue
the array will purge its items starting from the earliest based on timing
some stuff will call for "animation_cancel" which will purge the queue and execute immediatly


for example:
	I press 1 and then 2 fast
	queue is [ability1, ability2]

TWO TYPES of cancellations:
	next in queue
	move
	dodge
	parry/counter	
	
ability animation should have "cant be canceled" period in the middle, many times starts in 0

for example:
	basic attack - swings up still can be cancelled,
	when he swings down, it starts can't be cancelled,
	followed by can be cancelled right after that
when trying to cancel animation, check if same ability?:
	if yes, checks if it's the same animation:
		if its "post effect" -> it will start again
		else -> add to queue
if not:
	cancel animation

==============================================================================
# 9.8
Above enemy health indication if they're damaged
counter indication is set by bot the player and enemy melee
Dodge
Stamina
Health Stamina Regeneration

# 8.8
Player health indication
Skeleton hud health and name
Parry and counter and their indication
Story
Planning stats and items


# 7.8
When player gets hit there are no effects

# 6.8
* convert enemy melee zone to actual melee zone of enemy. keep stopping functionality. change melee attacks to be based on melee zone instead of range
* enemy retaliation on melee hit (by stopping thus restarting the attack animation)

# 5.8
* enemy anti clumb in new safe zone and not melee zone
* melee zone for player instead of enemy

# 4.8
* Set enemy animation types and only construct for them with iteration

# 3.8
* PLAYER: health and dying (S)
* ENEMY: basic AI: go to player	
* ENEMY: hitpoints and dying
* PLAYER: fix ordering with enemies. understand this better.
* ENEMY: basic AI: attack player when in range (S)
	
# 28-31.7
* PLAYER: build animations from code with assets as well? can use differnet model for variation.
* ENEMY: enemy animation - build from code with assets? (A)

# 27.7
Refactoring mainly

# 26.7
PLAYER: go and attack enemy function - MAIN THING - YES YES YES
	include going after a moving enemy



# 25.7

player: change stuff to signals to gamemanager script - yes
signals trigger call functions on the game objects themselves so they can all run in parallel even with timers:
* camera - yes
* enemy - yes




--------------------------
IDEAS
--------------------------

* Way to balance ranged builds:
	Monsters are stronger in the dark, affected by your light radius.
	It also means you can't cheese enemies away from too long.
	What exactly is stronger?:
		chance to dodge?
		resistance to damge?
		Spells that light areas?
