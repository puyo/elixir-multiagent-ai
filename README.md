# Elixir Multiagent AI

* Each agent is a process (NOTE: but not an Elixir.Agent)
* Each agent updates itself periodically
* One "source of truth" process called "world" to model the environment in
  which the agents operate
* Agents query world to perceive what's around them
* Agents tell world when they want to move within it
* Agent <-> world via OTP message queues
* Agent <-> Agent via OTP message queues
* No existing multiagent protocols used, KISS for this weekend for fun

## Compiling and Running

### Elixir

Runs the simulation. Sends the state to the viewer via inter-process comms.

    cd rikrok
    mix deps.get
    mix run --no-halt

### SDL based viewer

Renders the state. Obtains the state from the simulation via inter-process comms.

    cd viewer

    # if OSX
    brew install msgpack nanomsg sdl libpng

    # if Ubuntu
    apt-get install libmsgpack-dev libnanomsg-dev libsdl1.2-dev libpng-dev

    make
    ./viewer

## TODO

* Refactor all the awful code. It's weekend hacking quality.

* Make agents smarter. A* pathfinding, for example.

* Add line-of-sight checks.

* Swap client/server. The simulation should probably be the server and the
  viewer should be the client. They're around the wrong way currently, but it
  doesn't matter too much because I am running one of each in a 2-way pair and
  they both try to reconnect. Only relevant if you wanted an MVC like situation
  with 1 simulation and multiple views of it. Then you'd probably need sub, not
  pair mode.
