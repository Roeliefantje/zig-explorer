const std = @import("std");
const rl = @import("raylib");
const cl = @import("zclay");
const math = std.math;

pub fn clayColorToRaylibColor(color: cl.Color) rl.Color {
    return rl.Color{
        .r = @intFromFloat(color[0]),
        .g = @intFromFloat(color[1]),
        .b = @intFromFloat(color[2]),
        .a = @intFromFloat(color[3]),
    };
}

pub var raylib_fonts: [10]?rl.Font = .{null} ** 10;

pub fn clayRaylibRender(render_commands: *cl.ClayArray(cl.RenderCommand), allocator: std.mem.Allocator) void {
    var i: usize = 0;
    while (i < render_commands.length) : (i += 1) {
        const render_command = cl.renderCommandArrayGet(render_commands, @intCast(i));
        const bounding_box = render_command.bounding_box;
        switch (render_command.command_type) {
            .None => {},
            .Text => {
                const text = render_command.text.chars[0..@intCast(render_command.text.length)];
                const cloned = allocator.dupeZ(c_char, text) catch unreachable;
                defer allocator.free(cloned);
                const fontToUse: rl.Font = raylib_fonts[render_command.config.text_element_config.font_id].?;
                rl.setTextLineSpacing(render_command.config.text_element_config.line_height);
                rl.drawTextEx(
                    fontToUse,
                    @ptrCast(@alignCast(cloned.ptr)),
                    rl.Vector2{ .x = bounding_box.x, .y = bounding_box.y },
                    @floatFromInt(render_command.config.text_element_config.font_size),
                    @floatFromInt(render_command.config.text_element_config.letter_spacing),
                    clayColorToRaylibColor(render_command.config.text_element_config.color),
                );
            },
            .Image => {
                const image_texture: *const rl.Texture2D = @ptrCast(
                    @alignCast(render_command.config.image_element_config.image_data),
                );
                rl.drawTextureEx(
                    image_texture.*,
                    rl.Vector2{ .x = bounding_box.x, .y = bounding_box.y },
                    0,
                    bounding_box.width / @as(f32, @floatFromInt(image_texture.width)),
                    rl.Color.white,
                );
            },
            .ScissorStart => {
                rl.beginScissorMode(
                    @intFromFloat(math.round(bounding_box.x)),
                    @intFromFloat(math.round(bounding_box.y)),
                    @intFromFloat(math.round(bounding_box.width)),
                    @intFromFloat(math.round(bounding_box.height)),
                );
            },
            .ScissorEnd => rl.endScissorMode(),
            .Rectangle => {
                const config = render_command.config.rectangle_element_config;
                if (config.corner_radius.top_left > 0) {
                    const radius: f32 = (config.corner_radius.top_left * 2) / @min(bounding_box.width, bounding_box.height);
                    rl.drawRectangleRounded(
                        rl.Rectangle{
                            .x = bounding_box.x,
                            .y = bounding_box.y,
                            .width = bounding_box.width,
                            .height = bounding_box.height,
                        },
                        radius,
                        8,
                        clayColorToRaylibColor(config.color),
                    );
                } else {
                    rl.drawRectangle(
                        @intFromFloat(bounding_box.x),
                        @intFromFloat(bounding_box.y),
                        @intFromFloat(bounding_box.width),
                        @intFromFloat(bounding_box.height),
                        clayColorToRaylibColor(config.color),
                    );
                }
            },
            .Border => {
                const config = render_command.config.border_element_config;
                if (config.left.width > 0) {
                    rl.drawRectangle(
                        @intFromFloat(math.round(bounding_box.x)),
                        @intFromFloat(math.round(bounding_box.y + config.corner_radius.top_left)),
                        @intCast(config.left.width),
                        @intFromFloat(math.round(bounding_box.height - config.corner_radius.top_left - config.corner_radius.bottom_left)),
                        clayColorToRaylibColor(config.left.color),
                    );
                }
                if (config.right.width > 0) {
                    rl.drawRectangle(
                        @intFromFloat(math.round(bounding_box.x + bounding_box.width - @as(f32, @floatFromInt(config.right.width)))),
                        @intFromFloat(math.round(bounding_box.y + config.corner_radius.top_right)),
                        @intCast(config.right.width),
                        @intFromFloat(math.round(bounding_box.height - config.corner_radius.top_right - config.corner_radius.bottom_right)),
                        clayColorToRaylibColor(config.right.color),
                    );
                }
                if (config.top.width > 0) {
                    rl.drawRectangle(
                        @intFromFloat(math.round(bounding_box.x + config.corner_radius.top_left)),
                        @intFromFloat(math.round(bounding_box.y)),
                        @intFromFloat(math.round(bounding_box.width - config.corner_radius.top_left - config.corner_radius.top_right)),
                        @intCast(config.top.width),
                        clayColorToRaylibColor(config.top.color),
                    );
                }
                if (config.bottom.width > 0) {
                    rl.drawRectangle(
                        @intFromFloat(math.round(bounding_box.x + config.corner_radius.bottom_left)),
                        @intFromFloat(math.round(bounding_box.y + bounding_box.height - @as(f32, @floatFromInt(config.bottom.width)))),
                        @intFromFloat(math.round(bounding_box.width - config.corner_radius.bottom_left - config.corner_radius.bottom_right)),
                        @intCast(config.bottom.width),
                        clayColorToRaylibColor(config.bottom.color),
                    );
                }

                if (config.corner_radius.top_left > 0) {
                    rl.drawRing(
                        rl.Vector2{
                            .x = math.round(bounding_box.x + config.corner_radius.top_left),
                            .y = math.round(bounding_box.y + config.corner_radius.top_left),
                        },
                        math.round(config.corner_radius.top_left - @as(f32, @floatFromInt(config.top.width))),
                        config.corner_radius.top_left,
                        180,
                        270,
                        10,
                        clayColorToRaylibColor(config.top.color),
                    );
                }
                if (config.corner_radius.top_right > 0) {
                    rl.drawRing(
                        rl.Vector2{
                            .x = math.round(bounding_box.x + bounding_box.width - config.corner_radius.top_right),
                            .y = math.round(bounding_box.y + config.corner_radius.top_right),
                        },
                        math.round(config.corner_radius.top_right - @as(f32, @floatFromInt(config.top.width))),
                        config.corner_radius.top_right,
                        270,
                        360,
                        10,
                        clayColorToRaylibColor(config.top.color),
                    );
                }
                if (config.corner_radius.bottom_left > 0) {
                    rl.drawRing(
                        rl.Vector2{
                            .x = math.round(bounding_box.x + config.corner_radius.bottom_left),
                            .y = math.round(bounding_box.y + bounding_box.height - config.corner_radius.bottom_left),
                        },
                        math.round(config.corner_radius.bottom_left - @as(f32, @floatFromInt(config.top.width))),
                        config.corner_radius.bottom_left,
                        90,
                        180,
                        10,
                        clayColorToRaylibColor(config.bottom.color),
                    );
                }
                if (config.corner_radius.bottom_right > 0) {
                    rl.drawRing(
                        rl.Vector2{
                            .x = math.round(bounding_box.x + bounding_box.width - config.corner_radius.bottom_right),
                            .y = math.round(bounding_box.y + bounding_box.height - config.corner_radius.bottom_right),
                        },
                        math.round(config.corner_radius.bottom_right - @as(f32, @floatFromInt(config.top.width))),
                        config.corner_radius.bottom_right,
                        0.1,
                        90,
                        10,
                        clayColorToRaylibColor(config.bottom.color),
                    );
                }
            },
            .Custom => {
                // Implement custom element rendering here
            },
        }
    }
}

