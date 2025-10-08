// control_unit.v — ENTREGA FINAL
module control_unit(
    input  wire [6:0] opcode,
    input  wire Z, N, C, V,
    output reg loadA, loadB,
    output reg mem_write, mem_read,
    output reg pc_load,
    output reg [2:0] alu_s,
    output reg [1:0] src_sel, dst_sel, wb_sel,
    output reg use_lit, use_mem_addr, use_mem_data, mem_src
);
  always @* begin
    loadA = 0; loadB = 0;
    mem_write = 0; mem_read = 0; pc_load = 0;
    use_lit = 0; use_mem_addr = 0; use_mem_data = 0; mem_src = 0;
    alu_s = 3'b000;
    src_sel = 2'b00;
    dst_sel = 2'b00;
    wb_sel = 2'b00;

    case (opcode)
      // ===== Entrega parcial =====
      7'b0000000: begin loadA = 1; wb_sel = 2'b11; end // MOV A,B
      7'b0000001: begin loadB = 1; wb_sel = 2'b10; end // MOV B,A
      7'b0000010: begin loadA = 1; use_lit = 1; wb_sel = 2'b01; end // MOV A,lit
      7'b0000011: begin loadB = 1; use_lit = 1; wb_sel = 2'b01; end // MOV B,lit
      7'b0000100: begin loadA=1; alu_s=3'b000; src_sel=2'b00; dst_sel=2'b00; wb_sel=2'b00; end // ADD A,B
      7'b0000101: begin loadB=1; alu_s=3'b000; src_sel=2'b01; dst_sel=2'b01; wb_sel=2'b00; end // ADD B,A
      7'b0000110: begin loadA=1; alu_s=3'b000; use_lit=1; wb_sel=2'b00; end
      7'b0000111: begin loadB=1; alu_s=3'b000; use_lit=1; dst_sel=2'b01; wb_sel=2'b00; end
      7'b0001000: begin loadA=1; alu_s=3'b001; use_lit=0; wb_sel=2'b00; end // SUB A,B
      7'b0001001: begin loadB=1; alu_s=3'b001; use_lit=0; wb_sel=2'b00; end // SUB B,A
      7'b0001010: begin loadA=1; alu_s=3'b001; use_lit=1; wb_sel=2'b00; end
      7'b0001011: begin loadB=1; alu_s=3'b001; use_lit=1; wb_sel=2'b00; end
      7'b0001100: begin loadA=1; alu_s=3'b010; src_sel=2'b00; dst_sel=2'b00; wb_sel=2'b00; end // AND A,B
      7'b0001101: begin loadB=1; alu_s=3'b010; src_sel=2'b01; dst_sel=2'b01; wb_sel=2'b00; end // AND B,A
      7'b0001110: begin loadA=1; alu_s=3'b010; use_lit=1; wb_sel=2'b00; end
      7'b0001111: begin loadB=1; alu_s=3'b010; use_lit=1; dst_sel=2'b01; wb_sel=2'b00; end
      7'b0010000: begin loadA=1; alu_s=3'b011; src_sel=2'b00; dst_sel=2'b00; wb_sel=2'b00; end // OR A,B
      7'b0010001: begin loadB=1; alu_s=3'b011; src_sel=2'b01; dst_sel=2'b01; wb_sel=2'b00; end // OR B,A
      7'b0010010: begin loadA=1; alu_s=3'b011; use_lit=1; wb_sel=2'b00; end
      7'b0010011: begin loadB=1; alu_s=3'b011; use_lit=1; dst_sel=2'b01; wb_sel=2'b00; end
      7'b0010100: begin loadA=1; alu_s=3'b101; src_sel=2'b01; wb_sel=2'b00; end // NOT A,A
      7'b0010101: begin loadA=1; alu_s=3'b101; src_sel=2'b00; wb_sel=2'b00; end // NOT A,B
      7'b0010110: begin loadB=1; alu_s=3'b101; src_sel=2'b01; wb_sel=2'b00; end // NOT B,A
      7'b0010111: begin loadB=1; alu_s=3'b101; src_sel=2'b00; wb_sel=2'b00; end // NOT B,B
      7'b0011000: begin loadA=1; alu_s=3'b100; src_sel=2'b00; dst_sel=2'b00; wb_sel=2'b00; end // XOR A,B
      7'b0011001: begin loadB=1; alu_s=3'b100; src_sel=2'b01; dst_sel=2'b01; wb_sel=2'b00; end // XOR B,A
      7'b0011010: begin loadA=1; alu_s=3'b100; use_lit=1; wb_sel=2'b00; end
      7'b0011011: begin loadB=1; alu_s=3'b100; use_lit=1; dst_sel=2'b01; wb_sel=2'b00; end
      7'b0011100: begin loadA=1; alu_s=3'b110; src_sel=2'b01; wb_sel=2'b00; end // SHL A,A
      7'b0011101: begin loadA=1; alu_s=3'b110; src_sel=2'b00; wb_sel=2'b00; end // SHL A,B
      7'b0011110: begin loadB=1; alu_s=3'b110; src_sel=2'b01; wb_sel=2'b00; end // SHL B,A
      7'b0011111: begin loadB=1; alu_s=3'b110; src_sel=2'b00; wb_sel=2'b00; end // SHL B,B
      7'b0100000: begin loadA=1; alu_s=3'b111; src_sel=2'b01; wb_sel=2'b00; end // SHR A,A
      7'b0100001: begin loadA=1; alu_s=3'b111; src_sel=2'b00; wb_sel=2'b00; end // SHR A,B
      7'b0100010: begin loadB=1; alu_s=3'b111; src_sel=2'b01; wb_sel=2'b00; end // SHR B,A
      7'b0100011: begin loadB=1; alu_s=3'b111; src_sel=2'b00; wb_sel=2'b00; end // SHR B,B
      7'b0100100: begin loadB=1; alu_s=3'b000; wb_sel=2'b00; end // INC B

      // ===== Entrega FINAL: Memoria =====
      7'b0100101: begin loadA=1; use_lit=1; mem_read=1; wb_sel=2'b10; end // MOV A, (Dir)
      7'b0100110: begin loadB=1; use_lit=1; mem_read=1; wb_sel=2'b10; end // MOV B, (Dir)
      7'b0100111: begin mem_write=1; use_lit=1; mem_src=0; end // MOV (Dir), A
      7'b0101000: begin mem_write=1; use_lit=1; mem_src=1; end // MOV (Dir), B
      7'b0101001: begin loadA=1; use_mem_addr=1; mem_read=1; wb_sel=2'b10; end // MOV A, (B)
      7'b0101010: begin loadB=1; use_mem_addr=1; mem_read=1; wb_sel=2'b10; end // MOV B, (B)
      7'b0101011: begin mem_write=1; use_mem_addr=1; mem_src=0; end // MOV (B), A
      7'b0101100: begin loadA=1; alu_s=3'b000; use_lit=1; use_mem_data=1; mem_read=1; wb_sel=2'b00; end // ADD A, (Dir)
      7'b0101101: begin loadB=1; alu_s=3'b000; use_lit=1; use_mem_data=1; mem_read=1; wb_sel=2'b00; end // ADD B, (Dir)
      7'b0101110: begin loadA=1; alu_s=3'b000; use_mem_addr=1; use_mem_data=1; mem_read=1; wb_sel=2'b00; end // ADD A, (B)

      // ===== Saltos =====
      7'b1001101: begin alu_s=3'b001; src_sel=2'b00; dst_sel=2'b00; wb_sel=2'b00; end // CMP A,B
      7'b1001110: begin alu_s=3'b001; use_lit=1; wb_sel=2'b00; end // CMP A,Lit
      7'b1001111: begin alu_s=3'b001; use_lit=1; wb_sel=2'b00; end // CMP B,Lit
      7'b1010011: begin pc_load=1; use_lit=1; end // JMP Dir
      7'b1010100: begin if (Z) pc_load=1; use_lit=1; end // JEQ Dir
      default: begin end
    endcase
  end
endmodule