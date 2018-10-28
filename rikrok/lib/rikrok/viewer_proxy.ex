defmodule Rikrok.ViewerProxy do
  # iex> {:ok, data} = Msgpax.pack(["Greetings", 300, "Spartans"])
  # iex> {:ok, s} = :enm.pair
  # iex> :enm.connect(s, "ipc:///tmp/test.ipc")
  # iex> :enm.send(s, [<<2>>|data])
  # iex> :enm.send(s, <<42>>)

  # --------------------------------------------------
  # client

  def start_link(_) do
    GenServer.start_link(__MODULE__, ["ipc:///tmp/test.ipc"], name: __MODULE__)
  end

  # --------------------------------------------------
  # server

  use GenServer

  @impl true
  def init([socket_path]) do
    {:ok, socket} = :enm.pair
    :enm.connect(socket, socket_path)
    {:ok, %{socket: socket, socket_path: socket_path}}
  end

  @impl true
  def handle_cast({:send, game_state}, state) do
    send_to_socket(state.socket, game_state)
    {:noreply, state}
  end

  def send_to_socket(socket, glyph_map) do
    {:ok, data} = Msgpax.pack(glyph_map)
    :enm.send(socket, [<<2>>|data])
  end
end
