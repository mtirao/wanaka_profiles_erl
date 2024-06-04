-module(config_db_handler).

-export([configs/0, create/1, update/2, query/1, delete/1, services/1]).

connect() ->
    pgsql_connection:open("localhost", "smart_bff", "mtirao", "").

close(Conn) ->
    pgsql_connection:close(Conn).

services(Request) when is_map(Request) ->
    Service = binary_to_list(maps:get(<<"service">>,Request)),
    Conn = connect(),
    erlang:display(Conn),
    Result = pgsql_connection:extended_query("select id, service, url, endpoint, priority, count from services where service = $1 order by priority,count",[Service], Conn),
    close(Conn),
    {ok, Result}.

configs() ->
    Conn = connect(),
    erlang:display(Conn),
    Result = pgsql_connection:simple_query("select id, service, url, endpoint, priority, count from services", Conn),
    close(Conn),
    {ok, Result}.
    
create(Config) when is_map(Config) ->
    Service = binary_to_list(maps:get(<<"service">>,Config)),
    Url = binary_to_list(maps:get(<<"url">>,Config)),
    Endpoint = binary_to_list(maps:get(<<"endpoint">>,Config)),
    Priority = maps:get(<<"priority">>,Config),
    Count = maps:get(<<"count">>,Config),
    io:format("~s~n", [Service]),
    io:format("~s~n", [Url]),
    io:format("~s~n", [Endpoint]),
    Conn = connect(),
    Result = pgsql_connection:extended_query("insert into services(service, url, endpoint, priority, count) values ($1, $2, $3, $4, $5, $6)", [Service, Url, Endpoint, Priority, Count], Conn),
    close(Conn),
    {ok, Result}.

update(Id, Config) when is_map(Config) ->
    Service = binary_to_list(maps:get(<<"service">>,Config)),
    Url = binary_to_list(maps:get(<<"url">>,Config)),
    Endpoint = binary_to_list(maps:get(<<"endpoint">>,Config)),
    Priority = maps:get(<<"priority">>,Config),
    io:format("~s~n", [Service]),
    io:format("~s~n", [Url]),
    io:format("~s~n", [Endpoint]),
    Conn = connect(),
    Result = pgsql_connection:extended_query("update services set service = $2, url = $3, endpoint = $4, priority = $5 where id = $1", [binary_to_integer(Id), Service, Url, Endpoint, Priority], Conn),
    close(Conn),
    {ok, Result}.

query(Id) when is_integer(Id) ->
    Conn = connect(),
    {_, Result} = pgsql_connection:extended_query("select * FROM services WHERE id = $1", [Id], Conn),
    close(Conn),
    {ok, Result}.

delete(Id) ->
    Conn = connect(),
    Result = pgsql_connection:extended_query("delete from services WHERE id = $1", [binary_to_integer(Id)], Conn),
    close(Conn),
    {ok, Result}.
