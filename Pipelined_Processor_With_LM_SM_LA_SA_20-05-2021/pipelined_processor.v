

module pipelined_processor ( clk, reset);

 input clk, reset;

 // ******************************************** signals for fetch stage + if-id pipeline ************************************************
 
	 wire [15:0] pc_out, pc_next, pc_from_if_id, pc_next_from_if_id;
	 wire [15:0] instruction , ir_from_if_id; 
	 wire  if_id_reg_reset;
	 wire nop_select_control;
	 wire [15:0] final_instrn_at_if;
	 wire [15:0] pc_current;
	 wire pc_enable;
	 wire if_id_pipe_rg_en;
	 
 
 // ********************************************** signals for ID-RR STAGE ************************************************

	 wire RR_A1_Address_sel, RR_A2_Address_sel, RR_Wr_En, MEM_Wr_En;
	 wire [1:0] RR_A3_Address_sel, EXE_ALU_Src2, EXE_ALU_Oper, Reg_D3_Sel;
	 wire [2:0] A1_address, A2_address;
	 wire [15:0] RF_D1, RF_D2;
	 wire [111:0] RF_D_R6_to_R0; // 112 bit long sequence containing contents of registers R6 to R0 for SA and SM
	 wire [9:0] control_signals;
	 
 // ********************************************** signals for branch and jump in ID stage ***************************************************************	 
    
    localparam JAL = 4'b1001;
	reg nop_select_for_if_from_id = 0;
	wire rr_wr_en_at_id_resolved;
	wire mem_wr_en_at_id_resolved;		
	reg [1:0] pc_control_from_id = 2'b00;
	reg [15:0] pc_next_from_id; 

 // ********************************************** signals for RR-EX pipeline register ************************************************
     wire id_ex_reg_reset;
	 wire [15:0] pc_out_from_id_ex, PC_next_from_id_ex;
	 wire [9:0] control_sig_out_from_id_ex;
	 wire [15:0] RF_D1_out_from_id_ex, RF_D2_out_from_id_ex, ir_out_from_id_ex;
	 wire [2:0] rs1_addr_from_rr_ex, rs2_addr_from_rr_ex, rd_prev_addr_from_rr_ex;
	 wire rf_wr_en_prev_from_rr_ex;
	 wire seperate_control_for_pc_select;
	 wire data_select_control_for_pc_at_ex;
	 wire id_ex_pipe_rg_en;
 
 // ********************************************** signals for EX stage ***************************************************************		 
	 wire carry_flag_in, zero_flag_in;
	 wire carry_flag_out, zero_flag_out;
	 reg zero_flag;
	 wire carry_write_en, zero_write_en;
	 wire [1:0] alu_control_redefined;
	 wire reg_write_en_redefined;
	 wire [2:0] new_control_signals_at_ex;
	 wire [1:0] rs1_frwd_control, rs2_frwd_control;
	 wire [15:0] alu_src_A, alu_src_B;
	 wire [15:0] rf_d2_forwarded;
	 wire [15:0] imm16, rf_d2_shift_left_1;
	 wire [15:0] alu_out;
	 wire [2:0] rf_d3_addr_at_ex;
	 wire [15:0] lhi_data;
	 wire [15:0] rf_d3_data_at_ex;
	 wire [15:0] rf_d3_data_temp;
	 wire [15:0] rd_prev_data_from_rr_ex;
	 
 // ********************************************** signals for branch and jump in EX stage ***************************************************************	 
	 wire equals;
	 localparam branch = 4'b1000;
	 localparam jlr = 4'b1010;
	 localparam jri = 4'b1011;
	 wire [15:0] pc_branch ;
	 reg nop_select_for_if_from_ex = 0;
	 reg reg_and_mem_wr_disable_for_id_from_ex = 0;
	 reg [1:0] pc_control_from_ex = 2'b00; 
	 reg [15:0] pc_next_from_ex;
	 wire [1:0] pc_select;
	 
 
 // ********************************************** signals for EX-MEM pipeline register ************************************************
	wire  ex_mem_reg_reset, ex_mem_enable;
	assign ex_mem_reg_reset = reset; 
	wire [2:0] control_out_from_ex_mem, rd_addr_ex_mem;
	wire [15:0] rd_data_ex_mem, mem_data_in, mem_addr, ir_out_from_ex_mem, rd_out_at_mem, start_address_lm_sm_la_sa;	
 
 // ********************************************** signals for MEM stage ****************************************************************
    
	wire [15:0] Memory_out;	
	reg zero_wr_en_from_mem = 0;
	reg zero_flag_from_mem = 0;

 // *********** LA SA LM SM related signals *****************
	wire [15:0] addr_in_dm, address_base, mem_data_in_load_store_multi, data_in_dm;
	wire [2:0] la_sa_index, lm_sm_index, address_offset, rd_addr_chosen_from_mem;
	wire load_store_multi_freeze, reg_or_mem_en_load_store_multi;
	
	reg mux_select_addr_in_mem, mux_select_index_in_mem, mux_sel_data_for_in_mem, mux_sel_dm_wr_en, mux_sel_reg_wr_en, mux_sel_rd_addr_in_mem;
 // ********************************************** signals for MEM-WB pipeline register ************************************************
	wire mem_wb_reg_reset, mem_wb_enable;
	assign mem_wb_reg_reset = reset ; 	
	wire reg_wr_en_at_wb;
	wire [2:0] rd_addr_at_wb;
	wire [15:0] rd_data_at_wb;
	
	// ******************************************** signals for MEM-WB pipeline register ************************************************
	wire [15:0] ir_at_wb;
	
	
	// ******************************************** signals for hazard detection ********************************************************
	reg [1:0] counter = 0;   
	wire [4:0] hazard_signal;// = 5'b11111;
	
	// ******************************************** signals for branch prediction ********************************************************
	
	wire [15:0] BTA_PC_BHT;
	wire  history_bit;
	wire [15:0] pc_to_predictor_mux;
	wire taken_from_ex;	
	wire branch_spec_taken_if;
	wire spec_taken_at_if_out;
	wire spec_taken_at_id_out;
	wire match;
	

 // ***********************************************************************************************************************************************
 // ***********************************************************************************************************************************************
 // --                                                               Fetch stage 
 // ***********************************************************************************************************************************************
 // ***********************************************************************************************************************************************	
	
	// program counter + instruction memory  
	assign pc_enable = hazard_signal[4] & load_store_multi_freeze;
    register_generic  program_counter ( .clk(clk), .reset(reset), .enable(pc_enable), .in(pc_current), .out(pc_out) );
    instruction_memory instr_mem ( .clk(clk), .reset(reset) , .readAdd(pc_out), .out(instruction) );		
	assign pc_next = pc_out + 1;
	
	//hazard resolver mux for flush
	assign nop_select_control = nop_select_for_if_from_id || nop_select_for_if_from_ex;
	mux_16_bit_2_input ir_select (.ip0(instruction), .ip1(16'b0111000000000000), .select(nop_select_control), .out(final_instrn_at_if));
	
	//branch and jump pc select controller
	branch_jump_controller branch_jump_decider ( .pc_control_from_ex(pc_control_from_ex), .pc_control_from_id(pc_control_from_id), 
												 .pc_select(pc_select));
												 
	
	mux_16_bit_4_input pc_elect_mux (.ip0(pc_next), .ip1(pc_next_from_id), .ip2(pc_next_from_ex), .ip3(16'd0), 
									.select(pc_select), .out(pc_to_predictor_mux)); 
									
									
 // ********************************************************* BRANCH PREDICTION ****************************************************************

	
	
	branch_history_table bht_lut ( .clk(clk), .pcAddressforMatch(pc_out), .pc_from_ex(pc_out_from_id_ex), .pc_from_id(pc_from_if_id), 
								   .bta_from_ex(pc_next_from_ex), .bta_from_id(pc_next_from_id), .opcode_from_ex( ir_out_from_id_ex[15:12]), 
								   .opcode_from_id(ir_from_if_id[15:12]), .taken_from_ex(taken_from_ex), .branchTargetAddr(BTA_PC_BHT), 
								   .match(match), .history_bit(history_bit) ); 
	
	assign branch_spec_taken_if = match && history_bit;
	
	// branch predictor mux 
	mux_16_bit_2_input predictor_mux (.ip0(pc_to_predictor_mux), .ip1(BTA_PC_BHT), .select( branch_spec_taken_if ), .out(pc_current));
			
	
 // ********************************************************* IF-ID PIPELINE REG ****************************************************************
 
	assign if_id_reg_reset = reset;  
	assign if_id_pipe_rg_en = hazard_signal[3] & load_store_multi_freeze;
	IF2ID_Pipline_Reg if_id_pipe_reg (.clk(clk), .rst(if_id_reg_reset), .enable(if_id_pipe_rg_en), .PC_In(pc_out), .PC_Next_In(pc_next), 
							.Instr_In(final_instrn_at_if), .Spec_taken_in(branch_spec_taken_if), .PC_Out(pc_from_if_id), 
							.PC_Next_Out(pc_next_from_if_id), .Instr_Out(ir_from_if_id), .Spec_taken_out(spec_taken_at_if_out) );
							
	
 // ***********************************************************************************************************************************************
 // ***********************************************************************************************************************************************
 // --                                                               ID + RR stage
 // ***********************************************************************************************************************************************
 // ***********************************************************************************************************************************************		
     
     // CONTROL DECODER
	 control_decoder id_controller ( .opcode(ir_from_if_id[15:12]), .ir_lsb_2(ir_from_if_id[1:0]), .RR_A1_Address_sel(RR_A1_Address_sel), 
										.RR_A2_Address_sel(RR_A2_Address_sel), .RR_A3_Address_sel(RR_A3_Address_sel), .RR_Wr_En(RR_Wr_En), 
										.EXE_ALU_Src2(EXE_ALU_Src2), .EXE_ALU_Oper(EXE_ALU_Oper), .Reg_D3_Sel(Reg_D3_Sel), .MEM_Wr_En(MEM_Wr_En),
 										 .pc_data_select(seperate_control_for_pc_select) );
										
	//Control_In format {RR_A3_Address_sel, RR_Wr_En, EXE_ALU_Src2, EXE_ALU_Oper, Reg_D3_Sel, MEM_Wr_En} total 10 bits									
	assign control_signals = { RR_A3_Address_sel, rr_wr_en_at_id_resolved, EXE_ALU_Src2, EXE_ALU_Oper, Reg_D3_Sel, mem_wr_en_at_id_resolved };			

	// MUX FOR RF_A1 AND RF_A2 CONTROL 	
     mux_3_bit_2_input mux_a1 (.ip0(ir_from_if_id[11:9]), .ip1(ir_from_if_id[8:6]), .select(RR_A1_Address_sel), .out(A1_address) );		 
	 mux_3_bit_2_input mux_a2 (.ip0(ir_from_if_id[8:6]), .ip1(ir_from_if_id[11:9]), .select(RR_A2_Address_sel), .out(A2_address) );		 
	 
	 
	 // register bank
	 register_bank  register_file ( .clk(clk), .reset(reset), .readAdd1(A1_address), .readAdd2(A2_address), .writeAdd(rd_addr_at_wb)
									,.writeData(rd_data_at_wb),.writeEnable(reg_wr_en_at_wb), .readData1(RF_D1), .readData2(RF_D2),
									.readData_R6_to_R0(RF_D_R6_to_R0), .r7writeData(pc_current), .r7wrEnable(hazard_signal[4]) ); // hazard_signal[4] is pc enable
 	
	// ************************************************** JAL @ ID STAGE ***********************************************************		
	// JAL 
	always @ (*) begin 
      if ( ( ir_from_if_id[15:12] == JAL ) && ( spec_taken_at_if_out == 0 ) ) begin 
	     nop_select_for_if_from_id = 1'b1;
		 pc_control_from_id = 2'b01;
		 pc_next_from_id = pc_from_if_id + {{7{ir_from_if_id[8]}}, ir_from_if_id[8:0]} ;
		end
	  else begin  
	     nop_select_for_if_from_id = 1'b0;
		 pc_control_from_id = 2'b00;
		 pc_next_from_id = 16'd0;
	  end
	end
	// ************************************************** END OF JAL @ ID STAGE ***********************************************************		
	
	 //NOP MUX AT ID STAGE
	  mux_1_bit_2_input nop_rr_wr_en_mux (.ip0(RR_Wr_En), .ip1(1'b0), .select(reg_and_mem_wr_disable_for_id_from_ex), .out(rr_wr_en_at_id_resolved));
	  mux_1_bit_2_input nop_mem_wr_en_mux (.ip0(MEM_Wr_En), .ip1(1'b0), .select(reg_and_mem_wr_disable_for_id_from_ex), .out(mem_wr_en_at_id_resolved));
		
	 
	// ***************************************************** ID-EX PIPELINE REG ********************************************************************	
	assign id_ex_reg_reset = reset;
	assign id_ex_pipe_rg_en = hazard_signal[2] & load_store_multi_freeze;
	ID2EX_Pipline_Reg id_ex_pipe_reg (.clk(clk), .rst(id_ex_reg_reset), .enable(id_ex_pipe_rg_en), .PC_In(pc_from_if_id),.PC_NEXT_IN(pc_next_from_if_id),
								.Control_In(control_signals), .RF_A1_In(A1_address), .RF_A2_In(A2_address), .RF_A3_From_WB_In(rd_addr_at_wb), 
								.RF_D3_From_WB_In(rd_data_at_wb), .RR_Write_En_In(reg_wr_en_at_wb), .RF_D1_In(RF_D1), .RF_D2_In(RF_D2), 
								.Instr_In(ir_from_if_id), .pc_data_select(seperate_control_for_pc_select), .Spec_Taken_In(spec_taken_at_if_out), 
								.PC_Out(pc_out_from_id_ex), .Control_Out (control_sig_out_from_id_ex), .RF_A1_Out(rs1_addr_from_rr_ex), 
								.RF_A2_Out(rs2_addr_from_rr_ex), .PC_NEXT_OUT(PC_next_from_id_ex), .RF_A3_From_WB_Out(rd_prev_addr_from_rr_ex), 
								.RF_D3_From_WB_Out(rd_prev_data_from_rr_ex), .RR_Write_En_Out(rf_wr_en_prev_from_rr_ex), 
								.RF_D1_Out(RF_D1_out_from_id_ex), .RF_D2_Out(RF_D2_out_from_id_ex), .Instr_Out(ir_out_from_id_ex), 
								.pc_data_select_out(data_select_control_for_pc_at_ex), .Spec_Taken_Out(spec_taken_at_id_out));
										
 // ***********************************************************************************************************************************************
 // ***********************************************************************************************************************************************
 // --                                                               EX stage
 // ***********************************************************************************************************************************************
 // ***********************************************************************************************************************************************		
   	 
	 ALU_controller alu_control (.ir(ir_out_from_id_ex), .alu_operation_from_controller(control_sig_out_from_id_ex[4:3]), .carry_in(carry_flag_out), 
								 .zero_in(zero_flag_out), .reg_write_enable_in(control_sig_out_from_id_ex[7]), .carry_write_en(carry_write_en), 
								 .zero_write_en(zero_write_en), .alu_operation_out(alu_control_redefined), .reg_write_enable_out(reg_write_en_redefined) );
	 
	// code control register 
     register_generic carry_register (.clk(clk), .reset(reset), .enable(carry_write_en), .in(carry_flag_in), .out(carry_flag_out) ); 
     defparam carry_register.n = 1;	
	 
	 //zero_wr_en_from_mem - comes from memory, for load signals
	 // zero_flag_from_mem - comes from memory, for load signals ( load can set the zero flag)
	 
	 always @ (*) begin 
	  if ( zero_write_en ) 
	      zero_flag <= zero_flag_in;
	  else if ( zero_wr_en_from_mem )
		  zero_flag <= zero_flag_from_mem;
	  end
	 
	 register_generic zero_register (.clk(clk), .reset(reset), .enable( zero_write_en || zero_wr_en_from_mem ), 
										.in(zero_flag), .out(zero_flag_out) );
	 defparam zero_register.n = 1;
	 	 
	//forwarding unit 
	 forwarding_control_unit forwardlogic ( .rs1_addr_rr_ex(rs1_addr_from_rr_ex), .rs2_addr_rr_ex(rs2_addr_from_rr_ex),
											.rd_addr_ex_mem(rd_addr_ex_mem), .rd_addr_mem_wb(rd_addr_at_wb), 
											.rd_prev_addr_rr_ex(rd_prev_addr_from_rr_ex),.reg_wr_en_ex_mem(control_out_from_ex_mem[2]), 
											.reg_wr_en_mem_wb(reg_wr_en_at_wb),.reg_wr_en_rr_ex_prev(rf_wr_en_prev_from_rr_ex), 
											.rs1_frwd_control(rs1_frwd_control), .rs2_frwd_control(rs2_frwd_control));	 	 
	 
	// ************************************************** BRANCH + JLR + JRI @ EX STAGE ***********************************************************	
	
	// BRANCH + JLR + JRI 	
	 assign pc_branch =  pc_out_from_id_ex + {{10{ir_out_from_id_ex[5]}}, ir_out_from_id_ex[5:0]} ;
	 
	 assign equals = ( alu_src_A == rf_d2_forwarded );
	 
	 assign taken_from_ex = equals && (ir_out_from_id_ex[15:12] == branch);
	 
	 
	 /* 									prediction   	actual
												T   		NT    ------  undo the operations -- send pc + 1 back to program counter and flush
												NT  		NT    ------  nothing to do.. pc + 1 continues
												T   		T	  ------  nothing to do , bta continues
												T   		T     ------  send bta back to pc and flush
	*/
	
	always @ (*) begin 
	 if ( ir_out_from_id_ex[15:12] == branch ) begin
		if ( ( equals == 0 ) && ( spec_taken_at_id_out == 1 ) ) begin // case1 prediction - > T ; actual -> NT 
			nop_select_for_if_from_ex = 1;
			reg_and_mem_wr_disable_for_id_from_ex = 1;
			pc_control_from_ex = 2'b10; // for branch
			pc_next_from_ex = ( pc_out_from_id_ex + 16'd1 );
		end
		else if ( ( equals == 1 ) && ( spec_taken_at_id_out == 0 ) ) begin // case4 prediction - > NT ; actual -> T 
			nop_select_for_if_from_ex = 1;
			reg_and_mem_wr_disable_for_id_from_ex = 1;
			pc_control_from_ex = 2'b10; // for branch
			pc_next_from_ex = pc_branch;
		end    
		else begin  							// case 2 and 3 -- prediction succeeds
			nop_select_for_if_from_ex = 0;
			reg_and_mem_wr_disable_for_id_from_ex = 0; 
			pc_control_from_ex = 2'b00;
			pc_next_from_ex = 16'd0;
		end
	 end
	 else if ( ir_out_from_id_ex[15:12] == jlr ) begin
	    nop_select_for_if_from_ex = 1;
		reg_and_mem_wr_disable_for_id_from_ex = 1;
		pc_control_from_ex = 2'b10; // for jlr
		pc_next_from_ex = rf_d2_forwarded;
	  end
	  else if ( ir_out_from_id_ex[15:12] == jri ) begin
	    nop_select_for_if_from_ex = 1;
		reg_and_mem_wr_disable_for_id_from_ex = 1;
		pc_control_from_ex = 2'b10; // for jri
		pc_next_from_ex = alu_src_A + {{7{ir_out_from_id_ex[8]}}, ir_out_from_id_ex[8:0]} ;
	  end
	 else begin  
		nop_select_for_if_from_ex = 0;
		reg_and_mem_wr_disable_for_id_from_ex = 0; 
		pc_control_from_ex = 2'b00;
		pc_next_from_ex = 16'd0;
	 end
	end
	// ************************************************** END OF BRANCH + JLR + JRI @ EX STAGE ***************************************************	 
	 
	 // forward unit rs1 rs2 mux 
	  mux_16_bit_4_input rs1_fwd_mux(.ip0(RF_D1_out_from_id_ex), .ip1(rd_data_ex_mem), .ip2(rd_data_at_wb), .ip3(rd_prev_data_from_rr_ex), 
									.select(rs1_frwd_control), .out(alu_src_A)); 
	  mux_16_bit_4_input rs2_fwd_mux(.ip0(RF_D2_out_from_id_ex), .ip1(rd_data_ex_mem), .ip2(rd_data_at_wb), .ip3(rd_prev_data_from_rr_ex), 
									.select(rs2_frwd_control), .out(rf_d2_forwarded));
	 
	 // alu srcb select
	  assign imm16 = { {10{1'b0}}, ir_out_from_id_ex[5:0]};
	  assign rf_d2_shift_left_1 = rf_d2_forwarded << 1;
	  mux_16_bit_4_input alu_srcb_mux (.ip0(rf_d2_forwarded), .ip1(imm16), .ip2(rf_d2_shift_left_1), .ip3(16'd0), 
									.select(control_sig_out_from_id_ex[6:5]), .out(alu_src_B));	 
	 
	 // alu 	  
	  ALU alu_execute ( .in1(alu_src_A), .in2(alu_src_B), .operation(alu_control_redefined), .out(alu_out), .zero(zero_flag_in),
							.carry(carry_flag_in));
	 
	 
	 // rf_d3 address selector mux
	 mux_3_bit_4_input rf_d3_addr_select ( .ip0(ir_out_from_id_ex[5:3]), .ip1(ir_out_from_id_ex[8:6]), .ip2(ir_out_from_id_ex[11:9]), .ip3(3'd0), 
											.select(control_sig_out_from_id_ex[9:8]), .out(rf_d3_addr_at_ex));
	 // rf_d3 data selector mux ( lhi data / aluout data ) 
	 assign lhi_data = {ir_out_from_id_ex[8:0],{7{1'b0}}};
	 mux_16_bit_2_input rf_d3_data_select (.ip0(alu_out), .ip1(lhi_data), .select(control_sig_out_from_id_ex[2]), .out(rf_d3_data_temp));
	 
	 
	 // pc data / prvs mux output data ( ALUOUT data/ LHI data) select mux
	 mux_16_bit_2_input pc_data_select (.ip0(rf_d3_data_temp), .ip1(PC_next_from_id_ex), .select(data_select_control_for_pc_at_ex), 
											.out(rf_d3_data_at_ex));
	 
	 
	 
	 // control_sig_out_from_id_ex[8] this selects between memory and alu 
	 assign new_control_signals_at_ex = {reg_write_en_redefined, control_sig_out_from_id_ex[1] , control_sig_out_from_id_ex[0]};
	 
	// ***************************************************************** EX-MEM PIPELINE REG ********************************************************	
	assign ex_mem_enable = hazard_signal[1] & load_store_multi_freeze;	
	EX2MEM_Pipline_Reg ex_mem_pipe_reg ( .clk(clk), .rst(ex_mem_reg_reset), .enable(ex_mem_enable), .Control_In(new_control_signals_at_ex), 
											.Rd_Addr_In_From_Ex(rf_d3_addr_at_ex), .Rd_Data_In_From_Ex(rf_d3_data_at_ex), .RF_D1_In(alu_src_A), .RF_D2_In(rf_d2_forwarded),
											.ALU_Result_In(alu_out), .Instr_In(ir_out_from_id_ex), .Control_Out(control_out_from_ex_mem), 
											.Rd_Addr_Out_PR(rd_addr_ex_mem), .Rd_Data_Out_PR(rd_data_ex_mem), .RF_D1_Out(start_address_lm_sm_la_sa), .RF_D2_Out(mem_data_in), 
											.ALU_Result_Out(mem_addr), .Instr_Out(ir_out_from_ex_mem) );
	 
		
	 
 // ***********************************************************************************************************************************************
 // ***********************************************************************************************************************************************
 // --                                                               MEM - STAGE
 // ***********************************************************************************************************************************************
 // ***********************************************************************************************************************************************		
	 	//Section for LM SM LA SA
		
		Load_Store_Multi_Block la_sa_lm_sm_block (.clk(clk), .ir(ir_out_from_ex_mem), .rf_d2(mem_data_in), .reg_data_form_id_112(RF_D_R6_to_R0), 
												 .reg_index_la_sa(la_sa_index), .reg_index_lm_sm(lm_sm_index), .freeze(load_store_multi_freeze), 
												 .reg_or_mem_enable(reg_or_mem_en_load_store_multi), .mem_data_for_sa_sm(mem_data_in_load_store_multi));
		
		always @( * ) begin
		    // generating control signals for various muxes inside memory stage as part of LA, SA, LM and SM instructions
			if ( (ir_out_from_ex_mem[15:12] ==  4'b1100 ) || (ir_out_from_ex_mem[15:12] ==  4'b1101 ) ) begin 
				mux_select_index_in_mem = 1;
			end
			else begin
				mux_select_index_in_mem = 0;
			end
			if ( (ir_out_from_ex_mem[15:12] ==  4'b1110 ) || (ir_out_from_ex_mem[15:12] ==  4'b1111 ) || (ir_out_from_ex_mem[15:12] ==  4'b1100 ) || (ir_out_from_ex_mem[15:12] ==  4'b1101 ) ) begin 
				mux_select_addr_in_mem = 1;
			end
			else begin
				mux_select_addr_in_mem = 0;
			end
			
			if ( (ir_out_from_ex_mem[15:12] ==  4'b1110 ) || (ir_out_from_ex_mem[15:12] ==  4'b1100 ) ) begin 
				mux_sel_rd_addr_in_mem = 1;
			end
			else begin
				mux_sel_rd_addr_in_mem = 0;
			end
			
			if ( (la_sa_index ==  rd_addr_at_wb ) && reg_wr_en_at_wb ) begin 
				mux_sel_data_for_in_mem = 0;
			end
			else begin
				mux_sel_data_for_in_mem = 1;
			end
			if ( ir_out_from_ex_mem[15:12] ==  4'b1101 ) begin 
				mux_sel_dm_wr_en = 1;
			end
			else begin
				mux_sel_dm_wr_en = 0;
			end
			if ( ir_out_from_ex_mem[15:12] ==  4'b1100 ) begin 
				mux_sel_reg_wr_en = 1;
			end
			else begin
				mux_sel_reg_wr_en = 0;
			end
			
			 
		end
		
		assign dm_wr_en = mux_sel_dm_wr_en ? (control_out_from_ex_mem[0] & reg_or_mem_en_load_store_multi) : control_out_from_ex_mem[0]; 
		assign reg_wr_en_from_mem = mux_sel_reg_wr_en ? (control_out_from_ex_mem[2] & reg_or_mem_en_load_store_multi) : control_out_from_ex_mem[2]; 
		
		
		//MUX to choose btw alu_out or RF_D1 which is starting address for LA SA LM SM
		mux_16_bit_2_input mux_choosing_address (.ip0(mem_addr), .ip1(start_address_lm_sm_la_sa), .select(mux_select_addr_in_mem), .out(address_base));
		// MUX to choose between la_sa_index or lm_sm_index
		mux_3_bit_2_input mux_choosing_index (.ip0(la_sa_index), .ip1(lm_sm_index), .select(mux_select_index_in_mem), .out(address_offset) );	
		
		assign addr_in_dm = address_base + address_offset;
		
		//MUX to choose btw mem_data_in_load_store_multi or rd_data_at_wb for enabling forwarding
		mux_16_bit_2_input mux_forwardng_data (.ip0(rd_data_at_wb), .ip1(mem_data_in_load_store_multi), .select(mux_sel_data_for_in_mem), .out(data_in_dm));
		
		//MUX to choose btw addr_in_dm or rd_addr_ex_mem for specifying which register to choose
		mux_3_bit_2_input mux_choosing_rd_addr (.ip0(rd_addr_ex_mem), .ip1(la_sa_index), .select(mux_sel_rd_addr_in_mem), .out(rd_addr_chosen_from_mem));
	    
		//data memory
		data_memory  dummy_memory ( .clk(clk), .reset(reset), .accessAddress(addr_in_dm), .writeData(data_in_dm), 
									.writeEnable(dm_wr_en), .dataOut(Memory_out));									
		//MUX to choose btw alu_out or memory_data to update register_file
		mux_16_bit_2_input reg_data_select (.ip0(rd_data_ex_mem), .ip1(Memory_out), .select(control_out_from_ex_mem[1]), .out(rd_out_at_mem));
		
		always @( * ) begin
			if ( ir_out_from_ex_mem[15:12] == 4'b0100 && rd_out_at_mem == 16'd0 ) begin 
			 zero_wr_en_from_mem = 1;
			 zero_flag_from_mem = 1;
			end
			else begin
			 zero_wr_en_from_mem = 0;
			 zero_flag_from_mem = 0;
			end
			
			 
		end
				
 //********************************************************* MEM-WB PIPELINE REG ****************************************************************** 

		MEM2WB_Pipline_Reg mem_wb_pipeline_reg (.clk(clk), .rst(mem_wb_reg_reset), .enable(hazard_signal[0]), .Control_In(reg_wr_en_from_mem), 
												.Rd_Addr_In_From_Mem(rd_addr_chosen_from_mem), .Rd_Data_In_From_Mem(rd_out_at_mem), 
												 .Instr_In(ir_out_from_ex_mem), .Control_Out(reg_wr_en_at_wb), .Rd_Addr_Out_PR(rd_addr_at_wb), 
												 .Rd_Data_Out_PR(rd_data_at_wb), .Instr_Out(ir_at_wb));				
     
 // ***********************************************************************************************************************************************
 // ***********************************************************************************************************************************************
 // --                                                    HAZARD DETECTION FOR LOAD
 // ***********************************************************************************************************************************************
 // ***********************************************************************************************************************************************	 
   
    // Hazard detection to check immediate load dependency - stalls for 1 clock. No other hazard handling needed since forwarding takes care of
	// others
   
    always @( posedge clk ) begin
	  counter = 0;
      if ((ir_out_from_id_ex[15:12] == 4'b0100) && ((A1_address == rf_d3_addr_at_ex ) || (A2_address == rf_d3_addr_at_ex ))) 
	  begin
	    counter <= counter + 1;		
		if ( counter == 1 )  
		begin 
			//hazard_signal = 5'b11111;
			counter = 0;
		end
	  end
    end
    assign hazard_signal = ( counter == 1) ? 5'b00011 : 5'b11111;
endmodule
	 
	 