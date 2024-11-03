%%%-------------------------------------------------------------------
%% @doc wanaka_profile public API
%% @end
%%%-------------------------------------------------------------------

-module(profiles_server_app).

-behaviour(application).

-export([start/2, stop/1]).

start(_StartType, _StartArgs) ->
    application:start(sasl),
    application:start(crypto),
    application:start(cowlib),
    application:start(ranch),
    application:start(cowboy),
    application:start(pgsql),
    Dispatch = cowboy_router:compile([
		{ '_', [ {"/api/smartlist/accounts/login", profile_handler, []} ]}
    ]),
    {ok, _} = cowboy:start_clear(my_http_listener,
        [{port, 8081}],
        #{env => #{dispatch => Dispatch}}
	),
    inets:start(),
	profiles_server_sup:start_link().
stop(_State) ->
    ok.

%% internal functions
