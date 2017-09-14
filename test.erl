-module(test).
-export([bench/2, bench/3]).

bench(Host, Port) ->
  bench(Host, Port, 100).

bench(Host, Port, N) ->
  Start = erlang:system_time(micro_seconds),
  run(N, Host, Port),
  Finish = erlang:system_time(micro_seconds),
  T = Finish - Start,
  io:format("~w requests in ~w micro seconds ~n", [N, T]).

run(N, Host, Port) ->
  if
    N == 0 ->
      ok;
    true ->
      request(Host, Port),
      run(N-1, Host, Port)
  end.

%
% bench(Host, Port) ->
%     bench(Host, Port, 4, 25).
%
% bench(Host, Port, C, N) ->
%     Start = erlang:system_time(micro_seconds),
%     parallel(C, Host, Port, N, self()),
%     collect(C),
%     Finish = erlang:system_time(micro_seconds),
%     T = Finish - Start,
%     io:format(" ~wx~w requests in ~w micro seconds~n", [C, N, T]).
%
% parallel(0, _, _, _, _) ->
%     ok;
% parallel(C, Host, Port, N, Ctrl) ->
%     spawn(fun() -> report(N, Host, Port, Ctrl) end),
%     parallel(C-1, Host, Port, N, Ctrl).
%
%
% report(N, Host, Port, Ctrl) ->
%     run(N, Host, Port),
%     Ctrl ! ok.
%
%
% collect(0) ->
%     ok;
% collect(N) ->
%     receive
% 	ok ->
% 	    collect(N-1)
%     end.
%
%   run(0, _, _) ->
%       ok;
%   run(N, Host, Port) ->
%       %%io:format("sending request ~w~n", [N]),
%       request(Host, Port),
%       %%dummy(Host, Port),
%       run(N-1, Host, Port).


request(Host, Port) ->
  Opt = [list, {active, false}, {reuseaddr, true}],
  {ok, Server} = gen_tcp:connect(Host, Port, Opt),
  gen_tcp:send(Server, http:get("foo")),
  Recv = gen_tcp:recv(Server, 0),
  case Recv of
    {ok, _} ->
      ok;
    {error, Error} ->
      io:format("test : error: ~w~n", [Error])
    end,
    gen_tcp:close(Server).
