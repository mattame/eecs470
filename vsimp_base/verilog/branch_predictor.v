//`define some  6'h3c

module branch_predictor (
                          //inputs
                          clock, reset, pc, instruction, result, pht_index_in,
                          //outputs
                          prediction, pht_index_out
                        );

//----------------inputs------------
input wire clock;
input wire reset;
input wire [31:0]pc;
input wire [4:0]pht_index_in;
input wire [63:0]instruction;
input wire result;


//----------------outputs-----------
output reg prediction;
output reg [4:0]pht_index_out;

//----------------internal-----------
reg [31:0]pht;
reg [2:0]ghr;
reg [2:0]new_ghr;
reg [4:0]pc_bits;
reg [4:0]ghr_bits;
reg [4:0]pht_index;
reg [5:0]inst_opcode1;
reg [5:0]inst_opcode2;
reg isBranch;


//decode instruction to check if branch but doesnt not count br or bsr instruction//

always@*
begin
                          	$display("instruction = %h", instruction);
    inst_opcode1 = instruction[63:58];
		$display("opcode =%h ",inst_opcode1);
    inst_opcode2 = instruction[31:26];
		

    if (inst_opcode1 ==  `BLBC_INST || inst_opcode1 == `BEQ_INST || 
        inst_opcode1 ==  `BLT_INST  || inst_opcode1 == `BLE_INST || 
        inst_opcode1 ==  `BLBS_INST || inst_opcode1 == `BNE_INST ||  
        inst_opcode1 ==  `BGE_INST  || inst_opcode1 == `BGT_INST)
  		begin
				$display("opcode1 is a branch");	      	
				isBranch = 1;
			end
    else
			begin
      	isBranch = 0;
    	end
    pc_bits = pc[6:2];        //for use with the xor
    ghr_bits = {2'b0, ghr};
    
    pht_index = pc_bits ^ ghr_bits;
    
  /*  if(inst_opcode1 == `BR_INST || inst_opcode1 == `BSR_INST) //checks if conditional branch
    begin
			$display("random shit");
      prediction = 1;
    end

    else
    begin
			$display("pc_xor_bits = %b", pc_bits);
			$display("pht_index = %b", pht_index);
      prediction = pht[pht_index];
    end
*/
		if(isBranch)
		begin
			new_ghr = ghr << 1;
		end

		else
		begin
			new_ghr = ghr;
		end
		
 /*   $display("pht is = %b ", pht);
    pht_index_out = pht_index;*/
end


always @*
begin
  if(inst_opcode1 == `BR_INST || inst_opcode1 == `BSR_INST) //checks if conditional branch
    begin
			$display("random shit");
      prediction = 1;
    end

    else
    begin
			$display("pc_xor_bits = %b", pc_bits);
			$display("pht_index = %b", pht_index);
      prediction = pht[pht_index];
    end

    $display("pht is = %b ", pht);
    pht_index_out = pht_index;
end

always @(posedge clock)
begin
  if(reset)
  begin
    ghr <= 3'b0;
    pht <= 32'b0;
		prediction <= 0;
  end

  else
  begin
    ghr <= new_ghr; 
		$display("ghr is = %b", ghr);
  end
end

always @*   //updates pht when branch is resolved
begin
    //assume that unconditional branches don't count in the global branch history register (ghr)
    if (inst_opcode1 != `BR_INST && inst_opcode1 != `BSR_INST)
      ghr[0] = result;
    
    
    if(result != pht[pht_index_in])
      pht[pht_index_in] = result;
end

endmodule
