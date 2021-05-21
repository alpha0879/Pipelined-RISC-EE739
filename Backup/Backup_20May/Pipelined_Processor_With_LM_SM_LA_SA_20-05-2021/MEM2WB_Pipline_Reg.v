//Control_In format {RR_A3_Address_sel, RR_Wr_En, EXE_ALU_Src2, EXE_ALU_Oper, Reg_D3_Sel, MEM_Wr_En} total 10 bits
module MEM2WB_Pipline_Reg (clk, rst, enable, Control_In, Rd_Addr_In_From_Mem, Rd_Data_In_From_Mem, Instr_In, Control_Out, Rd_Addr_Out_PR, 
							Rd_Data_Out_PR, Instr_Out);
 
	input clk, rst, enable;
	input [15:0] Instr_In, Rd_Data_In_From_Mem;
	input  Control_In;
	input [2:0] Rd_Addr_In_From_Mem ;
	output reg [15:0]  Instr_Out, Rd_Data_Out_PR;
	output reg  Control_Out;
	output reg [2:0] Rd_Addr_Out_PR;

	always @ (posedge clk) begin
		if (rst) begin
			//PC_Out <= 0;
			Control_Out <= 0;
			Instr_Out <= 0;
			//ALU_Result_Out <= 0;
			//MEM_Data_Out <= 0;
			Rd_Addr_Out_PR <= 0; 
			Rd_Data_Out_PR <= 0; 
		end
		else begin
			if (enable) begin
				//PC_Out <= PC_In;
				Control_Out <= Control_In;
				Instr_Out <= Instr_In;
				//ALU_Result_Out <= ALU_Result_In;
				//MEM_Data_Out <= MEM_Data_In;
				Rd_Addr_Out_PR <= Rd_Addr_In_From_Mem; 
				Rd_Data_Out_PR <= Rd_Data_In_From_Mem;
			end
		end
	end
endmodule // MEM2WB_Pipline_Reg