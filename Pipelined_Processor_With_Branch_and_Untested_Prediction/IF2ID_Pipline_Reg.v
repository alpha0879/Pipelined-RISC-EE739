// Added Spec_taken bit

module IF2ID_Pipline_Reg (clk, rst, enable, PC_In, PC_Next_In, Instr_In, Spec_taken_in, PC_Out, PC_Next_Out, Instr_Out, Spec_taken_out);
 
	input clk, rst, enable, Spec_taken_in;
	input [15:0] PC_In, PC_Next_In, Instr_In;
	output reg [15:0] PC_Out, PC_Next_Out, Instr_Out;
	output reg Spec_taken_out;

	always @ (posedge clk) begin
		if (rst) begin
			PC_Out <= 0;
			PC_Next_Out <= 0;
			Instr_Out <= 0;
			Spec_taken_out <= 0;
		end
		else begin
			if (enable) begin
				Spec_taken_out <= Spec_taken_in;
				Instr_Out <= Instr_In;
				PC_Out <= PC_In;
				PC_Next_Out <= PC_Next_In;
			end
		end
	end
endmodule // IF2ID_Pipline_Reg