module alu(a, b, s, out);
   input [7:0] a, b;
   input [2:0] s;          // 3 bits pa’ meter 8 operaciones, bien apretaditas
   output [7:0] out;

   reg [7:0] out;

   // pa’ no andar arriando la lista de sensibilidad a pura rienda.
   always @* begin
	   case (s)
		   3'b000: out = a + b;   // ADD  -> arre caballito
		   3'b001: out = a - b;   // SUB  -> pa’ atrás con dignidad
		   3'b010: out = a & b;   // AND  -> yunta bien junta
		   3'b011: out = a | b;   // OR   -> juntamos las veredas
		   3'b100: out = a ^ b;   // XOR  -> picardía
		   3'b101: out = ~a;      // NOT A -> damos vuelta el poncho
		   3'b110: out = a << 1;  // SHL A -> corrío pa’ la izquierda
		   3'b111: out = a >> 1;  // SHR A -> corrío pa’ la derecha
		   default: out = 8'h00;  // CAMBIO: por si el potro se desboca con un s distinto.
	   endcase
   end
endmodule
