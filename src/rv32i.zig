// Isaiah Grace

// RV32I instruction set refrence:
// https://msyksphinz-self.github.io/riscv-isadoc/html/rvi.html
// https://five-embeddev.com/riscv-isa-manual/latest/rv32.html

const std = @import("std");

// This file describes the risc specification from the programmers perspective

pub const State = struct {
    x: [32]u32,
    pc: u32,
};

pub const Instruction = u32;

pub const InstructionInfo = struct {
    group: InstructionGroup,
    type: InstructionType,

    pub fn init(instruction: Instruction) !InstructionInfo {
        var instructionGroup: ?InstructionGroup = null;
        var instructionType: ?InstructionType = null;

        // We'll use Table 19.1 from riscv-spec-v2.2.pdf to help parse the instructions:
        const mapCol = @intCast(u3, (instruction & 0b0011100) >> 2);
        const mapRow = @intCast(u2, (instruction & 0b1100000) >> 5);

        switch (mapCol) {
            0b000 => switch (mapRow) {
                0b00 => { // LOAD
                    instructionGroup = .I;
                    switch (@bitCast(Itype.Bits, instruction).funct3) {
                        0b000 => instructionType = .LB,
                        0b001 => instructionType = .LH,
                        0b010 => instructionType = .LW,
                        0b100 => instructionType = .LBU,
                        0b101 => instructionType = .LHU,
                        else => return error.IllegalInstruction,
                    }
                },
                0b01 => { // STORE
                    instructionGroup = .S;
                    switch (@bitCast(Stype.Bits, instruction).funct3) {
                        0b000 => instructionType = .SB,
                        0b001 => instructionType = .SH,
                        0b010 => instructionType = .SW,
                        else => return error.IllegalInstruction,
                    }
                },
                0b10 => return error.IllegalInstruction, // MADD
                0b11 => { // BRANCH
                    instructionGroup = .B;
                    switch (@bitCast(Btype.Bits, instruction).funct3) {
                        0b000 => instructionType = .BEQ,
                        0b001 => instructionType = .BNE,
                        0b100 => instructionType = .BLT,
                        0b101 => instructionType = .BGE,
                        0b110 => instructionType = .BLTU,
                        0b111 => instructionType = .BGEU,
                        else => return error.IllegalInstruction,
                    }
                },
            },
            0b001 => switch (mapRow) {
                0b00 => return error.IllegalInstruction, // LOAD-FP
                0b01 => return error.IllegalInstruction, // STORE-FP
                0b10 => return error.IllegalInstruction, // MSUB
                0b11 => return error.IllegalInstruction, // JALR
            },
            0b010 => switch (mapRow) {
                0b00 => return error.IllegalInstruction, // custom-0
                0b01 => return error.IllegalInstruction, // custom-1
                0b10 => return error.IllegalInstruction, // NMSUB
                0b11 => return error.IllegalInstruction, // reserved
            },
            0b011 => switch (mapRow) {
                0b00 => return error.IllegalInstruction, // MISC-MEM
                0b01 => return error.IllegalInstruction, // AMO
                0b10 => return error.IllegalInstruction, // NMADD
                0b11 => return error.IllegalInstruction, // JAL
            },
            0b100 => switch (mapRow) {
                0b00 => { // OP-IMM
                    instructionGroup = .I;
                    const bits = @bitCast(Itype.Bits, instruction);
                    switch (bits.funct3) {
                        0b000 => instructionType = .ADDI,
                        0b010 => instructionType = .SLTI,
                        0b011 => instructionType = .SLTIU,
                        0b100 => instructionType = .XORI,
                        0b110 => instructionType = .ORI,
                        0b111 => instructionType = .ANDI,
                        0b001 => instructionType = .SLLI,
                        0b101 => switch (bits.imm) {
                            0b000000000000 => instructionType = .SRLI,
                            0b010000000000 => instructionType = .SRAI,
                            else => return error.IllegalInstruction,
                        },
                    }
                },
                0b01 => return error.IllegalInstruction, // OP
                0b10 => return error.IllegalInstruction, // OP-FP
                0b11 => return error.IllegalInstruction, // SYSTEM
            },
            0b101 => switch (mapRow) {
                0b00 => return error.IllegalInstruction, // AUIPC
                0b01 => return error.IllegalInstruction, // LUI
                0b10 => return error.IllegalInstruction, // reserved
                0b11 => return error.IllegalInstruction, // reserved
            },
            0b110 => switch (mapRow) {
                0b00 => return error.IllegalInstruction, // OP-IMM-32
                0b01 => return error.IllegalInstruction, // OP-32
                0b10 => return error.IllegalInstruction, // custom-2/rv128
                0b11 => return error.IllegalInstruction, // custom-3/rv128
            },
            else => return error.IllegalInstruction,
        }

        if (instructionGroup == null) return error.IllegalInstruction;
        if (instructionType == null) return error.IllegalInstruction;

        return InstructionInfo{
            .group = instructionGroup.?,
            .type = instructionType.?,
        };
    }
};

pub const InstructionGroup = enum {
    R,
    I,
    S,
    B,
    U,
    J,
};

