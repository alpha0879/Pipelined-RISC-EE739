/* shift left 9 bit immediate value and make it 16 bit by appending lsb's with 0
*/

module shift_left_imm9_by_7(in, out ); 

	output [15:0] out;	
	input  [8:0] in;	
	wire [15:0] temp;

    assign temp = {{7{1'b0}}, in};
	
	assign out = temp << 7;
	
endmodule

