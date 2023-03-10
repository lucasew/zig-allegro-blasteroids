const utils = @import("./utils.zig");

const allegro = utils.allegro;

pub const Asteroid = struct {
    position: utils.Point,
    heading: f32,
    speed: f32,
    rot_speed: f32,
    scale: f32,
    health: f32,
    color: allegro.ALLEGRO_COLOR,
    pub fn update_position(self: *Asteroid, ticks: f32) bool {
        self.heading += self.rot_speed * ticks;
        self.position.x += utils.get_delta_x(ticks * self.speed, self.heading);
        self.position.y += utils.get_delta_y(ticks * self.speed, self.heading);
        return self.health > 0;
    }
    pub fn get_radius(self: *const Asteroid) f32 {
        return 22 * self.scale;
    }
    pub fn draw(self: *const Asteroid) void {
        var transform: allegro.ALLEGRO_TRANSFORM = undefined;
        allegro.al_identity_transform(&transform);
        allegro.al_rotate_transform(&transform, utils.deg2rad(self.heading));
        allegro.al_translate_transform(&transform, self.position.x, self.position.y);
        allegro.al_use_transform(&transform);
        const points: [12][2]f32 = .{
            .{ -20, 20 },
            .{ -25, 5 },
            .{ -25, -10 },
            .{ -5, -10 },
            .{ -10, -20 },
            .{ 5, -20 },
            .{ 20, -10 },
            .{ 20, -5 },
            .{ 0, 0 },
            .{ 20, 10 },
            .{ 10, 20 },
            .{ 0, 15 },
        };
        const points_len = 12;

        var i: u8 = 0;
        while (i < points_len) {
            const i_i = i;
            const i_f = (i + 1) % points_len;
            allegro.al_draw_line(points[i_i][0] * self.scale, points[i_i][1] * self.scale, points[i_f][0] * self.scale, points[i_f][1] * self.scale, self.color, 2.0);
            i += 1;
        }
    }
};

pub const Bullet = struct {
    position: utils.Point,
    heading: f32,
    speed: f32,
    power: f32,
    color: allegro.ALLEGRO_COLOR,
    pub fn update_position(self: *Bullet, ticks: f32) bool {
        self.position.x += utils.get_delta_x(ticks * self.speed, self.heading);
        self.position.y += utils.get_delta_y(ticks * self.speed, self.heading);
        self.power -= ticks;
        return self.power > 0;
    }
    pub fn get_radius(_: *const Bullet) f32 {
        return 1;
    }
    pub fn draw(self: *const Bullet) void {
        var transform: allegro.ALLEGRO_TRANSFORM = undefined;
        allegro.al_identity_transform(&transform);
        allegro.al_rotate_transform(&transform, utils.deg2rad(self.heading));
        allegro.al_translate_transform(&transform, self.position.x, self.position.y);
        allegro.al_use_transform(&transform);
        allegro.al_draw_line(1, 0, 0, 1, self.color, 2.0);
        allegro.al_draw_line(0, 1, -1, 0, self.color, 2.0);
        allegro.al_draw_line(-1, 0, 0, -1, self.color, 2.0);
        allegro.al_draw_line(0, -1, 1, 0, self.color, 2.0);
    }
};

pub const Spaceship = struct {
    position: utils.Point,
    heading: f32,
    speed: f32,
    health: f32,
    color: allegro.ALLEGRO_COLOR,
    heading_step: f32 = 10,
    pub fn turn_left(self: *Spaceship) void {
        self.heading -= self.heading_step;
    }
    pub fn turn_right(self: *Spaceship) void {
        self.heading += self.heading_step;
    }
    pub fn go_ahead(self: *Spaceship) void {
        self.position.x += utils.get_delta_x(self.speed, self.heading);
        self.position.y += utils.get_delta_y(self.speed, self.heading);
    }
    pub fn go_back(self: *Spaceship) void {
        self.position.x -= utils.get_delta_x(self.speed, self.heading);
        self.position.y -= utils.get_delta_y(self.speed, self.heading);
    }
    pub fn get_radius(_: *Spaceship) f32 {
        return 10;
    }
    pub fn draw(self: *Spaceship) void {
        var transform: allegro.ALLEGRO_TRANSFORM = undefined;
        allegro.al_identity_transform(&transform);
        allegro.al_rotate_transform(&transform, utils.deg2rad(self.heading));
        allegro.al_translate_transform(&transform, self.position.x, self.position.y);
        allegro.al_use_transform(&transform);
        allegro.al_draw_line(-8, 9, 0, -11, self.color, 3.0);
        allegro.al_draw_line(0, -11, 8, 9, self.color, 3.0);
        allegro.al_draw_line(-6, 4, -1, 4, self.color, 3.0);
        allegro.al_draw_line(6, 4, 1, 4, self.color, 3.0);
    }
};
