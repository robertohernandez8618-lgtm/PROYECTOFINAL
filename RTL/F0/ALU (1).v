module ALU_MIPS (input [31:0]A, input [31:0]B, input [3:0]Sel, output [31:0] R);
wire [31:0]c1;
wire [31:0]c2;
wire [31:0]c3;
wire [31:0]c4;
wire [31:0]c5;
s32_comp suma(.so1(A), .so2(B), .rs(c1));
r32_comp resta(.ro1(A), .ro2(B), .xr(c2));
or32_comp _or(.oo1(A), .oo2(B), .ro(c3) );
and32_comp _and(.ao1(A), .ao2(B), .ar(c4) );
slt32 selector(.slto1(A), .slto2(B), .rslt(c5) );
mux5a1 mux(.suma(c1), .resta(c2), ._or(c3), ._and(c4), .slt(c5), .ALUctl(Sel), .R(R));
endmodule

