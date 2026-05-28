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
    wire [31:0] pc_jump;
    
    // Cables de instrucciones y control
    wire [31:0] instr_to_dp;
    wire [31:0] ifid_instr;
    wire [31:0] ifid_pc4;
    wire branch_sig, zero_sig, pcsource;
    wire [31:0] sign_ext_val;
    wire jump_sig;
    wire [25:0] jump_target;
    wire [31:0] idex_pc4_branch; //PARA EL PC EN LA ETAPA EX

    PC pc1(
        .clk(clk), 
        .reset(reset), 
        .next_pc(pc_siguiente), 
        .pc_out(pc_actual)
    );

    Mem_I memi(
        .dir(pc_actual), 
        .DSalida(instr_to_dp)
    );

    BufferInstr ifid(
        .clk(clk),
        .reset(reset),
        .flush(pcsource | jump_sig), //Vacía el buffer si hay salto
        .instr_in(instr_to_dp),
        .pc4_in(pc_mas_4),
        .instr_out(ifid_instr),
        .pc4_out(ifid_pc4)
    );

    DPTR dp(
        .clk(clk),
        .reset(reset),
        .instruction(ifid_instr), 
        .pc4_in(ifid_pc4),            //Manda el PC+4 al DPTR
        .result(out_result),
        .Branch_out(branch_sig), 
        .Zero_out(zero_sig), 
        .SignExt_out(sign_ext_val),
        .PC4_Branch_out(idex_pc4_branch), //Recibe el PC alineado de la etapa EX
        .Jump_out(jump_sig),
        .JumpTarget_out(jump_target)
    );

    // Sumador 1: PC + 4
    assign pc_mas_4 = pc_actual + 32'd4;

    // Sumador 2: Destino del Branch 
    assign pc_branch = idex_pc4_branch + (sign_ext_val << 2);

    // Cálculo de la dirección del Jump
    assign pc_jump = {ifid_pc4[31:28], jump_target, 2'b00};

    // Mux del PC
    assign pc_siguiente = (reset) ? 32'b0 : (jump_sig == 1'b1) ? pc_jump : (pcsource == 1'b1) ? pc_branch : pc_mas_4;

    // Compuerta AND para el Branch (lógica de inversión del BNE ya esta em DPTR)
    assign pcsource = (!reset) ? (branch_sig & zero_sig) : 1'b0;

endmodule