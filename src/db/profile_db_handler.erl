-module(profile_db_handler).

-export([create/1, update/2, query/1, delete/1, userAuthenticate/1]).

connect() ->
    pgsql_connection:open("localhost", "smartlist_profiles", "mtirao", "").

close(Conn) ->
    pgsql_connection:close(Conn).

    
create(Profile) when is_map(Profile) ->
    Service = binary_to_list(maps:get(<<"service">>,Config)),
    Url = binary_to_list(maps:get(<<"url">>,Config)),
    Endpoint = binary_to_list(maps:get(<<"endpoint">>,Config)),
    Priority = maps:get(<<"priority">>,Config),
    Count = maps:get(<<"count">>,Config),
    
    Conn = connect(),
    Query = "INSERT INTO profiles(cell_phone, email, first_name, last_name, phone, user_name, user_password, user_role, gender, address, city, user_id) VALUES($1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12) RETURNING  cell_phone, email, first_name, last_name, phone, user_name, user_password, user_role, id, gender, address, city"
    Params = []
    Result = pgsql_connection:extended_query(Query, [Service, Url, Endpoint, Priority, Count], Conn),
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
    Result = pgsql_connection:extended_query("SELECT user_id FROM profiles WHERE user_name=$1 AND  user_password=$2", [Username, Password], Conn),
    close(Conn),
    {ok, Result}.

query(Id) when is_integer(Id) ->
    Conn = connect(),
    {_, Result} = pgsql_connection:extended_query("SELECT cell_phone, email, first_name, last_name, phone, user_name, user_password, user_role, id, gender, address, city, user_id FROM profiles WHERE user_id=$1", [Id], Conn),
    close(Conn),
    {ok, Result}.

delete(Id) ->
    Conn = connect(),
    Result = pgsql_connection:extended_query("delete from services WHERE id = $1", [binary_to_integer(Id)], Conn),
    close(Conn),
    {ok, Result}.
