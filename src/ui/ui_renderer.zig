const std = @import("std");
const rl = @import("raylib");
const cl = @import("zclay");
const renderer = @import("raylib_render_clay.zig");

const light_grey: cl.Color = .{ 224, 215, 210, 255 };
const red: cl.Color = .{ 168, 66, 28, 255 };
const orange: cl.Color = .{ 225, 138, 50, 255 };
const white: cl.Color = .{ 250, 250, 255, 255 };

pub const UiText = struct {
    string: []const u8,
    config: cl.Config,
};

pub const UiItem = struct {
    config: []const cl.Config,
    children: ?std.ArrayList(UiItem),
    text: ?UiText,
};

pub const LayoutItems = struct {
    side_bar_items: std.ArrayList(UiItem),
    main_screen_items: std.ArrayList(UiItem),
};

fn render_ui_item(ui_item: UiItem) void {
    cl.UI(ui_item.config);
    defer cl.CLOSE();

    if (ui_item.text) |text| {
        cl.text(text.string, text.config);
    }

    if (ui_item.children) |list| {
        for (list.items) |child| {
            render_ui_item(child);
        }
    }
}

pub fn createLayout(layout_items: LayoutItems) cl.ClayArray(cl.RenderCommand) {
    cl.beginLayout();
    {
        cl.UI(&.{
            .ID("OuterContainer"),
            .layout(.{ .direction = .LEFT_TO_RIGHT, .sizing = .grow, .padding = .all(0), .gap = 1 }),
            .rectangle(.{ .color = white }),
        });
        defer cl.CLOSE();

        cl.UI(&.{
            .ID("SideBar"),
            .layout(.{
                .direction = .TOP_TO_BOTTOM,
                .sizing = .{ .h = .grow, .w = .fixed(300) },
                .padding = .all(16),
                .alignment = .{ .x = .CENTER, .y = .TOP },
                .gap = 16,
            }),
            .rectangle(.{ .color = light_grey }),
        });
        {
            defer cl.CLOSE(); //Close Sidebar

            for (layout_items.side_bar_items.items) |child| {
                render_ui_item(child);
            }
        }

        cl.UI(&.{
            .ID("MainContent"),
            .layout(.{
                .sizing = .grow,
                .direction = .TOP_TO_BOTTOM,
            }),
            .rectangle(.{ .color = light_grey }),
        });
        {
            defer cl.CLOSE();

            for (layout_items.main_screen_items.items) |child| {
                render_ui_item(child);
            }
        }
    }
    return cl.endLayout();
}
