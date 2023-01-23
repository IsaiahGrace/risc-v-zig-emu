const std = @import("std");
const rv32i = @import("rv32i.zig");
const CPU = @import("CPU.zig");
const Assembler = @import("assembler.zig").Assembler;

fn prepare(allocator: std.mem.Allocator, input: []const u8) !rv32i.Machine {
    var assembler = Assembler.init(allocator);
    defer assembler.deinit();

    try assembler.parseAsm(input);

    var machine = rv32i.Machine.init();
    assembler.loadProgram(&machine);

    return machine;
}

test "ADD & ADDI" {
    const allocator = std.testing.allocator;

    const input =
        \\ ADDI r1, r0, 42
        \\ ADDI r2, r1, 5
        \\ ADD r3, r1, r2
        \\ ADDI r4, r0, -1
    ;

    var machine = try prepare(allocator, std.mem.span(input));

    try CPU.execute(&machine);
    try CPU.execute(&machine);
    try CPU.execute(&machine);
    try CPU.execute(&machine);

    try std.testing.expectEqual(machine.r[0], 0);
    try std.testing.expectEqual(machine.r[1], 42);
    try std.testing.expectEqual(machine.r[2], 47);
    try std.testing.expectEqual(machine.r[3], 89);
    try std.testing.expectEqual(machine.r[4], 4294967295);
}

test "All files in ./asm" {
    const allocator = std.testing.allocator;

    var testDir = try std.fs.cwd().openIterableDir("asm", .{});
    defer testDir.close();

    var walker = try testDir.walk(allocator);
    defer walker.deinit();

    while (try walker.next()) |walkerEntry| {
        var input = try testDir.dir.readFileAlloc(allocator, walkerEntry.path, std.math.maxInt(usize));
        defer allocator.free(input);

        var machine = try prepare(allocator, std.mem.span(input));

        var cycles: usize = 0;
        while (cycles < 1000) : (cycles += 1) {
            try CPU.execute(&machine);
        }
    }
}
