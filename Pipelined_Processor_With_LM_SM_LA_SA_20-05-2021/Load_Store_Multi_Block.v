module Load_Store_Multi_Block(clk, ir, rf_d2, reg_data_form_id_112, reg_index_la_sa, reg_index_lm_sm, freeze, reg_or_mem_enable, mem_data_for_sa_sm);

	output reg [2:0] reg_index_la_sa, reg_index_lm_sm;
	output reg freeze, reg_or_mem_enable;
	output reg [15:0] mem_data_for_sa_sm;
	input  [111:0] reg_data_form_id_112;
	input  [15:0] ir, rf_d2;
	input clk;
	reg [6:0] imm;
		
	parameter LA = 4'b1110;
	parameter SA = 4'b1111;
	parameter LM = 4'b1100;
	parameter SM = 4'b1101;

	
	
	initial begin 
	 reg_index_la_sa = 3'b000;
	 reg_index_lm_sm = 3'b000;
	 freeze = 1'b1;
	 reg_or_mem_enable = 1'b0;
	 mem_data_for_sa_sm = 15'd0;
    end
    
	always @(*) begin 
	    imm = ir[6:0];
		if ( (reg_index_la_sa >=0) && (reg_index_la_sa <=5) && ((ir[15:12] == LA ) || (ir[15:12] == SA ) || (ir[15:12] == LM ) || (ir[15:12] == SM )))
			freeze = 1'b0;
		else
			freeze = 1'b1;
			
		if ( imm[6 - reg_index_la_sa] == 1'b1 )
			reg_or_mem_enable = 1'b1;
		else
			reg_or_mem_enable = 1'b0;
			
		if ( (ir[15:12] == SA ) || (ir[15:12] == SM )) begin
			if( reg_index_la_sa == 0)
				mem_data_for_sa_sm = reg_data_form_id_112[15 : 0];
			else if( reg_index_la_sa == 1)
				mem_data_for_sa_sm = reg_data_form_id_112[31 : 16];
			else if( reg_index_la_sa == 2)
				mem_data_for_sa_sm = reg_data_form_id_112[47 : 32];
			else if( reg_index_la_sa == 3)
				mem_data_for_sa_sm = reg_data_form_id_112[63 : 48];
			else if( reg_index_la_sa == 4)
				mem_data_for_sa_sm = reg_data_form_id_112[79 : 64];
			else if( reg_index_la_sa == 5)
				mem_data_for_sa_sm = reg_data_form_id_112[95 : 80];
			else if( reg_index_la_sa == 6)
				mem_data_for_sa_sm = reg_data_form_id_112[111 : 96];
		end
		else begin
			mem_data_for_sa_sm = rf_d2;
		end
					
	end

	always @(posedge clk ) begin 
	  imm = ir[6:0];
	  if ( reg_index_la_sa >= 6 ) begin 
		reg_index_la_sa = 3'b000;
		reg_index_lm_sm = 3'b000;
	  end
      else if ( (ir[15:12] == LA ) || (ir[15:12] == SA )) begin
	    reg_index_la_sa = reg_index_la_sa + 1;
	  end
	  else if ( (ir[15:12] == LM ) || (ir[15:12] == SM )) begin
			if ( imm[5 - reg_index_la_sa] == 1'b1) begin
				reg_index_lm_sm = reg_index_lm_sm + 1;
			end	
	    reg_index_la_sa = reg_index_la_sa + 1;
	  end
	end

endmodule