// alu.v — versión corregida: operaciones unarias usan solo 'a'
module alu(
    input  [7:0] a,      // operando principal (para unarias) o primer operando (para binarias)
    input  [7:0] b,      // segundo operando (solo usado en operaciones binarias)
    input  [2:0] s,      // operación: 000=ADD, 001=SUB, 010=AND, 011=OR, 100=XOR, 101=NOT, 110=SHL, 111=SHR
    output [7:0] out,
    output       z, n, c, v
);

    reg [8:0] result;  // resultado de 9 bits para capturar carry
    reg       carry_out;

    always @(*) begin
        case (s)
            3'b000: begin // ADD
                result = {1'b0, a} + {1'b0, b};
                carry_out = result[8];
            end
            3'b001: begin // SUB
                result = {1'b0, a} - {1'b0, b};
                carry_out = ~result[8]; // carry = no borrow
            end
            3'b010: begin // AND
                result = {1'b0, a & b};
                carry_out = 1'b0;
            end
            3'b011: begin // OR
                result = {1'b0, a | b};
                carry_out = 1'b0;
            end
            3'b100: begin // XOR
                result = {1'b0, a ^ b};
                carry_out = 1'b0;
            end
            3'b101: begin // NOT — usa solo 'a'
                result = {1'b0, ~a};
                carry_out = 1'b0;
            end
            3'b110: begin // SHL — usa solo 'a'
                result = {1'b0, a << 1};
                carry_out = a[7]; // bit desplazado hacia afuera
            end
            3'b111: begin // SHR — usa solo 'a'
                result = {1'b0, a >> 1};
                carry_out = a[0]; // bit desplazado hacia afuera
            end
            default: begin
                result = 9'h000;
                carry_out = 1'b0;
            end
        endcase
    end

    assign out = result[7:0];
    assign z = (out == 8'h00);
    assign n = out[7];
    assign c = carry_out;
    // Overflow solo para ADD/SUB: V = (A7 == B7) && (OUT7 != A7)
    assign v = (s == 3'b000 || s == 3'b001) ? (a[7] == b[7] && out[7] != a[7]) : 1'b0;

endmodule