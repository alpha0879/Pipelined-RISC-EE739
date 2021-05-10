/* sign extend 9 bit immediate to 16 bit immediate
*/

module se7(in, out ); 

	output [15:0] out;	
	input  [8:0] in;	


    assign out = {{7{in[8]}}, in};
	
	
endmodule

