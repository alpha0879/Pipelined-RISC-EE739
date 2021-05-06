module comparator(ip0, ip1, equal); 

	output equal;
	
	input  [15:0] ip0, ip1;
	
	assign equal = (ip0 == ip1) ? 1'b1 : 1'b0;
endmodule