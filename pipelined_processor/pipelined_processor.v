
module pipelined_processor ( clk, reset);

	input clk, reset;
 
 // ******************************************** signals for fetch stage + if-id pipeline ************************************************
 
	 wire [15:0] pc_out, pc_next, pc_from_if_id, pc_next_from_if_id;
	 wire [15:0] instruction , ir_from_if_id; 
	 wire  if_id_reg_reset, if_id_hazard_reset;

 
 // ********************************************** signals for ID-RR STAGE ************************************************

	 wire RR_A1_Address_sel, RR_A2_Address_sel, RR_Wr_En, MEM_Wr_En;
	 wire [1:0] RR_A3_Address_sel, EXE_ALU_Src2, EXE_ALU_Oper, Reg_D3_Sel;
	 wire [2:0] A1_address, A2_address;
	 wire [15:0] RF_D1, RF_D2;
	 wire [9:0] control_signals;

 // ********************************************** signals for RR-EX pipeline register ************************************************
     wire id_ex_reg_reset, id_ex_enable;
	 wire [15:0] pc_out_from_id_ex;
	 wire [9:0] control_sig_out_from_id_ex;
	 wire [15:0] RF_D1_out_from_id_ex, RF_D2_out_from_id_ex, ir_out_from_id_ex, RF_D1_NEW, RF_D2_NEW;
	 wire [2:0] rs1_addr_from_rr_ex, rs2_addr_from_rr_ex;

 // ********************************************** signals for EX stage ***************************************************************		 
	 wire carry_flag_in, zero_flag_in;
	 wire carry_flag_out, zero_flag_out;
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

 // ********************************************** signals for EX-MEM pipeline register ************************************************
	wire ex_mem_reg_reset, ex_mem_enable;
	assign ex_mem_reg_reset = reset; 
	wire [2:0] control_out_from_ex_mem, rd_addr_ex_mem;
	wire [15:0] rd_data_ex_mem, mem_data_in, mem_addr, ir_out_from_ex_mem, rd_out_at_mem;	
 
 // ********************************************** signals for MEM stage ****************************************************************
    wire [15:0] Memory_out;	
	reg zero_wr_en_from_mem = 0;
	reg zero_flag_from_mem = 0;

 // ********************************************** signals for MEM-WB pipeline register ************************************************
	wire  mem_wb_reg_reset, mem_wb_enable;
	assign mem_wb_reg_reset = reset; 	
	wire reg_wr_en_at_wb;
	wire [2:0] rd_addr_at_wb;
	wire [15:0] rd_data_at_wb;
	
	// ********************************************** signals for MEM-WB pipeline register ************************************************
	wire [15:0] ir_at_wb;
	
	
	// ********************************************** signals for hazard detection ************************************************
	reg [1:0] counter = 0;   
	wire [4:0] hazard_signal;// = 5'b11111;

 // ***************************************************************** Fetch stage *****************************************************************
 
	// program counter + instruction memory  
    register_generic  program_counter ( .clk(clk), .reset(reset), .enable(hazard_signal[4]), .in(pc_next), .out(pc_out) );
    instruction_memory instr_mem ( .clk(clk), .reset(reset) , .readAdd(pc_out), .out(instruction) );		
	assign pc_next = pc_out + 1;
	
 // ***************************************************************** IF-ID PIPELINE REG ********************************************************
 
	assign if_id_reg_reset = reset ;  
	IF2ID_Pipline_Reg if_id_pipe_reg (.clk(clk), .rst(if_id_reg_reset), .enable(hazard_signal[3]), .PC_In(pc_out), .PC_Next_In(pc_next), 
							.Instr_In(instruction), .PC_Out(pc_from_if_id), .PC_Next_Out(pc_next_from_if_id), .Instr_Out(ir_from_if_id));
							
	
 // ***************************************************************** ID + RR stage *****************************************************************
 
     // CONTROL DECODER
	 control_decoder id_controller ( .opcode(ir_from_if_id[15:12]), .ir_lsb_2(ir_from_if_id[1:0]), .RR_A1_Address_sel(RR_A1_Address_sel), 
										.RR_A2_Address_sel(RR_A2_Address_sel), .RR_A3_Address_sel(RR_A3_Address_sel), .RR_Wr_En(RR_Wr_En), 
										.EXE_ALU_Src2(EXE_ALU_Src2), .EXE_ALU_Oper(EXE_ALU_Oper), .Reg_D3_Sel(Reg_D3_Sel), .MEM_Wr_En(MEM_Wr_En) );
										
	//Control_In format {RR_A3_Address_sel, RR_Wr_En, EXE_ALU_Src2, EXE_ALU_Oper, Reg_D3_Sel, MEM_Wr_En} total 10 bits									
	assign control_signals = { RR_A3_Address_sel, RR_Wr_En, EXE_ALU_Src2, EXE_ALU_Oper, Reg_D3_Sel, MEM_Wr_En };																

	// MUX FOR RF_A1 AND RF_A2 CONTROL 	
     mux_3_bit_2_input mux_a1 (.ip0(ir_from_if_id[11:9]), .ip1(ir_from_if_id[8:6]), .select(RR_A1_Address_sel), .out(A1_address) );		 
	 mux_3_bit_2_input mux_a2 (.ip0(ir_from_if_id[8:6]), .ip1(ir_from_if_id[11:9]), .select(RR_A2_Address_sel), .out(A2_address) );		 
	 
	 
	 // register bank
	 register_bank  register_file ( .clk(clk), .reset(reset), .readAdd1(A1_address), .readAdd2(A2_address), .writeAdd(rd_addr_at_wb)
									,.writeData(rd_data_at_wb),.writeEnable(reg_wr_en_at_wb), .readData1(RF_D1), .readData2(RF_D2)  ,
									.r7writeData(pc_next), .r7wrEnable(hazard_signal[4])); // hazard_signal[4] is pc enable		


	//forwarding unit 
	 forwarding_control_unit forwardlogic ( .rs1_addr_rr(A1_address), .rs2_addr_rr(A2_address),
											.rd_addr_ex(rf_d3_addr_at_ex), .rd_addr_mem(rd_addr_ex_mem), 
											.rd_addr_wb(rd_addr_at_wb),.reg_wr_en_ex(reg_write_en_redefined), 
											.reg_wr_en_mem(control_out_from_ex_mem[2]),.reg_wr_en_wb(reg_wr_en_at_wb), 
											.rs1_frwd_control(rs1_frwd_control), .rs2_frwd_control(rs2_frwd_control));	 	 
	 

	 // forward unit rs1 rs2 mux 
	  mux_16_bit_4_input rs1_fwd_mux(.ip0(RF_D1), .ip1(rf_d3_data_at_ex), .ip2(rd_out_at_mem), .ip3(rd_data_at_wb), 
									.select(rs1_frwd_control), .out(RF_D1_NEW)); 
	  mux_16_bit_4_input rs2_fwd_mux(.ip0(RF_D2), .ip1(rf_d3_data_at_ex), .ip2(rd_out_at_mem), .ip3(rd_data_at_wb), 
									.select(rs2_frwd_control), .out(RF_D2_NEW));
									
	 
	// ***************************************************************** ID-EX PIPELINE REG ********************************************************	
	assign id_ex_reg_reset = reset;
	
	 ID2EX_Pipline_Reg id_ex_pipe_reg (.clk(clk), .rst(id_ex_reg_reset), .enable(hazard_signal[2]), .PC_In(pc_from_if_id), .Control_In(control_signals), 
								.RF_A1_In(A1_address), .RF_A2_In(A2_address),.RF_D1_In(RF_D1_NEW), .RF_D2_In(RF_D2_NEW), .Instr_In(ir_from_if_id), 
								.PC_Out(pc_out_from_id_ex),.Control_Out (control_sig_out_from_id_ex), .RF_A1_Out(rs1_addr_from_rr_ex), 
								.RF_A2_Out(rs2_addr_from_rr_ex),.RF_D1_Out(alu_src_A), .RF_D2_Out(rf_d2_forwarded), .Instr_Out(ir_out_from_id_ex));
										
	// ***************************************************************** EX stage *****************************************************************
	 
	 ALU_controller alu_control (.ir(ir_out_from_id_ex), .alu_operation_from_controller(control_sig_out_from_id_ex[4:3]), .carry_in(carry_flag_out), 
								 .zero_in(zero_flag_out), .reg_write_enable_in(control_sig_out_from_id_ex[7]), .carry_write_en(carry_write_en), 
								 .zero_write_en(zero_write_en), .alu_operation_out(alu_control_redefined), .reg_write_enable_out(reg_write_en_redefined) );
	 
	// code control register 
     register_generic carry_register (.clk(clk), .reset(reset), .enable(carry_write_en), .in(carry_flag_in), .out(carry_flag_out) ); 
     defparam carry_register.n = 1;	
	 
	 //zero_wr_en_from_mem - comes from memory, for load signals
	 // zero_flag_from_mem - comes from memory, for load signals ( load can set the zero flag)
	 register_generic zero_register (.clk(clk), .reset(reset), .enable( zero_write_en || zero_wr_en_from_mem ), 
										.in(zero_flag_in || zero_flag_from_mem), .out(zero_flag_out) );
	 defparam zero_register.n = 1;
	 
	 //Control_In format {RR_A3_Address_sel(btwn aluout and mem), RR_Wr_En, EXE_ALU_Oper, MEM_Wr_En} total 3 bits	
	
	 
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
	 // rf_d3 data selector mux
	 assign lhi_data = {ir_out_from_id_ex[8:0],{7{1'b0}}};
	 mux_16_bit_2_input rf_d3_data_select (.ip0(alu_out), .ip1(lhi_data), .select(control_sig_out_from_id_ex[2]), .out(rf_d3_data_at_ex));
	 	 	 
	 // control_sig_out_from_id_ex[8] this selects between memory and alu 
	 assign new_control_signals_at_ex = {reg_write_en_redefined, control_sig_out_from_id_ex[1] , control_sig_out_from_id_ex[0]};
	 
	// ***************************************************************** EX-MEM PIPELINE REG ********************************************************	
		
	 EX2MEM_Pipline_Reg ex_mem_pipe_reg ( .clk(clk), .rst(ex_mem_reg_reset), .enable(hazard_signal[1]), .Control_In(new_control_signals_at_ex), 
											.Rd_Addr_In_From_Ex(rf_d3_addr_at_ex), .Rd_Data_In_From_Ex(rf_d3_data_at_ex), .RF_D2_In(rf_d2_forwarded),
											.ALU_Result_In(alu_out), .Instr_In(ir_out_from_id_ex), .Control_Out(control_out_from_ex_mem), 
											.Rd_Addr_Out_PR(rd_addr_ex_mem), .Rd_Data_Out_PR(rd_data_ex_mem), .RF_D2_Out(mem_data_in), 
											.ALU_Result_Out(mem_addr), .Instr_Out(ir_out_from_ex_mem) );
	 
		
	 
	 
	// ***************************************************************** MEM - STAGE *********************************************************** 
	 		 
	    //data memory
		data_memory  dummy_memory ( .clk(clk), .reset(reset), .accessAddress(mem_addr), .writeData(mem_data_in), 
									.writeEnable(control_out_from_ex_mem[0]), .dataOut(Memory_out));									
		//MUX to choose btw alu_out or memory_data to update register_file
		mux_16_bit_2_input reg_data_select (.ip0(rd_data_ex_mem), .ip1(Memory_out), .select(control_out_from_ex_mem[1]), .out(rd_out_at_mem));
		
		always @( * ) begin
			if ( ir_out_from_ex_mem == 4'b0100 && rd_out_at_mem == 16'd0 ) begin 
			 zero_wr_en_from_mem = 1;
			 zero_flag_from_mem = 1;
			end
			else begin
			 zero_wr_en_from_mem = 0;
			 zero_flag_from_mem = 0;
			end
			
			 
		end
				
	//*************************************************** MEM-WB PIPELINE REG *************************************************************** 

		MEM2WB_Pipline_Reg mem_wb_pipeline_reg (.clk(clk), .rst(mem_wb_reg_reset), .enable(hazard_signal[0]), .Control_In(control_out_from_ex_mem[2]), 
												.Rd_Addr_In_From_Mem(rd_addr_ex_mem), .Rd_Data_In_From_Mem(rd_out_at_mem), 
												 .Instr_In(ir_out_from_ex_mem), .Control_Out(reg_wr_en_at_wb), .Rd_Addr_Out_PR(rd_addr_at_wb), 
												 .Rd_Data_Out_PR(rd_data_at_wb), .Instr_Out(ir_at_wb));				
     
    //*************************************************** HAZARD DETECTION *************************************************************** 	
   
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
	 
	 