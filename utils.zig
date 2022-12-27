const std = @import("std");

pub const allegro = @cImport({
    @cInclude("allegro5/allegro.h");
    @cInclude("allegro5/allegro_primitives.h");
    @cInclude("allegro5/allegro_ttf.h");
});

pub var rng = std.rand.DefaultPrng.init(69);

pub const sin = std.math.sin;
pub const cos = std.math.cos;

pub fn deg2rad(deg: f32) f32 {
    return 0.0174532925 * deg;
}

pub fn get_delta_x(speed: f32, degrees: f32) f32 {
    return speed * sin(deg2rad(degrees));
}

pub fn get_delta_y(speed: f32, degrees: f32) f32 {
    return speed * cos(deg2rad(degrees)) * -1;
}

pub fn randint(max: i32) i32 {
    return rng.random().intRangeAtMost(max);
}

pub fn get_random_color() allegro.ALLEGRO_COLOR {
    return allegro.al_map_rgb(randint(255), randint(255), randint(255));
}

pub const Point = struct {
    x: f32,
    y: f32,
};
