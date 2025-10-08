// computer.v — ENTREGA FINAL
module computer(input wire clk);
  wire [6:0] pc_out;
  wire [14:0] im_out;
  wire pc_load;
  pc PC(.clk(clk), .load(pc_load), .new_value(im_out[6:0]), .pc(pc_out));
  instruction_memory IM(.address(pc_out), .out(im_out));
  wire [6:0] opcode  = im_out[14:8];
  wire [7:0] literal = im_out[7:0];
  wire [7:0] regA_out, regB_out;
  wire [7:0] alu_out, data_out;
  wire loadA, loadB, mem_write, mem_read, use_mem_addr, use_mem_data, mem_src;
  wire [2:0] alu_s;
  wire [1:0] src_sel, dst_sel, wb_sel;
  wire use_lit;
  wire z, n, c, v;

  control_unit CU(
    .opcode(opcode),
    .Z(z), .N(n), .C(c), .V(v),
    .loadA(loadA), .loadB(loadB),
    .mem_write(mem_write), .mem_read(mem_read),
    .pc_load(pc_load),
    .alu_s(alu_s), .src_sel(src_sel),
    .dst_sel(dst_sel), .wb_sel(wb_sel),
    .use_lit(use_lit), .use_mem_addr(use_mem_addr),
    .use_mem_data(use_mem_data), .mem_src(mem_src)
  );

  // --- Operandos ALU ---
  wire is_not = (opcode >= 7'b0010100) && (opcode <= 7'b0010111);
  wire is_shl = (opcode >= 7'b0011100) && (opcode <= 7'b0011111);
  wire is_shr = (opcode >= 7'b0100000) && (opcode <= 7'b0100011);
  wire is_unary = is_not || is_shl || is_shr;
  wire is_sub = (opcode >= 7'b0001000) && (opcode <= 7'b0001011);
  wire is_inc = (opcode == 7'b0100100);

  wire [7:0] alu_a_normal = (dst_sel == 2'b00) ? regA_out : regB_out;
  wire [7:0] alu_b_normal = 
      use_mem_data ? data_out :
      use_lit ? literal :
      (src_sel == 2'b00) ? regB_out :
      (src_sel == 2'b01) ? regA_out : 8'h00;

  wire [7:0] alu_a_sub = regA_out;
  wire [7:0] alu_b_sub = use_mem_data ? data_out : (use_lit ? literal : regB_out);
  wire [7:0] alu_a_unary = (src_sel == 2'b00) ? regB_out : regA_out;
  wire [7:0] alu_a_inc = regB_out;

  wire [7:0] alu_a = 
      is_sub     ? alu_a_sub :
      is_unary   ? alu_a_unary :
      is_inc     ? alu_a_inc :
                   alu_a_normal;
  wire [7:0] alu_b = 
      is_sub     ? alu_b_sub :
      is_unary   ? 8'h00 :
      is_inc     ? 8'h01 :
                   alu_b_normal;

  wire z_in, n_in, c_in, v_in;
  alu ALU(.a(alu_a), .b(alu_b), .s(alu_s),
          .out(alu_out), .z(z_in), .n(n_in), .c(c_in), .v(v_in));

  status_register SR(
    .clk(clk),
    .z_in(z_in), .n_in(n_in), .c_in(c_in), .v_in(v_in),
    .z(z), .n(n), .c(c), .v(v)
  );

  // Dirección de memoria
  wire [7:0] mem_addr = use_mem_addr ? regB_out : literal;
  wire [7:0] mem_data_in = mem_src ? regB_out : regA_out;
  data_memory DM(
    .address(mem_addr),
    .data_in(mem_data_in),
    .data_out(data_out),
    .write_enable(mem_write),
    .clk(clk)
  );

  // Write-back
  wire [7:0] wb_data_A =
      (wb_sel == 2'b01) ? literal :
      (wb_sel == 2'b10) ? data_out :
      (wb_sel == 2'b11) ? regB_out :
                          alu_out;
  wire [7:0] wb_data_B =
      (wb_sel == 2'b01) ? literal :
      (wb_sel == 2'b10) ? data_out :
      (wb_sel == 2'b11) ? regA_out :
                          alu_out;

  register regA(.clk(clk), .data(wb_data_A), .load(loadA), .out(regA_out));
  register regB(.clk(clk), .data(wb_data_B), .load(loadB), .out(regB_out));
endmodule