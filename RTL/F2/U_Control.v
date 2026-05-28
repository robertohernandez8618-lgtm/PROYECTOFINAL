
module U_Control(
    input [5:0] op,
    input [5:0] funct,
    // Señales fase 2
    output reg RegDst,
    output reg ALUSrc,
    output reg Branch,
    // fase 1
    output reg memToReg,
    output reg memToWrite,
    output reg memToRead,
    output reg [2:0] AluOP, 
    output reg RegWrite
);

always@(*) begin 
    // Valores por defecto 
    RegDst = 1'b0; ALUSrc = 1'b0; Branch = 1'b0;
    RegWrite = 1'b0; AluOP = 3'b000; memToRead = 1'b0; 
    memToWrite = 1'b0; memToReg = 1'b0;

    case (op)
        // TIPO R
        6'b000000: begin
            RegDst = 1'b1;     // Destino es rd 
            ALUSrc = 1'b0;     
            AluOP  = 3'b010;   // Código para ir al case(funct)
            
            if(funct == 6'b110100 || funct == 6'b110000) // para teq y tge
                RegWrite = 1'b0;
            else
                RegWrite = 1'b1;
        end

        // LW (Load Word)
        6'b100011: begin
            RegDst = 1'b0;     
            ALUSrc = 1'b1;     
            memToReg = 1'b1;  // Viene de Memoria
            RegWrite = 1'b1;   
            memToRead = 1'b1;  
            AluOP = 3'b000;   // Suma
        end
        
        // SW (Store Word)
        6'b101011: begin
            ALUSrc = 1'b1;     
            memToWrite = 1'b1; // Escribe en Memoria
            AluOP = 3'b000;   // Suma
        end
        
        // BEQ (Branch if Equal)
        6'b000100: begin
            ALUSrc = 1'b0;     
            Branch = 1'b1;    // Enciende el salto
            AluOP = 3'b001;   // Resta para comparar
        end

        // ADDI 
        6'b001000: begin
            RegDst = 1'b0; 
            ALUSrc = 1'b1; 
            RegWrite = 1'b1; 
            AluOP = 3'b000;   // ALUControl hará SUMA
        end

        // ANDI 
        6'b001100: begin
            RegDst = 1'b0; 
            ALUSrc = 1'b1; 
            RegWrite = 1'b1; 
            AluOP = 3'b011;   // ALUControl hará AND
        end

        // ORI 
        6'b001101: begin
            RegDst = 1'b0; 
            ALUSrc = 1'b1; 
            RegWrite = 1'b1; 
            AluOP = 3'b100;   // ALUControl hará OR
        end

        // SLTI 
        6'b001010: begin
            RegDst = 1'b0; 
            ALUSrc = 1'b1; 
            RegWrite = 1'b1; 
            AluOP = 3'b101;   
        end

        6'b001001: begin
            RegDst = 1'b0; 
            ALUSrc = 1'b1; 
            RegWrite = 1'b1; 
            AluOP = 3'b001;   // ALUControl hará RESTA
        end

    endcase 
end
endmodule