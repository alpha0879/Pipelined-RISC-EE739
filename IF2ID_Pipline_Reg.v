module IF2ID_Pipline_Reg (clk, rst, flush, freeze, PC_In, Instr_In, PC_Out, Instr_Out);

	parameter  WORD_LEN = 16;  
	input clk, rst, flush, freeze;
	input [WORD_LEN-1:0] PC_In, Instr_In;
	output reg [WORD_LEN-1:0] PC_Out, Instr_Out;

	always @ (posedge clk) begin
		if (rst) begin
			PC_Out <= 0;
			Instr_Out <= 0;
		end
		else begin
			if (~freeze) begin
				if (flush) begin
					Instr_Out <= 0;
					PC_Out <= 0;
				end
			else begin
				Instr_Out <= Instr_In;
				PC_Out <= PC_In;
			end
			end
		end
	end
endmodule // IF2ID_Pipline_Reg