pub fn measureText(clay_text: []const u8, config: *cl.TextElementConfig) cl.Dimensions {
    const font = raylib_fonts[config.font_id].?;
    const text: []const u8 = clay_text;
    const font_size: f32 = @floatFromInt(config.font_size);
    const letter_spacing: f32 = @floatFromInt(config.letter_spacing);
    const line_height = config.line_height;

    var temp_byte_counter: usize = 0;
    var byte_counter: usize = 0;
    var text_width: f32 = 0.0;
    var temp_text_width: f32 = 0.0;
    var text_height: f32 = font_size;
    const scale_factor: f32 = font_size / @as(f32, @floatFromInt(font.baseSize));

    var utf8 = std.unicode.Utf8View.initUnchecked(text).iterator();

    while (utf8.nextCodepoint()) |codepoint| {
        byte_counter += std.unicode.utf8CodepointSequenceLength(codepoint) catch 1;
        const index: usize = @intCast(
            rl.getGlyphIndex(font, @as(i32, @intCast(codepoint))),
        );

        if (codepoint != '\n') {
            if (font.glyphs[index].advanceX != 0) {
                text_width += @floatFromInt(font.glyphs[index].advanceX);
            } else {
                text_width += font.recs[index].width + @as(f32, @floatFromInt(font.glyphs[index].offsetX));
            }
        } else {
            if (temp_text_width < text_width) temp_text_width = text_width;
            byte_counter = 0;
            text_width = 0;
            text_height += font_size + @as(f32, @floatFromInt(line_height));
        }

        if (temp_byte_counter < byte_counter) temp_byte_counter = byte_counter;
    }

    if (temp_text_width < text_width) temp_text_width = text_width;

    return cl.Dimensions{
        .h = text_height,
        .w = temp_text_width * scale_factor + @as(f32, @floatFromInt(temp_byte_counter - 1)) * letter_spacing,
    };
}