module load_hazard( stall_for_load, pc_enable, if_id_enable, id_ex_enable, ex_mem_enable ,mem_wb_enable );

    input stall_for_load;
	output reg pc_enable, if_id_enable, id_ex_enable, ex_mem_enable ,mem_wb_enable;
	
	initial begin 
		 pc_enable = 1;
		 if_id_enable = 1;
		 id_ex_enable = 1;
		 ex_mem_enable = 1;
		 mem_wb_enable = 1;
	end
	
	always @ (*) begin 
	   if ( stall_for_load == 1 ) begin 
		 pc_enable = 0;
		 if_id_enable = 0;
		 id_ex_enable = 0;
		 ex_mem_enable = 1;
		 mem_wb_enable = 1;
		end 
	  else begin 
		 pc_enable = 1;
		 if_id_enable = 1;
		 id_ex_enable = 1;
		 ex_mem_enable = 1;
		 mem_wb_enable = 1;
	  end
	end
endmodule