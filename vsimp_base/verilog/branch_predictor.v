module branch_predictor (clock, reset, pc, instruction, result, pht_index_in, prediction, pht_index_out)

//----------------inputs------------
input wire clock;
input wire reset;
input reg [31:0]pc;
input reg [4:0]pht_index_in;
input reg [63:0]instruction;


//----------------outputs-----------
output reg prediction;
output reg [4:0]pht_index_out;

//----------------internal-----------
reg [4:0]pht;
reg [2:0]ghr;
reg [2:0]new_ghr;
reg [4:0]pc_bits;
reg [4:0]ghr_bits;
reg [4:0]pht_index;
reg [5:0]inst_opcode1
reg [5:0]inst_opcode2;
reg isBranch;


inst_opcode1 = instruction[63:58];
inst_opcode2 = instruction[31:26];

always@*
begin
    //decode instruction to check if branch
    if (inst_opcode1 ==  `BR_INST   || inst_opcode1 == `BSR_INST ||  
        inst_opcode1 ==  `BLBC_INST || inst_opcode1 == `BEQ_INST || 
        inst_opcode1 ==  `BLT_INST  || inst_opcode1 == `BLE_INST || 
        inst_opcode1 ==  `BLBS_INST || inst_opcode1 == `BNE_INST ||  
        inst_opcode1 ==  `BGE_INST  || inst_opcode1 == `BGT_INST)
      
      isBranch = 1;
    else
      isBranch = 0;
end 

//init pht to not taken. 0 means not taken, 1 means taken. 
pht = 32'b0;

always@*
begin
    //for use with the xor
    pc_bits = pc[6:2];
    ghr_bits = {2'b0, ghr};
    
    pht_index = pc_bits^ghr_bits;
    
    if(inst_opcode1 == `BR_INST || inst_opcode1 == `BSR_INST)
      prediction = 1;
    else
      prediction = pht[pht_index];
    
    pht_index_out = pht_index;
end



assign new_ghr = ghr<<1;
always@(posedge clk)
begin
  if(reset)
  begin
    ghr <= 3'b0;
  end

  else
  begin
    ghr <= new_ghr;
  end
end

always@*
begin
    //assume that unconditional branches don't count in the global branch history register (ghr)
    if (inst_opcode1 != `BR_INST && inst_opcode1 != `BSR_INST)
      ghr[0] = result;
    
    
    if(result != pht[pht_index_in])
      pht[pht_index_in] = result;
end

