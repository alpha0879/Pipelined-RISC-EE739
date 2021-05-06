/* Memory stage-- not sure of the values stored in ex-mem pipeline register, for the time being adding only the inputs and outputs required by
    the memory stage.*/
	
module memory_stage (clk, reset, alu_out, rf_d2_value, memwrite_enable, reg_dst, imm9_ls7, pc_current, mem_data_out, reg_write_value ) ;
 
 input clk, reset, memwrite_enable;
 input [15:0] alu_out, rf_d2_value, imm9_ls7, pc_current;
 input [1:0] reg_dst;
 
 output [15:0] mem_data_out,  reg_write_value;
 
 wire [15:0] memory_out;
 
 data_memory main_memory (.clk(clk), .reset(1'b0), .accessAddress(alu_out), .writeData(rf_d2_value), .writeEnable(memwrite_enable), .dataOut(memory_out));
 
 mux_16_bit_4_input target_reg_value (.ip0(alu_out), .ip1(memory_out), .ip2(imm9_ls7), .ip3(pc_current), .select(reg_dst), .out(reg_write_value));
 
 assign mem_data_out = memory_out;
 
 endmodule
 