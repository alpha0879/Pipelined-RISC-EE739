//Control_In format {RR_A3_Address_sel, RR_Wr_En, EXE_ALU_Src2, EXE_ALU_Oper, Reg_D3_Sel, MEM_Wr_En} total 10 bits

module ID2EX_Pipline_Reg (clk, rst, enable, PC_In,PC_NEXT_IN, Control_In, RF_A1_In, RF_A2_In, RF_A3_From_WB_In, RF_D3_From_WB_In, RR_Write_En_In, 
								RF_D1_In, RF_D2_In,pc_data_select, Instr_In, Spec_Taken_In, PC_Out,PC_NEXT_OUT, Control_Out, RF_A1_Out, RF_A2_Out, RF_A3_From_WB_Out, RF_D3_From_WB_Out, 
									RR_Write_En_Out, RF_D1_Out, RF_D2_Out, Instr_Out, pc_data_select_out, Spec_Taken_Out);
 
	input clk, rst, enable, RR_Write_En_In, pc_data_select, Spec_Taken_In;
	input [15:0] PC_In, RF_D1_In, RF_D2_In, Instr_In, RF_D3_From_WB_In, PC_NEXT_IN;
	input [2:0] RF_A1_In, RF_A2_In, RF_A3_From_WB_In;
	input [9:0] Control_In;
	output reg RR_Write_En_Out, pc_data_select_out;
	output reg [15:0] PC_Out, RF_D1_Out, RF_D2_Out, Instr_Out, RF_D3_From_WB_Out, PC_NEXT_OUT;
	output reg [9:0] Control_Out;
	output reg [2:0] RF_A1_Out, RF_A2_Out, RF_A3_From_WB_Out;
	output reg Spec_Taken_Out;
	
	always @ (posedge clk) begin
		if (rst) begin
			Spec_Taken_Out <= 0;
			PC_Out <= 0;
			PC_NEXT_OUT <= 0;
			Control_Out <= 0;
			Instr_Out <= 0;
			RF_D1_Out <= 0;
			RF_D2_Out <= 0;
			RF_A1_Out <= 0;
			RF_A2_Out <= 0;
			RF_A3_From_WB_Out <= 0;
			RF_D3_From_WB_Out <= 0;
			RR_Write_En_Out <= 0;
			pc_data_select_out <= 0;
		end
		else begin
			if (enable) begin
				Spec_Taken_Out <= Spec_Taken_In;
				pc_data_select_out <= pc_data_select;
				PC_Out <= PC_In;
				PC_NEXT_OUT <= PC_NEXT_IN;
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