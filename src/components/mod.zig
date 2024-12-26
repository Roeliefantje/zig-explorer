const std = @import("std");
const rl = @import("raylib");
const cl = @import("zclay");
const renderer = @import("raylib_render_clay.zig");

const light_grey: cl.Color = .{ 224, 215, 210, 255 };
const red: cl.Color = .{ 168, 66, 28, 255 };
const orange: cl.Color = .{ 225, 138, 50, 255 };
const white: cl.Color = .{ 250, 250, 255, 255 };

const MainScreen = struct {
    side_bar_components: std.ArrayList(Component),
    main_screen_components: std.ArrayList(Component),

    pub fn render_screen(self: MainScreen) !cl.ClayArray(cl.RenderCommand) {
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

                for (self.side_bar_components.items) |child| {
                    child.render_component();
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

                for (self.main_screen_components.items) |child| {
                    child.render_component();
                }
            }
        }
        return cl.endLayout();
    }
};

const Folder = struct {
    name: []const u8,
};

const File = struct {
    name: []const u8,
    filetype: []const u8,
};

pub const Component = union(enum) {
    folder: Folder,
    file: File,

    pub fn render_component(self: Component) !void {
        _ = self;
    }
};
