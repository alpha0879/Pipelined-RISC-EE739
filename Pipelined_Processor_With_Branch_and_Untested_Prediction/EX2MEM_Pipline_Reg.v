//Control_In format {RR_A3_Address_sel, RR_Wr_En, EXE_ALU_Src2, EXE_ALU_Oper, Reg_D3_Sel, MEM_Wr_En} total 10 bits
module EX2MEM_Pipline_Reg (clk, rst, enable, Control_In, Rd_Addr_In_From_Ex, Rd_Data_In_From_Ex, RF_D2_In, ALU_Result_In, Instr_In, 
							Control_Out, Rd_Addr_Out_PR, Rd_Data_Out_PR, RF_D2_Out, ALU_Result_Out, Instr_Out);
 
	input clk, rst, enable;
	input [15:0] RF_D2_In, Instr_In, ALU_Result_In, Rd_Data_In_From_Ex;
	input [2:0] Control_In;
	input [2:0] Rd_Addr_In_From_Ex ;
	output reg [15:0] RF_D2_Out, Instr_Out, ALU_Result_Out, Rd_Data_Out_PR;
	output reg [2:0] Control_Out;
	output reg [2:0] Rd_Addr_Out_PR;

	always @ (posedge clk) begin
		if (rst) begin
			//PC_Out <= 0;
			Control_Out <= 0;
			Instr_Out <= 0;
			ALU_Result_Out <= 0;
			//CZ_Out <= 0;
			RF_D2_Out <= 0;
			Rd_Addr_Out_PR <= 0; 
			Rd_Data_Out_PR <= 0; 
		end
		else begin
			if (enable) begin
				//PC_Out <= PC_In;
				Control_Out <= Control_In;
				Instr_Out <= Instr_In;
				ALU_Result_Out <= ALU_Result_In;
				//CZ_Out <= CZ_In;
				RF_D2_Out <= RF_D2_In;
				Rd_Addr_Out_PR <= Rd_Addr_In_From_Ex; 
			    Rd_Data_Out_PR <= Rd_Data_In_From_Ex; 
			end
		end
	end
endmodule // EX2MEM_Pipline_Reg