module register(clk, data, load, out);
   input clk, load;
   input [7:0] data;
   output [7:0] out;

   // saque los 'wire' inutiles; el 'input' ya viene como wire.
   // wire         clk, load;
   // wire [7:0]   data;

   reg [7:0]    out; // Queda tal cual, reg de 8 bits, maceteado pa' aguantar.

   initial begin
	   out = 0;     // Partimos en cero, como potro domao con calma.
   end

   always @(posedge clk) begin
	   if (load) begin
		   out <= data; // Cuando dan la orden, cargamos no más; derechito y sin maña.
	   end
   end
endmodule
