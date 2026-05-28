module ALUControl (
    input [5:0] fnc,
    input [2:0] ALUOp,
    output reg [3:0] Sel
);
    always @(*) begin
        case (ALUOp)
            3'b010: begin
                case (fnc)
                    6'b100000: Sel = 4'b0010; // add
                    6'b100010: Sel = 4'b0110; // sub
                    6'b100100: Sel = 4'b0000; // and
                    6'b100101: Sel = 4'b0001; // or
                    6'b101010: Sel = 4'b0111; // sl
                    6'b100110: Sel = 4'b0011; // xor
                    6'b000000: Sel = 4'b1111; // nop
                    6'b000011: Sel = 4'b1000; // sra
                    6'b000010: Sel = 4'b1001; // srl
                    6'b110100: Sel = 4'b1100; // teq
                    6'b110000: Sel = 4'b1101; // tge
                 default:   Sel = 4'b0000;
                endcase
             end
    	 endcase
    end
endmodule

