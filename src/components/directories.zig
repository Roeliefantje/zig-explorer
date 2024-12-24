const std = @import("std");
const ArrayList = std.ArrayList;

pub fn getFolders(workdir: std.fs.Dir, allocator: std.mem.Allocator) ![][]const u8 {
    var list = ArrayList([]const u8).init(allocator);

    var iter = workdir.iterate();
    while (try iter.next()) |entry| {
        if (entry.kind == .directory) {
            const name = try allocator.alloc(u8, entry.name.len);
            @memcpy(name, entry.name);
            try list.append(name); // Append the allocated slice
        }
    }

    return list.toOwnedSlice();
}
