// Isaiah Grace

// RV32I instruction set refrence:
// https://msyksphinz-self.github.io/riscv-isadoc/html/rvi.html
// https://five-embeddev.com/riscv-isa-manual/latest/rv32.html

const std = @import("std");

pub const RV32I_opcode = enum {
    lui,
    auipc,
    addi,
    slti,
    sltiu,
    xori,
    ori,
    andi,
    slli,
    srli,
    srai,
    add,
    sub,
    sll,
    slt,
    sltu,
    xor,
    srl,
    sra,
    @"or",
    @"and",
    fence,
    @"fence.i",
    csrrw,
    csrrs,
    csrrc,
    csrrwi,
    csrrsi,
    csrrci,
    ecall,
    ebreak,
    uret,
    sret,
    mret,
    wfi,
    @"sfence.vma",
    lb,
    lh,
    lw,
    lbu,
    lhu,
    sb,
    sh,
    sw,
    jal,
    jalr,
    beq,
    bne,
    blt,
    bge,
    bltu,
    bgeu,
};

pub const Rtype = packed struct {
    funct7: u7,
    rs2: u5,
    rs1: u5,
    funct3: u3,
    rd: u5,
    opcode: u7,
};

pub const Itype = packed struct {
    imm: u12,
    rs1: u5,
    funct3: u3,
    rd: u5,
    opcode: u7,
};

pub const Stype = packed struct {
    imm2: u7,
    rs2: u5,
    rs1: u5,
    funct3: u3,
    imm1: u5,
    opcode: u7,
};

pub const Btype = packed struct {
    imm4: u1,
    imm2: u6,
    rs2: u5,
    rs1: u5,
    funct3: u3,
    imm1: u4,
    imm3: u1,
    opcode: u7,
};

pub const Utype = packed struct {
    imm: u20,
    rd: u5,
    opcode: u7,
};

pub const Jtype = packed struct {
    imm4: u1,
    imm1: u10,
    imm3: u1,
    imm2: u8,
    rd: u5,
    opcode: u7,
};

pub const Instruction = packed union {
    r: Rtype,
    i: Itype,
    s: Stype,
    b: Btype,
    u: Utype,
    j: Jtype,
};

pub const State = struct {
    x: [32]u32,
    pc: u32,
};

comptime {
    // Double check to make sure all my instruction types are the correct size.
    std.debug.assert(@sizeOf(Rtype) == 4);
    std.debug.assert(@sizeOf(Itype) == 4);
    std.debug.assert(@sizeOf(Stype) == 4);
    std.debug.assert(@sizeOf(Btype) == 4);
    std.debug.assert(@sizeOf(Utype) == 4);
    std.debug.assert(@sizeOf(Jtype) == 4);
    std.debug.assert(@sizeOf(Instruction) == 4);

    std.debug.assert(@bitSizeOf(Rtype) == 32);
    std.debug.assert(@bitSizeOf(Itype) == 32);
    std.debug.assert(@bitSizeOf(Stype) == 32);
    std.debug.assert(@bitSizeOf(Btype) == 32);
    std.debug.assert(@bitSizeOf(Utype) == 32);
    std.debug.assert(@bitSizeOf(Jtype) == 32);
    std.debug.assert(@bitSizeOf(Instruction) == 32);
}
