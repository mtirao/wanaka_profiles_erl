-module(profile_handler).
-behavior(cowboy_handler).

-export([init/2]).


init(Req0, State) ->
    Method = cowboy_req:method(Req0),
    Id = cowboy_req:binding(id, Req0),
    Req = application(Method, Id, Req0),
    {ok, Req, State}.


application(<<"GET">>, Id,  Req) when is_binary(Id) ->
    Config = profile_json_handler:profile_by_id(Id),
    cowboy_req:reply(200,
        #{<<"content-type">> => <<"application/json">>},
        Config,
        Req);
    
application(_, _, Req) ->
    %% Method not allowed.
    cowboy_req:reply(405, Req).

