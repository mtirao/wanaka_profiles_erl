-module(routing_handler).
-behavior(cowboy_handler).

-export([init/2]).


init(Req0, State) ->
    Method = cowboy_req:method(Req0),
    Req = application(Method,Req0),
    {ok, Req, State}.


application(<<"POST">>, Req) ->
    HasBody = cowboy_req:has_body(Req),
    case HasBody of
        true ->  Length = cowboy_req:body_length(Req),
            {ok, Data, _} = cowboy_req:read_body(Req, #{length => Length}),
            Request = jsone:decode(Data),
            io:format("~p~n", [Request]),
            Result = validate_request_process(Request),
            io:format("~p~n", [Result]),
                case Result of
                    {ok, Body} -> 
                        cowboy_req:reply(200,#{<<"content-type">> => <<"application/json">>}, list_to_binary(Body), Req);
                    _ -> 
                        cowboy_req:reply(400, Req) 
                end;
        false -> cowboy_req:reply(400, Req)
    end;

application(_, Req) ->
    %% Method not allowed.
    cowboy_req:reply(405, Req).

validate_request_process(Request) -> 
    Method = maps:is_key(<<"method">>, Request),
    Payload = maps:is_key(<<"payload">>, Request),
    Service = maps:is_key(<<"service">>, Request),
    if 
        Method and Service and Payload -> process_request(Request);
        Method and Service -> process_request_without_payload(Request);
        true -> {notfound, <<"bad request">>}
    end.

process_request(Request) ->
    Result = routing_helper:url_for_service(Request),
    Payload = maps:get(<<"payload">>,Request),
    Method = maps:get(<<"method">>,Request),
    case Result of 
        {ok, Url} -> make_request(Url, Payload, Method);
        _ -> {notfound, <<"bad request">>}
    end.

process_request_without_payload(Request) ->
    Result = routing_helper:url_for_service(Request),
    Method = maps:get(<<"method">>,Request),
    case Result of 
        {ok, Url} -> make_request(Url, Method);
        _ -> {notfound, <<"bad request">>}
    end.

make_request(Url, Payload, <<"POST">>) ->
    io:format("~p~n", [Url]),
    {ok, <<"succuseful">>};

make_request(Url, Payload, <<"PUT">>) ->
    io:format("~p~n", [Url]),
    {ok, <<"succuseful">>};

make_request(Url, Payload, <<"DELETE">>) ->
    io:format("~p~n", [Url]),
    {ok, <<"succuseful">>};

make_request(Url, Payload, <<"GET">>) ->
    io:format("~p~n", [Url]),
    {ok, <<"succuseful">>};

make_request(Url, Payload, _) ->
    {error, <<"Unsupported method!">>}.

%% Function to process any request without payload.
%% for now only GET is supported 
make_request(Url, <<"GET">>) ->
    io:format("~p~n", [Url]),
    {ok, {{_, 200, _}, _, NewBody}} =
      httpc:request(get, {binary_to_list(Url), [{"connection", "close"}]}, [], []),
    io:format("~p~n", [NewBody]),
    {ok, NewBody};

make_request(Url, _) ->
    {error, <<"Unsupported method!">>}.
