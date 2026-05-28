module DPTR (
    input clk,
    input reset,
    input [31:0] instruction,
    input [31:0] pc4_in,           //Recibe PC+4 de la etapa ID
    output [31:0] result,
    
    output Branch_out,
    output Zero_out,
    output [31:0] SignExt_out,
    output [31:0] PC4_Branch_out,  //Exporta PC+4 desde la etapa EX
    
    output Jump_out,     
    output [25:0] JumpTarget_out
);

    wire [5:0] op = instruction[31:26];
    wire [4:0] rs = instruction[25:21];
    wire [4:0] rt = instruction[20:16];
    wire [4:0] rd = instruction[15:11];
    wire [4:0] sh = instruction[10:6];
    wire [5:0] funct = instruction[5:0];
    wire [15:0] inmed = instruction[15:0]; 

    wire [5:0] idex_funct;
    wire [4:0] idex_shamt;
    wire [4:0] idex_rt;
    wire [4:0] idex_rd;
    wire [4:0] idex_rs;
    wire idex_RegDst;
    wire [4:0] exmem_writeReg;
    wire [4:0] memwb_writeReg;
    
    wire RegDst, ALUSrc, Branch; 
    wire memToReg, RegWrite, memToWrite, memToRead;
    wire [2:0] ALUOp;
    wire [2:0] idex_ALUOp;
    wire [3:0] ALUCtrl;

    wire aluException; 
    wire [31:0] readData1, readData2, aluResult;
    wire [31:0] sign_ext_out;
    wire [31:0] idex_rd1; 
    wire [31:0] idex_rd2;
    wire [31:0] idex_imm;
    wire [31:0] idex_pc4; // CABLE PARA EL PC DEL BUFFER ID/EX
    wire idex_ALUSrc;
    wire [31:0] exmem_aluResult;
    wire [31:0] exmem_writeData;
    
    wire exmem_Zero;
    wire exmem_Branch;
    wire idex_Branch;
    wire aluZero;
    
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
    
    wire Jump;
    
    wire [1:0] ForwardA, ForwardB;
    wire [31:0] alu_operand_A, alu_operand_B_pre_mux;

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
        .RegWrite(RegWrite),
        .Jump(Jump),
		.Bne()
    );

    ALUControl ALUC(
        .fnc(idex_funct),
        .ALUOp(idex_ALUOp),
        .Sel(ALUCtrl)
    );

    Mux2_1_5 mux_regdst(
        .in0(idex_rt),        
        .in1(idex_rd),        
        .sel(idex_RegDst),    
        .out(write_reg_addr)  
    );

    SignExtend se(
        .in(inmed), 
        .out(sign_ext_out)
    );    

    BancoReg BR (
        .clk(clk),
        .RegWrite(memwb_RegWrite),
        .rs(rs),
        .rt(rt),
        .rd(memwb_writeReg),
        .writeData(write_data_in),
        .readData1(readData1),
        .readData2(readData2)
    );

    assign alu_operand_A = (ForwardA == 2'b00) ? idex_rd1 :           
                       (ForwardA == 2'b10) ? exmem_aluResult :    
                       (ForwardA == 2'b01) ? write_data_in :      
                                             idex_rd1;
    
    assign alu_operand_B_pre_mux = (ForwardB == 2'b00) ? idex_rd2 :        
                               (ForwardB == 2'b10) ? exmem_aluResult : 
                               (ForwardB == 2'b01) ? write_data_in :   
                                                     idex_rd2;

    wire [31:0] final_srcB = idex_ALUSrc ? idex_imm : alu_operand_B_pre_mux;

    ALU alu(
        .A(alu_operand_A),
        .B(final_srcB),
        .shamt(idex_shamt), 
        .ALUCtrl(ALUCtrl), 
        .Result(aluResult), 
        .Exception(aluException),
        .Zero(aluZero)
    );

    BufferDatos idex(
        .clk(clk),
        .reset(reset),
        
        .pc4_in(pc4_in),     // RECIBE DE LA ETAPA ID
        .pc4_out(idex_pc4),  //  GUARDA PARA LA ETAPA EX
        
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
        
        .funct_in(funct),
        .shamt_in(sh),
        .shamt_out(idex_shamt),
        .funct_out(idex_funct),

        .rd1_out(idex_rd1),
        .rd2_out(idex_rd2),
        .imm_out(idex_imm),

        .rs_out(idex_rs),
        .rt_out(idex_rt),
        .rd_out(idex_rd),

        .RegWrite_out(idex_RegWrite),
        .MemWrite_out(idex_MemWrite),
        .MemToReg_out(idex_MemToReg),
        .MemRead_out(),
        .ALUSrc_out(idex_ALUSrc),
        .RegDst_out(idex_RegDst),
        .Branch_out(idex_Branch),
        .ALUOp_out(idex_ALUOp)
    );

    BufferALU exmem(
        .clk(clk),
        .reset(reset),

        .aluResult_in(aluResult),
        .writeData_in(alu_operand_B_pre_mux),
        .writeReg_in(write_reg_addr),

        .Zero_in(aluZero),
        .Branch_in(idex_Branch), 

        .aluResult_out(exmem_aluResult),
        .writeData_out(exmem_writeData),
        .writeReg_out(exmem_writeReg),

        .Zero_out(exmem_Zero),
        .Branch_out(exmem_Branch),

        .RegWrite_in(idex_RegWrite),
        .MemToReg_in(idex_MemToReg),
        .MemWrite_in(idex_MemWrite),
        .MemRead_in(1'b0),

        .RegWrite_out(exmem_RegWrite),
        .MemToReg_out(exmem_MemToReg),
        .MemWrite_out(exmem_MemWrite),
        .MemRead_out()
    );
    
    Mem_D dmem(
        .clk(clk), 
        .MemWrite(exmem_MemWrite), 
        .dir(exmem_aluResult),           
        .DEntrada(exmem_writeData),     
        .DSalida(mem_data_out)     
    );

    BufferFinal memwb(
        .clk(clk),
        .reset(reset),
        .memData_in(mem_data_out),
        .aluResult_in(exmem_aluResult),

        .writeReg_in(exmem_writeReg), 

        .RegWrite_in(exmem_RegWrite),
        .MemToReg_in(exmem_MemToReg),

        .memData_out(memwb_memData),
        .aluResult_out(memwb_aluResult),

        .writeReg_out(memwb_writeReg),

        .RegWrite_out(memwb_RegWrite),
        .MemToReg_out(memwb_MemToReg)
    );

    Mux2_1_32 mux_memtoreg(
        .in0(memwb_aluResult),
        .in1(memwb_memData),
        .sel(memwb_MemToReg),
        .out(write_data_in)
    ); 
    
    Forwarding_Unit FU (
        .idex_rs(idex_rs),                
        .idex_rt(idex_rt),                
        .exmem_rd(exmem_writeReg),        
        .memwb_rd(memwb_writeReg),        
        .exmem_RegWrite(exmem_RegWrite),  
        .memwb_RegWrite(memwb_RegWrite),  
        .ForwardA(ForwardA),
        .ForwardB(ForwardB)
    );

    // Identificador para invertir el comportamiento del BNE
    wire idex_is_bne = (idex_ALUOp == 3'b110);

    //Evaluar el salto en la etapa EX
    assign result = aluResult;
    assign Branch_out = idex_Branch;
    
    // Si es BNE, el salto se da cuando Zero es 0. Si es BEQ, cuando es 1.
    assign Zero_out = idex_is_bne ? ~aluZero : aluZero;
    
    assign SignExt_out = idex_imm;
    assign PC4_Branch_out = idex_pc4; // Mandamos el PC correcto al MIPS_TM
    
    assign Jump_out = Jump;
    assign JumpTarget_out = instruction[25:0];
endmodule