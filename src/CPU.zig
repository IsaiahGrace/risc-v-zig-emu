const std = @import("std");
const rv32i = @import("rv32i.zig");

pub fn execute(machine: *rv32i.Machine) !void {
    // Instruction fetch
    const instruction: rv32i.Instruction = machine.memory[machine.pc];

    // Instruction decode
    const instructionInfo = try rv32i.InstructionInfo.create(instruction);

    // Execute
    switch (instructionInfo.group) {
        .R => try execR(machine, instruction, instructionInfo),
        .I => try execI(machine, instruction, instructionInfo),
        .S => try execS(machine, instruction, instructionInfo),
        .B => try execB(machine, instruction, instructionInfo),
        .U => try execU(machine, instruction, instructionInfo),
        .J => try execJ(machine, instruction, instructionInfo),
    }

    // r0 is hard wired to 0, but is this enough to enforce the invariant?
    machine.r[0] = 0;
}

fn execR(machine: *rv32i.Machine, instruction: rv32i.Instruction, info: rv32i.InstructionInfo) !void {
    const bits = @bitCast(rv32i.Rtype.Bits, instruction);
    switch (info.type) {
        .ADD => machine.r[bits.rd] = machine.r[bits.rs1] + machine.r[bits.rs2],
        else => return error.UnsuportedInstruction,
    }
    machine.pc += 1;
}

fn execI(machine: *rv32i.Machine, instruction: rv32i.Instruction, info: rv32i.InstructionInfo) !void {
    const bits = @bitCast(rv32i.Itype.Bits, instruction);
    switch (info.type) {
        .LB => {},
        .ADDI => machine.r[bits.rd] = @bitCast(u32, @bitCast(i32, machine.r[bits.rs1]) + @as(i32, bits.imm)),
        else => return error.UnsuportedInstruction,
    }
    machine.pc += 1;
}

fn execS(machine: *rv32i.Machine, instruction: rv32i.Instruction, info: rv32i.InstructionInfo) !void {
    _ = machine;
    _ = info;
    _ = instruction;
}

fn execB(machine: *rv32i.Machine, instruction: rv32i.Instruction, info: rv32i.InstructionInfo) !void {
    _ = machine;
    _ = info;
    _ = instruction;
}

fn execU(machine: *rv32i.Machine, instruction: rv32i.Instruction, info: rv32i.InstructionInfo) !void {
    _ = machine;
    _ = info;
    _ = instruction;
}

fn execJ(machine: *rv32i.Machine, instruction: rv32i.Instruction, info: rv32i.InstructionInfo) !void {
    _ = machine;
    _ = info;
    _ = instruction;
}
