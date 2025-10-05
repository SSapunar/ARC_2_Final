// computer.v
// ISA 15 bits: [14:8]=opcode (7b), [7:0]=literal (8b)
// ALU: s=000 ADD, 001 SUB, 010 AND, 011 OR, 100 XOR, 101 NOT(~a), 110 SHL(a<<1), 111 SHR(a>>1)

module computer(clk, alu_out_bus);
  input  wire clk;
  output wire [7:0] alu_out_bus;

  // PC (7b) e IM (15b)
  wire [6:0]  pc_out_bus;
  wire [14:0] im_out_bus;

  // Registros visibles (mantén estos nombres: regA/regB)
  wire [7:0]  regA_out_bus;
  wire [7:0]  regB_out_bus;

  // Instancias
  pc PC(.clk(clk), .pc(pc_out_bus));
  instruction_memory IM(.address(pc_out_bus), .out(im_out_bus));

  // Campos de instrucción
  wire [6:0] opcode  = im_out_bus[14:8];
  wire [7:0] literal = im_out_bus[7:0];

  // -------- Señales de control --------
  reg loadA, loadB;          // escribe en A / B
  reg dst_is_A;              // 1: destino=A, 0: destino=B
  reg src_is_A;              // 1: fuente=A, 0: fuente=B
  reg src_is_lit;            // 1: usar literal en b
  reg use_src_as_a;          // 1: en unarias, 'a' = fuente (no el destino)
  reg use_const1;            // 1: fuerza b=1 (para INC)
  reg [2:0] alu_s;           // operación ALU

  // write-back selector: 00=ALU, 01=literal, 10=regA, 11=regB
  reg [1:0] wb_sel;

  // -------- Enrutado de operandos hacia ALU --------
  wire [7:0] a_from_dest = dst_is_A ? regA_out_bus : regB_out_bus;
  wire [7:0] a_from_src  = src_is_A ? regA_out_bus : regB_out_bus;
  wire [7:0] alu_a       = use_src_as_a ? a_from_src : a_from_dest;

  wire [7:0] b_src       = src_is_lit ? literal : (src_is_A ? regA_out_bus : regB_out_bus);
  wire [7:0] alu_b       = use_const1 ? 8'h01 : b_src;

  // ALU
  alu ALU(.a(alu_a), .b(alu_b), .s(alu_s), .out(alu_out_bus));

  // Write-back
  wire [7:0] write_bus =
      (wb_sel == 2'b01) ? literal :
      (wb_sel == 2'b10) ? regA_out_bus :
      (wb_sel == 2'b11) ? regB_out_bus :
                          alu_out_bus;  // 00

  // Registros (nombres que mira el testbench)
  register regA(.clk(clk), .data(write_bus), .load(loadA), .out(regA_out_bus));
  register regB(.clk(clk), .data(write_bus), .load(loadB), .out(regB_out_bus));

  // -------- Decoder ----------
  // Mapa de opcodes según im.dat:
  // 0000000 MOV A,B      0000001 MOV B,A
  // 0000010 MOV A,lit    0000011 MOV B,lit
  // 0000100 ADD A,B      0000110 ADD A,lit   0000111 ADD B,lit
  // 0001000 SUB A,B      0001001 SUB B,A     0001010 SUB A,lit  0001011 SUB B,lit
  // 0001100 AND A,B      0001101 AND B,A     0001110 AND A,lit  0001111 AND B,lit
  // 0010000 OR  A,B      0010001 OR  B,A     0010010 OR  A,lit  0010011 OR  B,lit
  // 0010100 NOT A,A      0010101 NOT A,B     0010110 NOT B,A    0010111 NOT B,B
  // 0011000 XOR A,B      0011001 XOR B,A     0011010 XOR A,lit  0011011 XOR B,lit
  // 0011100 SHL A,A      0011101 SHL A,B     0011110 SHL B,A    0011111 SHL B,B
  // 0100000 SHR A,A      0100001 SHR A,B     0100010 SHR B,A    0100011 SHR B,B
  // 0100100 INC B

  always @* begin
    // defaults
    loadA = 1'b0; loadB = 1'b0;
    dst_is_A = 1'b1; src_is_A = 1'b0;
    src_is_lit = 1'b0; use_src_as_a = 1'b0; use_const1 = 1'b0;
    alu_s = 3'b000;     // ADD
    wb_sel = 2'b00;     // ALU

    case (opcode)
      // -------- MOV reg,reg (bypass directo) --------
      7'b0000000: begin // MOV A,B
        dst_is_A = 1'b1; loadA = 1'b1;
        wb_sel = 2'b11;  // write_bus = regB
      end
      7'b0000001: begin // MOV B,A
        dst_is_A = 1'b0; loadB = 1'b1;
        wb_sel = 2'b10;  // write_bus = regA
      end

      // -------- MOV reg,lit --------
      7'b0000010: begin // MOV A,lit
        dst_is_A = 1'b1; loadA = 1'b1;
        wb_sel = 2'b01;  // literal
      end
      7'b0000011: begin // MOV B,lit
        dst_is_A = 1'b0; loadB = 1'b1;
        wb_sel = 2'b01;
      end

      // -------- ADD --------
      7'b0000100: begin // ADD A,B  -> A = A + B
        dst_is_A = 1'b1; loadA = 1'b1;
        src_is_A = 1'b0; // b = B
        alu_s = 3'b000;
      end
      7'b0000110: begin // ADD A,lit
        dst_is_A = 1'b1; loadA = 1'b1;
        src_is_lit = 1'b1;
        alu_s = 3'b000;
      end
      7'b0000111: begin // ADD B,lit
        dst_is_A = 1'b0; loadB = 1'b1;
        src_is_lit = 1'b1;
        alu_s = 3'b000;
      end

      // -------- SUB --------
      7'b0001000: begin // SUB A,B  -> A = A - B
        dst_is_A = 1'b1; loadA = 1'b1;
        src_is_A = 1'b0; // b = B
        alu_s = 3'b001;
      end
      7'b0001001: begin // SUB B,A  -> B = B - A
        dst_is_A = 1'b0; loadB = 1'b1;
        src_is_A = 1'b1; // b = A
        alu_s = 3'b001;
      end
      7'b0001010: begin // SUB A,lit
        dst_is_A = 1'b1; loadA = 1'b1;
        src_is_lit = 1'b1;
        alu_s = 3'b001;
      end
      7'b0001011: begin // SUB B,lit
        dst_is_A = 1'b0; loadB = 1'b1;
        src_is_lit = 1'b1;
        alu_s = 3'b001;
      end

      // -------- AND --------
      7'b0001100: begin // AND A,B
        dst_is_A = 1'b1; loadA = 1'b1; src_is_A=1'b0; alu_s=3'b010;
      end
      7'b0001101: begin // AND B,A
        dst_is_A = 1'b0; loadB = 1'b1; src_is_A=1'b1; alu_s=3'b010;
      end
      7'b0001110: begin // AND A,lit
        dst_is_A = 1'b1; loadA = 1'b1; src_is_lit=1'b1; alu_s=3'b010;
      end
      7'b0001111: begin // AND B,lit
        dst_is_A = 1'b0; loadB = 1'b1; src_is_lit=1'b1; alu_s=3'b010;
      end

      // -------- OR --------
      7'b0010000: begin // OR A,B
        dst_is_A = 1'b1; loadA = 1'b1; src_is_A=1'b0; alu_s=3'b011;
      end
      7'b0010001: begin // OR B,A
        dst_is_A = 1'b0; loadB = 1'b1; src_is_A=1'b1; alu_s=3'b011;
      end
      7'b0010010: begin // OR A,lit
        dst_is_A = 1'b1; loadA = 1'b1; src_is_lit=1'b1; alu_s=3'b011;
      end
      7'b0010011: begin // OR B,lit
        dst_is_A = 1'b0; loadB = 1'b1; src_is_lit=1'b1; alu_s=3'b011;
      end

      // -------- NOT (~a) --------
      7'b0010100: begin // NOT A,A  -> A=~A
        dst_is_A = 1'b1; loadA = 1'b1;
        src_is_A = 1'b1; use_src_as_a = 1'b1; // 'a' = A
        alu_s = 3'b101;
      end
      7'b0010101: begin // NOT A,B  -> A=~B
        dst_is_A = 1'b1; loadA = 1'b1;
        src_is_A = 1'b0; use_src_as_a = 1'b1; // 'a' = B
        alu_s = 3'b101;
      end
      7'b0010110: begin // NOT B,A  -> B=~A
        dst_is_A = 1'b0; loadB = 1'b1;
        src_is_A = 1'b1; use_src_as_a = 1'b1; // 'a' = A
        alu_s = 3'b101;
      end
      7'b0010111: begin // NOT B,B  -> B=~B
        dst_is_A = 1'b0; loadB = 1'b1;
        src_is_A = 1'b0; use_src_as_a = 1'b1; // 'a' = B
        alu_s = 3'b101;
      end

      // -------- XOR --------
      7'b0011000: begin // XOR A,B
        dst_is_A=1'b1; loadA=1'b1; src_is_A=1'b0; alu_s=3'b100;
      end
      7'b0011001: begin // XOR B,A
        dst_is_A=1'b0; loadB=1'b1; src_is_A=1'b1; alu_s=3'b100;
      end
      7'b0011010: begin // XOR A,lit
        dst_is_A=1'b1; loadA=1'b1; src_is_lit=1'b1; alu_s=3'b100;
      end
      7'b0011011: begin // XOR B,lit
        dst_is_A=1'b0; loadB=1'b1; src_is_lit=1'b1; alu_s=3'b100;
      end

      // -------- SHL (a<<1) --------
      7'b0011100: begin // SHL A,A  -> A<<1
        dst_is_A=1'b1; loadA=1'b1; src_is_A=1'b1; use_src_as_a=1'b1; alu_s=3'b110;
      end
      7'b0011101: begin // SHL A,B  -> A = B<<1
        dst_is_A=1'b1; loadA=1'b1; src_is_A=1'b0; use_src_as_a=1'b1; alu_s=3'b110;
      end
      7'b0011110: begin // SHL B,A  -> B = A<<1
        dst_is_A=1'b0; loadB=1'b1; src_is_A=1'b1; use_src_as_a=1'b1; alu_s=3'b110;
      end
      7'b0011111: begin // SHL B,B
        dst_is_A=1'b0; loadB=1'b1; src_is_A=1'b0; use_src_as_a=1'b1; alu_s=3'b110;
      end

      // -------- SHR (a>>1) --------
      7'b0100000: begin // SHR A,A
        dst_is_A=1'b1; loadA=1'b1; src_is_A=1'b1; use_src_as_a=1'b1; alu_s=3'b111;
      end
      7'b0100001: begin // SHR A,B  -> A = B>>1
        dst_is_A=1'b1; loadA=1'b1; src_is_A=1'b0; use_src_as_a=1'b1; alu_s=3'b111;
      end
      7'b0100010: begin // SHR B,A  -> B = A>>1
        dst_is_A=1'b0; loadB=1'b1; src_is_A=1'b1; use_src_as_a=1'b1; alu_s=3'b111;
      end
      7'b0100011: begin // SHR B,B
        dst_is_A=1'b0; loadB=1'b1; src_is_A=1'b0; use_src_as_a=1'b1; alu_s=3'b111;
      end

      // -------- INC B --------
      7'b0100100: begin // INC B -> B = B + 1
        dst_is_A=1'b0; loadB=1'b1;
        use_const1=1'b1;       // b = 1
        alu_s=3'b000;          // ADD
      end

      default: begin
        // NOP
      end
    endcase
  end
endmodule
