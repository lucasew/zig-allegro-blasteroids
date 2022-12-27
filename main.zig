const std = @import("std");
const os = std.os;

const print = std.debug.print;
const assert = std.debug.assert;
const Timer = std.time.Timer;

const utils = @import("./utils.zig");
const entities = @import("./entities.zig");

const allegro = utils.allegro;
const deg2rad = utils.deg2rad;
const get_delta_x = utils.get_delta_x;
const get_delta_y = utils.get_delta_y;
const randint = utils.randint;
const get_random_color = utils.get_random_color;

const WindowTitle = "BLASTEROIDS by Lucas59356";

var running = true;
pub fn stop(_: c_int) callconv(.C) void {
    print("stop triggered", .{});
    running = false;
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
    spaceship: entities.Spaceship,
    tick_timer: Timer,

    pub fn new(allocator: *const std.mem.Allocator) *Game {
        print("Creating game object\n", .{});
        var game = allocator.create(Game) catch @panic("Game: can't allocate Game struct");

        game.queue = allegro.al_create_event_queue() orelse @panic("Allegro: can't create a queue");

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

        // entities
        const display_width = game.get_display_width();
        const display_height = game.get_display_height();
        game.spaceship = entities.Spaceship{
            .position = utils.Point{
                .x = @intToFloat(f32, display_width) / @as(f32, 2),
                .y = @intToFloat(f32, display_height) / @as(f32, 2),
            },
            .heading = 0,
            .speed = 10,
            .health = 200,
            .color = utils.get_random_color(),
        };
        game.tick_timer = Timer.start() catch @panic("Game: can't start tick_timer");
        return game;
    }
    fn get_display_width(self: *Game) i32 {
        return allegro.al_get_display_width(self.display);
    }
    fn get_display_height(self: *Game) i32 {
        return allegro.al_get_display_height(self.display);
    }

    fn tick(self: *Game) void {
        while (!allegro.al_is_event_queue_empty(self.queue)) {
            var event: allegro.ALLEGRO_EVENT = undefined;
            allegro.al_wait_for_event(self.queue, &event);
            switch (event.type) {
                allegro.ALLEGRO_EVENT_KEY_DOWN => {
                    switch (event.keyboard.keycode) {
                        allegro.ALLEGRO_KEY_LEFT => entities.Spaceship.turn_left(&self.spaceship),
                        allegro.ALLEGRO_KEY_RIGHT => entities.Spaceship.turn_right(&self.spaceship),
                        allegro.ALLEGRO_KEY_UP => entities.Spaceship.go_ahead(&self.spaceship),
                        allegro.ALLEGRO_KEY_DOWN => entities.Spaceship.go_back(&self.spaceship),
                        allegro.ALLEGRO_KEY_ESCAPE => stop(0),
                        allegro.ALLEGRO_KEY_SPACE => self.handle_shot(),
                        else => void{},
                    }
                },
                allegro.ALLEGRO_EVENT_DISPLAY_CLOSE => stop(0),
                allegro.ALLEGRO_EVENT_DISPLAY_RESIZE => {
                    if (!allegro.al_acknowledge_resize(self.display)) {
                        @panic("Allegro: can't resize display");
                    }
                    return void{};
                },
                else => void{},
            }
        }
        // TODO: tick everyone
        const ns_since_last_iter = self.tick_timer.lap();
        print("tick time: {}ns\n", .{ns_since_last_iter});
    }

    fn handle_shot(self: *Game) void {
        print("shot: {}\n", .{self});
        // TODO: implement shot
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
    var memory: [3 * 1024 * 1024]u8 = undefined;
    var fba = std.heap.FixedBufferAllocator.init(&memory);
    const allocator = &fba.allocator();

    // const allocator = &std.heap.page_allocator;
    print("Allocator: {}\n", .{allocator});

    defer stop(0);

    assert(allegro.al_init());
    assert(allegro.al_init_primitives_addon());
    assert(allegro.al_init_font_addon());
    assert(allegro.al_init_ttf_addon());
    assert(allegro.al_install_keyboard());

    var game = Game.new(allocator); // catch @panic("Can't start game");
    print("game: {}\n", .{game});
    print("timer: {}\n", .{game.tick_timer.lap()});
    std.time.sleep(10 * 1000 * 1000);
    defer Game.destroy(game, allocator);
    print("timer: {}\n", .{game.tick_timer.lap()});
    setup_signals();
    while (running) {
        game.tick();
    }
}
