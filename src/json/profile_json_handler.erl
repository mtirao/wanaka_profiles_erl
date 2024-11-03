-module(profile_json_handler).

-export([create_token/2]).

create_token(Id, UserId) ->
    binary_to_list(jsone:encode(#{access_token => UserId,  token_type => <<"JWT">>, expires_in => 3600, refresh_token => <<"">>})).