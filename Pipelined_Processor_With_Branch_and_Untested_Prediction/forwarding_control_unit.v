/* rs1_frwd_control rs2_frwd_control -- forwards directly from decode_stage -- 00
										forwards from start of mem -- 01
										forwards  from start of wb -- 10
										forwards the data of 3 cycles apart using rd_prev_addr_rr_ex -- 11
*/

//rs1_addr_rr_ex, rs2_addr_rr_ex - address from rr_ex pipeline to alu
//rd_addr_ex_mem - rd address in ex_mem pipeline - for immediate dependency
//rd_addr_mem_wb - rd address in mem_wb pipeline - for two cycle apart dependency
//rd_prev_addr_rr_ex - rd address for 3 cycles apart dependency

module forwarding_control_unit ( rs1_addr_rr_ex, rs2_addr_rr_ex, rd_addr_ex_mem, rd_addr_mem_wb, rd_prev_addr_rr_ex,reg_wr_en_ex_mem, 
								 reg_wr_en_mem_wb, reg_wr_en_rr_ex_prev, rs1_frwd_control, rs2_frwd_control);
								 
	input [2:0] rs1_addr_rr_ex, rs2_addr_rr_ex, rd_addr_ex_mem, rd_addr_mem_wb, rd_prev_addr_rr_ex ;
	input reg_wr_en_ex_mem, reg_wr_en_mem_wb, reg_wr_en_rr_ex_prev;	
	output reg [1:0] rs1_frwd_control, rs2_frwd_control;
								 
	always @(*) begin	 
	 rs1_frwd_control = 2'b00;
	 rs2_frwd_control = 2'b00;
	
	// rs1 control	  
	  if ( (rs1_addr_rr_ex == rd_addr_ex_mem) && (reg_wr_en_ex_mem == 1 ) )  
	      rs1_frwd_control = 2'b01;
	  else if ((rs1_addr_rr_ex == rd_addr_mem_wb) && (reg_wr_en_mem_wb == 1 ) )
	      rs1_frwd_control = 2'b10;
	  else if ((rs1_addr_rr_ex == rd_prev_addr_rr_ex) && (reg_wr_en_rr_ex_prev == 1 ) ) 
	      rs1_frwd_control = 2'b11;
		  
	// rs2 control 
	  if ( (rs2_addr_rr_ex == rd_addr_ex_mem) && (reg_wr_en_ex_mem == 1 ) )  
	      rs2_frwd_control = 2'b01;
	  else if ((rs2_addr_rr_ex == rd_addr_mem_wb) && (reg_wr_en_mem_wb == 1 ) )
	      rs2_frwd_control = 2'b10;
	  else if ((rs2_addr_rr_ex == rd_prev_addr_rr_ex) && (reg_wr_en_rr_ex_prev == 1 ) ) 
	      rs2_frwd_control = 2'b11;				
	end
endmodule	