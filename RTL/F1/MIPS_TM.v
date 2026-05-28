module MIPS_TM (
    input clk,
    input reset,
    output [31:0] out_result
);
    wire [31:0] pc_to_mem;
    wire [31:0] instr_to_dp;

    PC pc1(clk, reset, pc_to_mem);
    Mem_I memi(pc_to_mem, instr_to_dp);
    DPTR dp(clk, instr_to_dp, out_result);
endmodule
