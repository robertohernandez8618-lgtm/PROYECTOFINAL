module BancoReg (
    input clk,
    input RegWrite,
    input [4:0] rs, rt, rd,
    input [31:0] writeData,
    output [31:0] readData1, readData2
);

reg [31:0] regs [0:31];

//inicializar para evitar el error
integer i;
initial begin
    for (i = 0; i < 32; i = i + 1) begin
        regs[i] = 32'b0;
    end
end

    assign readData1 = regs[rs];
    assign readData2 = regs[rt];

    always @(posedge clk) begin
    if (RegWrite && rd != 0)
        regs[rd] <= writeData;
end

endmodule


