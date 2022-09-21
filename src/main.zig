const std = @import("std");

const Opcode = enum {
    op_nop,
    op_mov,
    op_movi,
    op_add,
    op_xor,
    op_and,
    op_jnz,
    op_jmp,
};

const Instruction = struct {
    op: Opcode,
    src: [2]u5,
    dst: u5,
    imm: u32,
};

const RegisterFile = struct {
    r: [32]u32,
};

fn exe(inst: Instruction, reg: *RegisterFile) void {
    switch (inst.op) {
        .op_nop => {},
        .op_mov => reg.r[inst.dst] = reg.r[inst.src[0]],
        .op_movi => reg.r[inst.dst] = inst.imm,
        .op_add => reg.r[inst.dst] = reg.r[inst.src[0]] +% reg.r[inst.src[1]],
        .op_xor => reg.r[inst.dst] = reg.r[inst.src[0]] ^ reg.r[inst.src[1]],
        .op_and => reg.r[inst.dst] = reg.r[inst.src[0]] & reg.r[inst.src[1]],
        else => unreachable,
    }
}

pub fn main() anyerror!void {
    std.log.info("Booting up RISC-V emulator!", .{});
    var reg = std.mem.zeroInit(RegisterFile, .{});

    const program = [_]Instruction{
        .{ .op = .op_movi, .src = .{ 0, 0 }, .dst = 1, .imm = 0xdeadbeef },
        .{ .op = .op_movi, .src = .{ 0, 0 }, .dst = 2, .imm = 0xbaadc0de },
        .{ .op = .op_movi, .src = .{ 0, 0 }, .dst = 3, .imm = 0xaabbccdd },
        .{ .op = .op_movi, .src = .{ 0, 0 }, .dst = 4, .imm = 0xaaaacccc },
        .{ .op = .op_and, .src = .{ 3, 4 }, .dst = 1, .imm = 0 },
        .{ .op = .op_xor, .src = .{ 3, 4 }, .dst = 2, .imm = 0 },
        .{ .op = .op_add, .src = .{ 3, 4 }, .dst = 5, .imm = 0 },
    };

    for (program) |inst, pc| {
        exe(inst, &reg);
        std.log.info("PC : {}", .{pc});
        printRegisters(reg, false);
    }

    std.log.info("Done with program execution.", .{});
    printRegisters(reg, true);
}

fn printRegisters(reg: RegisterFile, printZeros: bool) void {
    for (reg.r) |r, i| {
        if (!printZeros and r == 0) continue;
        std.log.info("r{:<2} : 0x{X:0>8}", .{ i, r });
    }
}
