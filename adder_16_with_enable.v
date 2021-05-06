/* Might need to freeze the pc for stalls. Hence making an adder for freezing the pc */

module adder_16_with_enable (in1, in2 ,enable, out);

	output reg [15:0]  out;	
	input  [15:0] in1, in2;
	input enable;
	//assign out = in1+in2;
	
	always @( enable, in1, in2 ) begin 
	   if (enable == 1'b0) 
	     out = out;
	   else 
	     out = in1 + in2;
	end
	
endmodule