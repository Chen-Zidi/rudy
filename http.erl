%HTTP request parser
-module(http).
-export([parse_request/1, ok/1, get/1,receive_request/1]).

receive_request([13,10,13,10|L0])->
    {[],L0};

receive_request([C|L0])->
    {R,L1}= receive_request(L0),
    {[C|R],L1}.

%identify request-line, header, and body in the request
parse_request(R0)->
    {Request,R1} = request_line(R0),
    {Headers,R2} = headers(R1),
    {Body,_} = message_body(R2),
    {Request,Headers,Body}.

%identify method(only GET), uri, version from the request-line
request_line([$G,$E,$T,32|R0])->
    {URI,R1} = request_uri(R0),
    {Ver,R2} = http_version(R1),
    [13,10|R3] = R2,
    {{get,URI,Ver},R3}.

%get uri(end with SP)
request_uri([32|R0])->
    {[],R0};

request_uri([C|R0])->
    {Rest,R1} = request_uri(R0),
    {[C|Rest],R1}.

%get version (1.1/1.0)
http_version([$H,$T,$T,$P,$/,$1,$.,$1|R0])->
    {v11,R0};
http_version([$H,$T,$T,$P,$/,$1,$.,$0|R0])->
    {v10,R0}.

%get headers(end with CRLF)
%several lines of headers
headers([13,10|R0])->
    {[],R0};
headers(R0)->
    {Header,R1}= header(R0),
    {Rest,R2}=headers(R1),
    {[Header|Rest],R2}.
%a single line of headers
header([13,10|R0])->
    {[],R0};
header([C|R0])->
    {Rest,R1} = header(R0),
    {[C|Rest],R1}.

%get message body
message_body(R)->
    {R,[]}.

%reply ok
ok(Body) ->
    % io:format("HTTP/1.1 200 OK\r\n" ++ "\r\n" ++ Body),
    "HTTP/1.1 200 OK\r\n" ++ "\r\n" ++ Body.
%reply uri
get(URI) ->
    "GET " ++ URI ++ " HTTP/1.1\r\n" ++ "\r\n".


