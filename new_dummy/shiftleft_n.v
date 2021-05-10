module shiftleft_n( in, out ); 

	output [15:0] out;	
	input  [15:0] in;

	parameter n = 1;


    assign out = in << n; // Left shift by n
	
	
endmodule