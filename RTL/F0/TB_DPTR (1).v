`timescale 1ns/1ns 
module TB_DPTR;


    reg [31:0] r_instruccion;

    // Instanciación del módulo principal
    dptr UUT (
        .instruccion(r_instruccion)
    );

    initial begin

        //la tabla viene en el reporte
        r_instruccion = 32'h012A5820; // ADD $t3, $t1, $t2
        #20;
        r_instruccion = 32'h012A6022; // SUB $t4, $t1, $t2
        #20;
        r_instruccion = 32'h012A6824; // AND $t5, $t1, $t2
        #20;
        r_instruccion = 32'h012A7025; // OR $t6, $t1, $t2
        #20;
        r_instruccion = 32'h012A782A; // SLT $t7, $t1, $t2
        #20;

        r_instruccion = 32'h02119020; // ADD $s2, $s0, $s1
        #20;
        r_instruccion = 32'h02119822; // SUB $s3, $s0, $s1
        #20;
        r_instruccion = 32'h0211A024; // AND $s4, $s0, $s1
        #20;
        r_instruccion = 32'h0211A825; // OR $s5, $s0, $s1
        #20;
        r_instruccion = 32'h0211B02A; // SLT $s6, $s0, $s1
        #20;

        $finish;
    end

endmodule