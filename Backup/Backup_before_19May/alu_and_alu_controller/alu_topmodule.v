`timescale 1ns/1ps


module alu_topmodule ( ir, in1 , in2,  alu_operation_from_controller, carry_in, zero_in, reg_write_enable_in , reg_write_enable_out, 
					carry_write_en, zero_write_en, out, zero, carry);
							
							
		input [15:0] ir, in1, in2;
		input [1:0] alu_operation_from_controller;
		input carry_in, zero_in;
		input reg_write_enable_in;
		
		output  reg_write_enable_out, carry_write_en, zero_write_en, zero, carry;
		output [15:0] out;
		
		wire [1:0] alu_operation_out;
		
							
	ALU_controller a1 ( ir, alu_operation_from_controller, carry_in, zero_in, reg_write_enable_in, carry_write_en, zero_write_en,alu_operation_out,
							reg_write_enable_out ) ;
	ALU a2 ( in1, in2 , alu_operation_out, out, zero, carry );
	
 endmodule
 
 
 
module alu_topmodule_tb;

  reg [15:0] ir, in1 , in2 ;
  reg [1:0] alu_operation_from_controller = 0;
  reg carry_in, zero_in, reg_write_enable_in ;
  wire reg_write_enable_out,carry_write_en, zero_write_en, zero, carry;
  wire [15:0] out;
  
  alu_topmodule uut ( ir, in1 , in2,  alu_operation_from_controller, carry_in, zero_in, reg_write_enable_in , reg_write_enable_out, 
					carry_write_en, zero_write_en, out, zero, carry);
  
  initial begin
     ir = 0;
	 in1 = 0;
	 in2 = 0;
	 carry_in = 0;
	 zero_in = 0;
	 reg_write_enable_in = 0;
     #10   //add
       ir[15:12] = 4'b0001;
	   ir [1:0] = 2'b00;
	   in1 = 15'd1;
	   in2 = 15'd2;
	   alu_operation_from_controller = 2'b00;
	   carry_in = 0 ;
	   zero_in = 0 ;
	   reg_write_enable_in = 1;
	   
	 #10   //adc no carry
	   ir[15:12] = 4'b0001;
	   ir [1:0] = 2'b10;
	   in1 = 15'd1;
	   in2 = 15'd2;
	   alu_operation_from_controller = 2'b00;
	   carry_in = 0 ;
	   zero_in = 0 ;
	   reg_write_enable_in = 1;
	   
	 #10   //adc carry
       ir[15:12] = 4'b0001;
	   ir [1:0] = 2'b10;
	   in1 = 15'd1;
	   in2 = 15'd2;
	   alu_operation_from_controller = 2'b00;
	   carry_in = 1 ;
	   zero_in = 0 ;	 
	   reg_write_enable_in = 1;
	 #10 //adz no zero
       ir[15:12] = 4'b0001;
	   ir [1:0] = 2'b01;
	   in1 = 15'd1;
	   in2 = 15'd2;
	   alu_operation_from_controller = 2'b00;
	   carry_in = 1 ;
	   zero_in = 0 ;	 
	   reg_write_enable_in = 1; 
	  #10   //adz zero
       ir[15:12] = 4'b0001;
	   ir [1:0] = 2'b01;
	   in1 = 15'd1;
	   in2 = 15'd2;
	   alu_operation_from_controller = 2'b00;
	   carry_in = 1 ;
	   zero_in = 1 ;	 
	   reg_write_enable_in = 1;	  
	 #10 // adl   
	   ir[15:12] = 4'b0001;
	   ir [1:0] = 2'b11;
	   in1 = 15'd1;
	   in2 = 15'd2;
	   alu_operation_from_controller = 2'b00;
	   carry_in = 0 ;
	   zero_in = 0 ;	 
	   reg_write_enable_in = 1;	 
	  #10 // adi 
	   ir[15:12] = 4'b0000;
	   ir [1:0] = 2'b11;
	   in1 = 15'd1;
	   in2 = 15'd2;
	   alu_operation_from_controller = 2'b00;
	   carry_in = 0 ;
	   zero_in = 0 ;	 
	   reg_write_enable_in = 1;	 
	  #10   //ndu  
	   ir[15:12] = 4'b0010;
	   ir [1:0] = 2'b00;
	   in1 = 15'd1;
	   in2 = 15'd2;
	   alu_operation_from_controller = 2'b01;
	   carry_in = 0 ;
	   zero_in = 0 ;	 
	   reg_write_enable_in = 1;	
	   #10   //ndz   no zero
	   ir[15:12] = 4'b0010;
	   ir [1:0] = 2'b01;
	   in1 = 15'd1;
	   in2 = 15'd2;
	   alu_operation_from_controller = 2'b01;
	   carry_in = 0 ;
	   zero_in = 0 ;	 
	   reg_write_enable_in = 1;	
	   #10 //ndz zero 
	   ir[15:12] = 4'b0010;
	   ir [1:0] = 2'b01;
	   in1 = 15'd1;
	   in2 = 15'd2;
	   alu_operation_from_controller = 2'b01;
	   carry_in = 0 ;
	   zero_in = 1 ;	 
	   reg_write_enable_in = 1;	
	   #10 //ndc no carry
	   ir[15:12] = 4'b0010;
	   ir [1:0] = 2'b10;
	   in1 = 15'd1;
	   in2 = 15'd2;
	   alu_operation_from_controller = 2'b01;
	   carry_in = 0 ;
	   zero_in = 1 ;	 
	   reg_write_enable_in = 1;	
	   #10 //ndc carry
	   ir[15:12] = 4'b0010;
	   ir [1:0] = 2'b10;
	   in1 = 15'd1;
	   in2 = 15'd2;
	   alu_operation_from_controller = 2'b01;
	   carry_in = 1 ;
	   zero_in = 1 ;	 
	   reg_write_enable_in = 1;	
	   
	   #10  // any other ir
	   ir[15:12] = 4'b1100;
	   in1 = 15'd1;
	   in2 = 15'd2;
	   alu_operation_from_controller = 2'b01;
	   carry_in = 1 ;
	   zero_in = 1 ;	 
	   reg_write_enable_in = 0;
	   
	    #10  // any other ir
	   ir[15:12] = 4'b1110;
	   in1 = 15'd1;
	   in2 = 15'd2;
	   alu_operation_from_controller = 2'b00;
	   carry_in = 1 ;
	   zero_in = 1 ;	 
	   reg_write_enable_in = 0;
    end 

 endmodule
 




	   
	   
	   
	   
	   
	   
	   
	   