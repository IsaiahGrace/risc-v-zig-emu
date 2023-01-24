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
    const rs1 = machine.r[bits.rs1];
    const rs2 = machine.r[bits.rs2];
    switch (info.type) {
        .ADD => machine.r[bits.rd] = @addWithOverflow(rs1, rs2)[0],
        .SUB => machine.r[bits.rd] = @subWithOverflow(rs1, rs2)[0],
        .SLL => return error.UnsuportedInstruction,
        .SLT => return error.UnsuportedInstruction,
        .SLTU => return error.UnsuportedInstruction,
        .XOR => machine.r[bits.rd] = rs1 ^ rs2,
        .SRL => return error.UnsuportedInstruction,
        .SRA => return error.UnsuportedInstruction,
        .OR => machine.r[bits.rd] = rs1 | rs2,
        .AND => machine.r[bits.rd] = rs1 & rs2,
        else => return error.UnsuportedInstruction,
    }
    machine.pc += 1;
}

fn execI(machine: *rv32i.Machine, instruction: rv32i.Instruction, info: rv32i.InstructionInfo) !void {
    const bits = @bitCast(rv32i.Itype.Bits, instruction);
    const rs1 = @bitCast(i32, machine.r[bits.rs1]);
    const imm = @as(i32, bits.imm);
    switch (info.type) {
        .LB => {}, // This is the all-zero instruction.
        .ADDI => machine.r[bits.rd] = @bitCast(u32, @addWithOverflow(rs1, imm)[0]),
        .SLTI => return error.UnsuportedInstruction,
        .SLTIU => return error.UnsuportedInstruction,
        .XORI => machine.r[bits.rd] = @bitCast(u32, rs1 ^ imm),
        .ORI => machine.r[bits.rd] = @bitCast(u32, rs1 | imm),
        .ANDI => machine.r[bits.rd] = @bitCast(u32, rs1 & imm),
        .SLLI => return error.UnsuportedInstruction,
        .SRLI => return error.UnsuportedInstruction,
        .SRAI => return error.UnsuportedInstruction,
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
