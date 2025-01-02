const std = @import("std");
const cl = @import("zclay");
const ui = @import("../ui/ui_renderer.zig");
const component = @import("mod.zig");
const ArrayList = std.ArrayList;

pub fn getFolders(workdir: std.fs.Dir, list: *ArrayList(component.Component), allocator: std.mem.Allocator) !void {
    // var list = ArrayList([]const u8).init(allocator);

    var iter = workdir.iterate();
    while (try iter.next()) |entry| {
        if (entry.kind == .directory) {
            const name = try allocator.alloc(u8, entry.name.len);
            @memcpy(name, entry.name);

            const comp = component.Component{ .folder = .{ .name = name } };
            try list.append(comp); // Append the allocated slice
        }
    }
}

pub fn getFiles(workdir: std.fs.Dir, list: *ArrayList(component.Component), allocator: std.mem.Allocator) !void {
    // var list = ArrayList([]const u8).init(allocator);

    var iter = workdir.iterate();
    while (try iter.next()) |entry| {
        if (entry.kind == .file) {
            const name = try allocator.alloc(u8, entry.name.len);
            @memcpy(name, entry.name);

            const comp = component.Component{ .file = .{ .name = name, .filetype = "TODO" } };
            try list.append(comp); // Append the allocated slice
        }
    }
}
