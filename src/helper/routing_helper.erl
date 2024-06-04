-module(routing_helper).

-export([url_for_service/1]).


url_for_service(Request) ->
    Result = config_db_handler:services(Request),
    case Result of
        {ok, {{select, _}, Rows}} -> 
            service_rows(Rows);
        _ -> error
    end.

minimum([]) -> error;
minimum([H|T])  ->
    minimum(H, T).

minimum(Min, [H|T]) ->
    case count_from_row(Min) < count_from_row(H) of
        true -> minimum(Min, T);
        false -> minimum(H, T)
    end;
minimum(Min, []) -> {ok, Min}.

count_from_row(Row) ->
    {_, _, _, _, _, Count} = Row,
    Count.

build_url(Service) ->
    io:format("~p~n", [Service]),
    {_,_,Url,Endpoint,_,_} = Service,
    <<Url/binary, Endpoint/binary>>.

service_rows(Rows) ->
    Result = minimum(Rows),
    case Result of
        {ok, Min} -> {ok, build_url(Min)};
        _ -> {notfound, <<"">>}
    end.

