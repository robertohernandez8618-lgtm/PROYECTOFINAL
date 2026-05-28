module Mem_I(
	input [31:0] dir,
	output reg [31:0] DSalida
);

reg [7:0]MEM[0:1023];

integer i;

initial begin
    for(i=0;i<1024;i=i+1)
        MEM[i]=0;
		$readmemb("DIOS.txt", MEM);//DIOS.txt
	end

always @*
	begin
		DSalida = {MEM[dir],MEM[dir+1],MEM[dir+2],MEM[dir+3]};
	end
endmodule
