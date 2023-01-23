const std = @import("std");
const rv32i = @import("rv32i.zig");

pub const Assembler = struct {
    const Self = @This();

    const Program = std.ArrayList(rv32i.Instruction);

    program: Program,

    pub fn init(allocator: std.mem.Allocator) Self {
        return Assembler{
            .program = Program.init(allocator),
        };
    }

    pub fn deinit(self: Self) void {
        self.program.deinit();
    }

    pub fn loadProgram(self: *Self, machine: *rv32i.Machine) void {
        for (self.program.items) |w, i| {
            machine.memory[i] = w;
        }
    }

    pub fn parseAsm(self: *Self, input: []const u8) !void {
        var lines = std.mem.tokenize(u8, input, "\n");
        while (lines.next()) |line| {
            std.log.info("Parsing: {s}", .{line});
            try self.program.append(try parseAsmLine(line));
        }
    }
};

fn parseAsmLine(line: []const u8) !rv32i.Instruction {
    var tokens = std.mem.tokenize(u8, line, ", ");
    const inst = tokens.next().?;

    switch (inst[0]) {
        'A' => {
            if (std.mem.eql(u8, inst, "ADD")) return try parseADD(&tokens);
            if (std.mem.eql(u8, inst, "ADDI")) return try parseADDI(&tokens);

            // AND
            // ANDI
            // AUIPC
            return error.UnsupportedAsm;
        },
        'B' => {
            // BEQ
            // BGE
            // BGEU
            // BLT
            // BLTU
            // BNE
            return error.UnsupportedAsm;
        },
        'C' => {
            // CSRRC
            // CSRRCI
            // CSRRS
            // CSRRSI
            // CSRRW
            // CSRRWI
            return error.UnsupportedAsm;
        },
        'E' => {
            // EBREAK
            // ECALL
            return error.UnsupportedAsm;
        },
        'F' => {
            // FENCE
            // FENCE.I
            return error.UnsupportedAsm;
        },
        'J' => {
            // JAL
            // JALR
            return error.UnsupportedAsm;
        },
        'L' => {
            // LB
            // LBU
            // LH
            // LHU
            // LUI
            // LW
            return error.UnsupportedAsm;
        },
        'O' => {
            // OR
            // ORI
            return error.UnsupportedAsm;
        },
        'S' => {
            // SB
            // SH
            // SLL
            // SLLI
            // SLT
            // SLTI
            // SLTIU
            // SLTU
            // SRA
            // SRAI
            // SRL
            // SRLI
            // SUB
            // SW
            return error.UnsupportedAsm;
        },
        'X' => {
            // XOR
            // XORI
            return error.UnsupportedAsm;
        },
        else => return error.IllegalAsm,
    }
}

fn parseADD(tokens: *std.mem.TokenIterator(u8)) !rv32i.Instruction {
    var add: rv32i.Rtype.Bits = undefined;
    add.opcode = 0b0110011;
    add.rd = try std.fmt.parseInt(u5, tokens.next().?[1..], 10);
    add.funct3 = 0b000;
    add.rs1 = try std.fmt.parseInt(u5, tokens.next().?[1..], 10);
    add.rs2 = try std.fmt.parseInt(u5, tokens.next().?[1..], 10);
    add.funct7 = 0b0000000;
    return @bitCast(rv32i.Instruction, add);
}

fn parseADDI(tokens: *std.mem.TokenIterator(u8)) !rv32i.Instruction {
    var addi: rv32i.Itype.Bits = undefined;
    addi.opcode = 0b0010011;
    addi.rd = try std.fmt.parseInt(@TypeOf(addi.rd), tokens.next().?[1..], 10);
    addi.funct3 = 0b000;
    addi.rs1 = try std.fmt.parseInt(@TypeOf(addi.rs1), tokens.next().?[1..], 10);
    addi.imm = try std.fmt.parseInt(@TypeOf(addi.imm), tokens.next().?, 10);
    return @bitCast(rv32i.Instruction, addi);
}
