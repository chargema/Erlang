-module (say).
-export ([start/0,saysth/2]).

saysth(What,0)->
	done;
saysth(What,Times)->
	io:format("~p~n",[What]),
	saysth(What,Times-1).

start()->
	spawn(say,saysth,[hello,3]),
	spawn(say,saysth,[goodbye,3]).