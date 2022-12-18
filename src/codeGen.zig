const std = @import("std");
const rv32i = @import("rv32i.zig");

// This is a semantic representation of an RV32I instruction
pub const asmInstr = struct {
    opcode: rv32i.RV32I_opcode,
    rd: u5,
    rs1: u5,
    rs2: u5,
    imm: u32,

    pub fn ToBits(self: asmInstr) rv32i.Instruction {
        var bits: u32 = 0;
        var inst: rv32i.Instruction = undefined;

        switch (self.opcode) {
            .addi => bits |= 0x000000013,
            else => @panic("unsuported opcode"),
        }

        switch (self.opcode) {
            .addi => inst = rv32i.Instruction{ .i = @bitCast(rv32i.Itype, bits) },
            else => @panic("unsuported opcode"),
        }
        return inst;
    }
};

comptime {
    const addi = asmInstr{
        .opcode = .addi,
        .rd = 2,
        .rs1 = 3,
        .rs2 = 4,
        .imm = 0xffffffff,
    };

    const inst: rv32i.Instruction = addi.ToBits();
    @compileLog(inst.i.imm);
}
