const std = @import("std");
const rv32i = @import("rv32i.zig");

pub fn execute(state: *rv32i.State, instruction: rv32i.Instruction) !void {
    const opcodeInfo = rv32i.InstructionInfo.init(instruction);
    switch (opcodeInfo.group) {
        .R => try exeR(state, opcodeInfo, @bitCast(rv32i.Rtype.Bits, instruction)),
        .I => try exeI(state, opcodeInfo, @bitCast(rv32i.Itype.Bits, instruction)),
        .S => try exeS(state, opcodeInfo, @bitCast(rv32i.Stype.Bits, instruction)),
        .B => try exeB(state, opcodeInfo, @bitCast(rv32i.Btype.Bits, instruction)),
        .U => try exeU(state, opcodeInfo, @bitCast(rv32i.Utype.Bits, instruction)),
        .J => try exeJ(state, opcodeInfo, @bitCast(rv32i.Jtype.Bits, instruction)),
    }
}

fn exeR(state: rv32i.State, info: rv32i.InstructionInfo, opcode: rv32i.Rtype) !void {}
fn exeI(state: rv32i.State, info: rv32i.InstructionInfo, opcode: rv32i.Itype) !void {}
fn exeS(state: rv32i.State, info: rv32i.InstructionInfo, opcode: rv32i.Stype) !void {}
fn exeB(state: rv32i.State, info: rv32i.InstructionInfo, opcode: rv32i.Btype) !void {}
fn exeU(state: rv32i.State, info: rv32i.InstructionInfo, opcode: rv32i.Utype) !void {}
fn exeJ(state: rv32i.State, info: rv32i.InstructionInfo, opcode: rv32i.Jtype) !void {}
