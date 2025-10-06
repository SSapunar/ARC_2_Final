// computer.v — versión final
// Integra todos los módulos del computador básico de 8 bits.

module computer(clk);
  input wire clk;

  // PC e Instruction Memory
  wire [6:0] pc_out;
  wire [14:0] im_out;
  pc PC(.clk(clk), .load(pc_load), .new_value(im_out[6:0]), .pc(pc_out));
  instruction_memory IM(.address(pc_out), .out(im_out));

  wire [6:0] opcode  = im_out[14:8];
  wire [7:0] literal = im_out[7:0];

  // Registros
  wire [7:0] regA_out, regB_out;
  wire [7:0] alu_out, data_out;

  // Señales de control
  wire loadA, loadB, mem_write, pc_load, use_lit;
  wire [2:0] alu_s;
  wire [1:0] src_sel, dst_sel, wb_sel;

  // Banderas
  wire z, n, c, v;

  // Unidad de control
  control_unit CU(.opcode(opcode), .Z(z), .N(n), .C(c), .V(v),
                  .loadA(loadA), .loadB(loadB),
                  .mem_write(mem_write), .pc_load(pc_load),
                  .alu_s(alu_s), .src_sel(src_sel),
                  .dst_sel(dst_sel), .wb_sel(wb_sel),
                  .use_lit(use_lit));

  // Fuente de datos a la ALU
  wire [7:0] alu_a = (dst_sel == 2'b00) ? regA_out : regB_out;
  wire [7:0] alu_b = use_lit ? literal :
                     (src_sel == 2'b00) ? regB_out :
                     (src_sel == 2'b01) ? regA_out : data_out;

  // ALU con banderas
  alu ALU(.a(alu_a), .b(alu_b), .s(alu_s),
          .out(alu_out), .z(z_in), .n(n_in), .c(c_in), .v(v_in));

  // Status Register
  status_register SR(.clk(clk),
                     .z_in(z_in), .n_in(n_in), .c_in(c_in), .v_in(v_in),
                     .z(z), .n(n), .c(c), .v(v));

  // Data Memory
  data_memory DM(.address(literal), .data_in(regA_out),
                 .data_out(data_out), .write_enable(mem_write),
                 .clk(clk));

  // Write-back (ALU, literal o memoria)
  wire [7:0] wb_data =
      (wb_sel == 2'b01) ? literal :
      (wb_sel == 2'b10) ? data_out :
                          alu_out;

  register regA(.clk(clk), .data(wb_data), .load(loadA), .out(regA_out));
  register regB(.clk(clk), .data(wb_data), .load(loadB), .out(regB_out));
endmodule
