-module (version4).
-export ([ahu/2, hotair/0, duct/4, vent/0, room/1, bms/3, start/0]).

ahu(N,Duct_PID)->
	if
		(N==1000) ->
			body
	end
	Duct_PID ! {pressurise},
	%io:format("ahu running ~n,[]"),
	ahu(N+1,Duct_PID).

hotair()->
	room1 ! {getHot1},
	room2 ! {getHot2},
	room3 ! {getHot3},
	%io:format("T is up! ~n,[]"),
	hotair().

duct(P,Vent1_PID,Vent2_PID,Vent3_PID)->
	%io:format("Current P is: ~w~n",[P]),
	if 
		(P == 250) ->
			Vent1_PID ! {getAir1},
			Vent2_PID ! {getAir2},
			Vent3_PID ! {getAir3},
			%io:format("Release the getAir to vent. ~n",[]),
			duct(P-3,Vent1_PID,Vent2_PID,Vent3_PID);
		true ->
			receive
				{pressurise} when P < 250->
				%io:format("Get pressurise. Times:~w~n",[P+1]),
				duct(P+1,Vent1_PID,Vent2_PID,Vent3_PID)		
			end
	end.

vent()->
	receive
		{v1on}->
			receive
				{getAir1}->
					%io:format("Release giveAir to room1. ~n",[]),
					room1 ! {giveAir1},
					vent()
			end;
		{v1off}->
			%io:format("Vent off, release getHot~n",[]),
			vent();
		{v2on}->
			receive
				{getAir2}->
					%io:format("Release giveAir to room2. ~n",[]),
					room2 ! {giveAir2},
					vent()
			end;
		{v2off}->
			%io:format("Vent off, release getHot~n",[]),
			vent();
		{v3on}->
			receive
				{getAir3}->
					%io:format("Release giveAir to room3. ~n",[]),
					room3 ! {giveAir3},
					vent()
			end;
		{v3off}->
			%io:format("Vent off, release getHot~n",[]),
			vent()
	end.

room(T)->
	if
		(T > 20) ->
			receive
				{giveAir1}->
					io:format("Room1 temperatrue is low down to: ~w~n",[T-1]),
					CurrentT1 = T-1,
					bms ! {currentT1, CurrentT1},
					room(T-1);
				{giveAir2}->
					io:format("Room2 temperatrue is low down to: ~w~n",[T-1]),
					CurrentT2 = T-1,
					bms ! {currentT2, CurrentT2},
					room(T-1);
				{giveAir3}->
					io:format("Room3 temperatrue is low down to: ~w~n",[T-1]),
					CurrentT3 = T-1,
					bms ! {currentT3, CurrentT3},
					room(T-1)
			end;
		true ->
			receive
				{getHot1} ->
					T_inc = rand:uniform(5),
					io:format("Vent1 is off now.~n",[]),
					io:format("Room1 temperatrue is up to: ~w~n",[T+T_inc]),
					io:format("Vent1 is on now.~n",[]),
					CurrentT1 = T+T_inc,
					bms ! {currentT1, CurrentT1},
					room(T+T_inc);
				{getHot2} ->
					T_inc = rand:uniform(5),
					io:format("Vent2 is off now.~n",[]),
					io:format("Room2 temperatrue is up to: ~w~n",[T+T_inc]),
					io:format("Vent2 is on now.~n",[]),
					CurrentT2 = T+T_inc,
					bms ! {currentT2, CurrentT2},
					room(T+T_inc);
				{getHot3} ->
					T_inc = rand:uniform(5),
					io:format("Vent3 is off now.~n",[]),
					io:format("Room3 temperatrue is up to: ~w~n",[T+T_inc]),
					io:format("Vent3 is on now.~n",[]),
					CurrentT3 = T+T_inc,
					bms ! {currentT3, CurrentT3},
					room(T+T_inc)
			end
	end.

bms(Vent1_PID,Vent2_PID,Vent3_PID) ->
 	receive
		{currentT1,CurrentT1}->
			if
				CurrentT1 == 20 ->
					Vent1_PID ! {v1off},
%					io:format("Vent1 is off now.~n",[]),
					bms(Vent1_PID,Vent2_PID,Vent3_PID);
				true->
					Vent1_PID ! {v1on},
%					io:format("Vent1 is on now.~n",[]),
					bms(Vent1_PID,Vent2_PID,Vent3_PID)
			end;
		{currentT2,CurrentT2}->
			if
				CurrentT2 == 20 ->
					Vent2_PID ! {v2off},
%					io:format("Vent2 is off now.~n",[]),
					bms(Vent1_PID,Vent2_PID,Vent3_PID);
				true->
					Vent2_PID ! {v2on},
%					io:format("Vent2 is on now.~n",[]),
					bms(Vent1_PID,Vent2_PID,Vent3_PID)
 			end;
  		{currentT3,CurrentT3}->
 			if
 				CurrentT3 == 20 ->
 					Vent3_PID ! {v3off},
%					io:format("Vent3 is off now.~n",[]),
					bms(Vent1_PID,Vent2_PID,Vent3_PID);
				true->
					Vent3_PID ! {v3on},
%					io:format("Vent3 is on now.~n",[]),
					bms(Vent1_PID,Vent2_PID,Vent3_PID)
 			end
 	end.

start()->
	register(room1,spawn(?MODULE,room,[20])),
	Vent1_PID = spawn(?MODULE,vent,[]),
	register(room2,spawn(?MODULE,room,[20])),
	Vent2_PID = spawn(?MODULE,vent,[]),
	register(room3,spawn(?MODULE,room,[20])),
	Vent3_PID = spawn(?MODULE,vent,[]),
	register(bms,spawn(?MODULE,bms,[Vent1_PID,Vent2_PID,Vent3_PID])),
	Duct_PID = spawn(?MODULE,duct,[0,Vent1_PID,Vent2_PID,Vent3_PID]),
	spawn(?MODULE,hotair,[]),
	spawn(?MODULE,ahu,[0,Duct_PID]).