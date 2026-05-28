module ALU (
    input [31:0] A, B,
    input [4:0] shamt, //para sra y srl
    input [3:0] ALUCtrl,
    output reg [31:0] Result,
    output reg Exception //senal de teq y tge
);
    always @(*) begin
        Result = 0;
        Exception = 0;
        case (ALUCtrl)
            4'b0010: Result = A + B;          // add
            4'b0110: Result = A - B;          // sub
            4'b0000: Result = A & B;          // and
            4'b0001: Result = A | B;          //or
            4'b0111: Result = (A < B) ? 1:0;  // slt
            4'b0011: Result = A ^ B;          // xor
            4'b1000: Result = $signed(B) >>> shamt;    // sra
            4'b1001: Result = B >> shamt;     // srl
            4'b1100: Exception = (A == B);    // teq
            4'b1101: Exception = (A >= B);    // tge
            4'b1111: Result = 0;              // nop
        endcase
    end
endmodule

