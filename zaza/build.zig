const std = @import("std");

// tigerbeetle's whole VSR library (src/vsr.zig) built from source through the
// standard Zig build graph Zaza is built on. tigerbeetle is zero-dependency
// pure Zig, so Zaza's C/C++ target DSL does not apply. vsr reads a vsr_options
// module that tigerbeetle's own build.zig synthesizes; here it is built by hand
// with addOptions — the imperative counterpart to azazel's declarative
// option_values.
const tb = "vendor/tigerbeetle";

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const stdx = b.createModule(.{
        .root_source_file = b.path(tb ++ "/src/stdx/stdx.zig"),
        .target = target,
        .optimize = optimize,
    });

    const vsr_options = b.addOptions();
    vsr_options.addOption(bool, "config_verify", false);
    vsr_options.addOption(?[40]u8, "git_commit", null);
    vsr_options.addOption([]const u8, "release", "0.16.4");
    vsr_options.addOption([]const u8, "release_client_min", "0.16.4");

    const vsr = b.addLibrary(.{
        .name = "tb_vsr",
        .linkage = .static,
        .root_module = b.createModule(.{
            .root_source_file = b.path(tb ++ "/src/vsr.zig"),
            .target = target,
            .optimize = optimize,
        }),
    });
    vsr.root_module.addImport("stdx", stdx);
    vsr.root_module.addOptions("vsr_options", vsr_options);
    b.installArtifact(vsr);

    const step = b.step("vsr", "Build tigerbeetle's VSR library");
    step.dependOn(&b.addInstallArtifact(vsr, .{}).step);
}
