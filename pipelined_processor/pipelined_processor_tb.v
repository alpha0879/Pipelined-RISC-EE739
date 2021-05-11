`timescale 1us/1ns

module pipelined_processor_tb;

reg clk, reset;

pipelined_processor uut ( clk, reset, 1'b0, 1'b0, 1'b0,1'b0);

always #10 clk = ~clk;

initial begin 
 clk = 0;
 reset = 1'b1;
 
 #20
 reset = 1'b0;
 end
 
endmodule