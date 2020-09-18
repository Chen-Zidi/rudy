%basic server
-module(server).
-export([start/1, stop/0]).

start(Port)->
   register(rudy, spawn(fun() -> init(Port) end)).


stop() ->
   exit(whereis(rudy), "time to die").


%open a listening socket
init(Port) ->
    Opt = [list, {active, false}, {reuseaddr, true}],

    %listen to the port
    case gen_tcp:listen(Port, Opt) of
        {ok, Listen}->
            
            %pass to handler
            handler(Listen),
            

            gen_tcp:close(Listen),
            ok;
        {error, _Error}->
            io:format("rudy: error1: ~w~n", [_Error]),
            error
    end.


%accept request
handler(Listen) ->
    case gen_tcp:accept(Listen) of
        {ok, Client} ->
            
            %pass to request
            request(Client),

            %prepare to accept request again
            handler(Listen);

           
        {error, _Error} ->
            io:format("rudy: error2: ~w~n", [_Error]),
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
            gen_tcp:send(Client, Response);
        {error, Error} ->
            io:format("rudy: error3: ~w~n", [Error])
    end,
    gen_tcp:close(Client).

%reply
reply({{get, _URI, _}, _, Body}) ->
    %sleep for 20 ms
    timer:sleep(20),
    http:ok(Body).

