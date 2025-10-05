// instruction_memory.v
// 128 palabras de 15 bits: [14:8]=opcode (7b), [7:0]=literal (8b)
module instruction_memory(address, out);
  input  wire [6:0]  address;
  output wire [14:0] out;

  // 128 x 15-bit
  reg [14:0] mem [0:127];

  // OJO: no cargamos aquí; el testbench hace: $readmemb("im.dat", Comp.IM.mem)
  // Si quieres soporte autónomo, puedes descomentar:
  // initial $readmemb("im.dat", mem);

  assign out = mem[address];
endmodule
