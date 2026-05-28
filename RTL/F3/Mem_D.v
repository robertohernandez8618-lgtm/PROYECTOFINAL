module Mem_D(
    input clk,
    input MemWrite,       //1 para escribir, 0 para leer
    input [31:0] dir,
    input [31:0] DEntrada,
	output reg [31:0] DSalida
);

    reg [31:0] MEM [0:255];

    integer i;

    initial begin
    for(i = 0; i < 256; i = i + 1)
        MEM[i] = 32'b0;
    end

	//divide dir entre 4
	always @(*) begin
		if (^dir === 1'bx)
			DSalida = 32'b0;
		else
			DSalida = MEM[(dir >> 2) & 8'hFF];
	end

    // divide la dirección entre 4
    always @(posedge clk)
    begin
        if (MemWrite) begin
            MEM[(dir >> 2) & 8'hFF] <= DEntrada;
        end
    end
endmodule

