//FASE 2 DEL PROYECTO
//multiplexor de 5 bits para la entrada del banco de registros write register

module Mux2_1_5 (
    input [4:0] in0, in1,
    input sel,
    output [4:0] out
);
    assign out = sel ? in1 : in0;
endmodule
