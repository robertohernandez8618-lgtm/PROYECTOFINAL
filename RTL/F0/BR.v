module BR(
    input  wire       WE,   // Write Enable (1 = Escribir, 0 = Solo leer)
    input  wire [4:0] AR1,  // Dirección de lectura 1
    input  wire [4:0] AR2,  // Dirección de lectura 2
    input  wire [4:0] AW,   // Dirección de escritura
    input  wire [31:0] DW,   // Dato a escribir 
    output reg  [31:0] DR1,  // Dato leído 1
    output reg  [31:0] DR2   // Dato leído 2
);

    reg [31:0] mem [0:31];

    initial begin
        $readmemb("nuevo.txt", mem);
    end

    always @* begin

        DR1 = mem[AR1]; 
        DR2 = mem[AR2]; 

        if (WE) begin
            mem[AW] = DW; 
        end
    end

endmodule
