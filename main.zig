const std = @import("std");
const os = std.os;

const print = std.debug.print;
const assert = std.debug.assert;

const utils = @import("./utils.zig");

const allegro = utils.allegro;
const deg2rad = utils.deg2rad;
const get_delta_x = utils.get_delta_x;
const get_delta_y = utils.get_delta_y;
const randint = utils.randint;
const get_random_color = utils.get_random_color;
const Point = utils.Point;

const WindowTitle = "BLASTEROIDS by Lucas59356";

var running = true;
pub fn stop(_: c_int) callconv(.C) void {
    print("stop triggered", .{});
    running = false;
}

pub fn demo() !void {
    print("Hello, {s}! {} {d:.2}\n", .{ "world", 2, 3.444444444444 });
    print("{}\n", .{Point{ .x = 2, .y = 2 }});
}

pub fn setup_signals() void {
    inline for (.{ os.SIG.TERM, os.SIG.INT }) |sig| {
        os.sigaction(sig, &os.Sigaction{ .handler = .{ .handler = stop }, .mask = os.empty_sigset, .flags = 0 }, null);
    }
}

const Game = struct {
    timer: *allegro.ALLEGRO_TIMER,
    queue: *allegro.ALLEGRO_EVENT_QUEUE,
    display: *allegro.ALLEGRO_DISPLAY,
    font: *allegro.ALLEGRO_FONT,

    // pub fn new(allocator: *const std.mem.Allocator, _: f64) *Game {
    pub fn new(allocator: *const std.mem.Allocator, fps: f64) *Game {
        print("Creating game object\n", .{});
        var game = allocator.create(Game) catch @panic("Game: can't allocate Game struct");

        game.queue = allegro.al_create_event_queue() orelse @panic("Allegro: can't create a queue");

        game.timer = allegro.al_create_timer(1.0 / fps) orelse @panic("Allegro: can't create a timer");
        allegro.al_start_timer(game.timer);

        var kbd_event_source = allegro.al_get_keyboard_event_source() orelse @panic("Allegro: can't create keyboard event source");
        allegro.al_register_event_source(game.queue, kbd_event_source);

        allegro.al_set_new_display_flags(allegro.ALLEGRO_RESIZABLE);

        game.display = allegro.al_create_display(600, 600) orelse @panic("Allegro: can't create a display");
        allegro.al_set_window_title(game.display, WindowTitle);
        allegro.al_register_event_source(game.queue, allegro.al_get_display_event_source(game.display));

        const font_file = std.os.getenv("ZAB_FONT") orelse @panic("Allegro: invalid font file");
        const c_font_file = allocator.dupeZ(u8, font_file) catch @panic("Game: can't allocate C compatible font file environment variable");
        // defer allocator.free(c_font_file);
        game.font = allegro.al_load_font(c_font_file, 24, 0) orelse @panic("Allegro: can't load font");

        return game;
    }

    pub fn destroy(self: *Game, allocator: *const std.mem.Allocator) void {
        print("Destroying game object: {}\n", .{self});
        allegro.al_destroy_timer(self.timer);
        allegro.al_destroy_event_queue(self.queue);
        allegro.al_destroy_display(self.display);
        allegro.al_destroy_font(self.font);
        allocator.destroy(self);
    }
};

pub fn main() !void {
    try demo();

    var memory: [3 * 1024 * 1024]u8 = undefined;
    var fba = std.heap.FixedBufferAllocator.init(&memory);
    const allocator = &fba.allocator();

    // const allocator = &std.heap.page_allocator;
    print("Allocator: {}\n", .{allocator});

    setup_signals();
    defer stop(0);

    assert(allegro.al_init());
    assert(allegro.al_init_primitives_addon());
    assert(allegro.al_init_font_addon());
    assert(allegro.al_init_ttf_addon());
    assert(allegro.al_install_keyboard());

    var game = Game.new(allocator, 30.0); // catch @panic("Can't start game");
    print("{}\n", .{game});
    std.time.sleep(10 * 1000 * 1000);
    defer Game.destroy(game, allocator);
}
