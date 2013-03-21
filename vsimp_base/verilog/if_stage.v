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

`timescale 1ns/100ps

module if_stage(// Inputs
                clock,
                reset,
                mem_wb_valid_inst,
                ex_mem_take_branch,
                ex_mem_target_pc,
                Imem2proc_data,
                    
                // Outputs
                proc2Imem_addr,

                if_NPC_out_1,        // PC+4 of fetched instruction
                if_IR_out_1,         // fetched instruction out
                if_valid_inst_out_1,  // when low, instruction is garbage
		
				if_NPC_out_2,
				if_IR_out_2,
				if_valid_inst_out_2
               );

  input         clock;              // system clock
  input         reset;              // system reset
  input         mem_wb_valid_inst;  // only go to next instruction when true
                                    // makes pipeline behave as single-cycle
  input         ex_mem_take_branch; // taken-branch signal
  input  [63:0] ex_mem_target_pc;   // target pc: use if take_branch is TRUE
  input  [63:0] Imem2proc_data;     // Data coming back from instruction-memory

  output [63:0] proc2Imem_addr;     // Address sent to Instruction memory

  output [63:0] if_NPC_out_1;         // PC of instruction after fetched (PC+4).
  output [31:0] if_IR_out_1;          // fetched instruction
  output        if_valid_inst_out_1;

  output [63:0] if_NPC_out_2;         // PC of instruction after fetched (PC+4).
  output [31:0] if_IR_out_2;          // fetched instruction
  output        if_valid_inst_out_2;

  reg    [63:0] PC_reg;               // PC we are currently fetching
  reg           if_valid_inst_out;

  wire   [63:0] PC_plus_4;
  wire   [63:0] next_PC;
  wire          PC_enable;
   
  assign proc2Imem_addr = {PC_reg[63:3], 3'b0};

    // Two words out of the Imem
  assign if_IR_out_1 = Imem2proc_data[63:32];
  assign if_IR_out_2 = Imem2proc_data[31:0];

    // Pass PC+4 down pipeline w/instruction
  assign if_NPC_out_1 = PC_reg+4;
  assign if_NPC_out_2 = (PC_reg[2]) ? if_NPC_out_1: PC_reg+8;

    // next PC is target_pc if there is a taken branch or
    // the next sequential PC (PC+4) if no branch
    // and we're on the second word or PC+8 if not.
    // (halting is handled with the enable PC_enable;
  assign next_PC = ex_mem_take_branch ? ex_mem_target_pc: if_NPC_out_2;

    // Assign the first valid only if the PC is not the second word in the cache.
    // The second is always valid
  assign if_valid_inst_out_1 = PC_reg[2] ? 1'b0: 1'b1;
  assign if_valid_inst_out_2 = 1'b1;

    // The take-branch signal must override stalling (otherwise it may be lost)
//  assign PC_enable= if_valid_inst_out | ex_mem_take_branch;    			//DO WE EVEN NEED THIS LINE?



  // This register holds the PC value
  // synopsys sync_set_reset "reset"
  always @(posedge clock)
  begin
    if(reset)
      PC_reg <= `SD 0;       // initial PC value is 0
    else if(PC_enable)
      PC_reg <= `SD next_PC; // transition to next PC
  end  // always

  
endmodule  // module if_stage
