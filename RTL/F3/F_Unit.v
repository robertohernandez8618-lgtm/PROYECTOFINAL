//resolves data hazards (ej. Read-After-Write)
module Forwarding_Unit(
    input [4:0] idex_rs,          // Registro rs en etapa EX
    input [4:0] idex_rt,          // Registro rt en etapa EX
    input [4:0] exmem_rd,         // Registro destino en etapa MEM
    input [4:0] memwb_rd,         // Registro destino en etapa WB
    input exmem_RegWrite,         // Decide s MEM va a escribir en registros
    input memwb_RegWrite,         // Si WB va a escribir en registros o no 
    
    output reg [1:0] ForwardA,    // Control para el operando A de la ALU
    output reg [1:0] ForwardB     // Control para el operando B de la ALU
);

    always @* begin
        // Valores por defecto: Usar los datos normales que vienen del Banco de Registros (00)
        ForwardA = 2'b00;
        ForwardB = 2'b00;


        // RIESGOS EN LA ETAPA EX
        // Si la instrucción en MEM va a escribir, el destino no es el registro 0, 
        // y coincide con rs o rt de la instrucción actual en EX:
        if (exmem_RegWrite && (exmem_rd != 5'b0) && (exmem_rd == idex_rs)) begin
            ForwardA = 2'b10; // Adelantar desde la salida de la ALU (EX/MEM)
        end
        
        if (exmem_RegWrite && (exmem_rd != 5'b0) && (exmem_rd == idex_rt)) begin
            ForwardB = 2'b10; // Adelantar desde la salida de la ALU (EX/MEM)
        end


        // RIESGOS EN LA ETAPA MEM (Prioridad Baja)
        // Se evalúa como "else if" o con una condición extra para no pisar un riesgo EX activo
        if (memwb_RegWrite && (memwb_rd != 5'b0) && 
            !(exmem_RegWrite && (exmem_rd != 5'b0) && (exmem_rd == idex_rs)) && 
            (memwb_rd == idex_rs)) begin
            ForwardA = 2'b01; // Adelantar desde la etapa WB (salida del multiplexor MemToReg)
        end

        if (memwb_RegWrite && (memwb_rd != 5'b0) && 
            !(exmem_RegWrite && (exmem_rd != 5'b0) && (exmem_rd == idex_rt)) && 
            (memwb_rd == idex_rt)) begin
            ForwardB = 2'b01; // Adelantar desde la etapa WB (salida del multiplexor MemToReg)
        end
    end

endmodule
