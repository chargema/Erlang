- module ( hello ).
- export ([ say /1]).
%- export ([ respond /1]).
%- export ([ broken / 1]).

say ( A ) ->
	io : format (" Hello , ~p~n " ,[ A ]).
%respond ( mike ) ->
%	" Hi mike !";
%respond (42) ->
%	meaningoflife ;
%respond ({ mytuple , _}) ->
%	" You gave me a pair but I ignored half of it ".
%broken ({1 , A }) ->
%	1 + A ;
%broken ({1 ,0}) ->
%	1;
%broken ( A ) ->
%	{ error , " I can ’ t handle that !" , A }.

