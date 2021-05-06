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
					for( i=0;i<65536;i=i+1 ) ram_data_memory[i] = 0;
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

				/*
				  instruction_mem[0] = 16'b0011000000000001;//LHI R0,#1     ro = 80
				  instruction_mem[1] = 16'b0000000000000000;//ADD R0,R0,R0   ro=100
				  instruction_mem[2] = 16'b0011001000000111;//LHI R1     r1=380
				  instruction_mem[3] = 16'b0000000001010000; //ADD R2, R0, R1  r2 = 480
				  instruction_mem[4] = 16'b0101010011000000;//SW R2,R3,6'b0  instruction_mem(0) = 480
				  instruction_mem[5] = 16'b0100100011000000;//LW R4,R3,6'b0  r4 = instruction_mem(0) = 480
				  instruction_mem[6] = 16'b0101010011000001;//SW R2,R3,6'b1  instruction_mem(1) = 480
				  instruction_mem[7] = 16'b0100101011000001;//LW R5,R3,6'b1  r5 = instruction_mem(1) = 480
				  instruction_mem[8] = 16'b0110011001100000;//LM r3, 01100000(r6,r5)  r5 = instruction_mem(0) = 480 , r6 = 480
				  instruction_mem[9] = 16'b0000000001000000;//Add R0,R1,R0           r0 = 480
				  instruction_mem[10] = 16'b0000000000000000;////ADD R0,R0,R0         r0  = 900
				  instruction_mem[11] = 16'b0000011011000000; //ADD R0,R3,R3			r0 = 0
				  instruction_mem[12] = 16'b0000101000000001; //ADZ R0,R0,R5       r0 = 480
				  instruction_mem[13] = 16'b0011111000000001;//LHI R7 1
				  instruction_mem[128] = 16'b0001011100101010;//ADI R4 = R3+#101010 = #sext(101010)
				  instruction_mem[129] = 16'b0111011000000110;//SM instruction_mem(0) = R1	 , instruction_mem(1) =R2
				  instruction_mem[130] = 16'b0110011000001100;   //LM R2 = instruction_mem(0) R3 = instruction_mem(1)
				  instruction_mem[131] = 16'b1000000000000111;//JAL R0, #111
				  instruction_mem[138] = 16'b1100110101001000;//BEQ R6 R5 #2 // instruction_mem[136] = 16'b1100111101000010; (one jumps the other doesn't)
				  instruction_mem[139] = 16'b1001101000000000;//JLR R5,R0 (jump back to 82)
				  */

				// Lab Testbench 1 w/o LM SM
				/*
				instruction_mem[0]	<=		16'b1100000001011101;
				// instruction_mem[0]	<=		16'b1111000000000000;
				instruction_mem[1]	<=		16'b0100100110000101;
				instruction_mem[2]	<=		16'b0100110110000101;
				instruction_mem[3]	<=		16'b0100000101010100;
				instruction_mem[4]	<=		16'b0100001101010101;
				instruction_mem[5]	<=		16'b0001000010000000;
				instruction_mem[6]	<=		16'b0010000001011000;
				instruction_mem[7]	<=		16'b0010011011011000;
				instruction_mem[8]	<=		16'b0001011011000000;
				instruction_mem[9]	<=		16'b0000100010100001;
				instruction_mem[10]	<=		16'b0000000000000000;
				instruction_mem[11]	<=		16'b0010110110110010;
				instruction_mem[12]	<=		16'b1100110101111010;
				instruction_mem[13]	<=		16'b0101100101010110;
				

				instruction_mem[29] <=   	16'b0001011011000001;
				instruction_mem[30] <=   	16'b0001110110010111;
				instruction_mem[31] <=   	16'b0101000110000100;
				instruction_mem[32] <=   	16'b0100000110000000;
				instruction_mem[33] <=   	16'b0100001110000001;
				instruction_mem[34] <=   	16'b1100101001001100;
				instruction_mem[35] <=   	16'b0000000010010000;
				instruction_mem[36] <=   	16'b0000011100100010;
				instruction_mem[37] <=   	16'b0001001001111111;
				instruction_mem[38] <=   	16'b1000111111111011;

				instruction_mem[46] <=   	16'b0101010110000010;
				instruction_mem[47] <=   	16'b0101100110000011;
				instruction_mem[48] <=   	16'b0001011011111111;
				instruction_mem[49] <=   	16'b0101011110000101;
				instruction_mem[50] <=   	16'b0100111110000100;
				*/

				
				instruction_mem[0]  <=		16'b0100101000010111; 
				instruction_mem[1] 	<= 		16'b1111000000000000;
				instruction_mem[2]  <= 		16'b1111000000000000;
				instruction_mem[3]	<= 		16'b1111000000000000;
				instruction_mem[4]  <=		16'b0100011000011000; 
				instruction_mem[5] 	<= 		16'b1111000000000000;
				instruction_mem[6]  <= 		16'b1111000000000000;
				instruction_mem[7]	<= 		16'b1111000000000000;
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
				instruction_mem[24] <=		16'b0101110000011001; 
				
				end	
endmodule