pub const InstructionType = enum {
    LUI,
    AUIPC,
    JAL,
    JALR,
    BEQ,
    BNE,
    BLT,
    BGE,
    BLTU,
    BGEU,
    LB,
    LH,
    LW,
    LBU,
    LHU,
    SB,
    SH,
    SW,
    ADDI,
    SLTI,
    SLTIU,
    XORI,
    ORI,
    ANDI,
    SLLI,
    SRLI,
    SRAI,
    ADD,
    SUB,
    SLL,
    SLT,
    SLTU,
    XOR,
    SRL,
    SRA,
    OR,
    AND,
    FENCE,
    @"FENCE.I",
    ECALL,
    EBREAK,
    CSRRW,
    CSRRS,
    CSRRC,
    CSRRWI,
    CSRRSI,
    CSRRCI,
};

pub const Rtype = struct {
    const Bits = packed struct {
        opcode: u7,
        rd: u5,
        funct3: u3,
        rs1: u5,
        rs2: u5,
        funct7: u7,
    };
};

pub const Itype = struct {
    const Bits = packed struct {
        opcode: u7,
        rd: u5,
        funct3: u3,
        rs1: u5,
        imm: u12,
    };
};

pub const Stype = struct {
    const Bits = packed struct {
        opcode: u7,
        imm1: u5,
        funct3: u3,
        rs1: u5,
        rs2: u5,
        imm2: u7,
    };
};

pub const Btype = struct {
    const Bits = packed struct {
        opcode: u7,
        imm3: u1,
        imm1: u4,
        funct3: u3,
        rs1: u5,
        rs2: u5,
        imm2: u6,
        imm4: u1,
    };
};

pub const Utype = struct {
    const Bits = packed struct {
        opcode: u7,
        rd: u5,
        imm: u20,
    };
};

pub const Jtype = struct {
    const Bits = packed struct {
        opcode: u7,
        rd: u5,
        imm2: u8,
        imm3: u1,
        imm1: u10,
        imm4: u1,
    };
};

comptime {
    // Double check to make sure all my instruction types are the correct size.
    std.debug.assert(@sizeOf(Rtype.Bits) == 4);
    std.debug.assert(@sizeOf(Itype.Bits) == 4);
    std.debug.assert(@sizeOf(Stype.Bits) == 4);
    std.debug.assert(@sizeOf(Btype.Bits) == 4);
    std.debug.assert(@sizeOf(Utype.Bits) == 4);
    std.debug.assert(@sizeOf(Jtype.Bits) == 4);
    std.debug.assert(@sizeOf(Instruction) == 4);

    std.debug.assert(@bitSizeOf(Rtype.Bits) == 32);
    std.debug.assert(@bitSizeOf(Itype.Bits) == 32);
    std.debug.assert(@bitSizeOf(Stype.Bits) == 32);
    std.debug.assert(@bitSizeOf(Btype.Bits) == 32);
    std.debug.assert(@bitSizeOf(Utype.Bits) == 32);
    std.debug.assert(@bitSizeOf(Jtype.Bits) == 32);
    std.debug.assert(@bitSizeOf(Instruction) == 32);
}

test "InstructionInfo.init Btype" {
    try std.testing.expectEqual(try InstructionInfo.init(0b000000001100011), InstructionInfo{ .group = .B, .type = .BEQ });
    try std.testing.expectEqual(try InstructionInfo.init(0b001000001100011), InstructionInfo{ .group = .B, .type = .BNE });
    try std.testing.expectEqual(try InstructionInfo.init(0b100000001100011), InstructionInfo{ .group = .B, .type = .BLT });
    try std.testing.expectEqual(try InstructionInfo.init(0b101000001100011), InstructionInfo{ .group = .B, .type = .BGE });
    try std.testing.expectEqual(try InstructionInfo.init(0b110000001100011), InstructionInfo{ .group = .B, .type = .BLTU });
    try std.testing.expectEqual(try InstructionInfo.init(0b111000001100011), InstructionInfo{ .group = .B, .type = .BGEU });
    try std.testing.expectEqual(InstructionInfo.init(0b010000001100011), error.IllegalInstruction);
}

test "InstructionInfo.init Itype" {
    try std.testing.expectEqual(try InstructionInfo.init(0b000000000010011), InstructionInfo{ .group = .I, .type = .ADDI });
    try std.testing.expectEqual(try InstructionInfo.init(0b010000000010011), InstructionInfo{ .group = .I, .type = .SLTI });
    try std.testing.expectEqual(try InstructionInfo.init(0b011000000010011), InstructionInfo{ .group = .I, .type = .SLTIU });
    try std.testing.expectEqual(try InstructionInfo.init(0b100000000010011), InstructionInfo{ .group = .I, .type = .XORI });
    try std.testing.expectEqual(try InstructionInfo.init(0b110000000010011), InstructionInfo{ .group = .I, .type = .ORI });
    try std.testing.expectEqual(try InstructionInfo.init(0b111000000010011), InstructionInfo{ .group = .I, .type = .ANDI });

    try std.testing.expectEqual(try InstructionInfo.init(0b00000000000000000001000000010011), InstructionInfo{ .group = .I, .type = .SLLI });
    try std.testing.expectEqual(try InstructionInfo.init(0b00000000000000000101000000010011), InstructionInfo{ .group = .I, .type = .SRLI });
    try std.testing.expectEqual(try InstructionInfo.init(0b01000000000000000101000000010011), InstructionInfo{ .group = .I, .type = .SRAI });
}
