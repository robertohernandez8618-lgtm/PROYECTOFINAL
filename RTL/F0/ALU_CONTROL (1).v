module alu_ctrl (
    input  wire [2:0] aluOp, 
    input  wire [5:0] fnc,  
    output reg  [3:0] sel    
);

    always @(*) begin
        sel = 4'b0000; 

     
        if (aluOp == 3'b010) begin 
            case (fnc) // 
                6'b100000: sel = 4'b0000; 
                6'b100010: sel = 4'b0001; 
                6'b100100: sel = 4'b0011; 
                6'b100101: sel = 4'b0010; 
                6'b101010: sel = 4'b0100; 
            endcase
        end
    end
endmodule
