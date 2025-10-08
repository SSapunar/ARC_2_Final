module data_memory(address, data_in, data_out, write_enable, clk);
  input  wire [7:0] address;
  input  wire [7:0] data_in;
  input  wire       write_enable;
  input  wire       clk;
  output wire [7:0] data_out;
  reg [7:0] mem [0:255];
  assign data_out = mem[address];
  always @(posedge clk) begin
    if (write_enable)
      mem[address] <= data_in;
  end
  initial begin
    $readmemb("mem.dat", mem);
  end
endmodule