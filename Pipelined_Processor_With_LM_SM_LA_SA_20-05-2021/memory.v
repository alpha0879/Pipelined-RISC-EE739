
module data_memory(clk,reset,accessAddress, writeData, writeEnable, dataOut);

	output  [15:0] dataOut;

	input  [15:0] accessAddress, writeData;
	input  writeEnable, clk, reset;
	
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
					ram_data_memory[7] <= 16'd0;
				end
			else if(writeEnable ==1'b1)
					ram_data_memory[(accessAddress[11:0])] <= writeData;
		end

	assign dataOut  = ram_data_memory[accessAddress[11:0]];

endmodule


module instruction_memory(clk, reset, readAdd, out);

	output  [15:0] out;
	
	input  [15:0] readAdd;
	input reset,clk;
	
	reg [15:0] instruction_mem [0:4095];

	integer i;
	
	assign out = (reset==1'b1)?16'b0111000000000000:instruction_mem[readAdd[11:0]];	
	
	always @(posedge clk)
		begin
			if(reset== 1'b1)
				begin
					for(i=0;i<4096;i=i+1) instruction_mem [i] =  16'b0111000000000000;
				end
				//worked , need to check
				// for prediction check
				/* instruction_mem[0]  <=		16'b0001000000000000; // ADD R0, R0, R0 ADD: 00_01 RA RB RC 0 00				//RC, RA, RB
				instruction_mem[1]  <=		16'b0001001110010000; // ADD R2, R1, R6 ADD: 00_01 RA RB RC 0 00 // R2 = 1 + 6 = 7 
				instruction_mem[2] 	<= 		16'b0001010100000000; // ADD R0, R2, R4 ADD: 00_01 RA RB RC 0 00 // R0 = 10 , 2nd iteration r0 = 18+3 = 21
				
				instruction_mem[3] <=      16'b1000011100001100; // beq r3, r4, 12 ( pc = 3 + 12 = 15 )
				
				instruction_mem[4] <=      16'b0001000000001000;  // add r1, r0 r0    r1 = 42
				instruction_mem[5] <=      16'b0001001000100000;  // add r4, r1, r0   r4 = 63
				instruction_mem[6] <=      16'b1011000000001010;                 // jri r0 , 10 21 + 10 // new addition
				
				instruction_mem[15] <= 	  16'b0001001110011000;  // ADD R3, R1, R6 ADD: 00_01 RA RB RC 0 00 r3 = 7
				instruction_mem[16] <= 	  16'b0001001110101000;  // add r5, r1, r6 r5 = 7
				instruction_mem[17] <=    16'b1001010111110001; // jal r2, ,-15 ( pc = 17 - 15 = 2 ) R2 = 18  */
				
				//For checking LA
				/* instruction_mem[0]  <=		16'b0001000000000000; // ADD R0, R0, R0 ADD: 00_01 RA RB RC 0 00				//RC, RA, RB
				instruction_mem[1]  <=		16'b0001001110010000; // ADD R2, R1, R6 ADD: 00_01 RA RB RC 0 00 // R2 = 1 + 6 = 7 
				instruction_mem[2] 	<= 		16'b0001010100101000; // ADD R5, R2, R4 ADD: 00_01 RA RB RC 0 00 // R0 = 10 
				
				instruction_mem[3] <=      16'b1110101000000000; // LA R5 */
				
				/* instruction_mem[4] <=      16'b0001000000001000;  // add r1, r0 r0    r1 = 42
				instruction_mem[5] <=      16'b0001001000100000;  // add r4, r1, r0   r4 = 63
				instruction_mem[6] <=      16'b0001001000100000;  // add r4, r1, r0   r4 = 63 */
				
				//For checking SA
				/* instruction_mem[0]  <=		16'b0001000000000000; // ADD R0, R0, R0 ADD: 00_01 RA RB RC 0 00				//RC, RA, RB
				instruction_mem[1]  <=		16'b0001001110010000; // ADD R2, R1, R6 ADD: 00_01 RA RB RC 0 00 // R2 = 1 + 6 = 7 
				instruction_mem[2] 	<= 		16'b0001010100000000; // ADD R0, R2, R4 ADD: 00_01 RA RB RC 0 00 // R0 = 10 
				
				instruction_mem[3] <=      16'b1111000000000000; // SA R0 */
				
				/* instruction_mem[4] <=      16'b0001000000001000;  // add r1, r0 r0    r1 = 42
				instruction_mem[5] <=      16'b0001001000100000;  // add r4, r1, r0   r4 = 63
				instruction_mem[6] <=      16'b0001001000100000;  // add r4, r1, r0   r4 = 63 */
				
				//For checking LM
				/* instruction_mem[0]  <=		16'b0001000000000000; // ADD R0, R0, R0 ADD: 00_01 RA RB RC 0 00				//RC, RA, RB
				instruction_mem[1]  <=		16'b0001001110010000; // ADD R2, R1, R6 ADD: 00_01 RA RB RC 0 00 // R2 = 1 + 6 = 7 
				instruction_mem[2] 	<= 		16'b0001010100000000; // ADD R0, R2, R4 ADD: 00_01 RA RB RC 0 00 // R0 = 10 , 2nd iteration r0 = 18+3 = 21
				
				instruction_mem[3] <=      16'b1100000001010110; // LM R0 */
				
				/* instruction_mem[4] <=      16'b0001000000001000;  // add r1, r0 r0    r1 = 42
				instruction_mem[5] <=      16'b0001001000100000;  // add r4, r1, r0   r4 = 63
				instruction_mem[6] <=      16'b0001001000100000;  // add r4, r1, r0   r4 = 63
				 */
				//For checking SM
				instruction_mem[0]  <=		16'b0001000000000000; // ADD R0, R0, R0 ADD: 00_01 RA RB RC 0 00				//RC, RA, RB
				instruction_mem[1]  <=		16'b0001001110010000; // ADD R2, R1, R6 ADD: 00_01 RA RB RC 0 00 // R2 = 1 + 6 = 7 
				instruction_mem[2] 	<= 		16'b0001010100000000; // ADD R0, R2, R4 ADD: 00_01 RA RB RC 0 00 // R0 = 10 , 2nd iteration r0 = 18+3 = 21
				
				instruction_mem[3] <=      16'b1101000001010110; // SM R0
				
				/* instruction_mem[4] <=      16'b0001000000001000;  // add r1, r0 r0    r1 = 42
				instruction_mem[5] <=      16'b0001001000100000;  // add r4, r1, r0   r4 = 63
				instruction_mem[6] <=      16'b0001001000100000;  // add r4, r1, r0   r4 = 63 */
				
				
				
				
				/*instruction_mem[0]  <=		16'b0001000000000000; // ADD R0, R0, R0 ADD: 00_01 RA RB RC 0 00				//RC, RA, RB
				instruction_mem[1]  <=		16'b0001001110010010; // ADC R2, R1, R6 ADD: 00_01 RA RB RC 0 00 // should not run
				instruction_mem[2] 	<= 		16'b0000010000010010; // ADI R0, R2, 18 ADD: 00_01 RA RB RC 0 00 // R0 =20
				instruction_mem[3] 	<= 		16'b0001010100110000; // ADD R6, R2, R4 ADD: 00_01 RA RB RC 0 00 // r6 = 6
				instruction_mem[4] 	<= 		16'b0001010100101000; // ADD R5, R2, R4 ADD: 00_01 RA RB RC 0 00 //r5 = 6
				instruction_mem[5] 	<= 		16'b0100001110000001; //lw R1, R6, 1                             // r1 = 0
				instruction_mem[6]  <=      16'b0001010110011000; // ADD R3, R2, R6 ADD: 00_01 RA RB RC 0 00  // r3 = 8
				instruction_mem[7]  <=      16'b0001001110100000;// ADD R4, R1, R6 ADD: 00_01 RA RB RC 0 00   // r4 = 6
				instruction_mem[8]  <=      16'b0101100001000001;// sw R4, R1 1   6 to 1th loc                
				
				instruction_mem[9]  <=      16'b0100101101000001;// lw r5, r5,1                               // r5 = 0
				instruction_mem[10]  <=     16'b0001101000101001;// adz r5, r5,r0                             // r5 = 20
				instruction_mem[11] <=      16'b0001100101001001;// adz r1, r4,r5 -- should not execute  
				instruction_mem[12] <=      16'b1011011000001100; // jri r3, 12 (BRANCH TO r3 + 12 = 20 )  
				instruction_mem[13]  <=		16'b0001001110010010; // ADC R2, R1, R6 ADD: 00_01 RA RB RC 0 00     // should not run
				instruction_mem[14] 	<= 		16'b0001010100000000; // ADD R0, R2, R4 ADD: 00_01 RA RB RC 0 00 // should not run
				instruction_mem[15] 	<= 		16'b0001010100110000; // ADD R6, R2, R4 ADD: 00_01 RA RB RC 0 00 // should not run
				instruction_mem[16] 	<= 		16'b0001010100111000; // ADD R7, R2, R4 ADD: 00_01 RA RB RC 0 00 // should not run
				instruction_mem[17] 	<= 		16'b0100001110000001; //lw R1, R6, 1 							 // should not run
				instruction_mem[18]  <=      16'b0001010110011000; // ADD R3, R2, R6 ADD: 00_01 RA RB RC 0 00    // should not run
				instruction_mem[19]  <=      16'b0001001110100000;// ADD R4, R1, R6 ADD: 00_01 RA RB RC 0 00     // should not run
				instruction_mem[20]  <=      16'b0001100101011000;// add r3, r4,r5 ;// r3 = 6 + 20 = 26	, */

				
				end	
endmodule
