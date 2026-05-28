module memoria(input [4:0]dir,
output [31:0]Dsalida);

reg [31:0]mem1[0:31];
reg [31:0]mem2[0:31];
reg [31:0]mem3[0:31];
initial
begin
mem3[0] = 32'd5;
mem3[1] = 32'd8;
mem3[1] = 32'd64;
end

assign Dsalida = mem3[dir];
always @*
begin

end
endmodule 

