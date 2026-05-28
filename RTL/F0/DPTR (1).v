module dptr (
    input  wire [31:0] instruccion 
);

    wire [5:0] opcode = instruccion[31:26]; 
    wire [4:0] rs     = instruccion[25:21]; 
    wire [4:0] rt     = instruccion[20:16]; 
    wire [4:0] rd     = instruccion[15:11]; 
    wire [4:0] shamt  = instruccion[10:6];  
    wire [5:0] funct  = instruccion[5:0];   

    //cables para el modulo 
    wire       memToReg;
    wire       memToWrite;
    wire       memToRead;
    wire [2:0] aluOp;
    wire       regWrite;
    wire [3:0] alu_sel; 
    
    wire [31:0] dato_leido1; 
    wire [31:0] dato_leido2; 
    wire [31:0] resultado_alu; 
    wire [31:0] dato_memoria;     // es lo que sale de la memoria de datos
    wire [31:0] dato_escritura;   // es lo que sale del mux y entra al br


    u_control UC (
        .op(opcode),             
        .memToReg(memToReg),    
        .memToWrite(memToWrite),
        .memToRead(memToRead),
        .aluOp(aluOp),
        .regWrite(regWrite)
    );
    

    alu_ctrl ALU_C (
        .aluOp(aluOp),          
        .fnc(funct),             
        .sel(alu_sel)            
    );

   
    BR BancoReg (
        .WE(regWrite),        
        .AR1(rs), 
        .AR2(rt), 
        .AW(rd), 
        .DW(dato_escritura),     
        .DR1(dato_leido1), 
        .DR2(dato_leido2)
    );

  
    ALU_MIPS ALU_Datapath (
        .A(dato_leido1), 
        .B(dato_leido2), 
        .Sel(alu_sel), 
        .R(resultado_alu)
    );


    memoria MemDatos (
        .dir(resultado_alu[4:0]),
        .Dsalida(dato_memoria)
    );

    
    mux2a1 MUX_Escritura (
        .in0(resultado_alu),     
        .in1(dato_memoria),     
        .sel(memToReg),         
        .out(dato_escritura)    
    );

endmodule