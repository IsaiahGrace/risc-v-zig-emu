const std = @import("std");
const rv32i = @import("rv32i.zig");
const CPU = @import("CPU.zig");
const Assembler = @import("assembler.zig").Assembler;

const tests = @import("tests.zig");
comptime {
    _ = tests;
}

pub fn main() anyerror!void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();

    var machine = rv32i.Machine.init();

    var assembler = Assembler.init(allocator);
    defer assembler.deinit();

    var input = try std.fs.cwd().readFileAlloc(allocator, "asm/test1", std.math.maxInt(usize));
    defer allocator.free(input);

    std.log.info("Parsing asm file.", .{});
    try assembler.parseAsm(input);

    assembler.loadProgram(&machine);

    std.log.info("Booting up RISC-V emulator!", .{});
    try CPU.execute(&machine);
    try CPU.execute(&machine);
    try CPU.execute(&machine);
    try CPU.execute(&machine);
    try CPU.execute(&machine);
    try CPU.execute(&machine);
    try CPU.execute(&machine);
    try CPU.execute(&machine);
    std.log.info("Done with program execution.", .{});

    printRegisters(&machine, false);
    std.log.info(" pc = {d}", .{machine.pc});
    printMemory(&machine, false);
}

fn printRegisters(machine: *rv32i.Machine, printZeroes: bool) void {
    for (machine.r) |r, i| {
        if (!printZeroes and r == 0) continue;
        if (i < 10) {
            // std.log.info(" r{d} = 0b{b:0>32}", .{ i, r });
            // std.log.info(" r{d} = 0x{X:0>8}", .{ i, r });
            std.log.info(" r{d} = {d}", .{ i, r });
        } else {
            std.log.info("r{:<2} = 0b{b:0>32}", .{ i, r });
            // std.log.info("r{:<2} = 0x{X:0>8}", .{ i, r });
            std.log.info("r{:<2} = {d}", .{ i, r });
        }
    }
}

fn printMemory(machine: *rv32i.Machine, printZeroes: bool) void {
    for (machine.memory) |w, i| {
        if (!printZeroes and w == 0) continue;
        std.log.info("m[{:4}] = 0b{b:0>32}", .{ i, w });
        // std.log.info("m[{:4}] = 0x{X:0>8}", .{ i, w });
        // std.log.info("m[{:4}] = {d}", .{ i, w });
    }
}
