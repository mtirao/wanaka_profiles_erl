-module(config_handler).
-behavior(cowboy_handler).

-export([init/2]).


init(Req0, State) ->
    Method = cowboy_req:method(Req0),
    Id = cowboy_req:binding(id, Req0),
    io:format("~p~n", [Id]),
    Req = application(Method, Id, Req0),
    {ok, Req, State}.

application(<<"GET">>, Id , Req) when is_binary(Id) ->
    Config = config_json_handler:config_by_id(Id),
    cowboy_req:reply(200,
        #{<<"content-type">> => <<"application/json">>},
        Config,
        Req);

application(<<"GET">>, _, Req) ->
    Configs = config_json_handler:list(),
    cowboy_req:reply(200,
        #{<<"content-type">> => <<"application/json">>},
        Configs,
        Req);

application(<<"POST">>, _, Req) ->
    HasBody = cowboy_req:has_body(Req),
    case HasBody of
        true ->  Length = cowboy_req:body_length(Req),
            {ok, Data, _} = cowboy_req:read_body(Req, #{length => Length}),
            Config = jsone:decode(Data),
            io:format("~p~n", [Config]),
            {ok, Result} = config_db_handler:create(Config),
                case Result of
                    {{_, _, _}, []} -> 
                        cowboy_req:reply(204, Req);
                    _ -> 
                        cowboy_req:reply(400, Req) 
                end;
        false -> cowboy_req:reply(400, Req)
    end;

application(<<"PUT">>, Id, Req) when is_binary(Id) ->
    HasBody = cowboy_req:has_body(Req),
    case HasBody of
        true ->  Length = cowboy_req:body_length(Req),
            {ok, Data, _} = cowboy_req:read_body(Req, #{length => Length}),
            Config = jsone:decode(Data),
            io:format("~p~n", [Config]),
            {ok, Result} = config_db_handler:update(Id, Config),
            io:format("~p~n", [Result]),
                case Result of
                    {{update, 1}, []} -> 
                        cowboy_req:reply(204, Req);
                    _ -> 
                        cowboy_req:reply(400, Req) 
                end;
        false -> cowboy_req:reply(400, Req)
    end;

application(<<"DELETE">>, Id , Req) when is_binary(Id) ->
    {ok, Result} = config_db_handler:delete(Id),
    case Result of
        {{delete,_},[]} -> 
            cowboy_req:reply(204, Req);
        _ -> 
            cowboy_req:reply(400, Req) 
        end;
    

application(_, _, Req) ->
    %% Method not allowed.
    cowboy_req:reply(405, Req).