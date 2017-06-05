-module (proc).
-export ([nil/1]).
-export ([p1/1]).
-export([p2/1]).

nil() ->
	ok.

p1() ->
	do({input, a}),
	do({input, b}),
	do({output, a}),
	do({output, b}),
	nil().

p2() ->
	do({input, a}),
	do({output, b}),
	p2().