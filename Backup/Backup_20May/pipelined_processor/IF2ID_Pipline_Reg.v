module IF2ID_Pipline_Reg (clk, rst, enable, PC_In, PC_Next_In, Instr_In, PC_Out, PC_Next_Out, Instr_Out);
 
	input clk, rst, enable;
	input [15:0] PC_In, PC_Next_In, Instr_In;
	output reg [15:0] PC_Out, PC_Next_Out, Instr_Out;

	always @ (posedge clk) begin
		if (rst) begin
			PC_Out <= 0;
			PC_Next_Out <= 0;
			Instr_Out <= 0;
		end
		else begin
			if (enable) begin
				Instr_Out <= Instr_In;
				PC_Out <= PC_In;
				PC_Next_Out <= PC_Next_In;
			end
		end
	end
endmodule // IF2ID_Pipline_Reg