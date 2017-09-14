-module(rudy).
-export([start/1, stop/0]).

start(Port) ->
  register(rudy, spawn(fun() -> init(Port) end)).
stop() ->
  exit(whereis(rudy), "time to die").

init(Port) ->
  Opt = [list, {active, false}, {reuseaddr, true}],
  case gen_tcp:listen(Port, Opt) of
    {ok, Listen} ->
      handler(Listen),
      % io:format("Listening to Port : ~p~n", [Port]);
      gen_tcp:close(Listen),
      ok;
    {error, Error} ->
      io:format("Error : ~p~n", [Error]),
      error
  end.

handler(Listen) ->
  case gen_tcp:accept(Listen) of
    {ok, Client} ->
      request(Client),
      handler(Listen);
      % io:format("Incoming request accepted.");
      {error, Error} ->
        io:format("Error : ~p~n", [Error]),
        error

  end.

request(Client) ->
  Recv = gen_tcp:recv(Client, 0),
  % if
  %   X = 13, Y = 10,
  %   {ok, [_| X,Y,X,Y]} ->
  %   io:format("ok"),
  %   NewRecv = Recv;
  %     true ->
  %       Recv1 = Recv,
  %       Recv2 = gen_tcp:recv(Client,0),
  %       NewRecv = Recv1 ++Recv2
  %
  %
  % end;
  case Recv of
    {ok, Str} ->
      Request = http:parse_request(Str),
      io:format("Request : ~w~n", [Recv]),
      Response = reply(Request),
      gen_tcp:send(Client, Response);
    {error, Error} ->
      io:format("rudy: error: ~w~n", [Error])
    end,
    gen_tcp:close(Client).

reply({{get, URI, _}, _, _}) ->
   timer:sleep(40),
    % http:get(URI).
    http:ok("<html><head><title>Rudy</title></head><body>Testsd<br/>" ++ URI ++ "</body></html>").
