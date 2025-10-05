// pc.v
module pc(clk, pc);
  input  wire clk;
  output reg  [6:0] pc;   // 7 bits → 128 instrucciones

  initial pc = 7'd0;

  always @(posedge clk) begin
    pc <= pc + 7'd1;
  end
endmodule
