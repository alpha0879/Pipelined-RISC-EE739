/*data_memory and instruction_memory -- taken from github */

module data_memory(clk,reset,accessAddress, writeData, writeEnable, dataOut);

	output  [15:0] dataOut;

	input  [15:0] accessAddress, writeData;
	input  writeEnable, clk, reset;
	
	reg [15:0] ram_data_memory [0:65535];  // for the time being let's take complete memory, change later!
	integer i;
	
	initial begin 
	  for(i=0;i<65536;i=i+1) ram_data_memory[i] = 0;
					ram_data_memory[20] <= 		16'b0000000000000001; // taken from github
					ram_data_memory[21] <= 		16'b0010111001010100; // taken from github					
					ram_data_memory[23] <= 		16'b0000000000010000; // taken from github
					ram_data_memory[24] <= 		16'b0000000000000101; // taken from github
					ram_data_memory[54] <= 		16'b0000000000001001; // taken from github
	  end
	
	always @(posedge clk)
		begin
			if(reset == 1'b1)
				begin
					for( i=0;i<65536;i=i+1 ) ram_data_memory[i] = i;
					ram_data_memory[6] <= 		16'd0;
					ram_data_memory[11] <= 		16'b0000000000001111; // taken from github
					ram_data_memory[12] <= 		16'b0000000000001111; // taken from github
					ram_data_memory[20] <= 		16'b0000000000000001; // taken from github
					ram_data_memory[21] <= 		16'b0010111001010100; // taken from github					
					ram_data_memory[23] <= 		16'b0000000000010000; // taken from github
					ram_data_memory[24] <= 		16'b0000000000000101; // taken from github
					ram_data_memory[54] <= 		16'b0000000000001001; // taken from github
				end
			else if(writeEnable ==1'b1)
					ram_data_memory[accessAddress] <= writeData;
		end

	assign dataOut  = ram_data_memory[accessAddress];

endmodule


module instruction_memory(clk, reset, readAdd, out);

	output  [15:0] out;
	
	input  [15:0] readAdd;
	input reset,clk;
	
	reg [15:0] instruction_mem [0:65535];
	wire [15:0]test;

	integer i;
	
	assign out = (reset==1'b1)?16'b1111000000000000:instruction_mem[readAdd];	
	
	always @(posedge clk)
		begin
			if(reset== 1'b1)
				begin
					for(i=0;i<65536;i=i+1) instruction_mem [i] =  16'b1111000000000000;
				end
				instruction_mem[0]  <=		16'b0001000000000000; // ADD R0, R0, R0 ADD: 00_01 RA RB RC 0 00				//RC, RA, RB
				instruction_mem[1]  <=		16'b0001001110010010; // ADC R2, R1, R6 ADD: 00_01 RA RB RC 0 00 // should not run
				instruction_mem[2] 	<= 		16'b0001010100000000; // ADD R0, R2, R4 ADD: 00_01 RA RB RC 0 00
				instruction_mem[3] 	<= 		16'b0001010100110000; // ADD R6, R2, R4 ADD: 00_01 RA RB RC 0 00 // r6 = 6
				instruction_mem[4] 	<= 		16'b0001010100111000; // ADD R7, R2, R4 ADD: 00_01 RA RB RC 0 00 
				instruction_mem[5] 	<= 		16'b0100001110000001; //lw R1, R6, 1
				instruction_mem[6]  <=      16'b0001010110011000; // ADD R3, R2, R6 ADD: 00_01 RA RB RC 0 00
				instruction_mem[7]  <=      16'b0001001110100000;// ADD R4, R1, R6 ADD: 00_01 RA RB RC 0 00
				instruction_mem[8]  <=      16'b0101100001000001;// sw R4, R1 1 
				
				instruction_mem[9]  <=      16'b0100111101000001;// lw r7, r5,1
				instruction_mem[10]  <=     16'b0001111000110001;// adz r6, r7,r0
				instruction_mem[11] <=      16'b0001100101010001;// adz r2, r4,r5 -- should not execute  
				
				/* instruction_mem[4]  <= 		16'b0001111001110011; // Adl R6,R7,R1
				
				instruction_mem[5]	<= 		16'b0000111110010000; // adi R6, R7, 16
				instruction_mem[6]  <=		16'b0010001100011000; // ndu R3, R1, R4
				instruction_mem[7] 	<= 		16'b0011111000000001; // lhi R7, 1 
				instruction_mem[8]  <= 		16'b0101101010000101; // sw R5, R2, 5 */
				/* instruction_mem[7]	<= 		16'b1111000000000000;
				instruction_mem[8] 	<= 		16'b0001011011111111;
				instruction_mem[9] 	<= 		16'b1111000000000000;
				instruction_mem[10] <=	 	16'b1111000000000000;
				instruction_mem[11]	<= 		16'b1111000000000000;
				instruction_mem[12] <= 		16'b0000101110110000;
				instruction_mem[13] <= 		16'b1111000000000000;
				instruction_mem[14] <= 		16'b1111000000000000;
				instruction_mem[15]	<= 		16'b1111000000000000;
				instruction_mem[16] <= 		16'b1100011000001000;
				instruction_mem[17] <= 		16'b1111000000000000;
				instruction_mem[18] <= 		16'b1111000000000000;
				instruction_mem[19]	<= 		16'b1111000000000000;
				instruction_mem[20] <= 		16'b1000001111110100;
				instruction_mem[21] <= 		16'b1111000000000000;
				instruction_mem[22] <= 		16'b1111000000000000;
				instruction_mem[23]	<= 		16'b1111000000000000;
				instruction_mem[24] <=		16'b0101110000011001;  */
				
				end	
endmodule
