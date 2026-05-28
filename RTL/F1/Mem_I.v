module Mem_I(
	input [31:0] dir,
	output reg [31:0] DSalida
);

reg [7:0]MEM[0:255];

initial
	begin
		$readmemb("Binary_Code.bin", MEM);
	end

always @*
	begin
		DSalida = {MEM[dir],MEM[dir+1],MEM[dir+2],MEM[dir+3]};
	end
endmodule

