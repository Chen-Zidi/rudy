%improved server for question 4.1
%this server can handle parallel requests
-module(improvedServer).
-export([start/1, start/2, stop/0]).

%start(Port)->
%   register(rudy, spawn(fun() -> init(Port) end)).

start(Port)->
    start(Port,1).

start(Port,N) ->
    register(rudy2,spawn(fun()->init(Port,N) end)).

%stop() ->
%    exit(whereis(rudy), "time to die").

%send stop message
stop()->
    rudy2!stop.

%open a listening socket
init(Port,N) ->
    Opt = [list, {active, false}, {reuseaddr, true}],

    %listen to the port
    case gen_tcp:listen(Port, Opt) of
        {ok, Listen}->
            %spawn(fun() -> handler(Listen) end),

            %pass to handler
            handlers(Listen,N),
            super();

            %gen_tcp:close(Listen),
            %ok;
        {error, _Error}->
            io:format("rudy2: error1: ~w~n", [_Error]),
            error
    end.

%receive stop message
super()->
    receive
        stop ->
            
            ok
    end.

%generate N handler processes at the same time. (parallel handlers)
handlers(Listen,N) ->
    case N of
        0->
            ok;
        N->
            spawn(fun()->handler(Listen,N) end),
            handlers(Listen,N-1)
        end.

%I is used to identify which parallel process it is
%accept request
handler(Listen,I) ->
    case gen_tcp:accept(Listen) of
        {ok, Client} ->
            %spawn(fun() -> handler(Listen) end),
            
            %pass to request
            request(Client),

            %prepare to accept request again
            handler(Listen,I);

           
        {error, _Error} ->
            %io:format("rudy2: error2: ~w~n", [_Error]),
            error
    end.

%get the request and parse it
request(Client) ->
    Recv = gen_tcp:recv(Client, 0),
    case Recv of
        {ok, Str} ->
            %parse the request by the parser
            Request = http:parse_request(Str),

            Response = reply(Request),
            gen_tcp:send(Client, Response),
            
            gen_tcp:close(Client);
        {error, _Error} ->
            %io:format("rudy2: error3: ~w~n", [Error])
            error
    end.
    %gen_tcp:close(Client).

%reply
reply({{get, _URI, _}, _, Body}) ->
    %sleep for 20 ms
    timer:sleep(20),
    http:ok(Body).

