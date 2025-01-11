# Readme

LEGEND:
	** means it's in focus right now.

Ideas:
	CODE:		CLASSES: It's a good idea to update all "derivative" properties on setters. chain of setters will ensure good architecture
	UI/UX:		Ingame game guide is awesome (like last Epoch)
	UI/UX:		Extra helpers for scaling and meaning and examples are awesome (like last epoch)
	Gameplay:	Charge skill for melee is fun
	Gameplay:	Try counter window BEFORE parry window. better emphasize quick reaction.

Project Milestones:
	1) Basic level:
		objects and walls - in progress
		enemies and player pathfind their way - in progress
		enemies scattered around, non agressive until player in radius - done!
		main SFX exists, even if placeholders
	2) Improved basic level:
		obastacles transparency when player behind them
		more abilities
		better built arena
		better enemy variety
		better animations (knockback for parry/counter/getting hit or interrupted)
		particle effects
		decals on the ground (blood)
		better sfx
		less intrusive counter/parry indication
		WSAD movement?

Game Design stuff to do:
	Stats:			Define types of defense.
	Itemization:	Define armor bases
	Progression:	Define classes/classless system
	Skills:			Define skills
	Skills:			Define skill trees
	Itemization:	Define crafting

Technical stuff that bothers me:
	BUG:			NavigationServer player tries to use nav map before it's initizalized
	WORLD:			Convert TileMap2 to the new system
	REFACTOR:		Player - use AnimationManager for its animation stuff?
	REFACTOR:		Switch Player and Enemy layers
	REFACTOR:		maybe i can get rid of the "is_locked" for enemies?
	PERFORMANCE:	sound dictionaries are calculated for each enemy instance instead of each unique enemy
	WORKFLOW:		debugging could be easier if I could toggle some types of messages
	WORKFLOW:		debugging could be easier if I put a debugging CanvasItem that shows me everything I need

Things that are very missing:
	GAMEPLAY:	improve cant_be_countered behaviour. make it so the enemy doesn't have to be in melee range
	GAMEPLAY:	improve telegraphed attacks. should I show an impact warning on the ground?
	GAMEPLAY:	parry on release sucks. revert this.
	GAMEPLAY:	no abilities in combat other than basic attack, parry, counter, dodge, shoot projectile
	WORLD:		arena is not an actual, interesting level
	WORLD:		arena has no walls, objects, etc.
	WORLD:		enemy variety
	GAMEPLAY:	consuming mana the very moment you press to cast the spell feels weird. maybe because it takes a while to shoot.
	GAMEPLAY:	Can't block ranged attacks
	BUG:		Weird parry/counter rings behaviour
	SOUND:		Play projectile sounds
	SOUND:		Play animation sounds for attack
	SOUND:		Play Get hit SFX by material (flesh, metallic, etc.), probably played from enemy
	SOUND:		Missing SFX all around
	VISUAL:		No red overlay when dead
	VISUAL:		No normal-map lightning
	GAMEPLAY:	Ranged enemies have no target prediction, they shoot in a stupid manner. (not working)
	GAMEPLAY:	parry / counter is not optimized for multiple enemies
	ANIMATION:	no counter and parry animations (maybe in the meantime - knockback? reverse step?)
	ANIMATION:	no ranged attack animation
	ART:		Artstyle is lacking
	MUSIC:		no music
	GAMEPLAY:	counter is immediate (maybe good?) and doesn't provide invulnerability (?)
	MENUS: Pause
	MENUS: SETTINGS
	GAMEPLAY:	higher priority highlighting for scarier enemies. make the switch by distance higher if current enemy in focus is more scary, and vice versa. maybe take enemy size into account. LOW PRIORITY
	ANIMATION:	enemy retaliation animations (lower priority)
	GAMEPLAY:	no movement accelaration (low priority)
	GAMEPLAY:	no decals like blood and bones flying in the air (very very low priority)
	ANIMATION:	movement could be smoother using root motion, or better more consistent animations (very very low priority)
	UI:	no indication for lack of stamina to parry on the highlight circles (very low priority, if parry actually uses atmina)

Pathfinding:
	GAMEPLAY:	Pathfinding: Set angle of offset based on angle from the collision point instead of just a random number times collisions
	GAMEPLAY:	Pathfinding: Player: not checking its sides for collision
	GAMEPLAY:	Pathfinding: Player: can get "funneled" between enemies, not going back
	GAMEPLAY:	Pathfinding: Player: can go out of navigation map when trying to circle around enemies - in progress, looking good
	GAMEPLAY:	Pathfinding: Player: sliding to the side near navigation map edge can act a bit weird
	GAMEPLAY:	Pathfinding: Player: when destination is set before enemies and not after - weird behaviour
	GAMEPLAY:	Pathfinding: Enemies: are jittery when clumped
	GAMEPLAY:	Pathfinding: Enemies: get stuck behind other enemies instead of circling around them or stopping
	GAMEPLAY:	Pathfinding: Enemies: not smooth around corners, lacking "slide"
	GAMEPLAY:	Pathfinding: [Milestone]: Diablo 4 style player movement

Stats (example, will not be defined together like that):
	Dictionary for each stat
	all sources are there. for example; 
	
	PlayerStats class
	static var spell_damage_increased_sources: Dictionary = { # each change will call for sum update via setter
		"right_hand_slot": 15,
		"slot_head": 20,
		"spell_rage": 15,
		"attribute_intellect": 40,
		}
	
	static var spell_damage_increased_sources_sum = sum_stat_dictionary(spell_damage_increased_sources)
	
	static var spell_damage_flat_sources: Dictionary = { # each change will call for sum update via setter
		"right_hand_slot": 5,
		"passive_melee_expertise": 5,
		}
	static var spell_damage_flat_sources_sum = sum_stat_dictionary(spell_damage_flat_sources)
	
	Skill Class
	static var damage_types: Array[String] = ["spell","fire"]
	static var skill_level: int = 3 # change will call for base_damage update function via setter
	static var base_damage_by_level: Dictionary = {1: 30, 2: 45, 3: 60 .....}
	
	var base_damage: float = base_damage_by_level[skill_level]
	var total_increased_damage: float = 0
	var modified_base_damage = base_damage
	
	for damage_type in damage_types:
		total_increased_damage += Player.get_increased_damage_sum(damage_type)
		modified_base_damage += Player.get_flat_damage_sum(damage_type)
		
	var total_damage = (modified_base_damage * total_increased_damage)
	


abilities queue:
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

3 Divine Paths:
	Blessed Champion:	handing over soulstone shards to the divine order, so they can recreate the stone of creation and other good acts
	Dark Slayer:		augmenting yourself with the soulstone shards and other evil acts
	Mortal Hero:		1 point for lowest stat between slayer and champion:
							(if you have 50 champion and 25 slayer, you get 25 for the "joint" points)
						"mortal" acts that are only beneficiary to mortal people

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
* Unlocks abilities based on Bless/Dark thresholds?!
* Light radius

Soulstone Core - Slay Death
* charm that provide overall powerful generic boost - all abilities, tiredness. Very strong
* gets stronger the more souls you slay
* maybe curse you with less light?
* maybe curse you with less resistences?
* quest item, cannot be dropped/stashed/sold/traded


	
	

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
# 17.8
enemy outline

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
