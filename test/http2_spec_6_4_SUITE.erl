-module(http2_spec_6_4_SUITE).

-include("http2.hrl").
-include_lib("eunit/include/eunit.hrl").
-include_lib("common_test/include/ct.hrl").
-compile([export_all]).

all() ->
    [
     sends_rst_stream_to_idle
    ].

init_per_suite(Config) ->
    application:ensure_started(crypto),
    chatterbox_test_buddy:start(Config).

end_per_suite(Config) ->
    chatterbox_test_buddy:stop(Config),
    ok.

sends_rst_stream_to_idle(_Config) ->
    {ok, Client} = http2c:start_link(),

    F = {
      #frame_header{
         stream_id=1
        },
      h2_frame_rst_stream:new(?CANCEL)
     },

    http2c:send_unaltered_frames(Client, [F]),

    Resp = http2c:wait_for_n_frames(Client, 0, 1),
    ct:pal("Resp: ~p", [Resp]),
    ?assertEqual(1, (length(Resp))),
    [{GoAwayH, GoAway}] = Resp,
    ?assertEqual(?GOAWAY, (GoAwayH#frame_header.type)),
    ?assertEqual(?PROTOCOL_ERROR, (h2_frame_goaway:error_code(GoAway))),
    ok.
