// ir -- instruction
// alu_operation_from_controller -- the main controller outputs control signal for alu operations.. this will redefine it if adc, adz, ndz etc.
// carry_in - ccr input
//zero_in - ccr input
//reg_write_enable_in -- reg write enable from controller, 
//carry_write_en - high for instruction which sets carry
//zero_write_en - high for instruction which sets zero
// alu_operation_out --- final redefined alu control to alu unit
// reg_write_enable_out -- redefined reg_write_enable_in (disabled in case of conditional instructions not being executed (adc, etc) )


module ALU_controller (ir, alu_operation_from_controller, carry_in, zero_in,
							reg_write_enable_in, carry_write_en, zero_write_en, alu_operation_out, reg_write_enable_out );
	
	
	input [15:0] ir;
	input [1:0] alu_operation_from_controller;
	input carry_in, zero_in;
	input reg_write_enable_in;
	
	output reg carry_write_en, zero_write_en;
	output reg [1:0] alu_operation_out;
	output reg reg_write_enable_out;
	
	wire [5:0] r_type_opcode;
	
	parameter ADD = 6'b000100;
	parameter ADC = 6'b000110;
	parameter ADZ = 6'b000101;
	parameter ADL = 6'b000111;
	parameter ADI = 4'b0000;
	parameter NDU = 6'b001000;
	parameter NDC = 6'b001010;
	parameter NDZ = 6'b001001; // ADD anything we want later
	
	assign r_type_opcode = {ir[15:12], ir[1:0]};
	
	initial begin 
	  carry_write_en = 0;
	  zero_write_en = 0;
	  alu_operation_out = 2'b10;
	  reg_write_enable_out = 0;
	end
	
   always @(*) begin 
     
	  if ( r_type_opcode == ADC ) begin 
	     if ( carry_in && reg_write_enable_in) begin 
		  carry_write_en = 1;
		  zero_write_en = 1;
		  alu_operation_out = 2'b00;
		  reg_write_enable_out = 1;
		  end
		 else begin 
		  carry_write_en = 0;
		  zero_write_en = 0;
		  alu_operation_out = 2'b10;
		  reg_write_enable_out = 0;
	      end
		end
	  else if ( r_type_opcode == ADZ && reg_write_enable_in) begin 
	     if ( zero_in ) begin 
		  carry_write_en = 1;
		  zero_write_en = 1;
		  alu_operation_out = 2'b00;
		  reg_write_enable_out = 1;
		  end
		 else begin 
		  carry_write_en = 0;
		  zero_write_en = 0;
		  alu_operation_out = 2'b10;
		  reg_write_enable_out = 0;
	      end
		end
		  
	  else if ( r_type_opcode == NDC && reg_write_enable_in) begin
	     if ( carry_in ) begin 
		  carry_write_en = 0;
		  zero_write_en = 1;
		  alu_operation_out = 2'b01;
		  reg_write_enable_out = 1;
		  end
		 else begin 
		  carry_write_en = 0;
		  zero_write_en = 0;
		  alu_operation_out = 2'b10;
		  reg_write_enable_out = 0;
	      end
		end
	 else if ( r_type_opcode == NDZ && reg_write_enable_in) begin
	     if ( zero_in ) begin 
		  carry_write_en = 0;
		  zero_write_en = 1;
		  alu_operation_out = 2'b01;
		  reg_write_enable_out = 1;
		  end
		 else begin 
		  carry_write_en = 0;
		  zero_write_en = 0;
		  alu_operation_out = 2'b10;
		  reg_write_enable_out = 0;
	      end
		end		  
	 else if ( (r_type_opcode == ADD || r_type_opcode == ADL || ( ir[15:12] == ADI )) && reg_write_enable_in ) begin 
		 alu_operation_out = 2'b00;
		 carry_write_en = 1;
		 zero_write_en = 1;
		 reg_write_enable_out = 1;
		 end
	 else if ( r_type_opcode == NDU && reg_write_enable_in ) begin 
	     alu_operation_out = 2'b01;
		 zero_write_en = 1;
		 carry_write_en = 0;
		 reg_write_enable_out = 1;
		 end
	 else begin
	     alu_operation_out = alu_operation_from_controller;
		 carry_write_en = 0;
		 zero_write_en = 0;
		 reg_write_enable_out = reg_write_enable_in;
	 end
	end
		  		  
endmodule