module pc(clk, pc, load, new_value);
  input  wire clk;
  input  wire load;
  input  wire [6:0] new_value;
  output reg  [6:0] pc;

  initial pc = 7'd0;

  always @(posedge clk) begin
    if (load)
      pc <= new_value;
    else
      pc <= pc + 7'd1;
  end
endmodule
