/////////////////////////////////////////////////////////////////////////
//                                                                     //
//   Modulename :  if_stage.v                                          //
//                                                                     //
//  Description :  instruction fetch (IF) stage of the pipeline;       // 
//                 fetch instruction, compute next PC location, and    //
//                 send them down the pipeline.                        //
//                                                                     //
//                                                                     //
/////////////////////////////////////////////////////////////////////////

//`timescale 1ns/100ps

module if_stage(// Inputs
                clock,
                reset,
                stall,

                inst1_result_in,inst2_result_in,
                inst1_write_NPC_in,inst2_write_NPC_in,
                inst1_write_CPC_in,inst2_write_CPC_in,
                inst1_pht_index_in,inst2_pht_index_in,
                inst1_mispredict_in,inst2_mispredict_in,

                Imem2proc_data,
                Imem_valid,
                    
                // Outputs
                proc2Imem_addr,

                if_NPC_out_1,        // PC+4 of fetched instruction
                if_IR_out_1,         // fetched instruction out
                if_valid_inst_out_1,  // when low, instruction is garbage
                if_PPC_out_1,	
	
                if_NPC_out_2,
                if_IR_out_2,
                if_valid_inst_out_2,
                if_PPC_out_2,

                inst1_pht_index_out,inst2_pht_index_out

               );

  // inputs and outputs //
  input wire        clock;              // system clock
  input wire        reset;              // system reset
  input wire        stall;              // stalling signal in.

  input wire [1:0]  inst1_result_in,inst2_result_in;
  input wire [63:0] inst1_write_NPC_in,inst2_write_NPC_in;
  input wire [63:0] inst1_write_CPC_in,inst2_write_CPC_in;
  input wire [(`HISTORY_BITS-1):0] inst1_pht_index_in,inst2_pht_index_in;
  input wire inst1_mispredict_in,inst2_mispredict_in;
 
  input wire [63:0] Imem2proc_data;     // Data coming back from instruction-memory
  input wire        Imem_valid;

  output [63:0] proc2Imem_addr;     // Address sent to Instruction memory

  output [63:0] if_NPC_out_1;         // PC of instruction after fetched (PC+4).
  output [31:0] if_IR_out_1;          // fetched instruction
  output        if_valid_inst_out_1;
  output [63:0] if_PPC_out_1;

  output [63:0] if_NPC_out_2;         // PC of instruction after fetched (PC+4).
  output [31:0] if_IR_out_2;          // fetched instruction
  output        if_valid_inst_out_2;
  output [63:0] if_PPC_out_2;

  output wire [(`HISTORY_BITS-1):0] inst1_pht_index_out,inst2_pht_index_out;


  // internal regs and wires //
  reg    [63:0]      PC_reg;               // PC we are currently fetching
  wire   [63:0] next_PC;

  wire stalling;

  wire inst1_branch_taken;
  wire inst2_branch_taken;
  wire [63:0] inst1_PPC_out;
  wire [63:0] inst2_PPC_out;
  wire inst1_prediction_out;
  wire inst2_prediction_out;

  wire [(`HISTORY_BITS-1):0] ghr;


  // assign branching state //
  assign inst1_branch_taken = (inst1_result_in==`BRANCH_TAKEN);
  assign inst2_branch_taken = (inst2_result_in==`BRANCH_TAKEN);
  
  // assign mem address // 
  assign proc2Imem_addr = { PC_reg[63:3], 3'b0 };

    // Two words out of the Imem
  assign if_IR_out_1 = Imem2proc_data[31: 0];
  assign if_IR_out_2 = Imem2proc_data[63:32];

    // Pass PC+4 down pipeline w/instruction
  assign if_NPC_out_1 = PC_reg+4;
  assign if_NPC_out_2 = (PC_reg[2]) ? if_NPC_out_1 : PC_reg+8;

    // next PC is target_pc if there is a taken branch or
    // the next sequential PC (PC+4) if no branch
    // and we're on the second word or PC+8 if not.
    // (halting is handled with the enable PC_enable;
  assign stalling = (stall || ~Imem_valid);
  assign next_PC = (inst1_mispredict_in) ? ((inst1_branch_taken) ? inst1_write_CPC_in : inst1_write_NPC_in) :
                  ((inst2_mispredict_in) ? ((inst2_branch_taken) ? inst2_write_CPC_in : inst2_write_NPC_in) :
                           (stalling ? PC_reg : if_NPC_out_2) );

    // Assign the first valid only if the PC is not the second word in the cache.
    // The second is always valid
  assign if_valid_inst_out_1 = ~(PC_reg[2] || reset || stalling);
  assign if_valid_inst_out_2 = ~(reset || stalling);


   // assign predicted PC output for both instructions //
   // if branch is predicted taken, use prediciton, otherwise use the next pc
   // values // 
   assign if_PPC_out_1 = (inst1_prediction_out ? inst1_PPC_out : if_NPC_out_1);  
   assign if_PPC_out_2 = (inst2_prediction_out ? inst2_PPC_out : if_NPC_out_2);


   // branch target buffer internal module //
   branch_target_buffer btb( .clock(clock),.reset(reset),

         .inst1_result_in(inst1_result_in),.inst2_result_in(inst2_result_in),
         .inst1_write_NPC_in(inst1_write_NPC_in),.inst2_write_NPC_in(inst2_write_NPC_in),
         .inst1_write_dest_in(inst1_write_CPC_in),.inst2_write_dest_in(inst2_write_CPC_in),

         .inst1_NPC_in(if_NPC_out_1),.inst2_NPC_in(if_NPC_out_2),
         .inst1_PPC_out(inst1_PPC_out),.inst2_PPC_out(inst2_PPC_out)

   );


   // branch predictor internal module //
   branch_predictor bp(
                          .clock(clock), .reset(reset),

                          .inst1_PC_in(if_NPC_out_1),
                          .inst2_PC_in(if_NPC_out_2),

                          .inst1_result_in(inst1_result_in),
                          .inst1_pht_index_in(inst1_pht_index_in),
                          .inst2_result_in(inst2_result_in),
                          .inst2_pht_index_in(inst2_pht_index_in),

                          .inst1_prediction_out(inst1_prediction_out),
                          .inst1_pht_index_out(inst1_pht_index_out),
                          .inst2_prediction_out(inst2_prediction_out),
                          .inst2_pht_index_out(inst2_pht_index_out),

                          .ghr(ghr)

                        );



  // This register holds the PC value
  // synopsys sync_set_reset "reset"
  always @(posedge clock)
  begin
    if(reset)
      PC_reg          <= `SD 0;       // initial PC value is 0
    else
      PC_reg          <= `SD next_PC; // transition to next PC
  end  // always

  
endmodule  // module if_stage



