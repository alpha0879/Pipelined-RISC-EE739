module control_decoder (opcode, CZ, RR_A1_Address, RR_A2_Address, RR_A3_Address, RR_Wr_En, 
						EXE_ALU_Src2, EXE_ALU_Oper, MEM_Reg_Dst_Sel, MEM_Wr_En,
						WB_C_Wr_En ,WB_Z_Wr_En);

input [3:0] opcode;
input [1:0] CZ;


output reg RR_A1_Address, RR_A2_Address, RR_Wr_En, EXE_ALU_Src2, MEM_Wr_En, WB_C_Wr_En ,WB_Z_Wr_En;
output reg [1:0] RR_A3_Address, EXE_ALU_Oper, MEM_Reg_Dst_Sel;

always @(opcode,CZ)
	begin
		if( opcode == 4'b0000 && (CZ == 2'b00 | CZ == 2'b10 | CZ == 2'b01 ) ) begin	  //ADD, ADC, ADZ
			RR_A1_Address = 1'b0;
			RR_A2_Address = 1'b1;
			RR_A3_Address = 2'b00;
			RR_Wr_En = 1'b1;
			EXE_ALU_Src2 = 1'b0;
			EXE_ALU_Oper = 2'b00;
			MEM_Reg_Dst_Sel = 2'b00;
			MEM_Wr_En = 1'b0;
			WB_C_Wr_En = 1'b1;
			WB_Z_Wr_En = 1'b1;
		end		
		else if( opcode == 4'b0001 ) begin  //ADI
			RR_A1_Address = 1'b0;
			RR_A2_Address = 1'b1; // not required during ADI
			RR_A3_Address = 2'b01;
			RR_Wr_En = 1'b1;
			EXE_ALU_Src2 = 1'b1;
			EXE_ALU_Oper = 2'b00;
			MEM_Reg_Dst_Sel = 2'b00;
			MEM_Wr_En = 1'b0;
			WB_C_Wr_En = 1'b1;
			WB_Z_Wr_En = 1'b1; 
		end
		else if( opcode == 4'b0010 && (CZ == 2'b00 | CZ == 2'b10 | CZ == 2'b01 ) ) begin  //NDU, NDC, NDZ
			RR_A1_Address = 1'b0;
			RR_A2_Address = 1'b1;
			RR_A3_Address = 2'b10;
			RR_Wr_En = 1'b1;
			EXE_ALU_Src2 = 1'b0;
			EXE_ALU_Oper = 2'b01;
			MEM_Reg_Dst_Sel = 2'b00;
			MEM_Wr_En = 1'b0;
			WB_C_Wr_En = 1'b1;
			WB_Z_Wr_En = 1'b1;
		end	
		else if( opcode == 4'b0011 ) begin  //LHI
			RR_A1_Address = 1'b1;  // not required during LHI
			RR_A2_Address = 1'b1;  // not required during LHI
			RR_A3_Address = 2'b10;
			RR_Wr_En = 1'b1;
			EXE_ALU_Src2 = 1'b1;
			EXE_ALU_Oper = 2'b10;  // no ALU operation
			MEM_Reg_Dst_Sel = 2'b01;
			MEM_Wr_En = 1'b0;
			WB_C_Wr_En = 1'b0;
			WB_Z_Wr_En = 1'b0;
		end
		else if( opcode == 4'b0100 ) begin  //LW
			RR_A1_Address = 1'b1;
			RR_A2_Address = 1'b1; // not required during LW
			RR_A3_Address = 2'b10;
			RR_Wr_En = 1'b1;
			EXE_ALU_Src2 = 1'b1;
			EXE_ALU_Oper = 2'b00;
			MEM_Reg_Dst_Sel = 2'b10;
			MEM_Wr_En = 1'b0;
			WB_C_Wr_En = 1'b0;
			WB_Z_Wr_En = 1'b0;
		end
		else if( opcode == 4'b0101 ) begin  //SW
			RR_A1_Address = 1'b1;
			RR_A2_Address = 1'b0; 
			RR_A3_Address = 2'b00; // not required during SW
			RR_Wr_En = 1'b0;
			EXE_ALU_Src2 = 1'b1;
			EXE_ALU_Oper = 2'b00;
			MEM_Reg_Dst_Sel = 2'b01; // not required during SW
			MEM_Wr_En = 1'b1;
			WB_C_Wr_En = 1'b0;
			WB_Z_Wr_En = 1'b0;
		end
		// LM and SM need to be implemented
		else if( opcode == 4'b1100 ) begin  //BEQ
			RR_A1_Address = 1'b0;  
			RR_A2_Address = 1'b1;  
			RR_A3_Address = 2'b10;   // not required during BEQ
			RR_Wr_En = 1'b0;         // not required during BEQ
			EXE_ALU_Src2 = 1'b1;     // not required during BEQ
			EXE_ALU_Oper = 2'b10;    // no ALU operation
			MEM_Reg_Dst_Sel = 2'b01;  // not required during BEQ
			MEM_Wr_En = 1'b0;
			WB_C_Wr_En = 1'b0;
			WB_Z_Wr_En = 1'b0;
		end
		else if( opcode == 4'b1000 ) begin  //JAL
			RR_A1_Address = 1'b1;  // not required during JAL
			RR_A2_Address = 1'b1;  // not required during JAL
			RR_A3_Address = 2'b10;
			RR_Wr_En = 1'b1;
			EXE_ALU_Src2 = 1'b1;   // not required during JAL
			EXE_ALU_Oper = 2'b10;  // no ALU operation
			MEM_Reg_Dst_Sel = 2'b11;
			MEM_Wr_En = 1'b0;
			WB_C_Wr_En = 1'b0;
			WB_Z_Wr_En = 1'b0;

		end
		else if( opcode == 4'b1001 ) begin  //JLR
			RR_A1_Address = 1'b1;  
			RR_A2_Address = 1'b1;  // not required during JLR
			RR_A3_Address = 2'b10;
			RR_Wr_En = 1'b1;
			EXE_ALU_Src2 = 1'b1;   // not required during JLR
			EXE_ALU_Oper = 2'b10;  // no ALU operation
			MEM_Reg_Dst_Sel = 2'b11;
			MEM_Wr_En = 1'b0;
			WB_C_Wr_En = 1'b0;
			WB_Z_Wr_En = 1'b0;
		end		
		else begin  // corresponding to ADD
			RR_A1_Address = 1'b0;
			RR_A2_Address = 1'b1;
			RR_A3_Address = 2'b00;
			RR_Wr_En = 1'b1;
			EXE_ALU_Src2 = 1'b0;
			EXE_ALU_Oper = 2'b00;
			MEM_Reg_Dst_Sel = 2'b00;
			MEM_Wr_En = 1'b0;
			WB_C_Wr_En = 1'b1;
			WB_Z_Wr_En = 1'b1;   
		end

	end
		
endmodule