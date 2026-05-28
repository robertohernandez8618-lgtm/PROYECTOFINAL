module DPTR (
    input clk,
    input [31:0] instruction,
    output [31:0] result
);
    wire [5:0] op = instruction[31:26];
    wire [4:0] rs = instruction[25:21];
    wire [4:0] rt = instruction[20:16];
    wire [4:0] rd = instruction[15:11];
    wire [4:0] sh = instruction[10:6];
    wire [5:0] funct = instruction[5:0];

    wire memToReg, RegWrite, memToWrite, memToRead;
    wire [2:0] ALUOp;
    wire [3:0] ALUCtrl;
    wire aluException;
    wire [31:0] readData1, readData2, aluResult;

    U_Control UC(op, funct, memToReg, memToWrite, memToRead, ALUOp, RegWrite);
    ALUControl ALUC(funct, ALUOp, ALUCtrl);
    BancoReg BR(clk, RegWrite, rs, rt, rd, aluResult, readData1, readData2);
    ALU alu(readData1, readData2, sh, ALUCtrl, aluResult, aluException);

    assign result = aluResult;
endmodule


