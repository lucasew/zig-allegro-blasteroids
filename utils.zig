const std = @import("std");

pub const allegro = @cImport({
    @cInclude("allegro5/allegro.h");
    @cInclude("allegro5/allegro_primitives.h");
    @cInclude("allegro5/allegro_ttf.h");
});

pub var rng = std.rand.DefaultPrng.init(69);

pub const sin = std.math.sin;
pub const cos = std.math.cos;
pub const sqrt = std.math.sqrt;
pub const floor = std.math.floor;

pub fn range(len: usize) []const u0 {
    return comptime @as([*]u0, undefined)[0..len];
}

pub fn deg2rad(deg: f32) f32 {
    return 0.0174532925 * deg;
}

pub fn get_delta_x(speed: f32, degrees: f32) f32 {
    return speed * sin(deg2rad(degrees));
}

pub fn get_delta_y(speed: f32, degrees: f32) f32 {
    return speed * cos(deg2rad(degrees)) * -1;
}

pub fn randint(comptime t: type, max: t) t {
    return rng.random().intRangeAtMost(t, 0, max);
}

pub fn get_random_color() allegro.ALLEGRO_COLOR {
    const r = randint(u8, 255);
    const g = randint(u8, 255);
    const b = randint(u8, 255);
    return allegro.al_map_rgb(r, g, b);
}

pub const Point = struct {
    x: f32,
    y: f32,
    pub fn distance(a: Point, b: Point) f32 {
        const x = a.x - b.x;
        const y = a.y - b.y;
        return sqrt(x * x + y * y);
    }
    pub fn intervalify(self: Point, max_x: f32, max_y: f32) Point {
        return Point{
            .x = self.x - floor(self.x / max_x) * max_x,
            .y = self.y - floor(self.y / max_y) * max_y,
        };
    }
};
