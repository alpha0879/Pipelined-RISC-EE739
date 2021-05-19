//1 - bit History Branch Lookup Table
// 8 entry History Table
// total size = (16 + 16 + 1) * 8 bits = 264 bits = 33 Bytes


// guess a prediction for JLR or JRI is not feasible, Making an entry is simple, but almost never works because the PC Address for
// both of these are dependent on value in Registers, which changes often. Presently not making it. :B

module branch_history_table ( clk, pcAddressforMatch, pc_from_ex, pc_from_id, bta_from_ex, bta_from_id, opcode_from_ex, opcode_from_id , taken_from_ex,
							  branchTargetAddr, match, history_bit );

input [15:0] pcAddressforMatch , pc_from_ex, pc_from_id;
input [15:0] bta_from_ex, bta_from_id;
input [3:0] opcode_from_ex, opcode_from_id;
input taken_from_ex, clk;
output reg [15:0] branchTargetAddr;
output reg  match, history_bit;

 reg [32:0] branchHistoryTable [0:7]; // [32:17] - pc, [16:1] - BTA, [0] - HB
 integer pointer = 0;
 reg [32:0] temp_data1, temp_data2;
 integer found = 0;
 integer i;
 integer j;
 reg found_at_jal = 0;
 
 localparam beq = 4'b1000;
 localparam jal = 4'b1001;
 
  initial begin 
	for ( i= 0; i <8 ; i = i + 1 ) 
	 branchHistoryTable[i] = 33'b111111111111111111111111111111111; 
  end
  
 // logic for checking whether a match is present
   always @ (pcAddressforMatch) begin 
    match = 0;
	history_bit = 0;
	branchTargetAddr = 16'd0;
    for ( i= 0; i < 8 ; i = i + 1 ) begin
	  temp_data2 = branchHistoryTable[i];
	  if ( pcAddressforMatch == temp_data2[32:17] ) begin 
	     branchTargetAddr = temp_data2[16:1];
		 history_bit = temp_data2 [0];
		 match = 1;  
      end
	end
   end
 
 // logic to make an entry to branchHistoryTable for branches and jumps
  //always @(opcode_from_ex, opcode_from_id, bta_from_id, bta_from_ex, taken_from_ex, pc_from_id, pc_from_ex) begin 
  always @(posedge clk) begin
    if ( ( opcode_from_ex == beq ) && ( taken_from_ex == 1 ) ) begin // initial case of finding beq and making an entry 
		found = 0;
		for ( j= 0; j < 8 ; j = j + 1 ) begin
			temp_data1 = branchHistoryTable[j];
			if ( pc_from_ex == temp_data1[32:17] ) begin 
				found = 1;
				branchHistoryTable[j] = {temp_data1[32:1], 1'b1 };
			end
		end	 
		
		if ( found == 0 ) begin 
			if ( pointer == 8 ) pointer = 0;
			else pointer = pointer + 1;
			branchHistoryTable[pointer] = {pc_from_ex, bta_from_ex, 1'b1 }; 
		end 
    end
	
	else if ( ( opcode_from_ex == beq ) && ( taken_from_ex == 0 ) ) begin		
		found = 0;
		for ( j= 0; j < 8 ; j = j + 1 ) begin
			temp_data1 = branchHistoryTable[j];
			if ( pc_from_ex == temp_data1[32:17] ) begin 
				found = 1;
				branchHistoryTable[j] = {temp_data1[32:1], 1'b0 };
			end
		end	 		
		/*if ( found == 0 ) begin 
			if ( pointer == 8 ) pointer = 0;
			else pointer = pointer + 1;
			branchHistoryTable[pointer] = {pc_from_ex, bta_from_ex, 1'b0 }; 
		end*/ 		
	end
	
	else  if  ( opcode_from_id == jal )  begin 
		found_at_jal = 0;
		for ( j= 0; j < 8 ; j = j + 1 ) begin
			temp_data1 = branchHistoryTable[j];
			if ( pc_from_id == temp_data1[32:17] ) found_at_jal = 1;
		end	 
		
		if ( found_at_jal == 0 ) begin 
			if ( pointer == 8 ) pointer = 0;
			else pointer = pointer + 1;
			branchHistoryTable[pointer] = {pc_from_id, bta_from_id, 1'b1 }; // for jal HB is always 1
		end 
	end
  end

endmodule