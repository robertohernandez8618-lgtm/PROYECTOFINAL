module BufferInstr(
    input clk,
    input reset,
    input flush, //PUERTO DE LIMPIEZA

    input [31:0] instr_in,
    input [31:0] pc4_in,

    output reg [31:0] instr_out,
    output reg [31:0] pc4_out
);

always @(posedge clk or posedge reset)
begin
    if(reset || flush) // SI HAY SALTO, METE UN NOP
    begin
        instr_out <= 32'b0;
        pc4_out   <= 32'b0;
    end
    else
    begin
        instr_out <= instr_in;
        pc4_out   <= pc4_in;
    end
end
endmodule


module BufferDatos(
    input clk,
    input reset,

    input [31:0] pc4_in,
    output reg [31:0] pc4_out,

    input [31:0] rd1_in,
    input [31:0] rd2_in,
    input [31:0] imm_in,

    input [4:0] rs_in,
    input [4:0] rt_in,
    input [4:0] rd_in,

    input RegWrite_in,
    input MemToReg_in,
    input MemWrite_in,
    input MemRead_in,
    input ALUSrc_in,
    input RegDst_in,
    input Branch_in,

    input [2:0] ALUOp_in,
    
    input [5:0] funct_in,
    input [4:0] shamt_in,
    output reg [4:0] shamt_out,
    output reg [5:0] funct_out,

    output reg [31:0] rd1_out,
    output reg [31:0] rd2_out,
    output reg [31:0] imm_out,

    output reg [4:0] rs_out,
    output reg [4:0] rt_out,
    output reg [4:0] rd_out,

    output reg RegWrite_out,
    output reg MemToReg_out,
    output reg MemWrite_out,
    output reg MemRead_out,
    output reg ALUSrc_out,
    output reg RegDst_out,
    output reg Branch_out,

    output reg [2:0] ALUOp_out
);

always @(posedge clk or posedge reset) begin
    if(reset) begin
        pc4_out      <= 32'b0;
        rd1_out      <= 32'b0;
        rd2_out      <= 32'b0;
        imm_out      <= 32'b0;
        rs_out       <= 5'b0;
        rt_out       <= 5'b0;
        rd_out       <= 5'b0;
        RegWrite_out <= 1'b0;
        MemWrite_out <= 1'b0;
        MemToReg_out <= 1'b0;
        MemRead_out  <= 1'b0;
        ALUSrc_out   <= 1'b0;
        RegDst_out   <= 1'b0;
        Branch_out   <= 1'b0;
        ALUOp_out    <= 3'b0;
        funct_out    <= 6'b0;
        shamt_out    <= 5'b0;
    end
    else begin
        pc4_out      <= pc4_in;
        rd1_out      <= rd1_in;
        rd2_out      <= rd2_in;
        imm_out      <= imm_in;
        rs_out       <= rs_in;
        rt_out       <= rt_in;
        rd_out       <= rd_in;
        RegWrite_out <= RegWrite_in;
        MemWrite_out <= MemWrite_in;
        MemToReg_out <= MemToReg_in;
        MemRead_out  <= MemRead_in;
        ALUSrc_out   <= ALUSrc_in;
        RegDst_out   <= RegDst_in;
        Branch_out   <= Branch_in;
        ALUOp_out    <= ALUOp_in;
        funct_out    <= funct_in;
        shamt_out    <= shamt_in;
    end
end
endmodule



module BufferALU(
    input clk,
    input reset,

    input [31:0] aluResult_in,
    input [31:0] writeData_in,

    input [4:0] writeReg_in,

    input Zero_in,
    input Branch_in,

    input RegWrite_in,
    input MemToReg_in,
    input MemWrite_in,
    input MemRead_in,

    output reg [31:0] aluResult_out,
    output reg [31:0] writeData_out,

    output reg [4:0] writeReg_out,

    output reg Zero_out,
    output reg Branch_out,

    output reg RegWrite_out,
    output reg MemToReg_out,
    output reg MemWrite_out,
    output reg MemRead_out
);

always @(posedge clk or posedge reset) begin
    if(reset) begin
        aluResult_out <= 32'b0;
        writeData_out <= 32'b0;
        writeReg_out  <= 5'b0;
        Zero_out      <= 1'b0;
        Branch_out    <= 1'b0;
        RegWrite_out  <= 1'b0;
        MemToReg_out  <= 1'b0;
        MemWrite_out  <= 1'b0;
        MemRead_out   <= 1'b0;
    end
    else begin
        aluResult_out <= aluResult_in;
        writeData_out <= writeData_in;
        writeReg_out  <= writeReg_in;
        Zero_out      <= Zero_in;
        Branch_out    <= Branch_in;
        RegWrite_out  <= RegWrite_in;
        MemToReg_out  <= MemToReg_in;
        MemWrite_out  <= MemWrite_in;
        MemRead_out   <= MemRead_in;
    end
end

endmodule



module BufferFinal(
    input clk,
    input reset,

    input [31:0] memData_in,
    input [31:0] aluResult_in,

    input [4:0] writeReg_in,

    input RegWrite_in,
    input MemToReg_in,

    output reg [31:0] memData_out,
    output reg [31:0] aluResult_out,

    output reg [4:0] writeReg_out,

    output reg RegWrite_out,
    output reg MemToReg_out
);

always @(posedge clk or posedge reset) begin
    if(reset) begin
        memData_out   <= 32'b0;
        aluResult_out <= 32'b0;
        writeReg_out  <= 5'b0;
        RegWrite_out  <= 1'b0;
        MemToReg_out  <= 1'b0;
    end
    else begin
        memData_out   <= memData_in;
        aluResult_out <= aluResult_in;
        writeReg_out  <= writeReg_in;
        RegWrite_out  <= RegWrite_in;
        MemToReg_out  <= MemToReg_in;
    end
end

endmodule
