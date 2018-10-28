#include "display.hpp"
#include "events.hpp"

#include <cstring>
#include <vector>
#include <nanomsg/nn.h>
#include <nanomsg/pair.h>
#include <msgpack.hpp>
#include <iostream>


int main(int argc, char *argv[]) {
  // init display
  printf("Opening window...\n");
  Display::open("Viewer", 1600, 800);
  int font = Display::load_font("fonts/map.png");
  Display::set_font(font);
  uint tw = Display::text_width(font, "W");
  uint th = Display::text_height(font);

  // init network
  printf("Connecting...\n");
  int s = nn_socket(AF_SP, NN_PAIR);
  nn_bind(s, "ipc:///tmp/test.ipc");
  void* buf = NULL;
  int count;
  struct nn_pollfd pfd;
  pfd.fd = s;
  pfd.events = NN_POLLIN;

  while (true) {
    int rc = nn_poll(&pfd, 1, 0);

    //printf("Pollin\n");
    if (rc > 0 && pfd.revents & NN_POLLIN) {
      //printf("Message can be received from s1!\n");

      if ((count = nn_recv(s, &buf, NN_MSG, 0)) != -1) {
        uint8_t type = 0;
        std::memcpy(&type, buf, 1);
        // std::cout << "type is: " << (int)type << "\n";

        if (type == 42) break;

        msgpack::object_handle oh = msgpack::unpack((const char*)buf+1, count-1);
        msgpack::object deserialized = oh.get();
        std::vector< std::vector<std::string> > glyphs;
        deserialized.convert(glyphs);
        nn_freemsg(buf);

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
