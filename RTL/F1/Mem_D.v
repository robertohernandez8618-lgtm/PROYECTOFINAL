module Mem_D(
    input clk,
    input MemWrite,       //1 para escribir, 0 para leer
    input [31:0] dir,
    input [31:0] DEntrada,    output reg [31:0] DSalida
);

    reg [31:0] MEM [0:255];

    always @*
    begin
        DSalida = MEM[dir];
    end

    always @(posedge clk)
    begin
        if (MemWrite) begin
            MEM[dir] <= DEntrada;
        end
    end

endmodule

