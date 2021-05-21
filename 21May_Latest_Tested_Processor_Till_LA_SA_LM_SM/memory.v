
module data_memory( clk,reset,accessAddress, dataIn, writeEnable, dataOut );

	input  writeEnable, clk, reset;
	input  [15:0] accessAddress, dataIn;
	output  [15:0] dataOut;

	
	
	
	reg [15:0] ram_data_memory [0:4095];  // for the time being let's take complete memory, change later!
	integer i;
	
	initial begin 
	  for(i=0;i<4096;i=i+1) ram_data_memory[i] = i;
	  end
	
	always @(posedge clk)
		begin
			if(reset == 1'b1)
				begin
					for( i=0;i<4096;i=i+1 ) ram_data_memory[i] = i;
					//ram_data_memory[7] <= 16'd0;
				end
			else if (writeEnable ==1'b1)
					ram_data_memory[(accessAddress[11:0])] <= dataIn;
		end

	assign dataOut  = ram_data_memory[accessAddress[11:0]];

endmodule


module instruction_memory(clk, reset, inputAddr, irOut);

	output  [15:0] irOut;
	
	input  [15:0] inputAddr;
	input reset,clk;
	
	reg [15:0] instruction_mem [0:4095];

	integer i;
	
	assign irOut = (reset==1'b1)?16'b0111000000000000:instruction_mem[inputAddr[11:0]];	
	
	always @(posedge clk)
		begin
			if(reset== 1'b1)
				begin
					for(i=0;i<4096;i=i+1) instruction_mem [i] =  16'b0111000000000000; // nop
				end				
				
				
				//test_new -- nikhil
				/* instruction_mem[0] <= 16'b0001000000000000;
				instruction_mem[1] <= 16'b0001010101011000; //add r3 r2 r5         r3 = 7
				instruction_mem[2] <= 16'b1100110000100001; // lm r6 so m[6 - 7] --> r0 to r6 r0=0,r1=6,r2=2,r3=7,r4=3,r5=5,r6=7
				instruction_mem[3] <= 16'b0001001110000000; //add ro r1 r6 ; r1 = 6, r6 = 7 ==> r0 = 13
				instruction_mem[4] <= 16'b1101000001001000; //sm r0 M[13 - 14 ] <-- r0, r3 
				instruction_mem[5] <= 16'b0001010110101000; // add r5 , r2, r6 ;r5 = 9 uncommented means pblm??
				instruction_mem[6] <= 16'b0001010110010000; // r2 = 9
				instruction_mem[7] <= 16'b0100100101000000;  // lw r4, loc = 9 //r4 = 9
				instruction_mem[8] <= 16'b0101100110000011;    // sw r4 to loc  10? */
				
				// test by robin
				instruction_mem[0]  <=		16'b0001000000000000; // ADD R0, R0, R0 ADD: 00_01 RA RB RC 0 00				//RC, RA, RB
				instruction_mem[1]  <=		16'b0001001110010000; // ADD R2, R1, R6 ADD: 00_01 RA RB RC 0 00 // R2 = 1 + 6 = 7 
				instruction_mem[2] 	<= 		16'b0001010100101000; // ADD R5, R2, R4 ADD: 00_01 RA RB RC 0 00 // R5 = 10 
				
				instruction_mem[3] <=      16'b1110101000000000; // LA R5
				
				instruction_mem[4] <=      16'b0001010011001000;  // add r1, r2, r3    r1 = 25
				instruction_mem[5]  <=     16'b0100101101000001;// lw r5, r5,1  r5 - 16
				instruction_mem[6] <=      16'b0001101000100000;  // add r4, r5, r0   r4 = 26
				instruction_mem[7] <=      16'b1111100000000000; // SA R4
				instruction_mem[8]  <=     16'b0101010110000001;// sw R2, R6, 1 
				

				
				end	
endmodule
