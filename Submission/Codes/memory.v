
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
				
				
				/* instruction_mem[0] <= 16'b0001000000000000;
				instruction_mem[1] <= 16'b0001010101011000; //add r3 r2 r5         r3 = 7
				instruction_mem[2] <= 16'b1100110000100001; // lm r6 so m[6 - 7] --> r0 to r6 r0=0,r1=6,r2=2,r3=7,r4=3,r5=5,r6=7
				instruction_mem[3] <= 16'b0001001110000000; //add ro r1 r6 ; r1 = 6, r6 = 7 ==> r0 = 13
				instruction_mem[4] <= 16'b1101000001001000; //sm r0 M[13 - 14 ] <-- r0, r3 
				instruction_mem[5] <= 16'b0001010110101000; // add r5 , r2, r6 ;r5 = 9 uncommented means pblm??
				instruction_mem[6] <= 16'b0001010110010000; // r2 = 9
				instruction_mem[7] <= 16'b0100100101000000;  // lw r4, loc = 9 //r4 = 9
				instruction_mem[8] <= 16'b0101100110000011;    // sw r4 to loc  10? */
				
				// test 
			    instruction_mem[0] <= 16'b0001000000000000;
				instruction_mem[1] <= 16'b0001001110010000;
				instruction_mem[2] <= 16'b0001010100101000;				
				instruction_mem[3] <= 16'b1110101000000000;				
				instruction_mem[4] <= 16'b0001010011001000;
				instruction_mem[5] <= 16'b0100101101000001;
				instruction_mem[6] <= 16'b0001101000100000;
				instruction_mem[7] <= 16'b1111100000000000;
				instruction_mem[8] <= 16'b0101010110000001;
				
				/*// PROGRAM TO FIND SUM OF NUMBERS UPTO 20
				instruction_mem[0] <= 16'b0001000000000000;  // add r0 r0 r0				
				instruction_mem[1] <= 16'b0000000001010100;	 // ADI R1,R0,010100	r1 =20;
				instruction_mem[2] <= 16'b1000000001000100;	 //BEQ R0,R1,000100					
				instruction_mem[3] <= 16'b0000000000000001;  // ADI R0,R0,000001
				instruction_mem[4] <= 16'b0001010000010000;  // ADD R2,R2,R0
				instruction_mem[5] <= 16'b1001100111111101;  // JAL R4, 111111101		*/
				
				end	
endmodule
