const std = @import("std");
const Builder = std.build.Builder;

pub fn build(b: *Builder) !void {
    const exe = b.addExecutable("zblasteroids", "main.zig");
    exe.setOutputDir(".");
    exe.linkSystemLibrary("allegro");
    exe.linkSystemLibrary("c");
    b.default_step.dependOn(&exe.step);
}
