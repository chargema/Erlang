-module (test).
-export ([ahu/2,duct/2,vent/2,start/0]).

%% prevent the duct be pressurised ridiculously %%
ahu(250,Duct_PID) ->
	Duct_PID ! finished;
%% pressurise the duct %%
ahu(N,Duct_PID) ->
	Duct_PID ! pressurise,
	ahu(N+1,Duct_PID).

%duct(P,Vent_PID) ->
	%Vent_PID ! getAir,
%	io:format("Sent~n",[]),
%	duct(P-1,Vent_PID);

duct(P,[]) ->
	receive
		%% The stop stituation when air pressre reaches 250 %%
		finished->
			io:format("Duct finished pressurised. Air pressure:~w~n",[P]);
		%% When receiving the pressre, p+1 %%
		pressurise->
			io:format("Duct received pressurise. Air pressure:~w~n",[P+1]),
			duct(P+1,[])
	end.

vent(Room_PID,Duct_PID) ->
	receive
		getAir->
			receive
				von->
					Room_PID!giveAir,
					vent(Room_PID,Duct_PID);
				voff->
					Duct_PID!pressurise
			end
	end.




start() ->
	%Vent_PID = spawn(?MODULE,vent)
	Duct_PID = spawn(?MODULE,duct,[0,[]]),
	spawn(?MODULE,ahu,[0,Duct_PID]).