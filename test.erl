%test for the basic server
%calculate response time
-module(test).
-export([bench/2]).

%calculate response time
bench(Host,Port)->
Start = erlang:system_time(micro_seconds),

%request for 100 times
run(100,Host,Port),
Finish = erlang:system_time(micro_seconds),
Finish - Start.

%send request for N times
run(N,Host,Port)->
if
    N == 0->
     ok;
    true->
     request(Host,Port),
     run(N-1,Host,Port)
end.

%send request to the server
request(Host,Port) ->
Opt = [list,{active,false},{reuseaddr,true}],
{ok,Server} = gen_tcp:connect(Host,Port,Opt),
gen_tcp:send(Server,http:get("foo")),

Recv = gen_tcp:recv(Server,0),
case Recv of
    {ok,_}->
        ok;
    {error,Error}->
        io:format("test:error:~w,~n",[Error])
    end,
gen_tcp:close(Server).

