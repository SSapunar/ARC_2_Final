module mux2(e0, e1, c, out);
   input  [7:0] e0, e1;
   input        c;
   output [7:0] out;
   
   // que no se nos cruce el caballo 'alu' en este potrero.
   // Este archivo DEBE tener solo el módulo mux2, ni un 'alu' escondido.

   reg [7:0] out;

   always @(e0, e1, c) begin
     case (c)
       1'b0: out = e0; // bien tipiado pa' que no patalee
       1'b1: out = e1;
     endcase
   end
endmodule
