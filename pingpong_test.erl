-module (ppt_test).
-include_lib ("eunit/include/eunit.hrl").

expect(Val)->
	receive
		Val->
			ok;
		Other ->
			{error,Other}
	end.

ping_test()->
	PID = spawn(pingpong,ping,[1,self()]),
	ok = expect({ping,PID}),
	PID ! pong,
	ok = expect(finished).

ping_expect2_test()->
	PID = spawn(pingpong,ping,[1,self()]),
	ok = expect({ping,PID}),
	PID ! pong,
	ok = expect({ping,PID}),
	PID ! pong,
	ok = expect(finished).