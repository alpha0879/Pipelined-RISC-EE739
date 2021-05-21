/* generic n bit register : default: 16 bit 
*/

module register_generic(clk, reset,enable, in, out ); 

	parameter n = 16;
	output reg [n-1:0] out;	
	input  [n-1:0] in;	
    input clk, reset, enable;
 
	always @( posedge clk ) begin
	 if (reset) 
	     out <= {n{1'b0}};
	 else if (enable)
	   out <= in;
	end
	
endmodule

