`timescale 1ns/1ps
module register_bank_tb;

	wire [15:0] readData1, readData2;
	reg  [15:0] writeData;
	reg  [2:0]  readAdd1, readAdd2, writeAdd;
	reg	writeEnable, clk, reset;

register_bank uut (clk, reset, readAdd1, readAdd2, writeAdd, writeData, writeEnable, readData1, readData2);


  always #10 clk = ~clk;
  
  initial begin 
    clk = 0 ;
	reset = 0;
	#15 reset = 1;
	#20 reset = 0;
	end
	
   initial begin 
    
	 #40 writeEnable = 1;
	 writeData = 16'd15;
	 writeAdd = 3'b011;
	 #20 writeEnable = 0;
	 
	 #40 writeEnable = 1;
	 writeData = 16'd13;
	 writeAdd = 3'b111;
	 #20 writeEnable = 0;
	 
   end
   
   initial begin 
     #140 readAdd1 = 3'b011;
	  readAdd2 = 3'b111;
	end
endmodule