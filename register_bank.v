module register_bank(clk, reset, readAdd1, readAdd2, writeAdd, writeData, writeEnable, readData1, readData2);

	output reg [15:0] readData1, readData2;
	input  [15:0] writeData;
	input  [2:0]  readAdd1, readAdd2, writeAdd;
	input	writeEnable, clk, reset;
		
	reg [15:0] register_ram [0:7];
	integer i = 0;
	
	initial begin 
	  for ( i =0; i<8 ; i = i+1 ) begin
	     register_ram[i] = 16'b0;
       end
	 readData1 = 16'b0;
	 readData2 = 16'b0;
    end
    
	always @(*) begin 
	 readData1 = register_ram[readAdd1];
	 readData2 = register_ram[readAdd2];
	end

	always @(posedge clk ) begin 
	  if ( reset ) begin 
	    for ( i =0; i<8 ; i = i+1 ) begin
	     register_ram[i] = 0;
        end
	  end
      else begin
	    if (writeEnable) 
		   register_ram[writeAdd] <= writeData;
	  end
	end

endmodule