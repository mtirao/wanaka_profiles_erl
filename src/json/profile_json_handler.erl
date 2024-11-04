-module(profile_json_handler).

-export([create_token/1, profile_by_id/1]).

create_token(UserId) ->
    ExpirationTime = unix_time() + 864000, % ten days
    Jwt = jwerl:sign([{user, UserId}, {exp, ExpirationTime}], hs256, <<"eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9">>),
    binary_to_list(jsone:encode(#{access_token => Jwt,  token_type => <<"JWT">>, expires_in => ExpirationTime, refresh_token => <<"">>})).


profile_by_id(Id) -> 
    {ok, [Row]} = profile_db_handler:query(binary_to_integer(Id)),
    io:format("~p~n", [Row]),
    binary_to_list(jsone:encode(profile_to_map(Row))).

unix_time() ->
    UnixEpoch = {{1970,1,1},{0,0,0}},
    calendar:datetime_to_gregorian_seconds(calendar:local_time()) -
    calendar:datetime_to_gregorian_seconds(UnixEpoch).

profile_to_map(Profile)  ->
    io:format("~p~n", [Profile]),
    {CellPhone, Email, FirstName, LastName, Phone, _, _, UserRole, Id, Gender, Address, City, UserId} = Profile,
    #{cellphone => CellPhone, email => Email, firstname => FirstName, lastname => LastName, phone => Phone, userrole => UserRole, 
    profileid => Id, gender => Gender, address => Address, city => City, userid => UserId}.