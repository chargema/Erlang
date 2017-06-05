-module (smartbuilding).
-export ([vent/2, room/2, duct/2, ahu/1, start/0]).

vent

%% the Building CCS -- start %%
start() ->
	Vent_PID = spawn(smartbuilding,vent,[]),
	Room_PID = spawn(smartbuilding,room,[]),
	Duct_PID = spawn(smartbuilding,duct,[]),
	spawn(smartbuilding,ahu,[Duct_PID]).