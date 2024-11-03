-module(profile_handler).
-behavior(cowboy_handler).

-export([init/2]).


init(Req0, State) ->
    Method = cowboy_req:method(Req0),
    Req = application(Method, Req0),
    {ok, Req, State}.

application(<<"POST">>, Req) ->
    HasBody = cowboy_req:has_body(Req),
    case HasBody of
        true ->  Length = cowboy_req:body_length(Req),
            {ok, Data, _} = cowboy_req:read_body(Req, #{length => Length}),
            User = jsone:decode(Data),
            io:format("~p~n", [User]),
            {ok, {_, Users}} = profile_db_handler:userAuthenticate(User),
                case Users of
                    [{Id, _, UserId}] -> 
                        cowboy_req:reply(200,
                            #{<<"content-type">> => <<"application/json">>},
                            profile_json_handler:create_token(Id, UserId),
                            Req);
                    [] -> 
                        cowboy_req:reply(400, Req) 
                end;
        false -> cowboy_req:reply(400, Req)
    end;

application(_, Req) ->
    %% Method not allowed.
    cowboy_req:reply(405, Req).

