/* rs1_frwd_control rs2_frwd_control -- forwards directly from decode_stage -- 00
										forwards from start of mem -- 01
										forwards  from start of wb -- 10
										forwards the data of 3 cycles apart using rd_addr_wb -- 11
*/

//rs1_addr_rr, rs2_addr_rr - address from rr_ex pipeline to alu
//rd_addr_ex - rd address in ex_mem pipeline - for immediate dependency
//rd_addr_mem - rd address in mem_wb pipeline - for two cycle apart dependency
//rd_addr_wb - rd address for 3 cycles apart dependency

module forwarding_control_unit ( rs1_addr_rr, rs2_addr_rr, rd_addr_ex, rd_addr_mem,
								 rd_addr_wb,reg_wr_en_ex, reg_wr_en_mem, reg_wr_en_wb,
									rs1_frwd_control, rs2_frwd_control/* , stall_for_load */);
								 
	input [2:0] rs1_addr_rr, rs2_addr_rr, rd_addr_ex, rd_addr_mem, rd_addr_wb ;
	input reg_wr_en_ex, reg_wr_en_mem, reg_wr_en_wb;
	
	output reg [1:0] rs1_frwd_control, rs2_frwd_control;
								 
	always @(*) begin
	 
	 rs1_frwd_control = 2'b00;
	 rs2_frwd_control = 2'b00;
	
	// rs1 control	  
	  if ( (rs1_addr_rr == rd_addr_ex) && (reg_wr_en_ex == 1 ) )  
	      rs1_frwd_control = 2'b01;
	  else if ((rs1_addr_rr == rd_addr_mem) && (reg_wr_en_mem == 1 ) )
	      rs1_frwd_control = 2'b10;
	  else if ((rs1_addr_rr == rd_addr_wb) && (reg_wr_en_wb == 1 ) ) 
	      rs1_frwd_control = 2'b11;
		  
	// rs2 control 
	  if ( (rs2_addr_rr == rd_addr_ex) && (reg_wr_en_ex == 1 ) )  
	      rs2_frwd_control = 2'b01;
	  else if ((rs2_addr_rr == rd_addr_mem) && (reg_wr_en_mem == 1 ) )
	      rs2_frwd_control = 2'b10;
	  else if ((rs2_addr_rr == rd_addr_wb) && (reg_wr_en_wb == 1 ) ) 
	      rs2_frwd_control = 2'b11;
	
			
	end
endmodule	