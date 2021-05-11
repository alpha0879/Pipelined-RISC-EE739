/* operation = 00 alu adds, 01 - alu nand, 10- disabled-  no operation */
//zero_write_en - enable signal for zero flag
//carry_write_en - enable for carry flag
//zero and carry  -- ouputs

module ALU (in1, in2, operation, out, zero, carry);
	
	output reg [15:0] out;
	output reg zero, carry;
	
	input  [15:0] in1, in2;
	input [1:0] operation;
	
	wire   [15:0]  outNand;
	wire [16:0] outAdd;
	
	
	initial begin 
	  zero = 0;
	  carry = 0;
	  out = 16'b0;
	end
	
	assign outNand = ~(in1 & in2);
	
	assign outAdd = {1'b0,in1} + {1'b0, in2};
	
	always @(*) begin
	 if(operation == 2'b10) begin 
        carry = 0;
		zero = 0;
		out = 16'd0;
	 end
	 else begin	
	   carry = (operation == 2'b01) ? 1'b0 : outAdd[16];
	   out = (operation == 2'b01) ? outNand : outAdd[15:0];
	  end 
	end
	
	always @(*) begin 
	   zero = (out == 16'b0) ? 1'b1 : 1'b0; 	   
	end
	
	
endmodule