-module (ppt).
-export ([start/0 , ping/2 , pong/0]).

ping(0,Pong_PID) ->
	Pong_PID!finished,
	io:format("ping finished ~n",[]);
ping(N, Pong_PID) ->
	Pong_PID!{ping,self()},
	receive
		pong ->
			io:format("Ping received pong ~n",[])
	end,
	ping(N-1,Pong_PID).

pong() ->
	receive
		finished ->
			io:format("Pong finished ~n",[]);
		{ping,Ping_PID} ->
			io:format("Pong received ping ~n",[]),
			Ping_PID!pong,
			pong()
	end.

start() ->
	Pong_PID = spawn(ppt,pong,[]),
	spawn(ppt,ping,[5,Pong_PID]).

%% The CCS like following%%
%Ping(0) = ~finished.0
%Ping(N) = ~ping.pong.P ing(N − 1)
%Pong = (~finished.0) + (ping.~pong.P ong)
%Start = (Pong|Ping(3))\{ping, pong, f inished}