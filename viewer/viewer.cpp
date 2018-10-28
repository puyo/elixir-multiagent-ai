#include "display.hpp"
#include "events.hpp"

#include <nanomsg/nn.h>
#include <nanomsg/pair.h>

#include <msgpack.hpp>

#include <assert.h>
#include <libc.h>

#include <cstring>
#include <vector>
#include <iostream>

int main(int argc, char *argv[]) {
  // init display
  printf("Opening window...\n");
  Display::open("Viewer", 800, 600);
  int font = Display::load_font("fonts/map.png");
  Display::set_font(font);
  uint tw = Display::text_width(font, "W");
  uint th = Display::text_height(font);

  // init network
  printf("Connecting...\n");
  int s = nn_socket(AF_SP, NN_PAIR);
  assert(s >= 0);
  assert( nn_bind(s, "ipc:///tmp/test.ipc") >= 0);
  void* buf = NULL;
  struct nn_pollfd pfd;
  pfd.fd = s;
  pfd.events = NN_POLLIN;

  while (true) {
    //printf("Pollin\n");
    int count = nn_recv(s, &buf, NN_MSG, NN_DONTWAIT);

    if (count > 0) {
      uint8_t type = 0;
      std::memcpy(&type, buf, 1);
      // std::cout << "type is: " << (int)type << "\n";
      std::cout << "." << std::flush;

      if (type == 42) break;

      msgpack::object_handle oh = msgpack::unpack((const char*)buf+1, count-1);
      msgpack::object deserialized = oh.get();
      std::vector< std::vector<std::string> > glyphs;
      deserialized.convert(glyphs);
      nn_freemsg(buf);

      uint h = glyphs.size() * th;
      uint w = glyphs[0].size() * tw;

      if (w != Display::width() || h != Display::height()) {
        std::cout << "setting size to " << w << "x" << h << std::flush;
        Display::set_size(w, h);
      }

      // DRAW
      Display::set_colour(0xffffff);
      for (uint y = 0; y < glyphs.size(); ++y) {
        auto const& row = glyphs[y];
        for (uint x = 0; x < row.size(); ++x) {
          auto const& g = row[x];
          uint col;
          switch (g[0]) {
          case '@': col = 0x00ff00; break;
          case '.': col = 0xcccccc; break;
          case '#': col = 0xaaaaaa; break;
          }
          Display::set_colour(col);
          uint px = x * tw;
          uint py = y * th;
          if (px < Display::width() + tw && py < Display::height() + th) {
            Display::draw_glyph(px, py, g[0]);
          }
        }
      }
      Display::refresh();
    }

    //printf("Get next\n");
    Events::poll();
    switch (Events::type()) {
    case Events::EVENT_RESIZE:
      Display::set_size(Events::event()->resize.w, Events::event()->resize.h);
      break;
    case Events::EVENT_EXIT:
      exit(0);
      break;
    case Events::EVENT_KEY_DOWN:
      switch (Events::key()) {
      case Events::KEY_ESCAPE:
        exit(0);
        break;
      }
    }
  }
  nn_close(s);
  return 0;
}
