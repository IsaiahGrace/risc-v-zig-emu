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
            if (std.mem.eql(u8, inst, "ADD")) return try parseRtype(.ADD, &tokens);
            if (std.mem.eql(u8, inst, "ADDI")) return try parseItype(.ADDI, &tokens);
            if (std.mem.eql(u8, inst, "AND")) return try parseRtype(.AND, &tokens);
            if (std.mem.eql(u8, inst, "ANDI")) return try parseItype(.ANDI, &tokens);
            if (std.mem.eql(u8, inst, "AUIPC")) return error.UnsupportedAsm;
            return error.IllegalAsm;
        },
        'B' => {
            if (std.mem.eql(u8, inst, "BEQ")) return error.UnsupportedAsm;
            if (std.mem.eql(u8, inst, "BGE")) return error.UnsupportedAsm;
            if (std.mem.eql(u8, inst, "BGEU")) return error.UnsupportedAsm;
            if (std.mem.eql(u8, inst, "BLT")) return error.UnsupportedAsm;
            if (std.mem.eql(u8, inst, "BLTU")) return error.UnsupportedAsm;
            if (std.mem.eql(u8, inst, "BNE")) return error.UnsupportedAsm;
            return error.IllegalAsm;
        },
        'C' => {
            if (std.mem.eql(u8, inst, "CSRRC")) return error.UnsupportedAsm;
            if (std.mem.eql(u8, inst, "CSRRCI")) return error.UnsupportedAsm;
            if (std.mem.eql(u8, inst, "CSRRS")) return error.UnsupportedAsm;
            if (std.mem.eql(u8, inst, "CSRRSI")) return error.UnsupportedAsm;
            if (std.mem.eql(u8, inst, "CSRRW")) return error.UnsupportedAsm;
            if (std.mem.eql(u8, inst, "CSRRWI")) return error.UnsupportedAsm;
            return error.IllegalAsm;
        },
        'E' => {
            if (std.mem.eql(u8, inst, "EBREAK")) return error.UnsupportedAsm;
            if (std.mem.eql(u8, inst, "ECALL")) return error.UnsupportedAsm;
            return error.IllegalAsm;
        },
        'F' => {
            if (std.mem.eql(u8, inst, "FENCE")) return error.UnsupportedAsm;
            if (std.mem.eql(u8, inst, "FENCE.I")) return error.UnsupportedAsm;
            return error.IllegalAsm;
        },
        'J' => {
            if (std.mem.eql(u8, inst, "JAL")) return error.UnsupportedAsm;
            if (std.mem.eql(u8, inst, "JALR")) return error.UnsupportedAsm;
            return error.IllegalAsm;
        },
        'L' => {
            if (std.mem.eql(u8, inst, "LB")) return error.UnsupportedAsm;
            if (std.mem.eql(u8, inst, "LBU")) return error.UnsupportedAsm;
            if (std.mem.eql(u8, inst, "LH")) return error.UnsupportedAsm;
            if (std.mem.eql(u8, inst, "LHU")) return error.UnsupportedAsm;
            if (std.mem.eql(u8, inst, "LUI")) return error.UnsupportedAsm;
            if (std.mem.eql(u8, inst, "LW")) return error.UnsupportedAsm;
            return error.IllegalAsm;
        },
        'O' => {
            if (std.mem.eql(u8, inst, "OR")) return try parseRtype(.OR, &tokens);
            if (std.mem.eql(u8, inst, "ORI")) return try parseItype(.ORI, &tokens);
            return error.IllegalAsm;
        },
        'S' => switch (inst[1]) {
            'B' => return error.UnsupportedAsm, // SB
            'H' => return error.UnsupportedAsm, // SH
            'L' => {
                if (std.mem.eql(u8, inst, "SLL")) return try parseRtype(.SLL, &tokens);
                if (std.mem.eql(u8, inst, "SLLI")) return try parseItype(.SLLI, &tokens);
                if (std.mem.eql(u8, inst, "SLT")) return try parseRtype(.SLT, &tokens);
                if (std.mem.eql(u8, inst, "SLTI")) return try parseItype(.SLTI, &tokens);
                if (std.mem.eql(u8, inst, "SLTIU")) return try parseItype(.SLTIU, &tokens);
                if (std.mem.eql(u8, inst, "SLTU")) return try parseRtype(.SLTU, &tokens);
                return error.IllegalAsm;
            },
            'R' => {
                if (std.mem.eql(u8, inst, "SRA")) return try parseRtype(.SRA, &tokens);
                if (std.mem.eql(u8, inst, "SRAI")) return try parseItype(.SRAI, &tokens);
                if (std.mem.eql(u8, inst, "SRL")) return try parseRtype(.SRL, &tokens);
                if (std.mem.eql(u8, inst, "SRLI")) return try parseItype(.SRLI, &tokens);
                return error.IllegalAsm;
            },
            'U' => return try parseRtype(.SUB, &tokens),
            'W' => return error.UnsupportedAsm, // SW
            else => return error.IllegalAsm,
        },
        'X' => {
            if (std.mem.eql(u8, inst, "XOR")) return try parseRtype(.XOR, &tokens);
            if (std.mem.eql(u8, inst, "XORI")) return try parseItype(.XORI, &tokens);
            return error.IllegalAsm;
        },
        else => return error.IllegalAsm,
    }
}

