const std = @import("std");
const os = std.os;

const print = std.debug.print;
const assert = std.debug.assert;

const allegro = @cImport({
    @cInclude("allegro5/allegro.h");
    @cInclude("allegro5/allegro_primitives.h");
    @cInclude("allegro5/allegro_ttf.h");
});

const WindowTitle = "BLASTEROIDS by Lucas59356";

var running = true;
pub fn stop(_: c_int) callconv(.C) void {
    print("stop triggered", .{});
    running = false;
}

const Point = struct {
    x: f32,
    y: f32,
};

pub fn demo() !void {
    print("Hello, {s}! {} {d:.2}\n", .{ "world", 2, 3.444444444444 });
    print("{}\n", .{Point{ .x = 2, .y = 2 }});
}

pub fn setup_signals() void {
    inline for (.{ os.SIG.TERM, os.SIG.INT }) |sig| {
        os.sigaction(sig, &os.Sigaction{ .handler = .{ .handler = stop }, .mask = os.empty_sigset, .flags = 0 }, null);
    }
}

const GameInitError = error{ CantCreateQueue, CantCreateTimer, CantCreateDisplay, CantCreateFont, InvalidFontFile };

const Game = struct {
    timer: *allegro.ALLEGRO_TIMER,
    queue: *allegro.ALLEGRO_EVENT_QUEUE,
    display: *allegro.ALLEGRO_DISPLAY,
    font: *allegro.ALLEGRO_FONT,

    pub fn new(allocator: *std.mem.Allocator, fps: f64) !*Game {
        print("Creating game object", .{});
        var game = try allocator.create(Game);
        // errdefer allocator.free(game);

        game.queue = allegro.al_create_event_queue() orelse return GameInitError.CantCreateQueue;

        game.timer = allegro.al_create_timer(1.0 / fps) orelse return GameInitError.CantCreateTimer;
        allegro.al_start_timer(game.timer);

        allegro.al_register_event_source(game.queue, allegro.al_get_keyboard_event_source());

        allegro.al_set_new_display_flags(allegro.ALLEGRO_RESIZABLE);

        game.display = allegro.al_create_display(600, 600) orelse return GameInitError.CantCreateDisplay;
        allegro.al_set_window_title(game.display, WindowTitle);
        allegro.al_register_event_source(game.queue, allegro.al_get_display_event_source(game.display));

        const font_file = std.os.getenv("ZAB_FONT") orelse return GameInitError.InvalidFontFile;
        game.font = allegro.al_load_font(font_file, 24, 0) orelse return GameInitError.CantCreateFont;

        return game;
    }

    pub fn destroy(self: *Game, allocator: *std.mem.Allocator) void {
        print("Destroying game object", .{});
        allegro.al_destroy_timer(self.timer);
        allegro.al_destroy_event_queue(self.queue);
        allegro.al_destroy_display(self.display);
        allegro.al_destroy_font(self.font);
        allocator.destroy(self);
    }
};

pub fn main() !void {
    try demo();

    var memory: [64 * 1024 * 1024]u8 = undefined;
    var allocator = std.heap.FixedBufferAllocator.init(&memory).allocator();

    setup_signals();
    defer stop(0);

    _ = allegro.al_init();
    _ = allegro.al_init_primitives_addon();
    _ = allegro.al_init_font_addon();
    _ = allegro.al_init_ttf_addon();

    var game = try Game.new(&allocator, 30);
    defer game.destroy();
    std.time.sleep(1 * std.time.us_per_s);
}
