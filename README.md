free thinking.

I now have a prototype that the player moves very good, enemies move pretty good. the player attacks the enemies and the enemies attack in melee.

Things that are very missing:
	No player health indication
	No enemy health indication
	Pathfinding is non existent for both player and enemies
	Sound is not good and responsive
	Enemy highlight makes them transparent and the highlight is not clear enough. I want outline.
	Combat is boring and needs to get the parry / counter ability
	enemy retaliation animations (lower priority)
	Artstyle is lacking
	no music
	player light is a bit awkard, and the dark is not dark enough

Do I want attack rating?
It's not really fun, and not very "actiony"
I could do enemies that actually "dodge", using dodge abillity the moves them away.

-----------------------
TO DO
-----------------------
  2404
 

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
* update player scene to include some changes from the game scene
player fix stopping bug with distance_to
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