fn parseRtype(instructionType: rv32i.InstructionType, tokens: *std.mem.TokenIterator(u8)) !rv32i.Instruction {
    var bits = std.mem.zeroInit(rv32i.Rtype.Bits, .{});
    bits.rd = try std.fmt.parseInt(@TypeOf(bits.rd), tokens.next().?[1..], 10);
    bits.rs1 = try std.fmt.parseInt(@TypeOf(bits.rd), tokens.next().?[1..], 10);
    bits.rs2 = try std.fmt.parseInt(@TypeOf(bits.rd), tokens.next().?[1..], 10);

    // All Rtype instructions have the same opcode
    bits.opcode = 0b0110011;
    switch (instructionType) {
        .ADD => {}, // All other bits are zero
        .SUB => bits.funct7 = 0b0100000,
        .SLL => bits.funct3 = 0b001,
        .SLT => bits.funct3 = 0b010,
        .SLTU => bits.funct3 = 0b011,
        .XOR => bits.funct3 = 0b100,
        .SRL => bits.funct3 = 0b101,
        .SRA => {
            bits.funct3 = 0b101;
            bits.funct7 = 0b0100000;
        },
        .OR => bits.funct3 = 0b110,
        .AND => bits.funct3 = 0b111,
        else => return error.UnsupportedAsm,
    }
    return @bitCast(rv32i.Instruction, bits);
}

fn parseItype(instructionType: rv32i.InstructionType, tokens: *std.mem.TokenIterator(u8)) !rv32i.Instruction {
    var bits = std.mem.zeroInit(rv32i.Itype.Bits, .{});
    bits.rd = try std.fmt.parseInt(@TypeOf(bits.rd), tokens.next().?[1..], 10);
    bits.rs1 = try std.fmt.parseInt(@TypeOf(bits.rs1), tokens.next().?[1..], 10);
    bits.imm = try std.fmt.parseInt(@TypeOf(bits.imm), tokens.next().?, 10);

    // Most Itype instructions have the same opcode
    bits.opcode = 0b0010011;
    switch (instructionType) {
        .ADDI => {},
        .SLTI => bits.funct3 = 0b010,
        .SLTIU => bits.funct3 = 0b011,
        .XORI => bits.funct3 = 0b100,
        .ORI => bits.funct3 = 0b110,
        .ANDI => bits.funct3 = 0b111,
        .SLLI => return error.UnsupportedAsm, // These have the shamt field, so we need to do something special here
        .SRLI => return error.UnsupportedAsm,
        .SRAI => return error.UnsupportedAsm,
        else => return error.UnsupportedAsm,
    }
    return @bitCast(rv32i.Instruction, bits);
}
