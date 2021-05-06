/* op = 00 alu adds, 01 - alu nand, 10- disabled-  no operation */

module ALU(in1, in2, op, out, zero, carry, operation_done); 
	
	output reg [15:0] out;
	output reg zero, carry, operation_done;
	
	input  [15:0] in1, in2;
	input [1:0] op;
	
	wire   [15:0]  outNand;
	wire [16:0] outAdd;
	
	
	initial begin 
	  zero = 0;
	  carry = 0;
	  out = 16'b0;
	  operation_done = 0;
	end
	
	assign outNand = ~(in1 & in2);
	
	assign outAdd = {1'b0,in1} + {1'b0, in2};
	
	always @(*) begin
	 if(op == 2'b10) begin 
        carry = 0;
		zero = 0;
		out = 16'b0;
		operation_done = 0;
	 end
	 else begin	
	   carry = (op == 2'b01) ? 1'b0 : outAdd[16];
	   out = (op == 2'b01) ? outNand : outAdd[15:0];
	   operation_done = 1;
	  end 
	end
	
	always @(*) begin 
	   zero = (out == 16'b0) ? 1'b1 : 1'b0; // not including the operation_done part here, anyway not planning to write the output if no operation
											// if needed add later.
	   
	end
	
	
endmodule