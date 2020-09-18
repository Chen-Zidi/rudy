%itest for improved server
-module(improvedTest).
-export([parse/0,bench/2,bench/4]).

%not use
parse() ->
    http:parse_request("GET /foo HTTP/1.1\r\nUser-Agent: Test\r\nAccept: anything\r\n\r\nThis is the body").


bench(Host,Port) ->
    bench(Host,Port,4,10).

%calcuate response time
bench(Host,Port,C,N) ->
    Start =erlang:system_time(micro_seconds),
    parallel(C,Host,Port,N,self()),
    collect(C),
    Finish = erlang:system_time(micro_seconds),
    T = Finish - Start,
    io:format(" ~wx~w requests in ~w ms~n",[C,N,(T)]).

%spawn C times process(parallel)
parallel(0,_,_,_,_)->
    ok;
parallel(C,Host,Port,N,Ctrl)->
    spawn(fun()->report(N,Host,Port,Ctrl)end),
    parallel(C-1,Host,Port,N,Ctrl).

%request n times (not parallel) and send ok message(if successful)
report(N,Host,Port,Ctrl)->
    run(N,Host,Port),
    %send ok message (sender in this program is the main program)
    Ctrl!ok.

%I think this function is just check if the program runs successfully
collect(0)->
    ok;
collect(N)->
    %get ok message
    receive
        ok->
            collect(N-1)
        end.

%run N times request(not parallel)
run(0,_,_)->
    ok;
run(N,Host,Port)->
    request(Host,Port),
    dummy(Host,Port),
    run(N-1,Host,Port).

%? it seems no use
%may be just make the program stop for a while
dummy(_,_)->
    ok.

%send request to the server
request(Host,Port)->
    {ok,Server} = gen_tcp:connect(Host,Port,[list,{active,false},{reuseaddr,true}]),
    gen_tcp:send(Server,http:get("foo")),
    Recv = gen_tcp:recv(Server,0),
    case Recv of
        {ok,_}->
            ok;
        {error,Error}->
            io:format("test:error:~w~n",[Error])
        end,
        gen_tcp:close(Server).
