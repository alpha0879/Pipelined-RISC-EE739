/* rs1_frwd_control rs2_frwd_control -- forwards directly from decode_stage -- 00
										forwards from start of mem -- 01
										forwards  from start of wb -- 10
										forwards the data of 3 cycles apart using rd_prev_addr_rr_ex -- 11
*/
/*		
	-- not implemented now, used this for something else -- ignore 
						alu_op_frwd_control -- needs the opcode to know whether the operation is ADC, ADZ, NDC , NDZ
						forwards the operation set by alu control unit directly with a mux - 0
						forwards the no operation -- 1 ( the input 1 of the mux is connected to 2'b10 ( refer alu.v) 
						
						Assuming that c and z flag register in each pipeline stage will only be written by the instr which has access to modify it. so reading data from c
						and z are valid data.	
*/

/* stall for load -- gives 1 when immediate dependency for load is present*/
/*ir -- instruction */

module forwarding_control_unit ( ir, rs1_addr_rr_ex, rs2_addr_rr_ex, rd_addr_ex_mem, rd_addr_mem_wb,
								 rd_prev_addr_rr_ex, /*carry_ex_mem, zero_ex_mem,*/ rs1_frwd_control, rs2_frwd_control, stall_for_load);
								 
	input [2:0] rs1_addr_rr_ex, rs2_addr_rr_ex, rd_addr_ex_mem, rd_addr_mem_wb, rd_prev_addr_rr_ex ;
	input [15:0] ir;
	
	//input [15:0] rs1_rr_ex, rs2_rr_ex, rd_ex_mem, rd_mem_wb, rd_prev_rr_ex;
	//input carry_ex_mem, zero_ex_mem;// carry_mem_wb, zero_mem_wb, carry_prev_rr_ex, zero_prev_rr_ex;
	//input writeRegEnable_ex_mem, writeRegEnable_mem_wb, writeRegEnable_rr_prev;
	
	output reg [1:0] rs1_frwd_control, rs2_frwd_control;
	output reg stall_for_load;
	
	
	/*localparam ADC = 6'b000010;
	localparam ADZ = 6'b000001;
	localparam NDC = 6'b001010;
	localparam NDZ = 6'b001001;*/
	
	localparam load = 4'b0100;
								 
	always @(*) begin
	 
	 rs1_frwd_control = 2'b00;
	 rs2_frwd_control = 2'b00;
	                           //alu_op_frwd_control = 1'b0; 
	
	// rs1 control
      if ( ir[15:12] == load && rs1_addr_rr_ex == rd_addr_ex_mem ) 
              stall_for_load = 1;	  
	  else if ( (rs1_addr_rr_ex == rd_addr_ex_mem) )  
	      rs1_frwd_control = 2'b01;
	  else if ((rs1_addr_rr_ex == rd_addr_mem_wb))
	      rs1_frwd_control = 2'b10;
	  else if ((rs1_addr_rr_ex == rd_prev_addr_rr_ex)) 
	      rs1_frwd_control = 2'b11;
		  
	// rs2 control 
      if ( ir[15:12] == load && rs2_addr_rr_ex == rd_addr_ex_mem )
			stall_for_load = 1;
	  else if ( (rs2_addr_rr_ex == rd_addr_ex_mem))  
	      rs2_frwd_control = 2'b01;
	  else if ((rs2_addr_rr_ex == rd_addr_mem_wb))
	      rs2_frwd_control = 2'b10;
	  else if ((rs2_addr_rr_ex == rd_prev_addr_rr_ex) ) 
	      rs2_frwd_control = 2'b11;
	
	/* ignore for now 	  
    // alu-op-forward control // for the time - being assuming that the instruction that can modify the carry and zero flag can only write to c and
	//   zero pipeline register in ex-mem stage. 
	   
	  if ( (opcode == ADC) || (opcode == NDC) ) begin 
	        if ( !carry_ex_mem  ) alu_op_frwd_control = 1'b1;
	  end 
	  
	  if ( (opcode == ADZ) || (opcode == NDZ) ) begin 
	        if ( !zero_ex_mem  ) alu_op_frwd_control = 1'b1;
	  end */
	  
			
	end
endmodule	