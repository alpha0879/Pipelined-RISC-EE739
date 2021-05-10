//Control_In format {RR_A3_Address_sel, RR_Wr_En, EXE_ALU_Src2, EXE_ALU_Oper, Reg_D3_Sel, MEM_Wr_En} total 10 bits

module ID2EX_Pipline_Reg (clk, rst, enable, PC_In, Control_In, RF_A1_In, RF_A2_In, RF_A3_From_WB_In, RF_D3_From_WB_In, RR_Write_En_In, 
								RF_D1_In, RF_D2_In, Instr_In, PC_Out, Control_Out, RF_A1_Out, RF_A2_Out, RF_A3_From_WB_Out, RF_D3_From_WB_Out, 
									RR_Write_En_Out, RF_D1_Out, RF_D2_Out, Instr_Out);
 
	input clk, rst, enable, RR_Write_En_In;
	input [15:0] PC_In, RF_D1_In, RF_D2_In, Instr_In, RF_D3_From_WB_In;
	input [2:0] RF_A1_In, RF_A2_In, RF_A3_From_WB_In;
	input [9:0] Control_In;
	output reg RR_Write_En_Out;
	output reg [15:0] PC_Out, RF_D1_Out, RF_D2_Out, Instr_Out, RF_D3_From_WB_Out;
	output reg [9:0] Control_Out;
	output reg [2:0] RF_A1_Out, RF_A2_Out, RF_A3_From_WB_Out;
	
	always @ (posedge clk) begin
		if (rst) begin
			PC_Out <= 0;
			Control_Out <= 0;
			Instr_Out <= 0;
			RF_D1_Out <= 0;
			RF_D2_Out <= 0;
			RF_A1_Out <= 0;
			RF_A2_Out <= 0;
			RF_A3_From_WB_Out <= 0;
			RF_D3_From_WB_Out <= 0;
			RR_Write_En_Out <= 0;
		end
		else begin
			if (enable) begin
				PC_Out <= PC_In;
				Control_Out <= Control_In;
				Instr_Out <= Instr_In;
				RF_D1_Out <= RF_D1_In;
				RF_D2_Out <= RF_D2_In;
				RF_A1_Out <= RF_A1_In;
				RF_A2_Out <= RF_A2_In;
				RF_A3_From_WB_Out <= RF_A3_From_WB_In;
				RF_D3_From_WB_Out <= RF_D3_From_WB_In;
				RR_Write_En_Out <= RR_Write_En_In;
			end
		end
	end
endmodule // ID2EX_Pipline_Reg