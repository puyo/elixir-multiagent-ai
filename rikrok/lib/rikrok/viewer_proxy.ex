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
  def handle_cast({:send, glyph_map}, state) do
    {:ok, data} = Msgpax.pack(glyph_map)
    with :ok <- :enm.send(state.socket, [<<2>>|data]) do
      # we sent it...
    else
      {:error, :closed} -> send(self(), :reconnect)
    end
    {:noreply, state}
  end

  @impl true
  def handle_info(:reconnect, state) do
    {:ok, socket} = :enm.pair
    :enm.connect(socket, state.socket_path)
    {:noreply, %{socket: socket, socket_path: state.socket_path}}
  end
end
