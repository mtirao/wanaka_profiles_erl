-module(profile_db_handler).

-export([create/1, update/2, query/1, delete/1, userAuthenticate/1]).

connect() ->
    pgsql_connection:open("localhost", "smartlist_profiles", "mtirao", "").

close(Conn) ->
    pgsql_connection:close(Conn).

    
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

userAuthenticate(Authenticate) ->
    Username = binary_to_list(maps:get(<<"username">>, Authenticate)),
    Password = binary_to_list(maps:get(<<"password">>, Authenticate)),
    Conn = connect(),
    Result = pgsql_connection:extended_query("SELECT id, user_password, user_id FROM profiles WHERE user_name=$1 AND  user_password=$2", [Username, Password], Conn),
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
