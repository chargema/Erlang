- module(singleproc).
- export([do/1]).
- export([sqrt/1]).
- export([calc_sqrt/1]).

do({output, E}) ->
	io:format("~~~p~n", [E]);
do({input,E}) ->
	io:format("~p~n",[E]);
do([]) ->
	ok;
do([E | MoreEs]) ->
	do(E),
	do(MoreEs);
do( _ ) ->
	io:format("Unknow argument to do/1 ~n").

calc_sqrt(x) ->
	
	
sqrt(x) ->
	FinalValue = case calc_sqrt(x) of
			{ok, Value} ->
			Value;
			{error, Reason}->
			exit(Reason)
		end,
	io: format("Produced: ~p~n",[FinalValue]).