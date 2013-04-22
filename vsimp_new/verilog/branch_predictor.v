
// defines //
//`define HISTORY_BITS 8
//`define PHT_ENTRIES 256
//`define BRANCH_NONE      2'b00
//`define BRANCH_TAKEN     2'b01
//`define BRANCH_NOT_TAKEN 2'b10
//`define BRANCH_UNUSED    2'b11
//`define SD #1

/*
// simple branch decoder module (combinational) //
module branch_decoder(
        IR_in,
	uncond_branch_out,
	cond_branch_out
	);

   input wire [63:0] IR_in;
   output reg uncond_branch_out;
   output reg cond_branch_out;	
	
   wire [5:0] inst_tag1;
   wire [5:0] inst_tag2;

   assign inst_tag1 = {IR_in[31:29], 3'b0};
   assign inst_tag2 =  IR_in[31:26];

   always @*
   begin
   
      cond_branch_out = 1'b0;
      uncond_branch_out = 1'b0;

      if (inst_tag1==6'h18 && inst_tag2==`JSR_GRP)
         uncond_branch_out = 1'b1;

      if (inst_tag1==6'h30 || inst_tag1==6'h38)
      begin
         if (inst_tag2==`BR_INST || inst_tag2==`BSR_INST)
            uncond_branch_out = 1'b1;
         else
            cond_branch_out = 1'b1;
      end

   end
   
endmodule
*/

// branch predictor module //
module branch_predictor (
                          clock, reset,
    
                          // pc of instruction in //
                          inst1_PC_in,
                          inst2_PC_in,

			  // for writing back the history after the branch is evaluated //
                          inst1_result_in,
                          inst1_pht_index_in,
                          inst2_result_in,
                          inst2_pht_index_in,                        
 
                          // output prediction and index //
                          inst1_prediction_out,
                          inst1_pht_index_out,
                          inst2_prediction_out,
                          inst2_pht_index_out,
 
                          ghr

                        );

//----------------inputs/outputs------------
   input wire clock;
   input wire reset;

   input wire [63:0] inst1_PC_in,inst2_PC_in;

   input wire [1:0]                 inst1_result_in,inst2_result_in;
   input wire [(`HISTORY_BITS-1):0] inst1_pht_index_in,inst2_pht_index_in;

   output wire inst1_prediction_out,inst2_prediction_out;
   output wire [(`HISTORY_BITS-1):0] inst1_pht_index_out,inst2_pht_index_out;

//----------------internal-----------
   reg [(`PHT_ENTRIES-1):0]      pht;
   reg [(`PHT_ENTRIES-1):0]  new_pht;
   output reg [(`HISTORY_BITS-1):0]     ghr;
   reg [(`HISTORY_BITS-1):0] new_ghr;
  
   wire inst1_result_taken;
   wire inst2_result_taken;
  
  
   // assignments for pht index //
   assign inst1_pht_index_out = inst1_PC_in[(`HISTORY_BITS-1):0]^ghr;
   assign inst2_pht_index_out = inst2_PC_in[(`HISTORY_BITS-1):0]^ghr;
   
   assign inst1_prediction_out = pht[inst1_pht_index_out];
   assign inst2_prediction_out = pht[inst2_pht_index_out];   
   
   // branch taken results //
   assign inst1_result_taken = (inst1_result_in==`BRANCH_TAKEN);
   assign inst2_result_taken = (inst2_result_in==`BRANCH_TAKEN);
   
   // set new pht and ghr //
   always @* 
   begin
   
      // defaults //
      new_ghr = ghr;
      new_pht = pht;
   
      // add two branches to the history //
      if (inst1_result_in!=`BRANCH_NONE && inst2_result_in!=`BRANCH_NONE)
      begin
         new_ghr = { ghr[(`HISTORY_BITS-3):0], inst1_result_taken, inst2_result_taken };
         new_pht[inst1_pht_index_in] = inst1_result_taken;
	 new_pht[inst2_pht_index_in] = inst2_result_taken;
      end
      
      // add one branch to the history from inst 1 //
      else if (inst1_result_in!=`BRANCH_NONE)
      begin
         new_ghr = { ghr[(`HISTORY_BITS-2):0], inst1_result_taken };
         new_pht[inst1_pht_index_in] = inst1_result_taken;
      end
	 
      // add one branch to the history from inst 2 //
      else if (inst2_result_in!=`BRANCH_NONE)
      begin
         new_ghr = { ghr[(`HISTORY_BITS-2):0], inst2_result_taken };
         new_pht[inst2_pht_index_in] = inst2_result_taken;
      end

   end
   

   // clock sychronous //
   always @(posedge clock)
   begin
      if(reset)
      begin
        ghr <= `SD {`HISTORY_BITS{1'b0}};
        pht <= `SD {`PHT_ENTRIES{1'b0}};
      end
      else
      begin
        ghr <= `SD new_ghr; 
        pht <= `SD new_pht;
      end
   end

endmodule


