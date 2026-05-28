module SignExtend (
    input [15:0] in,
    output [31:0] out
);
    // Replica el bit de signo (el bit 15) 16 veces hacia la izquierda
    assign out = {{16{in[15]}}, in};
endmodule