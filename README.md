-----------------------
TO DO
-----------------------

# Refactoring and cleaning



# 27.7
player - fix bug when walking too close to enemy and it keeps running
PLAYER: PATHFINDING and NAVIGATION ZONES
ENEMY:  PATHFINDING and NAVIGATION ZONES


# 26.7
PLAYER: go and attack enemy function - MAIN THING
	include going after a moving enemy
ENEMY: enemy movement
ENEMY: enemy animation - build from code with assets?
PLAYER: build animations from code with assets as well? can use differnet model for variation.
PLAYER: fix ordering with enemies. understand this better.


# 25.7

player: change stuff to signals to gamemanager script
signals trigger call functions on the game objects themselves so they can all run in parallel even with timers:
* camera - yes
* audio - not critical now
* enemy - yes

update player scene to include some changes from the game scene - no


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
