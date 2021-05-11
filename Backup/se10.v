/* sign extend 6 bit immediate to 16 bit immediate
*/

module se10(in, out ); 

	output [15:0] out;	
	input  [5:0] in;	


    assign out = {{10{in[5]}}, in};
	
	
endmodule

