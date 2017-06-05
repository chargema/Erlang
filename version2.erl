-module (version2).
-export ([ahu/1, hotair/1, duct/2, vent/1, room/1, bms/1, start/0]).

ahu(Duct_PID)->
	Duct_PID ! {pressurise},
	%io:format("ahu running ~n,[]"),
	ahu(Duct_PID).

hotair(Room_PID)->
	Room_PID ! {getHot},
	%io:format("T is up! ~n,[]"),
	hotair(Room_PID).

duct(P,Vent_PID)->
	%io:format("Current P is: ~w~n",[P]),
	if 
		(P == 250) ->
			Vent_PID ! {getAir},
			%io:format("Release the getAir to vent. ~n",[]),
			duct(P-1,Vent_PID);
		true ->
			receive
				%{getAir} when P == 250->	
				{pressurise} when P < 250->
				%io:format("Get pressurise. Times:~w~n",[P+1]),
				duct(P+1,Vent_PID)		
			end
	end.

vent(Room_PID)->
	receive
		{von}->
			receive
				{getAir}->
					%io:format("Release giveAir to room. ~n",[]),
					Room_PID ! {giveAir},
					vent(Room_PID)
			end;
		{voff}->
			%io:format("Vent off, release getHot~n",[]),
			vent(Room_PID)
	end.

room(T)->
	if
		(T > 20) ->
			receive
				{giveAir}->
					io:format("T is low down: ~w~n",[T-1]),
					Ctemp = T-1,
					bms ! {ctemp, Ctemp},
					room(T-1)
			end;
		true ->
			receive
				{getHot} ->
					T_inc = rand:uniform(5),
					io:format("T is up to: ~w~n",[T+T_inc]),
					Ctemp = T+T_inc,
					bms ! {ctemp, Ctemp},
					room(T+T_inc)					
			end
	end.

bms(Vent_PID) ->
 	receive
 		{ctemp,Ctemp}->
 			if
 				Ctemp == 20 ->
 					Vent_PID ! {voff},
					io:format("Vent off now.~n",[]),
					bms(Vent_PID);
				true->
					Vent_PID ! {von},
					io:format("Vent on now.~n",[]),
					bms(Vent_PID)
 			end
 	end.

start()->
	Room_PID = spawn(?MODULE,room,[20]),
	Vent_PID = spawn(?MODULE,vent,[Room_PID]),
	register(bms,spawn(?MODULE,bms,[Vent_PID])),
	Duct_PID = spawn(?MODULE,duct,[0,Vent_PID]),
	spawn(?MODULE,hotair,[Room_PID]),
	spawn(?MODULE,ahu,[Duct_PID]).