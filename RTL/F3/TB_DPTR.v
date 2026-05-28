`timescale 1ns / 1ps
module TB_DPTR;
    reg clk;
    reg reset;
    wire [31:0] result;

    MIPS_TM tm(clk, reset, result);

    //10 unidades de tiempo para reloj
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end
	
	always @(posedge clk) begin//somo para monitorear
		if(!reset) begin
			$display(
			"PC=%d Instr=%h RegWrite=%b writeReg=%d writeData=%d",
			tm.pc_actual,
			tm.ifid_instr,
			tm.dp.memwb_RegWrite,
			tm.dp.memwb_writeReg,
			tm.dp.write_data_in
			);
		end
	end
	
	always @(posedge clk) begin//monitor x2

		$display(
		"ALUResult=%d MemData=%d dir=%d",
		tm.dp.exmem_aluResult,
		tm.dp.mem_data_out,
		tm.dp.exmem_aluResult >> 2
		);

	end

    initial begin
        reset = 1;
        #10;
        //para cargar la memodria de datos con arreglo desordenado
		//utilizamos 45 en la busqueda binaria, para caso de exito hay que agregarlo
        tm.dp.dmem.MEM[0] = 32'd80;
        tm.dp.dmem.MEM[1] = 32'd20;
        tm.dp.dmem.MEM[2] = 32'd60;
        tm.dp.dmem.MEM[3] = 32'd40;
        tm.dp.dmem.MEM[4] = 32'd100;
        tm.dp.dmem.MEM[5] = 32'd5;
        tm.dp.dmem.MEM[6] = 32'd15;
        tm.dp.dmem.MEM[7] = 32'd45;//insertar para 7
        tm.dp.dmem.MEM[8] = 32'd25;
        tm.dp.dmem.MEM[9] = 32'd30;  // (El arreglo tiene n=10)

        tm.dp.BR.regs[0] = 32'd0;

        #10;
        reset = 0; //activa el program counter

        $display("Ejecutando Bubble sort y Busqueda Binaria...");

        // necesitamos darle suficiente tiempo para que complete los bucles.
        #200000; 

        $display("Simulacion finalizada. Revisa el registro $v0 (regs[2]) para el resultado.");
        $stop;
    end
endmodule

