module TB_DPTR;
    reg clk;
    reg reset;
    wire [31:0] result;

    MIPS_TM tm(clk, reset, result);

    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    initial begin
	reset = 1;
	#1;

	tm.dp.BR.regs[8]  = 32'd20;
	tm.dp.BR.regs[9]  = 32'd40;
	tm.dp.BR.regs[10]  = 32'd60;
	tm.dp.BR.regs[11]  = 32'd80;
	tm.dp.BR.regs[12]  = 32'd5;
	tm.dp.BR.regs[13]  = 32'd15;
	tm.dp.BR.regs[17] = 32'd100;
        tm.dp.BR.regs[18] = 32'd50;
        tm.dp.BR.regs[19] = 32'd25;
        tm.dp.BR.regs[20] = 32'd30;
        tm.dp.BR.regs[21] = 32'd10;
    
        tm.dp.BR.regs[0]  = 32'd0;

	#9;
	reset = 0;

	$display("Ejecutando Archivo .bin");

	#150;

	$display("Simulacion finalizada");

        $stop;
    end
endmodule


