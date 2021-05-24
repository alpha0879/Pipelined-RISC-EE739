// warning / note --- According to the specifications, Register R7 always stores the program counter.
// Assume R7 will not be modifiable by any other instrn and R7 has a seperate write port
// pc directly hardwired to r7 . r7 write enable and pc enable are shorted. 
// Hope no hazards won't come out of this assumption :)


module register_bank(clk, reset, readAdd1, readAdd2, writeAdd, writeData, writeEnable, readData1, readData2, readData_R6_to_R0, r7writeData, r7wrEnable);

	output reg [15:0] readData1, readData2;
	output reg [111:0] readData_R6_to_R0; // 112 bit long sequence read for SA and SM instructions - format {R6 R5 R4 R3 R2 R1 R0}
	input  [15:0] writeData, r7writeData;
	input  [2:0]  readAdd1, readAdd2, writeAdd;
	input	writeEnable, clk, reset, r7wrEnable;
		
	reg [15:0] register_ram [0:7];
	integer i = 0;
	
	initial begin 
	  for ( i =0; i<8 ; i = i+1 ) begin
	     register_ram[i] = 16'b0;
       end
	 readData1 = 16'b0;
	 readData2 = 16'b0;
	 readData_R6_to_R0 = 112'd0;
    end
    
	always @(*) begin 
	 readData1 = register_ram[readAdd1];
	 readData2 = register_ram[readAdd2];
	 readData_R6_to_R0 = {register_ram[6], register_ram[5], register_ram[4], register_ram[3], register_ram[2], register_ram[1], register_ram[0]};
	end

	always @(posedge clk ) begin 
	  if ( reset ) begin 
	    for ( i = 0; i < 7 ; i = i+1 ) begin
	     register_ram[i] = i;
        end
		register_ram[4] = 3; // for debugging purpose, change later
		register_ram[7] = 0; // pc starts @ loc 0
	  end
      else begin
	    if (writeEnable) begin 
		  if ( writeAdd < 7 )
		   register_ram[writeAdd] <= writeData;		   
		end
		if ( r7wrEnable ) 
		   register_ram[7] <= r7writeData;
	  end
	end

endmodule