
module MIPS_TM (
    input clk,
    input reset,
    output [31:0] out_result
);
    // Cables del PC
    wire [31:0] pc_actual;
    wire [31:0] pc_siguiente;
    wire [31:0] pc_mas_4;
    wire [31:0] pc_branch;
    
    // Cables de instrucciones y control
    wire [31:0] instr_to_dp;
    wire [31:0] ifid_instr;
    wire [31:0] ifid_pc4;
    wire branch_sig, zero_sig, pcsource;
    wire [31:0] sign_ext_val;

    PC pc1(
        .clk(clk), 
        .reset(reset), 
        .next_pc(pc_siguiente), // Recibe la decisión del Multiplexor
        .pc_out(pc_actual)
    );

    Mem_I memi(
        .dir(pc_actual), 
        .DSalida(instr_to_dp)
    );

    BufferInstr ifid(
    .clk(clk),
    .reset(reset),

    .instr_in(instr_to_dp),
    .pc4_in(pc_mas_4),

    .instr_out(ifid_instr),
    .pc4_out(ifid_pc4)
     );

    DPTR dp(
        .clk(clk), 
        .instruction(ifid_instr), 
        .result(out_result),
        .Branch_out(branch_sig), 
        .Zero_out(zero_sig), 
        .SignExt_out(sign_ext_val)
    );

    // Sumador 1: PC + 4 (Avanza a la siguiente instrucción normal)
    assign pc_mas_4 = pc_actual + 32'd4;

    // Sumador 2: Destino del Branch 
    // MIPS desplaza el inmediato 2 bits a la izquierda (equivale a multiplicar por 4)
    assign pc_branch = pc_mas_4 + (sign_ext_val << 2);

    // Compuerta AND: ¿Tenemos instrucción BEQ y los registros son iguales?
    assign pcsource = branch_sig & zero_sig;

    // Multiplexor del PC: Si pcsource es 1, salta; si es 0, avanza normal.
    assign pc_siguiente = pcsource ? pc_branch : pc_mas_4;

endmodule