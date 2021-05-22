This submission consists of two folders. Report and Codes.

Report Folder consists of the project report and a high resolution image of the datapath.

Codes Folder consists of all the codes in the design.

pipelined_processor.v -- the final 5 stage pipelined processor.
pipelined_processor_tb.v -- testbench with external clk and reset.

The testing has been done by modifiying the instructions in the module "instruction_memory" which is present in the file memory.v


************************************************************LIST OF FILES************************************************************

IF2ID_Pipline_Reg.v -- IF/ID Pipeline Register
ID2EX_Pipline_Reg.v -- ID/EX Pipeline Register
EX2MEM_Pipline_Reg.v -- EX/MEM Pipeline Register
MEM2WB_Pipline_Reg.v -- MEM/WB Pipeline Register

memory.v -- consists of data memory and instruction memory.

ALU.v, ALU_controller.v -- Main ALU and controller for ALU in Execute stage. (Refer Report).

branch_history_table.v -- logic for branch prediction in IF stage for branch and jump.

branch_jump_controller.v -- controller for branch/jump to select the next PC address.

control_decoder.v  -- The main controller in ID stage, which gives out control signals for all the steering logic and state updates.

forwarding_control_unit.v -- Controller for the forwarding unit present at the beginning of EX stage.

Load_Store_Multi_Block.v -- Controller for LA,SA, LM, SM instructions which is present in MEM stage. (Refer Report).(Needed to stall the pipeline for accessing
							consecutive memory address.

register_bank.v   -- Register file for 8 16 bit registers, with two read ports, one write port, one seperate port for PC address to R7, 
					 and a seperate 112 bit vector to LA/SA/LM/SM controller.
					 
					 
The hazard logic for stalls to take care of RAW dependency are implemented in the top module "pipelined_processor.v" itself.