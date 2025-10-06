// data_memory.v
// Memoria de datos de 256 bytes, direccionable por 8 bits.
// Se carga desde mem.dat al iniciar la simulación.

module data_memory(address, data_in, data_out, write_enable, clk);
  input  wire [7:0] address;
  input  wire [7:0] data_in;
  input  wire       write_enable;
  input  wire       clk;
  output wire [7:0] data_out;

  reg [7:0] mem [0:255];

  // Lectura combinacional
  assign data_out = mem[address];

  // Escritura en flanco positivo del reloj
  always @(posedge clk) begin
    if (write_enable)
      mem[address] <= data_in;
  end

  // Carga inicial desde archivo (si existe)
  initial begin
    $readmemb("mem.dat", mem);
  end
endmodule
