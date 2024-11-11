pub const packages = struct {
    pub const @"122062b24f031e68f0d11c91dfc32aed5baf06caf26ed3c80ea1802f9e788ef1c358" = struct {
        pub const build_root = "/Users/windu/.cache/zig/p/122062b24f031e68f0d11c91dfc32aed5baf06caf26ed3c80ea1802f9e788ef1c358";
        pub const deps: []const struct { []const u8, []const u8 } = &.{};
    };
    pub const @"122062d2421175ba6bf89382c86621270e4883f1074ee4cc09da282e231bdef57328" = struct {
        pub const build_root = "/Users/windu/.cache/zig/p/122062d2421175ba6bf89382c86621270e4883f1074ee4cc09da282e231bdef57328";
        pub const build_zig = @import("122062d2421175ba6bf89382c86621270e4883f1074ee4cc09da282e231bdef57328");
        pub const deps: []const struct { []const u8, []const u8 } = &.{
            .{ "raylib", "1220d1c8697d41a42d4eaaf3f8709865534d1f3d6ad63f8a27500fa881380651a1c5" },
            .{ "raygui", "122062b24f031e68f0d11c91dfc32aed5baf06caf26ed3c80ea1802f9e788ef1c358" },
        };
    };
    pub const @"1220d1c8697d41a42d4eaaf3f8709865534d1f3d6ad63f8a27500fa881380651a1c5" = struct {
        pub const build_root = "/Users/windu/.cache/zig/p/1220d1c8697d41a42d4eaaf3f8709865534d1f3d6ad63f8a27500fa881380651a1c5";
        pub const build_zig = @import("1220d1c8697d41a42d4eaaf3f8709865534d1f3d6ad63f8a27500fa881380651a1c5");
        pub const deps: []const struct { []const u8, []const u8 } = &.{};
    };
};

pub const root_deps: []const struct { []const u8, []const u8 } = &.{
    .{ "raylib-zig", "122062d2421175ba6bf89382c86621270e4883f1074ee4cc09da282e231bdef57328" },
};
