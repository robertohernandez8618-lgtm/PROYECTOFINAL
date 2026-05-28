//modificado Fase 2
module DPTR (
    input clk,
    input [31:0] instruction,
    output [31:0] result,
    
    
    output Branch_out,
    output Zero_out,
    output [31:0] SignExt_out
);

    wire [5:0] op = instruction[31:26];
    wire [4:0] rs = instruction[25:21];
    wire [4:0] rt = instruction[20:16];
    wire [4:0] rd = instruction[15:11];
    wire [4:0] sh = instruction[10:6];
    wire [5:0] funct = instruction[5:0];
    wire [15:0] inmed = instruction[15:0]; 

    wire RegDst, ALUSrc, Branch; // NUEVAS
    wire memToReg, RegWrite, memToWrite, memToRead;
    wire [2:0] ALUOp;
    wire [3:0] ALUCtrl;

    wire aluException; // funciona como la señal "Zero" para el beq
    wire [31:0] readData1, readData2, aluResult;
    wire [31:0] sign_ext_out;
    wire [31:0] idex_rd1; 
    wire [31:0] idex_rd2;
    wire [31:0] idex_imm;
    wire idex_ALUSrc;
    wire [31:0] exmem_aluResult;
    wire [31:0] exmem_writeData;
	
    wire exmem_RegWrite;
    wire exmem_MemWrite;
    wire exmem_MemToReg;
    wire idex_RegWrite;
    wire idex_MemWrite;
    wire idex_MemToReg;
    wire [31:0] memwb_memData;
    wire [31:0] memwb_aluResult;

    wire memwb_RegWrite;
    wire memwb_MemToReg;
    wire [4:0]  write_reg_addr;
    wire [31:0] alu_b_in;
    wire [31:0] mem_data_out;
    wire [31:0] write_data_in;


    U_Control UC(
        .op(op), 
        .funct(funct), 
        .RegDst(RegDst), 
        .ALUSrc(ALUSrc), 
        .Branch(Branch), 
        .memToReg(memToReg), 
        .memToWrite(memToWrite), 
        .memToRead(memToRead), 
        .AluOP(ALUOp), 
        .RegWrite(RegWrite)
    );

    ALUControl ALUC(
        .fnc(funct), 
        .ALUOp(ALUOp), 
        .Sel(ALUCtrl)
    );

    // MUX RegDst fase2
    // decide si el registro destino es rt (0) o rd (1)
    Mux2_1_5 mux_regdst(
        .in0(rt), 
        .in1(rd), 
        .sel(RegDst), 
        .out(write_reg_addr)
    );

    SignExtend se(
        .in(inmed), 
        .out(sign_ext_out)
    );     // Convierte el inmediato de 16 bits a 32 bits

    /*Mux2_1_32 mux_alusrc(
        .in0(readData2), 
        .in1(sign_ext_out), 
        .sel(ALUSrc), 
        .out(alu_b_in)
    );     // Decide si la ALU usa readData2 (0) o el inmediato extendido (1)
    */
    BancoReg BR(
        .clk(clk), 
        .RegWrite(memwb_RegWrite),
        .rs(rs), 
        .rt(rt), 
        .rd(write_reg_addr),       
        .writeData(write_data_in), 
        .readData1(readData1), 
        .readData2(readData2)
    );

    ALU alu(
        .A(idex_rd1),
        .B(alu_b_in),           
        .shamt(sh), 
        .ALUCtrl(ALUCtrl), 
        .Result(aluResult), 
        .Exception(aluException)
    );

     BufferDatos idex(
    .clk(clk),
    .reset(1'b0),

    .rd1_in(readData1),
    .rd2_in(readData2),
    .imm_in(sign_ext_out),

    .rs_in(rs),
    .rt_in(rt),
    .rd_in(rd),

    .RegWrite_in(RegWrite),
    .MemToReg_in(memToReg),
    .MemWrite_in(memToWrite),
    .MemRead_in(memToRead),
    .ALUSrc_in(ALUSrc),
    .RegDst_in(RegDst),
    .Branch_in(Branch),

    .ALUOp_in(ALUOp),

    .rd1_out(idex_rd1),
    .rd2_out(idex_rd2),
    .imm_out(idex_imm),

    .rs_out(),
    .rt_out(),
    .rd_out(),

    .RegWrite_out(idex_RegWrite),
    .MemWrite_out(idex_MemWrite),
    .MemToReg_out(idex_MemToReg),
    .MemRead_out(),
    .ALUSrc_out(idex_ALUSrc),
    .RegDst_out(),
    .Branch_out(),

    .ALUOp_out()
     );

     BufferALU exmem(
    .clk(clk),
    .reset(1'b0),

    .aluResult_in(aluResult),
    .writeData_in(idex_rd2),

    .writeReg_in(5'b0),

    .Zero_in(1'b0),
    .Branch_in(1'b0),

    .RegWrite_in(idex_RegWrite),
    .MemToReg_in(idex_MemToReg),
    .MemWrite_in(idex_MemWrite),
    .MemRead_in(1'b0),

    .aluResult_out(exmem_aluResult),
    .writeData_out(exmem_writeData),

    .writeReg_out(),

    .Zero_out(),
    .Branch_out(),

    .RegWrite_out(exmem_RegWrite),
    .MemToReg_out(exmem_MemToReg),
    .MemWrite_out(exmem_MemWrite),
    .MemRead_out()
    );
     Mux2_1_32 mux_alusrc_pipeline(
    .in0(idex_rd2),
    .in1(idex_imm),
    .sel(idex_ALUSrc),
    .out(alu_b_in)
     );

    Mem_D dmem(
        .clk(clk), 
        .MemWrite(exmem_memToWrite), 
        .dir(exmem_aluResult),           
        .DEntrada(exmem_writeData),     // dato a guardar (para sw)
        .DSalida(mem_data_out)     // dato extraído (para lw)
    );

    BufferFinal memwb(
    .clk(clk),
    .reset(1'b0),

    .memData_in(mem_data_out),
    .aluResult_in(exmem_aluResult),

    .writeReg_in(5'b0),

    .RegWrite_in(exmem_RegWrite),
    .MemToReg_in(exmem_MemToReg),

    .memData_out(memwb_memData),
    .aluResult_out(memwb_aluResult),

    .writeReg_out(),

    .RegWrite_out(memwb_RegWrite),
    .MemToReg_out(memwb_MemToReg)
    );

    Mux2_1_32 mux_memtoreg(
    .in0(memwb_aluResult),
    .in1(memwb_memData),
    .sel(memwb_MemToReg),
    .out(write_data_in)
     );   // Decide si se guarda en el Banco de Registros el resultado ALU (0) o la Memoria (1)

    // Salida para monitorear en el testbench

    assign result = aluResult;
    assign Branch_out = Branch;
    assign Zero_out = (aluResult == 32'd0) ? 1'b1 : 1'b0; // Si la resta da 0, levanta la bandera Zero
    assign SignExt_out = sign_ext_out;
endmodule
