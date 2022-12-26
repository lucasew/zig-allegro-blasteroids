const std = @import("std");
const os = std.os;

const print = std.debug.print;

// const allocator = std.heap.page_allocator;

const allegro = @cImport({
    @cInclude("allegro5/allegro.h");
    @cInclude("allegro5/allegro_primitives.h");
    @cInclude("allegro5/allegro_ttf.h");
});

const WindowTitle = "BLASTEROIDS by Lucas59356";

var running = true;
pub fn stop(_: c_int) callconv(.C) void {
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
    for (.{ os.SIG.TERM, os.SIG.INT }) |sig| {
        os.sigaction(sig, &os.Sigaction{ .handler = .{ .handler = stop }, .mask = os.empty_sigset, .flags = 0 }, null);
    }
}

const Game = struct {
    timer: allegro.ALLEGRO_TIMER,
    queue: allegro.ALLEGRO_EVENT_QUEUE,
    display: allegro.ALLEGRO_DISPLAY,
    font: allegro.ALLEGRO_FONT,

    pub fn new(allocator: *std.mem.Allocator, fps: i8) *Game {
        var game = try allocator.create(Game);
        errdefer allocator.destroy(game);

        game.queue = allegro.al_create_event_queue();

        game.timer = allegro.al_create_timer(1.0 / fps);
        allegro.al_start_timer(game.timer);

        allegro.al_register_event_source(game.queue, allegro.al_get_keyboard_event_source());

        allegro.al_set_new_display_flags(allegro.ALLEGRO_RESIZABLE);
        game.display = allegro.al_create_display(600, 600);
        allegro.al_set_window_title(game.display, WindowTitle);
        allegro.al_register_event_source(game.queue, allegro.al_get_display_event_source(game.display));
        game.font = allegro.al_load_font(std.process.getenv("ZBS_FONT"), 24, 0);

        return game;
    }

    pub fn destroy(self: Game, allocator: *std.mem.Allocator) void {
        allegro.al_destroy_timer(self.timer);
        allegro.al_destroy_event_queue(self.queue);
        allegro.al_destroy_display(self.display);
        allegro.al_destroy_font(self.font);
        allocator.destroy(self);
    }
};

pub fn main() !void {
    try demo();

    setup_signals();
    defer stop(0);

    _ = allegro.al_init();
    _ = allegro.al_init_primitives_addon();
    _ = allegro.al_init_font_addon();
    _ = allegro.al_init_ttf_addon();

    var timer = allegro.al_create_timer(1.0 / 60.0);
    allegro.al_start_timer(timer);
}
