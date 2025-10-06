// control_unit.v — versión compatible con testbench original
// Decodifica el opcode y genera las señales del computador modular final.

module control_unit(
    input  wire [6:0] opcode,
    input  wire Z, N, C, V,     // banderas, sin uso por ahora
    output reg loadA, loadB,
    output reg mem_write, pc_load,
    output reg [2:0] alu_s,
    output reg [1:0] src_sel, dst_sel, wb_sel,
    output reg use_lit
);

  always @* begin
    // valores por defecto
    loadA = 0; loadB = 0;
    mem_write = 0; pc_load = 0;
    use_lit = 0;
    alu_s = 3'b000;     // ADD por defecto
    src_sel = 2'b00;    // B por defecto
    dst_sel = 2'b00;    // A por defecto
    wb_sel = 2'b00;     // ALU

    case (opcode)
      // --- MOV ---
      7'b0000000: begin loadA=1; wb_sel=2'b10; dst_sel=2'b00; end // MOV A,B
      7'b0000001: begin loadB=1; wb_sel=2'b11; dst_sel=2'b01; end // MOV B,A
      7'b0000010: begin loadA=1; wb_sel=2'b01; end                // MOV A,lit
      7'b0000011: begin loadB=1; wb_sel=2'b01; end                // MOV B,lit

      // --- ADD ---
      7'b0000100: begin loadA=1; alu_s=3'b000; src_sel=2'b00; dst_sel=2'b00; end // A=A+B
      7'b0000110: begin loadA=1; alu_s=3'b000; use_lit=1; end // A=A+lit
      7'b0000111: begin loadB=1; alu_s=3'b000; use_lit=1; dst_sel=2'b01; end // B=B+lit

      // --- SUB ---
      7'b0001000: begin loadA=1; alu_s=3'b001; src_sel=2'b00; dst_sel=2'b00; end
      7'b0001001: begin loadB=1; alu_s=3'b001; src_sel=2'b01; dst_sel=2'b01; end
      7'b0001010: begin loadA=1; alu_s=3'b001; use_lit=1; end
      7'b0001011: begin loadB=1; alu_s=3'b001; use_lit=1; dst_sel=2'b01; end

      // --- AND ---
      7'b0001100: begin loadA=1; alu_s=3'b010; src_sel=2'b00; end
      7'b0001101: begin loadB=1; alu_s=3'b010; src_sel=2'b01; dst_sel=2'b01; end
      7'b0001110: begin loadA=1; alu_s=3'b010; use_lit=1; end
      7'b0001111: begin loadB=1; alu_s=3'b010; use_lit=1; dst_sel=2'b01; end

      // --- OR ---
      7'b0010000: begin loadA=1; alu_s=3'b011; src_sel=2'b00; end
      7'b0010001: begin loadB=1; alu_s=3'b011; src_sel=2'b01; dst_sel=2'b01; end
      7'b0010010: begin loadA=1; alu_s=3'b011; use_lit=1; end
      7'b0010011: begin loadB=1; alu_s=3'b011; use_lit=1; dst_sel=2'b01; end

      // --- NOT ---
      7'b0010100: begin loadA=1; alu_s=3'b101; src_sel=2'b01; end // NOT A,A
      7'b0010101: begin loadA=1; alu_s=3'b101; src_sel=2'b00; end // NOT A,B
      7'b0010110: begin loadB=1; alu_s=3'b101; src_sel=2'b01; dst_sel=2'b01; end // NOT B,A
      7'b0010111: begin loadB=1; alu_s=3'b101; src_sel=2'b00; dst_sel=2'b01; end // NOT B,B

      // --- XOR ---
      7'b0011000: begin loadA=1; alu_s=3'b100; src_sel=2'b00; end
      7'b0011001: begin loadB=1; alu_s=3'b100; src_sel=2'b01; dst_sel=2'b01; end
      7'b0011010: begin loadA=1; alu_s=3'b100; use_lit=1; end
      7'b0011011: begin loadB=1; alu_s=3'b100; use_lit=1; dst_sel=2'b01; end

      // --- SHL ---
      7'b0011100: begin loadA=1; alu_s=3'b110; src_sel=2'b01; end // SHL A,A
      7'b0011101: begin loadA=1; alu_s=3'b110; src_sel=2'b00; end // SHL A,B
      7'b0011110: begin loadB=1; alu_s=3'b110; src_sel=2'b01; dst_sel=2'b01; end // SHL B,A
      7'b0011111: begin loadB=1; alu_s=3'b110; src_sel=2'b00; dst_sel=2'b01; end // SHL B,B

      // --- SHR ---
      7'b0100000: begin loadA=1; alu_s=3'b111; src_sel=2'b01; end // SHR A,A
      7'b0100001: begin loadA=1; alu_s=3'b111; src_sel=2'b00; end // SHR A,B
      7'b0100010: begin loadB=1; alu_s=3'b111; src_sel=2'b01; dst_sel=2'b01; end // SHR B,A
      7'b0100011: begin loadB=1; alu_s=3'b111; src_sel=2'b00; dst_sel=2'b01; end // SHR B,B

      // --- INC B ---
      7'b0100100: begin loadB=1; alu_s=3'b000; use_lit=1; dst_sel=2'b01; end // INC B

      default: begin end
    endcase
  end
endmodule
