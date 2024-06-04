-module(config_json_handler).

-export([list/0, config_by_id/1]).

%convert_date_to_string(Datetime) ->
%    L = qdate:to_string("Y-m-d h:ia", Datetime),
%    lists:flatten([io_lib:format("~c", [V]) || V <- L]).

list() -> 
    {ok, {{_, Count}, Rows}} = config_db_handler:configs(),
    io:format("~p~n", [Rows]),
    Function = fun(Config, Acc) ->  [ config_to_map(Config) | Acc ] end,
    Values = lists:foldl(Function, [], Rows),
    binary_to_list(jsone:encode(#{count => Count, services => Values})).

config_by_id(Id) -> 
    {ok, [Row]} = config_db_handler:query(binary_to_integer(Id)),
    io:format("~p~n", [Row]),
    binary_to_list(jsone:encode(#{service => config_to_map(Row)})).

config_to_map(Config)  ->
    io:format("~p~n", [Config]),
    {Id, Budget, Url, Endpoint, Priority, Gap, Count} = Config,
    #{id => Id, budget => Budget, url => Url, endpoint => Endpoint, priority => Priority, gap => Gap, count => Count}.