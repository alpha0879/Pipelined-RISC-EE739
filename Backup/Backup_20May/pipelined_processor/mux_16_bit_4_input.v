module mux_16_bit_4_input(ip0, ip1, ip2, ip3, select, out); 

	output reg [15:0] out;
	
	input  [15:0] ip0, ip1, ip2, ip3;
	input  [1:0] select;
	
	always@(*) begin
		case(select)
			0: out = ip0;
			1: out = ip1;
			2: out = ip2;
			3: out = ip3;
			default : out = ip0;
		endcase
	end
	
endmodule