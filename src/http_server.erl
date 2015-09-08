-module(http_server).
-compile(export_all).

main() ->
    start(9090).

start(Port) ->
    io:format("server started.~n"),
    {ok, ServerSocket} = gen_tcp:listen(Port, [binary, {packet, 0},
        {reuseaddr, true}, {active, true}]),
    server_loop(ServerSocket).

server_loop(ServerSocket) ->
    {ok, Socket} = gen_tcp:accept(ServerSocket),

    Pid = spawn(fun() -> handle_client(Socket) end),
    inet:setopts(Socket, [{packet, 0}, binary,
        {nodelay, true}, {active, true}]),
    gen_tcp:controlling_process(Socket, Pid),

    server_loop(ServerSocket).

handle_client(Socket) ->
    receive
        {tcp, Socket, Request} ->
                io:format("received: ~s~n", [Request]),

                gen_tcp:send(Socket, header() ++ content()),
                gen_tcp:close(Socket),

                io:format("closed...~n")
    end.

header() ->
    "HTTP/1.0 200 OK\r\n" ++
    "Cache-Control: private\r\n" ++
    "Content-Type: text/html\r\n" ++
    "Connection: Close\r\n\r\n".

content() ->
    "Hello World".
