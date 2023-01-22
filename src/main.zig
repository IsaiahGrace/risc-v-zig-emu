const std = @import("std");
const rv32i = @import("rv32i.zig");
//const CPU = @import("CPU.zig");

// Thoughts on organization of this project:
// Binary representation of the opcodes probably isn't the fastest (or most idiomatic) way of representing them internally
// The "Instruction decode" stage of my emulator can read in the u32 instruction and create a struct of the instruction
// The "Instruction execute" stage of the emulator can be split into execution engines for each type of instruction.
// So there won't be an ALU unit per-say, just Itype, Rtype, etc.. executors.

// I can use a hashmap for the memory, the key being the address, and the value being the data
// Icahces and Dcaches seem reasonable to implement, but probably unnecessary for performance.

// Decode -->  Itype --> Done?
//        |->  Rtype -|
//        |->  Utype -|
//        |->  Jtype -|
//        etc...
comptime {
    _ = rv32i;
}

pub fn main() anyerror!void {
    std.log.info("Booting up RISC-V emulator!", .{});
    var state = std.mem.zeroInit(rv32i.State, .{});

    std.log.info("Done with program execution.", .{});
    printRegisters(state, true);
}

fn printRegisters(state: rv32i.State, printZeros: bool) void {
    for (state.x) |r, i| {
        if (!printZeros and r == 0) continue;
        std.log.info("r{:<2} : 0x{X:0>8}", .{ i, r });
    }
}
