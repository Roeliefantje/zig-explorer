const std = @import("std");
const rl = @import("raylib");
const cl = @import("zclay");
const renderer = @import("ui/raylib_render_clay.zig");
const ui = @import("ui/ui_renderer.zig");
const dir = @import("components/directories.zig");
const components = @import("components/mod.zig");

const light_grey: cl.Color = .{ 224, 215, 210, 255 };
const red: cl.Color = .{ 168, 66, 28, 255 };
const orange: cl.Color = .{ 225, 138, 50, 255 };
const white: cl.Color = .{ 250, 250, 255, 255 };

const sidebar_item_layout: cl.LayoutConfig = .{ .sizing = .{ .w = .grow, .h = .fixed(50) } };

fn loadFont(file_data: ?[]const u8, font_id: u16, font_size: i32) void {
    renderer.raylib_fonts[font_id] = rl.loadFontFromMemory(".ttf", file_data, font_size * 2, null);
    rl.setTextureFilter(renderer.raylib_fonts[font_id].?.texture, .bilinear);
}

pub fn main() anyerror!void {
    const allocator = std.heap.page_allocator;

    const mem = try init_clay(allocator);
    defer allocator.free(mem);

    // init raylib
    init_raylib("zexplorer");

    // load assets
    loadFont(@embedFile("./resources/Roboto-Regular.ttf"), 0, 24);
    // const profile_picture = rl.loadTextureFromImage(rl.loadImageFromMemory(".png", @embedFile("./resources/profile-picture.png")));

    const current_dir = try std.fs.cwd().openDir(
        ".",
        .{ .iterate = true },
    );
    _ = &current_dir;

    var debug_mode_enabled = false;
    while (!rl.windowShouldClose()) {
        debug_button(&debug_mode_enabled);
        set_pointer_state();
        update_scroll_containers();
        set_layout_dimensions();

        var main_screen = components.MainScreen{
            .main_screen_components = std.ArrayList(components.Component).init(allocator),
            .side_bar_components = std.ArrayList(components.Component).init(allocator),
        };

        try main_screen.main_screen_components.append(components.Component{ .folder = .{ .name = "../" } });

        try dir.getFolders(current_dir, &main_screen.main_screen_components, allocator);
        try dir.getFiles(current_dir, &main_screen.main_screen_components, allocator);

        var render_commands = try main_screen.render_screen();

        rl.beginDrawing();
        renderer.clayRaylibRender(&render_commands, allocator);
        rl.endDrawing();
    }
}

fn init_clay(allocator: std.mem.Allocator) ![]u8 {
    const min_memory_size: u32 = cl.minMemorySize();
    const memory = try allocator.alloc(u8, min_memory_size);
    const arena: cl.Arena = cl.createArenaWithCapacityAndMemory(min_memory_size, @ptrCast(memory));
    cl.initialize(arena, .{ .h = 1000, .w = 1000 });
    cl.setMeasureTextFunction(renderer.measureText);

    return memory;
}

fn init_raylib(title: [*:0]const u8) void {
    rl.setTraceLogLevel(.err);
    rl.setConfigFlags(.{
        .msaa_4x_hint = true,
        .vsync_hint = true,
        .window_highdpi = true,
        .window_resizable = true,
    });
    rl.initWindow(1000, 1000, title);
    rl.setTargetFPS(60);
}

fn debug_button(debug_mode_enabled: *bool) void {
    if (rl.isKeyPressed(.d)) {
        debug_mode_enabled.* = !debug_mode_enabled.*;
        cl.setDebugModeEnabled(debug_mode_enabled.*);
    }
}

fn set_layout_dimensions() void {
    cl.setLayoutDimensions(.{
        .w = @floatFromInt(rl.getScreenWidth()),
        .h = @floatFromInt(rl.getScreenHeight()),
    });
}

fn set_pointer_state() void {
    const mouse_pos = rl.getMousePosition();
    cl.setPointerState(.{
        .x = mouse_pos.x,
        .y = mouse_pos.y,
    }, rl.isMouseButtonDown(.left));
}

fn update_scroll_containers() void {
    const scroll_delta = rl.getMouseWheelMoveV().multiply(.{ .x = 6, .y = 6 });
    cl.updateScrollContainers(
        false,
        .{ .x = scroll_delta.x, .y = scroll_delta.y },
        rl.getFrameTime(),
    );
}
