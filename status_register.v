// status_register.v
// Guarda las banderas de estado generadas por la ALU: Z, N, C, V.

module status_register(clk, z_in, n_in, c_in, v_in, z, n, c, v);
  input  wire clk;
  input  wire z_in, n_in, c_in, v_in;
  output reg  z, n, c, v;

  initial begin
    z = 0; n = 0; c = 0; v = 0;
  end

  always @(posedge clk) begin
    z <= z_in;
    n <= n_in;
    c <= c_in;
    v <= v_in;
  end
endmodule
