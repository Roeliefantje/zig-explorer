const std = @import("std");
const cl = @import("zclay");
const ui = @import("../ui/ui_renderer.zig");
const ArrayList = std.ArrayList;

const light_grey: cl.Color = .{ 224, 215, 210, 255 };
const white: cl.Color = .{ 250, 250, 255, 255 };

const uiFolderLayoutConfig: cl.LayoutConfig = cl.LayoutConfig{
    .direction = .LEFT_TO_RIGHT,
    .sizing = .{ .h = .fixed(10), .w = .grow },
    .alignment = .{ .x = .LEFT, .y = .CENTER },
};
// const uiFolderConfig: []const Config = &.{.ID = }

fn getFolderStrings(workdir: std.fs.Dir, allocator: std.mem.Allocator) ![][]const u8 {
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

pub fn getFolderUiItems(workdir: std.fs.Dir, allocator: std.mem.Allocator, list: *ArrayList(ui.UiItem)) !void {
    const folders = try getFolderStrings(workdir, allocator);
    defer allocator.free(folders);

    // var items = ArrayList(ui.UiItem).init(allocator);
    for (folders) |folder| {
        // for (folders) |_folder| {

        const id = try allocator.alloc(u8, folder.len);
        @memcpy(id, folder);

        const item = ui.UiItem{
            .children = null,
            .config = &.{
                // .ID(folder),
                .layout(.{
                    .direction = .LEFT_TO_RIGHT,
                    .sizing = .{ .h = .fixed(10), .w = .grow },
                    .alignment = .{ .x = .LEFT, .y = .CENTER },
                }),
                // .rectangle(.{ .color = light_grey }),
                .border(cl.BorderElementConfig.all(white, 1, 0)),

                // .layout = uiFolderLayoutConfig,
            },
            // .text = null,
            .text = ui.UiText{
                .string = folder,
                .config = cl.Config.text(.{ .font_size = 24, .color = white }),
            },
        };

        try list.*.append(item);
    }

    // return items.toOwnedSlice();
    return;
}
