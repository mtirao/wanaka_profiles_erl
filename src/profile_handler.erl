-module(profile_handler).
-behavior(cowboy_handler).

-export([init/2]).


init(Req0, State) ->
    Method = cowboy_req:method(Req0),
    Id = cowboy_req:binding(id, Req0),
    Req = application(Method, Id, Req0),
    {ok, Req, State}.

application(<<"POST">>, _ Req) -> 
    HasBody = cowboy_req:has_body(Req),
    case HasBody of
        true ->  Length = cowboy_req:body_length(Req),
            {ok, Data, _} = cowboy_req:read_body(Req, #{length => Length}),
            Profile = jsone:decode(Data),
            io:format("~p~n", [Profile]),
            {ok, Result} = profile_db_handler:create(Profile),
                case Result of
                    {{_, _, _}, []} -> 
                        cowboy_req:reply(204, Req);
                    _ -> 
                        cowboy_req:reply(400, Req) 
                end;
        false -> cowboy_req:reply(400, Req)
    end;

application(<<"GET">>, Id,  Req) when is_binary(Id) ->
    Config = profile_json_handler:profile_by_id(Id),
    cowboy_req:reply(200,
        #{<<"content-type">> => <<"application/json">>},
        Config,
        Req);

application(_, _, Req) ->
    %% Method not allowed.
    cowboy_req:reply(405, Req).

