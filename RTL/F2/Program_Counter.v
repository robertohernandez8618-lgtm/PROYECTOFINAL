
module PC (
    input clk,
    input reset,
    input [31:0] next_pc,      // MIPS_TM le dira a donde ir	
    output reg [31:0] pc_out
);
    always @(posedge clk or posedge reset) begin
        if (reset)
            pc_out <= 32'b0;
        else
            pc_out <= next_pc; 
    end
endmodule