# 25.7

player: change stuff to signals to gamemanager script
signals trigger call functions on the game objects themselves so they can all run in parallel even with timers:
* camera - kinda
* audio - no
* enemy - yes

update player scene to include some changes from the game scene - no

BUG - attacking stopped not updated if canceling animation right after attack effects
