/////////////////////////////////////////////////////////////////////////
//                                                                     //
//   Modulename :  pipeline.v                                          //
//                                                                     //
//  Description :  Top-level module of the verisimple pipeline;        //
//                 This instantiates and connects the 5 stages of the  //
//                 Verisimple pipeline.                                //
//                                                                     //
//                                                                     //
/////////////////////////////////////////////////////////////////////////
/***
*
* These are the abbreviations to make it easier to reference:
*
*    IF  = Instruction Fetch
*    ID  = Instruction Decode     
*    MT  = Map Table
*    REG = Register File
*    ROB = Reorder Buffer
*    RS  = Reservation Station
*    EX  = Execute
*    CM  = Complete
*     
***/

//`timescale 1ns/100ps

module pipeline (// Inputs
                 clock,
                 reset,
                 mem2proc_response,
                 mem2proc_data,
                 mem2proc_tag,
                 
                 // Outputs
                 proc2mem_command,
                 proc2mem_addr,
                 proc2mem_data,

                 pipeline_completed_insts,
                 pipeline_error_status,
                 pipeline_commit_wr_data,
                 pipeline_commit_wr_idx,
                 pipeline_commit_wr_en,
                 pipeline_commit_NPC,


                 // testing hooks (these must be exported so we can test
                 // the synthesized version) data is tested by looking at
                 // the final values in memory
                 if_NPC_out,
                 id_IR_1,
                 id_IR_2,
                 if_valid_inst_out,
                 if_id_NPC,
                 if_id_IR,
                 if_id_valid_inst,
                 id_ex_NPC,
                 id_ex_IR,
                 id_ex_valid_inst,
                 ex_mem_NPC,
                 ex_mem_IR,
                 ex_mem_valid_inst,
                 mem_wb_NPC,
                 mem_wb_IR,
                 mem_wb_valid_inst
                );

  input         clock;             // System clock
  input         reset;             // System reset
  input  [3:0]  mem2proc_response; // Tag from memory about current request
  input  [63:0] mem2proc_data;     // Data coming back from memory
  input  [3:0]  mem2proc_tag;      // Tag from memory about current reply

  output [1:0]  proc2mem_command;  // command sent to memory
  output [63:0] proc2mem_addr;     // Address sent to memory
  output [63:0] proc2mem_data;     // Data sent to memory

  output [3:0]  pipeline_completed_insts;
  output [3:0]  pipeline_error_status;
  output [4:0]  pipeline_commit_wr_idx;
  output [63:0] pipeline_commit_wr_data;
  output        pipeline_commit_wr_en;
  output [63:0] pipeline_commit_NPC;

  output [63:0] if_NPC_out;
  output        if_valid_inst_out;
  output [63:0] if_id_NPC;
  output [31:0] if_id_IR;
  output        if_id_valid_inst;
  output [63:0] id_ex_NPC;
  output [31:0] id_ex_IR;
  output        id_ex_valid_inst;
  output [63:0] ex_mem_NPC;
  output [31:0] ex_mem_IR;
  output        ex_mem_valid_inst;
  output [63:0] mem_wb_NPC;
  output [31:0] mem_wb_IR;
  output        mem_wb_valid_inst;

  // Pipeline register enables
  wire   if_id_enable, id_ex_enable, ex_mem_enable, mem_wb_enable;

 // Outputs from IF-Stage
 // wire [63:0] proc2Imem_addr;     // Address sent to Instruction memory

  wire [63:0] if_NPC_out_1;         // PC of instruction after fetched (PC+4).
  wire [31:0] if_IR_out_1;          // fetched instruction
  wire        if_valid_inst_out_1;
  wire [63:0] if_PPC_out_1;
  wire [(`HISTORY_BITS-1):0] if_inst1_pht_index_out;

  wire [63:0] if_NPC_out_2;         // PC of instruction after fetched (PC+4).
  wire [31:0] if_IR_out_2;          // fetched instruction
  wire        if_valid_inst_out_2;
  wire [63:0] if_PPC_out_2;
  wire [(`HISTORY_BITS-1):0] if_inst2_pht_index_out;


// Outputs from IF/ID Pipeline Register
  reg [63:0] id_NPC_1;
  output reg [31:0] id_IR_1;
  reg        id_valid_inst1;
  reg [63:0] id_PPC_1;
 
  reg [63:0] id_NPC_2;
  output reg [31:0] id_IR_2;
  reg        id_valid_inst2;
  reg [63:0] id_PPC_2;
  
  reg [(`HISTORY_BITS-1):0] id_inst1_pht_index, id_inst2_pht_index;

//Outputs from ID Stage 
  wire  [4:0] id_rega_out_1, id_regb_out_1, id_dest_reg_out_1;
  wire  [1:0] id_opa_select_out_1, id_opb_select_out_1;
  wire  [4:0] id_alu_func_out_1;
  wire        id_rd_mem_out_1;
  wire        id_wr_mem_out_1;
  wire        id_cond_branch_out_1;
  wire        id_uncond_branch_out_1;
  wire        id_halt_out_1;
  wire        id_illegal_out_1;
  wire        id_valid_inst_out_1; 
  
  wire  [4:0] id_rega_out_2, id_regb_out_2, id_dest_reg_out_2;
  wire  [1:0] id_opa_select_out_2, id_opb_select_out_2;
  wire  [4:0] id_alu_func_out_2;
  wire        id_rd_mem_out_2;
  wire        id_wr_mem_out_2;
  wire        id_cond_branch_out_2;
  wire        id_uncond_branch_out_2;
  wire        id_halt_out_2;
  wire        id_illegal_out_2;
  wire        id_valid_inst_out_2;  
  
//Outputs from ID / [MT/REG] Pipeline Regsiter

  //MT Pipeline Registers
  reg [4:0] mt_inst1_rega, mt_inst1_regb;
  reg [4:0] mt_inst2_rega, mt_inst2_regb;
  
  reg [4:0] mt_inst1_dest;
  reg [4:0] mt_inst2_dest;
  reg [7:0] mt_inst1_tag;
  reg [7:0] mt_inst2_tag;

  //REG Pipeline Registers 
  reg  [4:0] reg_inst1_rega;
  reg  [4:0] reg_inst1_regb;
  reg  [4:0] reg_inst2_rega;
  reg  [4:0] reg_inst2_regb;
   
  reg  [4:0] reg_inst1_dest;
  reg  [4:0] reg_inst2_dest;
  reg [63:0] reg_inst1_value;
  reg [63:0] reg_inst2_value;
  
  //FF Pipeline Registers
  reg  [4:0] ff_dest_reg_1;
  reg  [1:0] ff_opa_select_1, ff_opb_select_1;
  reg  [4:0] ff_alu_func_1;
  reg        ff_rd_mem_1;
  reg        ff_wr_mem_1;
  reg        ff_cond_branch_1;
  reg        ff_uncond_branch_1;
  reg        ff_halt_1;
  reg        ff_illegal_1;
  reg        ff_valid_inst1; 

  reg  [4:0] ff_dest_reg_2;  
  reg  [1:0] ff_opa_select_2, ff_opb_select_2;
  reg  [4:0] ff_alu_func_2;
  reg        ff_rd_mem_2;
  reg        ff_wr_mem_2;
  reg        ff_cond_branch_2;
  reg        ff_uncond_branch_2;
  reg        ff_halt_2;
  reg        ff_illegal_2;
  reg        ff_valid_inst2;  

  reg [63:0] ff_NPC_1;
  reg [31:0] ff_IR_1;
  reg [63:0] ff_PPC_1;
  
  reg [63:0] ff_NPC_2;
  reg [31:0] ff_IR_2;
  reg [63:0] ff_PPC_2;
  
  reg [(`HISTORY_BITS-1):0] ff_inst1_pht_index, ff_inst2_pht_index;

//Outputs from MT
   wire [7:0] mt_inst1_taga_out, mt_inst1_tagb_out;
   wire [7:0] mt_inst2_taga_out, mt_inst2_tagb_out;

//Outputs from REG

   wire [63:0] reg_inst1_rega_out;
   wire [63:0] reg_inst1_regb_out;
   wire [63:0] reg_inst2_rega_out;
   wire [63:0] reg_inst2_regb_out;
   wire [31:0] reg_clear_entries_out;

//Outputs from [MT/REG] / [RS/ROB] Pipeline Register
   reg                       rob_inst1_valid;
   reg                       rob_inst2_valid;
   reg  [4:0]                rob_inst1_dest;
   reg  [4:0]                rob_inst2_dest;

   reg  [7:0]                rob_inst1_taga;
   reg  [7:0]                rob_inst1_tagb;
   reg  [7:0]                rob_inst2_taga;
   reg  [7:0]                rob_inst2_tagb;
   
   reg [63:0]                rs_inst1_rega_value, rs_inst1_regb_value;
   reg [7:0]                 rs_inst1_rega_tag, rs_inst1_regb_tag;
   reg [4:0]                 rs_inst1_dest_reg;
   reg [7:0]                 rs_inst1_dest_tag;
   reg [1:0]                 rs_inst1_opa_select, rs_inst1_opb_select;
   reg [4:0]                 rs_inst1_alu_func;
   reg                       rs_inst1_rd_mem, rs_inst1_wr_mem;
   reg                       rs_inst1_cond_branch, rs_inst1_uncond_branch;
   reg [63:0]                rs_inst1_NPC;
   reg [31:0]                rs_inst1_IR;
   reg [63:0]                rs_inst1_PPC;
   reg [(`HISTORY_BITS-1):0] rs_inst1_pht_index;
   reg                       rs_inst1_valid;
   
   reg [63:0]                rs_inst2_rega_value, rs_inst2_regb_value;
   reg [7:0]                 rs_inst2_rega_tag, rs_inst2_regb_tag;
   reg [4:0]                 rs_inst2_dest_reg;
   reg [7:0]                 rs_inst2_dest_tag;
   reg [1:0]                 rs_inst2_opa_select, rs_inst2_opb_select;
   reg [4:0]                 rs_inst2_alu_func;
   reg                       rs_inst2_rd_mem, rs_inst2_wr_mem;
   reg                       rs_inst2_cond_branch, rs_inst2_uncond_branch;
   reg [63:0]                rs_inst2_NPC;
   reg [31:0]                rs_inst2_IR;
   reg [63:0]                rs_inst2_PPC;
   reg [(`HISTORY_BITS-1):0] rs_inst2_pht_index;
   reg                       rs_inst2_valid;

   reg [63:0]                inst1_rega_rob_value;
   reg [63:0]                inst1_regb_rob_value;
   reg [63:0]                inst2_rega_rob_value;
   reg [63:0]                inst2_regb_rob_value;


//Outputs from ROB
   wire [7:0]                 rob_inst1_tag_out;
   wire [7:0]                 rob_inst2_tag_out;

   wire [63:0]                rob_inst1_rega_value_out;
   wire [63:0]                rob_inst1_regb_value_out;
   wire [63:0]                rob_inst2_rega_value_out;
   wire [63:0]                rob_inst2_regb_value_out;

   wire [4:0]                 rob_inst1_dest_out;
   wire [63:0]                rob_inst1_value_out;
   wire [7:0]                 rob_inst1_retire_tag_out;
   wire [4:0]                 rob_inst2_dest_out;
   wire [63:0]                rob_inst2_value_out;
   wire [7:0]                 rob_inst2_retire_tag_out;

   wire                       rob_inst1_mispredicted_out;
   wire [1:0]                 rob_inst1_branch_result_out;
   wire [63:0]                rob_inst1_NPC_out;
   wire [(`HISTORY_BITS-1):0] rob_inst1_pht_index_out;
   wire [63:0]                rob_inst1_CPC_out;
   
   wire                       rob_inst2_mispredicted_out;
   wire [1:0]                 rob_inst2_branch_result_out;
   wire [63:0]                rob_inst2_NPC_out;
   wire [(`HISTORY_BITS-1):0] rob_inst2_pht_index_out;
   wire [63:0]                rob_inst2_CPC_out;

   wire                       rob_rob_full_out;
   wire                       rob_rob_empty_out;
   
//Outputs from RS
   wire [63:0]                rs_inst1_rega_value_out, rs_inst1_regb_value_out;
   wire [1:0]                 rs_inst1_opa_select_out, rs_inst1_opb_select_out;
   wire [4:0]                 rs_inst1_alu_func_out;
   wire                       rs_inst1_rd_mem_out, rs_inst1_wr_mem_out;
   wire                       rs_inst1_cond_branch_out, rs_inst1_uncond_branch_out;
   wire [63:0]                rs_inst1_NPC_out;
   wire [31:0]                rs_inst1_IR_out;
   wire [63:0]                rs_inst1_PPC_out;
   wire [(`HISTORY_BITS-1):0] rs_inst1_pht_index_out;
   wire                       rs_inst1_valid_out;
   wire [4:0]                 rs_inst1_dest_reg_out;
   wire [7:0]                 rs_inst1_dest_tag_out;

   wire [63:0]                rs_inst2_rega_value_out, rs_inst2_regb_value_out;
   wire [1:0]                 rs_inst2_opa_select_out, rs_inst2_opb_select_out;
   wire [4:0]                 rs_inst2_alu_func_out;
   wire                       rs_inst2_rd_mem_out, rs_inst2_wr_mem_out;
   wire                       rs_inst2_cond_branch_out, rs_inst2_uncond_branch_out;
   wire [63:0]                rs_inst2_NPC_out;
   wire [31:0]                rs_inst2_IR_out;
   wire [63:0]                rs_inst2_PPC_out;
   wire [(`HISTORY_BITS-1):0] rs_inst2_pht_index_out;
   wire                       rs_inst2_valid_out;
   wire [4:0]                 rs_inst2_dest_reg_out;
   wire [7:0]                 rs_inst2_dest_tag_out;
   
  //debugging RS outputs
  
  wire rs_dispatch_out; 
  wire [(`NUM_RSES*3-1):0] rs_states_out;
  wire [(`NUM_RSES-1):0] rs_fills_out;
  
  wire [(`NUM_RSES-1):0] rs_first_empties_out;    // bit to indicate whether an rs entry is the first empty one available 
  wire [(`NUM_RSES-1):0] rs_second_empties_out;   // bit to indicate whether an rs entry is the second empty one available
  
  wire [(`NUM_RSES*8-1):0] rs_ages_out;
  
  wire [(`NUM_RSES-1):0] rs_issue_first_states_out;   // indicates whether or not this rs entry should issue next (first out)
  wire [(`NUM_RSES-1):0] rs_issue_second_states_out;  // indicates whether or not this rs entry should issue next (second out)
   
//Outputs from [RS/ROB] / EX Pipeline Register  
  reg         ex_valid_1;
  reg  [63:0] ex_NPC_1;         // incoming instruction PC+4
  reg  [63:0] ex_PPC_1;		 // Predicted PC for branches
  reg  [(`HISTORY_BITS-1):0] ex_pht_idx_1;
  reg  [31:0] ex_IR_1;          // incoming instruction
  reg   [7:0] ex_dest_reg_1;	 // destination register
  reg  [63:0] ex_rega_1;        // register A value from reg file
  reg  [63:0] ex_regb_1;        // register B value from reg file
  reg   [1:0] ex_opa_select_1;  // opA mux select from decoder
  reg   [1:0] ex_opb_select_1;  // opB mux select from decoder
  reg   [4:0] ex_alu_func_1;    // ALU function select from decoder
  reg         ex_cond_branch_1;   // is this a cond br? from decoder
  reg         ex_uncond_branch_1; // is this an uncond br? from decoder
  reg         ex_rd_mem_1;
  reg         ex_wr_mem_1;

  reg         ex_valid_2;
  reg  [63:0] ex_NPC_2;         // incoming instruction PC+4
  reg  [63:0] ex_PPC_2;		 // Predicted PC for branches
  reg  [(`HISTORY_BITS-1):0] ex_pht_idx_2;
  reg  [31:0] ex_IR_2;          // incoming instruction
  reg   [7:0] ex_dest_reg_2;	 // destination register
  reg  [63:0] ex_rega_2;        // register A value from reg file
  reg  [63:0] ex_regb_2;        // register B value from reg file
  reg   [1:0] ex_opa_select_2;  // opA mux select from decoder
  reg   [1:0] ex_opb_select_2;  // opB mux select from decoder
  reg   [4:0] ex_alu_func_2;    // ALU function select from decoder
  reg         ex_cond_branch_2;   // is this a cond br? from decoder
  reg         ex_uncond_branch_2; // is this an uncond br? from decoder 
  reg         ex_rd_mem_2;
  reg         ex_wr_mem_2;
 
   
//Outputs from EX-Stage
  wire        stall_bus_1;	     // Should input bus 1 stall?
  wire        stall_bus_2;	     // Should input bus 2 stall?
  wire        ex_branch_taken;  // is this a taken branch?

  wire   [7:0] ex_mem_tag_out;
  wire [63:0]  ex_mem_value_out;
  wire         ex_mem_valid_out;
 
  // Bus 1
  wire [63:0] ex_NPC_out_1;
  wire [7:0]  ex_dest_reg_out_1;
  wire [63:0] ex_result_out_1;
  wire        ex_mispredict_out_1;
  wire [1:0]  ex_branch_result_out_1;
  wire [(`HISTORY_BITS-1):0]  ex_pht_idx_out_1;
  wire        ex_valid_out_1;
  wire [63:0] ex_CPC_out_1;
  
				// Bus 2
  wire [63:0] ex_NPC_out_2;
  wire [7:0]  ex_dest_reg_out_2;
  wire [63:0] ex_result_out_2;
  wire        ex_mispredict_out_2;
  wire [1:0]  ex_branch_result_out_2;
  wire [(`HISTORY_BITS-1):0]  ex_pht_idx_out_2;
  wire        ex_valid_out_2;
  wire [63:0] ex_CPC_out_2;


//Outputs from EX / CM Pipline Register
   reg [7:0]                 cm_tag_1;
   reg [63:0]                cm_result_1;
   reg [63:0]                cm_NPC_1;
   reg                       cm_mispredict_1;
   reg [1:0]                 cm_branch_result_1;
   reg [(`HISTORY_BITS-1):0] cm_pht_index_1;
   reg                       cm_valid_1;
   reg [63:0]                cm_CPC_1;

   reg [7:0]                 cm_tag_2;
   reg [63:0]                cm_result_2;
   reg [63:0]                cm_NPC_2;
   reg                       cm_mispredict_2;
   reg [1:0]                 cm_branch_result_2;
   reg [(`HISTORY_BITS-1):0] cm_pht_index_2;
   reg                       cm_valid_2;
   reg [63:0]                cm_CPC_2;


//Outputs from Complete Stage
   wire [7:0]                 cm_tag_out_1;
   wire [63:0]                cm_value_out_1;
   wire [63:0]                cm_NPC_out_1;
   wire                       cm_mispredict_out_1;
   wire [1:0]                 cm_branch_result_out_1;
   wire [(`HISTORY_BITS-1):0] cm_pht_index_out_1;
   wire                       cm_valid_out_1;
   wire [63:0]                cm_CPC_out_1;

   wire [7:0]                 cm_tag_out_2;
   wire [63:0]                cm_value_out_2;
   wire [63:0]                cm_NPC_out_2;
   wire                       cm_mispredict_out_2;
   wire [1:0]                 cm_branch_result_out_2;
   wire [(`HISTORY_BITS-1):0] cm_pht_index_out_2;
   wire                       cm_valid_out_2;
   wire [63:0]                cm_CPC_out_2;
   
//LSQ Inputs

 reg [7:0] lsq_ROB_head_1;
 reg [7:0] lsq_ROB_head_2;

 reg [7:0] lsq_ROB_tag_1;
 reg       lsq_rd_mem_1;
 reg 		   lsq_wr_mem_1;
 reg 		   lsq_valid_1;

 reg [7:0]  lsq_EX_tag_1;
 reg [63:0] lsq_value_1;
 reg [63:0] lsq_address_1;
 reg        lsq_EX_valid_1;

 reg [7:0]  lsq_ROB_tag_2;
 reg        lsq_rd_mem_2;
 reg 		    lsq_wr_mem_2;
 reg 		    lsq_valid_2;

 reg [7:0]  lsq_EX_tag_2;
 reg [63:0] lsq_value_2;
 reg [63:0] lsq_address_2;
 reg        lsq_EX_valid_2;
 
 reg  [63:0] lsq_Dmem2proc_data;
 reg   [3:0] lsq_Dmem2proc_tag, lsq_Dmem2proc_response;
 
//LSQ outputs
  wire [7:0]  lsq_tag_out;
  wire [63:0] lsq_mem_result_out;    // outgoing instruction result (to MEM/WB)
  wire [1:0]  lsq_proc2Dmem_command_out;
  wire [63:0] lsq_proc2Dmem_addr_out;     // Address sent to data-memory
  wire [63:0] lsq_proc2Dmem_data_out;     // Data sent to data-memory
  
  wire lsq_LSQ_IF_stall_out, lsq_LSQ_EX_valid_out;
  wire LSQ_full,LSQ_empty;
 
  /**********************************/
  /**********************************/
  /**********************************/
  
  //wires to be sorted
  
  
//from ex stage  
  wire   [7:0] ex_MEM_tag_in;
  wire  [63:0] ex_MEM_value_in;
  wire         ex_MEM_valid_in;
  
   
  wire  [7:0] ex_LSQ_tag_out_1;
  wire [63:0] ex_LSQ_address_out_1;
  wire [63:0] ex_LSQ_value_out_1;
  wire        ex_LSQ_valid_out_1;

  wire  [7:0] ex_LSQ_tag_out_2;
  wire [63:0] ex_LSQ_address_out_2;
  wire [63:0] ex_LSQ_value_out_2;
  wire        ex_LSQ_valid_out_2;
  
  wire    ex_stall_bus_out_1;
  wire	  ex_stall_bus_out_2;

  
  /**********************************/
  /**********************************/
  /**********************************/
  
  // Memory interface/arbiter wires
  wire [63:0] proc2Dmem_addr, proc2Imem_addr;
  wire [1:0]  proc2Dmem_command, proc2Imem_command;
  wire [3:0]  Imem2proc_response, Dmem2proc_response;


/////// TEMPORARY WHILE WE DO NOT HAVE MEMORY WRITEBACK /////////////////
  assign proc2Dmem_command = `BUS_NONE;

  // Icache wires
  wire [63:0] cachemem_data;
  wire        cachemem_valid;
  wire  [6:0] Icache_rd_idx;
  wire [21:0] Icache_rd_tag;
  wire  [6:0] Icache_wr_idx;
  wire [21:0] Icache_wr_tag;
  wire        Icache_wr_en;
  wire [63:0] Icache_data_out, proc2Icache_addr;
  wire        Icache_valid_out;
////////////////////////////////////////////////////


/////////// STUFF FOR HALTING ///////////////
  reg    halted;
  wire n_halted;

  // set pipeline error status //
  wire inst1_retiring,inst2_retiring;
  assign inst1_retiring = (rob_inst1_retire_tag_out!=`RSTAG_NULL);
  assign inst2_retiring = (rob_inst2_retire_tag_out!=`RSTAG_NULL);

  // error status and completed instructions out //
  assign pipeline_completed_insts = {2'b0, (~n_halted)&&(inst1_retiring&&inst2_retiring), (~n_halted)&&(inst1_retiring^inst2_retiring) };
  assign pipeline_error_status =  
    (1'b0) ? `HALTED_ON_ILLEGAL : ((halted && LSQ_empty) ? `HALTED_ON_HALT : `NO_ERROR );

  // assign next halted signal //
  assign n_halted = (rob_inst1_branch_result_out==`BRANCH_HALT) || (rob_inst2_branch_result_out==`BRANCH_HALT) || halted;

  // assign next halted state //
  always@(posedge clock)
  begin
     if (reset)
        halted <= `SD 1'b0;
     else
        halted <= n_halted;
  end
////////////////////////////////////////////////



//////////// STUFF FOR BRANCH MISPREDICTIONS ///////////////////////
wire mispredict;
assign mispredict = (rob_inst1_mispredicted_out || rob_inst2_mispredicted_out);

/////////////////////////////////////////////////////////////////////


///////////////// MEMORY ARBITER ///////////////////////////////////
/*
  assign pipeline_commit_wr_idx = wb_reg_wr_idx_out;
  assign pipeline_commit_wr_data = wb_reg_wr_data_out;
  assign pipeline_commit_wr_en = wb_reg_wr_en_out;
  assign pipeline_commit_NPC = mem_wb_NPC;
*/

  assign proc2mem_command =
           (lsq_proc2Dmem_command_out==`BUS_NONE) ? proc2Imem_command : lsq_proc2Dmem_command_out;
  assign proc2mem_addr =
           (lsq_proc2Dmem_command_out==`BUS_NONE) ? proc2Imem_addr : lsq_proc2Dmem_addr_out;
  assign Dmem2proc_response = 
           (lsq_proc2Dmem_command_out==`BUS_NONE) ? 0 : mem2proc_response;
  assign Imem2proc_response =
           (lsq_proc2Dmem_command_out==`BUS_NONE) ? mem2proc_response : 0;
  assign proc2mem_data = lsq_proc2Dmem_data_out;

//////////////////////////////////////////////////////////////////


  ///***  MAKE D-CACHE  ***///
  //temporary D-CACHE
/*
  cache cachememory (// inputs
                              .clock(clock),
                              .reset(reset),
                              .wr1_en(Icache_wr_en),
                              .wr1_idx(Icache_wr_idx),
                              .wr1_tag(Icache_wr_tag),
                              .wr1_data(mem2proc_data),
                              
                              .rd1_idx(Icache_rd_idx),
                              .rd1_tag(Icache_rd_tag),

                              // outputs
                              .rd1_data(cachemem_data),
                              .rd1_valid(cachemem_valid)
                             );

  // Cache controller
  dcache dcache_0(// inputs 
                  .clock(clock),
                  .reset(reset),

                  .Dmem2proc_response(Dmem2proc_response),
                  .Dmem2proc_data(mem2proc_data),
                  .Dmem2proc_tag(mem2proc_tag),

                  .proc2Dcache_addr(proc2Dcache_addr),
                  .cachemem_data(cachemem_data),
                  .cachemem_valid(cachemem_valid),

                   // outputs
                  .proc2Dmem_command(proc2Dmem_command),
                  .proc2Dmem_addr(proc2Dmem_addr),

                  .Dcache_data_out(Dcache_data_out),
                  .Dcache_valid_out(Dcache_valid_out),
                  .current_index(Dcache_rd_idx),
                  .current_tag(Dcache_rd_tag),
                  .last_index(Dcache_wr_idx),
                  .last_tag(Dcache_wr_tag),
                  .data_write_enable(Dcache_wr_en)  
  
*/  

  // Actual cache (data and tag RAMs)
  cache cachememory (// inputs
                              .clock(clock),
                              .reset(reset || halted),
                              .wr1_en(Icache_wr_en),
                              .wr1_idx(Icache_wr_idx),
                              .wr1_tag(Icache_wr_tag),
                              .wr1_data(mem2proc_data),
                              
                              .rd1_idx(Icache_rd_idx),
                              .rd1_tag(Icache_rd_tag),

                              // outputs
                              .rd1_data(cachemem_data),
                              .rd1_valid(cachemem_valid)
                             );

  // Cache controller
  icache icache_0(// inputs 
                  .clock(clock),
                  .reset(reset || halted),

                  .Imem2proc_response(Imem2proc_response),
                  .Imem2proc_data(mem2proc_data),
                  .Imem2proc_tag(mem2proc_tag),

                  .proc2Icache_addr(proc2Icache_addr),
                  .cachemem_data(cachemem_data),
                  .cachemem_valid(cachemem_valid),

                   // outputs
                  .proc2Imem_command(proc2Imem_command),
                  .proc2Imem_addr(proc2Imem_addr),

                  .Icache_data_out(Icache_data_out),
                  .Icache_valid_out(Icache_valid_out),
                  .current_index(Icache_rd_idx),
                  .current_tag(Icache_rd_tag),
                  .last_index(Icache_wr_idx),
                  .last_tag(Icache_wr_tag),
                  .data_write_enable(Icache_wr_en)
                 );


  wire if_stage_stall_signal;
  wire stall_first_half_of_pipeline;
  assign stall_first_half_of_pipeline = (rob_rob_full_out || ~rs_dispatch_out || LSQ_full || halted);
  assign if_stage_stall_signal = (stall_first_half_of_pipeline || lsq_LSQ_IF_stall_out);

  //////////////////////////////////////////////////
  //                                              //
  //                  IF-Stage                    //
  //                                              //
  //////////////////////////////////////////////////
  if_stage if_stage_0 (// Inputs
                       .clock (clock),
                       .reset (reset || halted),
                       .Imem2proc_data(Icache_data_out),
                       .Imem_valid(Icache_valid_out),
                       
                       .inst1_cond_in(id_cond_branch_out_1),
                       .inst1_uncond_in(id_uncond_branch_out_1),
                       .inst2_cond_in(id_cond_branch_out_2),
                       .inst2_uncond_in(id_uncond_branch_out_2),
                       
                       .stall(if_stage_stall_signal),
                       .inst1_mispredict_in(rob_inst1_mispredicted_out),
                       .inst2_mispredict_in(rob_inst2_mispredicted_out),
                       .inst1_result_in(rob_inst1_branch_result_out),
                       .inst2_result_in(rob_inst2_branch_result_out),
                       .inst1_write_NPC_in(rob_inst1_NPC_out),
                       .inst2_write_NPC_in(rob_inst2_NPC_out),
                       .inst1_write_CPC_in(rob_inst1_CPC_out),
                       .inst2_write_CPC_in(rob_inst2_CPC_out),
                       .inst1_pht_index_in(rob_inst1_pht_index_out),
                       .inst2_pht_index_in(rob_inst2_pht_index_out),
                       
                        // Outputs
                        .proc2Imem_addr(proc2Icache_addr),
                       
                        .if_NPC_out_1(if_NPC_out_1),        // PC+4 of fetched instruction
                        .if_IR_out_1(if_IR_out_1),         // fetched instruction out
                        .if_valid_inst_out_1(if_valid_inst_out_1),  // when low, instruction is garbage
                        .if_PPC_out_1(if_PPC_out_1),	
                        .inst1_pht_index_out(if_inst1_pht_index_out),
	
                        .if_NPC_out_2(if_NPC_out_2),
                        .if_IR_out_2(if_IR_out_2),
                        .if_valid_inst_out_2(if_valid_inst_out_2),
                        .if_PPC_out_2(if_PPC_out_2),
                        .inst2_pht_index_out(if_inst2_pht_index_out)
                      );

  //////////////////////////////////////////////////
  //                                              //
  //            IF/ID Pipeline Register           //
  //                                              //
  //////////////////////////////////////////////////
  always @* //(posedge clock)
  begin
    if(reset || mispredict)
    begin
      id_NPC_1           = 0;
      id_IR_1            = `NOOP_INST;
      id_valid_inst1     = `FALSE;
      id_PPC_1           = 0;
      id_inst1_pht_index = 0;
      
      id_NPC_2           = 0;
      id_IR_2            = `NOOP_INST;
      id_valid_inst2     = `FALSE;
      id_PPC_2           = 0;
      id_inst2_pht_index = 0;
    end // if (reset)
    else
    begin
 /* 
     if (stall_first_half_of_pipeline)
      begin
         id_NPC_1           = id_NPC_1;
         id_IR_1            = id_IR_1;
         id_valid_inst1     = id_valid_inst1;
         id_PPC_1           = id_PPC_1;
         id_inst1_pht_index = id_inst1_pht_index;

         id_NPC_2           = id_NPC_2;
         id_IR_2            = id_IR_2;
         id_valid_inst2     = id_valid_inst2;
         id_PPC_2           = id_PPC_2;
         id_inst2_pht_index = id_inst2_pht_index;
      end
      else*/
      begin
         id_NPC_1           = if_NPC_out_1;
         id_IR_1            = if_IR_out_1;
         id_valid_inst1     = if_valid_inst_out_1;
         id_PPC_1           = if_PPC_out_1;
         id_inst1_pht_index = if_inst1_pht_index_out;
      
         id_NPC_2           = if_NPC_out_2;
         id_IR_2            = if_IR_out_2;
         id_valid_inst2     = if_valid_inst_out_2;
         id_PPC_2           = if_PPC_out_2;
         id_inst2_pht_index = if_inst2_pht_index_out;
      end
    end 
  end // always

   
  //////////////////////////////////////////////////
  //                                              //
  //                  ID-Stage                    //
  //                                              //
  //////////////////////////////////////////////////

  id_stage id_stage0(
                      // Inputs
                      .clock(clock),
                      .reset(reset || halted || mispredict),
                      .if_id_IR_1(id_IR_1),
                      .if_id_valid_inst_1(id_valid_inst1),

                      .if_id_IR_2(id_IR_2),
                      .if_id_valid_inst_2(id_valid_inst2),

                      // Outputs
                      .id_opa_select_out_1(id_opa_select_out_1),
                      .id_opb_select_out_1(id_opb_select_out_1),
                      .id_alu_func_out_1(id_alu_func_out_1),
                      .id_rd_mem_out_1(id_rd_mem_out_1),
                      .id_wr_mem_out_1(id_wr_mem_out_1),
                      .id_cond_branch_out_1(id_cond_branch_out_1),
                      .id_uncond_branch_out_1(id_uncond_branch_out_1),
                      .id_halt_out_1(id_halt_out_1),
                      .id_illegal_out_1(id_illegal_out_1),
                      .id_valid_inst_out_1(id_valid_inst_out_1),
                      
                      .ra_idx_1(id_rega_out_1),
                      .rb_idx_1(id_regb_out_1),
                      .id_dest_reg_idx_out_1(id_dest_reg_out_1),

                      .id_opa_select_out_2(id_opa_select_out_2),
                      .id_opb_select_out_2(id_opb_select_out_2),
                      .id_alu_func_out_2(id_alu_func_out_2),
                      .id_rd_mem_out_2(id_rd_mem_out_2),
                      .id_wr_mem_out_2(id_wr_mem_out_2),
                      .id_cond_branch_out_2(id_cond_branch_out_2),
                      .id_uncond_branch_out_2(id_uncond_branch_out_2),
                      .id_halt_out_2(id_halt_out_2),
                      .id_illegal_out_2(id_halt_out_2),
                      .id_valid_inst_out_2(id_valid_inst_out_2),
                      
                      .ra_idx_2(id_rega_out_2),
                      .rb_idx_2(id_regb_out_2),
                      .id_dest_reg_idx_out_2(id_dest_reg_out_2)
                      
                      );
  // Note: Decode signals for load-lock/store-conditional and "get CPU ID"
  //  instructions (id_{ldl,stc}_mem_out, id_cpuid_out) are not connected
  //  to anything because the provided EX and MEM stages do not implement
  //  these instructions.  You will have to implement these instructions
  //  if you plan to do a multicore project.
  
  
  
  //////////////////////////////////////////////////
  //                                              //
  //         ID/[MT/REG] Pipeline Register        //
  //                                              //
  //////////////////////////////////////////////////
  //ROB Asynchronous hacks
  always @*
  begin
  
    mt_inst1_tag = rob_inst1_tag_out;
    mt_inst2_tag = rob_inst2_tag_out;
    reg_inst1_dest  = rob_inst1_dest_out;
    reg_inst1_value = rob_inst1_value_out;
    reg_inst2_dest  = rob_inst2_dest_out;
    reg_inst2_value = rob_inst2_value_out;

  end

  //Map Table Synchonous
  always @(posedge clock)
  begin
    if(reset || mispredict)
    begin
      mt_inst1_rega <= `SD  0;
      mt_inst1_regb <= `SD  0;
      mt_inst1_dest <= `SD  0;
   //   mt_inst1_tag  <= `SD  0;
      
      mt_inst2_rega <= `SD  0;
      mt_inst2_regb <= `SD  0;
      mt_inst2_dest <= `SD  0;
    //  mt_inst2_tag  <= `SD  0;
    end
    else
    begin 
     if (stall_first_half_of_pipeline)
     begin
      mt_inst1_rega <= `SD  mt_inst1_rega;
      mt_inst1_regb <= `SD  mt_inst1_regb;
      mt_inst1_dest <= `SD  mt_inst1_dest;
  
      mt_inst2_rega <= `SD  mt_inst2_rega;
      mt_inst2_regb <= `SD  mt_inst2_regb;
      mt_inst2_dest <= `SD  mt_inst2_dest;
    
     end
     else
     begin
      mt_inst1_rega <= `SD  id_rega_out_1;
      mt_inst1_regb <= `SD  id_regb_out_1;
      mt_inst1_dest <= `SD  id_dest_reg_out_1;
      //mt_inst1_tag  <= `SD  rob_inst1_tag_out;
      
      mt_inst2_rega <= `SD  id_rega_out_2;
      mt_inst2_regb <= `SD  id_regb_out_2;
      mt_inst2_dest <= `SD  id_dest_reg_out_2;
      //mt_inst2_tag  <= `SD  rob_inst2_tag_out;      
     end
    end
  end
  
  //REG synchronous
  always @(posedge clock)
  begin
    if(reset)
    begin
    
    reg_inst1_rega  <= `SD  0;
    reg_inst1_regb  <= `SD  0;
  //  reg_inst1_dest  <= `SD  0;
  //  reg_inst1_value <= `SD  0;

    reg_inst2_rega  <= `SD  0;
    reg_inst2_regb  <= `SD  0;
  //  reg_inst2_dest  <= `SD  0;
  //  reg_inst2_value <= `SD  0;
    
    
    end
    else
    begin
   
    if (stall_first_half_of_pipeline)
    begin
      reg_inst1_rega  <= `SD  reg_inst1_rega;
      reg_inst1_regb  <= `SD  reg_inst1_regb;

      reg_inst2_rega  <= `SD  reg_inst2_rega;
      reg_inst2_regb  <= `SD  reg_inst2_regb;
    end
    else
    begin
 
    //comes from decode
      reg_inst1_rega  <= `SD  id_rega_out_1;
      reg_inst1_regb  <= `SD  id_regb_out_1;
    
    //comes from ROB
    //reg_inst1_dest  <= `SD  rob_inst1_dest_out;
    //reg_inst1_value <= `SD  rob_inst1_value_out;
    

      reg_inst2_rega  <= `SD  id_rega_out_2;
      reg_inst2_regb  <= `SD  id_regb_out_2;
    
    //reg_inst2_dest  <= `SD  rob_inst2_dest_out;
    //reg_inst2_value <= `SD  rob_inst2_value_out;
    end
    
    end
  end
 
 
  //Fast Forward Synchonous  
  always @(posedge clock)
  begin 
    if(reset || mispredict)
    begin
      ff_dest_reg_1       <= `SD 0;
      ff_opa_select_1     <= `SD 0;
      ff_opb_select_1     <= `SD 0;
      ff_alu_func_1       <= `SD 0;
      ff_rd_mem_1         <= `SD 0;
      ff_wr_mem_1         <= `SD 0;
      ff_cond_branch_1    <= `SD 0;
      ff_uncond_branch_1  <= `SD 0;
      ff_halt_1           <= `SD 0;
      ff_illegal_1        <= `SD 0;
      ff_valid_inst1      <= `SD 0;
      ff_NPC_1            <= `SD 0;
      ff_IR_1             <= `SD 0;
      ff_PPC_1            <= `SD 0;
      ff_inst1_pht_index  <= `SD 0;
  
      ff_dest_reg_2       <= `SD 0;
      ff_opa_select_2     <= `SD 0;
      ff_opb_select_2     <= `SD 0;
      ff_alu_func_2       <= `SD 0;
      ff_rd_mem_2         <= `SD 0;
      ff_wr_mem_2         <= `SD 0;
      ff_cond_branch_2    <= `SD 0;
      ff_uncond_branch_2  <= `SD 0;
      ff_halt_2           <= `SD 0;
      ff_illegal_2        <= `SD 0;
      ff_valid_inst2      <= `SD 0;      
      ff_NPC_2            <= `SD 0;
      ff_IR_2             <= `SD 0;
      ff_PPC_2            <= `SD 0;
      ff_inst2_pht_index  <= `SD 0;
    end
    else
    begin

     if (stall_first_half_of_pipeline)
     begin
      ff_dest_reg_1       <= `SD ff_dest_reg_1;
      ff_opa_select_1     <= `SD ff_opa_select_1;
      ff_opb_select_1     <= `SD ff_opb_select_1;
      ff_alu_func_1       <= `SD ff_alu_func_1;
      ff_rd_mem_1         <= `SD ff_rd_mem_1;
      ff_wr_mem_1         <= `SD ff_wr_mem_1;
      ff_cond_branch_1    <= `SD ff_cond_branch_1;
      ff_uncond_branch_1  <= `SD ff_uncond_branch_1;
      ff_halt_1           <= `SD ff_halt_1;
      ff_illegal_1        <= `SD ff_illegal_1;
      ff_valid_inst1      <= `SD ff_valid_inst1;
      ff_NPC_1            <= `SD ff_NPC_1;
      ff_IR_1             <= `SD ff_IR_1;
      ff_PPC_1            <= `SD ff_PPC_1;
      ff_inst1_pht_index  <= `SD ff_inst1_pht_index;

      ff_dest_reg_2       <= `SD ff_dest_reg_2;
      ff_opa_select_2     <= `SD ff_opa_select_2;
      ff_opb_select_2     <= `SD ff_opb_select_2;
      ff_alu_func_2       <= `SD ff_alu_func_2;
      ff_rd_mem_2         <= `SD ff_rd_mem_2;
      ff_wr_mem_2         <= `SD ff_wr_mem_2;
      ff_cond_branch_2    <= `SD ff_cond_branch_2;
      ff_uncond_branch_2  <= `SD ff_uncond_branch_2;
      ff_halt_2           <= `SD ff_halt_2;
      ff_illegal_2        <= `SD ff_illegal_2;
      ff_valid_inst2      <= `SD ff_valid_inst2;
      ff_NPC_2            <= `SD ff_NPC_2;
      ff_IR_2             <= `SD ff_IR_2;
      ff_PPC_2            <= `SD ff_PPC_2;
      ff_inst2_pht_index  <= `SD ff_inst2_pht_index;


    end
    else
    begin
      ff_dest_reg_1       <= `SD id_dest_reg_out_1;
      ff_opa_select_1     <= `SD id_opa_select_out_1;
      ff_opb_select_1     <= `SD id_opb_select_out_1;
      ff_alu_func_1       <= `SD id_alu_func_out_1;
      ff_rd_mem_1         <= `SD id_rd_mem_out_1;
      ff_wr_mem_1         <= `SD id_wr_mem_out_1;
      ff_cond_branch_1    <= `SD id_cond_branch_out_1;
      ff_uncond_branch_1  <= `SD id_uncond_branch_out_1;
      ff_halt_1           <= `SD id_halt_out_1;
      ff_illegal_1        <= `SD id_illegal_out_1;
      ff_valid_inst1      <= `SD id_valid_inst_out_1;
      ff_NPC_1            <= `SD id_NPC_1;
      ff_IR_1             <= `SD id_IR_1;
      ff_PPC_1            <= `SD id_PPC_1;
      ff_inst1_pht_index  <= `SD id_inst1_pht_index;
      
      ff_dest_reg_2       <= `SD id_dest_reg_out_2;
      ff_opa_select_2     <= `SD id_opa_select_out_2;
      ff_opb_select_2     <= `SD id_opb_select_out_2;
      ff_alu_func_2       <= `SD id_alu_func_out_2;
      ff_rd_mem_2         <= `SD id_rd_mem_out_2;
      ff_wr_mem_2         <= `SD id_wr_mem_out_2;
      ff_cond_branch_2    <= `SD id_cond_branch_out_2;
      ff_uncond_branch_2  <= `SD id_uncond_branch_out_2;
      ff_halt_2           <= `SD id_halt_out_2;
      ff_illegal_2        <= `SD id_illegal_out_2;
      ff_valid_inst2      <= `SD id_valid_inst_out_2; 
      ff_NPC_2            <= `SD id_NPC_2;
      ff_IR_2             <= `SD id_IR_2;
      ff_PPC_2            <= `SD id_PPC_2;
      ff_inst2_pht_index  <= `SD id_inst2_pht_index;      
     end

    end
  end   
      
       
  

  //////////////////////////////////////////////////
  //                                              //
  //                [MT/REG] Stage                //
  //                                              //
  ////////////////////////////////////////////////// 
   map_table map_table_0 (//Inputs
  
                           .clock(clock), .reset(reset || halted || mispredict), .clear_entries(reg_clear_entries_out),

                           // instruction 1 access inputs //
                           //THESE COME FROM DECODE
                           .inst1_rega_in(mt_inst1_rega),
                           .inst1_regb_in(mt_inst1_regb),
                           
                           // DEST COMES FROM ID (AFTER LATCH) //
                           .inst1_dest_in(mt_inst1_dest),
      
                           // TAG COMES FROM THE ROB //
                           .inst1_tag_in(mt_inst1_tag),

                           // RETIRE TAG FROM ROB //
                           .inst1_retire_tag_in(rob_inst1_retire_tag_out),

                           // instruction 2 access inputs //
                           .inst2_rega_in(mt_inst2_rega),
                           .inst2_regb_in(mt_inst2_regb),
 
                           // DEST COMES FROM ID (AFTER LATCH) //                          
                           .inst2_dest_in(mt_inst2_dest),

                           // TAG COMES FROM ROB //
                           .inst2_tag_in(mt_inst2_tag),

                           // RETIRE TAG FROM ROB //
                           .inst2_retire_tag_in(rob_inst2_retire_tag_out),

                           // cdb inputs //
                           .cdb1_tag_in(cm_tag_out_1),
                           .cdb2_tag_in(cm_tag_out_2),
                          
                           // tag outputs //
                           .inst1_taga_out(mt_inst1_taga_out), .inst1_tagb_out(mt_inst1_tagb_out),
                           .inst2_taga_out(mt_inst2_taga_out), .inst2_tagb_out(mt_inst2_tagb_out)  
                           
                           );      
                           

  register_file register_file0(//Inputs
                      
                               .clock(clock), .reset(reset),

                               //COMES FROM DECODE
                               // input busses: register indexes and values in // 
                               .inst1_rega_in(reg_inst1_rega), .inst1_regb_in(reg_inst1_regb), 
                               .inst2_rega_in(reg_inst2_rega), .inst2_regb_in(reg_inst2_regb),
                               
                               //Destination and Value to write
                               .inst1_dest_in(reg_inst1_dest), .inst1_value_in(reg_inst1_value),
                               .inst2_dest_in(reg_inst2_dest), .inst2_value_in(reg_inst2_value),

                               // output busses: register values out //
                               .inst1_rega_out(reg_inst1_rega_out), .inst1_regb_out(reg_inst1_regb_out),
                               .inst2_rega_out(reg_inst2_rega_out), .inst2_regb_out(reg_inst2_regb_out),

                               // ouput signals: tell the map table when to clear //
                               .clear_entries(reg_clear_entries_out)
                               );



  //////////////////////////////////////////////////
  //                                              //
  //    [MT/REG] / [RS/ROB] Pipeline Register     //
  //                                              //
  //////////////////////////////////////////////////    


  //ROB Synchronous
  always @* //(posedge clock)
  begin
    if(reset || mispredict)
    begin
      rob_inst1_valid = 0;
      rob_inst1_dest  = 0;
      rob_inst1_taga  = 0;
      rob_inst1_tagb  = 0;
    
      rob_inst2_valid = 0;
      rob_inst2_dest  = 0;
      rob_inst2_taga  = 0;
      rob_inst2_tagb  = 0;
    end
    else
    begin

      rob_inst1_valid = ff_valid_inst1;
      rob_inst1_dest  = ff_dest_reg_1;
      
      rob_inst1_taga  = mt_inst1_taga_out;
      rob_inst1_tagb  = mt_inst1_tagb_out;
    
      rob_inst2_valid = ff_valid_inst2;
      rob_inst2_dest  = ff_dest_reg_2;
      
      rob_inst2_taga  = mt_inst2_taga_out;
      rob_inst2_tagb  = mt_inst2_tagb_out;
    
    end
  end
  
  //RS Synchronous
  always @* //(posedge clock)
  begin
    if(reset || mispredict)
    begin
    
    rs_inst1_rega_value     = 0;
    rs_inst1_regb_value     = 0;
    rs_inst1_rega_tag       = 0;
    rs_inst1_regb_tag       = 0;
    rs_inst1_dest_reg       = 0;
    rs_inst1_dest_tag       = 0;
    rs_inst1_opa_select     = 0;
    rs_inst1_opb_select     = 0;
    rs_inst1_alu_func       = 0;
    rs_inst1_rd_mem         = 0;
    rs_inst1_wr_mem         = 0;
    rs_inst1_cond_branch    = 0;
    rs_inst1_uncond_branch  = 0;
    rs_inst1_NPC            = 0;
    rs_inst1_IR             = 0;
    rs_inst1_valid          = 0;
    rs_inst1_PPC            = 0;
    rs_inst1_pht_index      = 0;

    rs_inst2_rega_value     = 0;
    rs_inst2_regb_value     = 0;
    rs_inst2_rega_tag       = 0;
    rs_inst2_regb_tag       = 0;
    rs_inst2_dest_reg       = 0;
    rs_inst2_dest_tag       = 0;
    rs_inst2_opa_select     = 0;
    rs_inst2_opb_select     = 0;
    rs_inst2_alu_func       = 0;
    rs_inst2_rd_mem         = 0;
    rs_inst2_wr_mem         = 0;
    rs_inst2_cond_branch    = 0;
    rs_inst2_uncond_branch  = 0;
    rs_inst2_NPC            = 0;
    rs_inst2_IR             = 0;
    rs_inst2_valid          = 0;
    rs_inst2_PPC            = 0;
    rs_inst2_pht_index      = 0;     
    
    end
    else
    begin
    
    rs_inst1_rega_value     = reg_inst1_rega_out;
    rs_inst1_regb_value     = reg_inst1_regb_out;
    //
    rs_inst1_rega_tag       = mt_inst1_taga_out;   // MT
    rs_inst1_regb_tag       = mt_inst1_tagb_out;   // MT
    rs_inst1_dest_reg       = ff_dest_reg_1;   // DEC
    rs_inst1_dest_tag       = rob_inst1_tag_out;   // ROB
    //
    rs_inst1_opa_select     = ff_opa_select_1;
    rs_inst1_opb_select     = ff_opb_select_1;
    rs_inst1_alu_func       = ff_alu_func_1;
    rs_inst1_rd_mem         = ff_rd_mem_1;
    rs_inst1_wr_mem         = ff_wr_mem_1;
    rs_inst1_cond_branch    = ff_cond_branch_1;
    rs_inst1_uncond_branch  = ff_uncond_branch_1;
    //
    rs_inst1_NPC            = ff_NPC_1;
    rs_inst1_IR             = ff_IR_1;
    rs_inst1_valid          = ff_valid_inst1;
    rs_inst1_PPC            = ff_PPC_1;
    rs_inst1_pht_index      = ff_inst1_pht_index;
    //
    
    rs_inst2_rega_value     = reg_inst2_rega_out;
    rs_inst2_regb_value     = reg_inst2_regb_out;
    //
    rs_inst2_rega_tag       = mt_inst2_taga_out;
    rs_inst2_regb_tag       = mt_inst2_tagb_out;
    rs_inst2_dest_reg       = ff_dest_reg_2;
    rs_inst2_dest_tag       = rob_inst2_tag_out;
    //
    rs_inst2_opa_select     = ff_opa_select_2;
    rs_inst2_opb_select     = ff_opb_select_2;
    rs_inst2_alu_func       = ff_alu_func_2;
    rs_inst2_rd_mem         = ff_rd_mem_2;
    rs_inst2_wr_mem         = ff_wr_mem_2;
    rs_inst2_cond_branch    = ff_cond_branch_2;
    rs_inst2_uncond_branch  = ff_uncond_branch_2;
    //
    rs_inst2_NPC            = ff_NPC_2;
    rs_inst2_IR             = ff_IR_2;
    rs_inst2_valid          = ff_valid_inst2;
    rs_inst2_PPC            = ff_PPC_2;
    rs_inst2_pht_index      = ff_inst2_pht_index;  
    
    
    end
  end



  //////////////////////////////////////////////////
  //                                              //
  //               [RS/ROB] Stage                 //
  //                                              //
  //////////////////////////////////////////////////             
                                      
  reservation_station reservation_station_0(//Inputs
                                           .clock(clock),
                                           .reset(reset || halted || mispredict),
 
                                           // signals and busses in for inst 1 (from id1) //
                                           //Values from ROB
                                           .inst1_rega_value_in(rs_inst1_rega_value),
                                           .inst1_regb_value_in(rs_inst1_regb_value),
                                        
                                           //Tags from Map Table
                                           .inst1_rega_tag_in(rs_inst1_rega_tag),
                                           .inst1_regb_tag_in(rs_inst1_regb_tag),

                                           //Tag from ROB                           
                                           .inst1_dest_tag_in(rs_inst1_dest_tag), 
                                           
                                           //Instruction signals from Decode                         
                                           .inst1_dest_reg_in(rs_inst1_dest_reg),
                                           .inst1_opa_select_in(rs_inst1_opa_select),
                                           .inst1_opb_select_in(rs_inst1_opb_select),
                                           .inst1_alu_func_in(rs_inst1_alu_func),
                                           .inst1_rd_mem_in(rs_inst1_rd_mem),
                                           .inst1_wr_mem_in(rs_inst1_wr_mem),
                                           .inst1_cond_branch_in(rs_inst1_cond_branch),
                                           .inst1_uncond_branch_in(rs_inst1_uncond_branch),
                                           .inst1_NPC_in(rs_inst1_NPC),
                                           .inst1_IR_in(rs_inst1_IR),
                                           .inst1_PPC_in(rs_inst1_PPC),
                                           .inst1_pht_index_in(rs_inst1_pht_index),
                                           .inst1_valid(rs_inst1_valid && ~stall_first_half_of_pipeline),


                                           // signals and busses in for inst 2 (from id2) //
                                           //Values from DECODE
                                           .inst2_rega_value_in(rs_inst2_rega_value),
                                           .inst2_regb_value_in(rs_inst2_regb_value),
                                           
                                           //Tags from Map Table
                                           .inst2_rega_tag_in(rs_inst2_rega_tag),
                                           .inst2_regb_tag_in(rs_inst2_regb_tag),
                                           
                                           //Tag from ROB
                                           .inst2_dest_tag_in(rs_inst2_dest_tag),
                                           
                                           //Instruction signals from Decode
                                           .inst2_dest_reg_in(rs_inst2_dest_reg),
                                           .inst2_opa_select_in(rs_inst2_opa_select),
                                           .inst2_opb_select_in(rs_inst2_opb_select),
                                           .inst2_alu_func_in(rs_inst2_alu_func),
                                           .inst2_rd_mem_in(rs_inst2_rd_mem),
                                           .inst2_wr_mem_in(rs_inst2_wr_mem),
                                           .inst2_cond_branch_in(rs_inst2_cond_branch),
                                           .inst2_uncond_branch_in(rs_inst2_uncond_branch),
                                           .inst2_NPC_in(rs_inst2_NPC),
                                           .inst2_IR_in(rs_inst2_IR),
                                           .inst2_PPC_in(rs_inst2_PPC),
                                           .inst2_pht_index_in(rs_inst2_pht_index),
                                           .inst2_valid(rs_inst2_valid && ~stall_first_half_of_pipeline),

                                           // cdb inputs //
                                           .cdb1_tag_in(cm_tag_out_1),
                                           .cdb2_tag_in(cm_tag_out_2),
                                           .cdb1_value_in(cm_value_out_1),
                                           .cdb2_value_in(cm_value_out_2),

                                           // inputs from the EX to stall //
                                           .inst1_stall_in(ex_stall_bus_out_1),
                                           .inst2_stall_in(ex_stall_bus_out_2 || `NO_SUPERSCALAR),


                                           // inputs from the ROB //
                                           .inst1_rega_rob_value_in(rob_inst1_rega_value_out),
                                           .inst1_regb_rob_value_in(rob_inst1_regb_value_out),
                                           .inst2_rega_rob_value_in(rob_inst2_rega_value_out),
                                           .inst2_regb_rob_value_in(rob_inst2_regb_value_out),


                                           /*** OUTPUTS ***/
                                           // signals and busses out for inst1 to the ex stage
                                           .inst1_rega_value_out(rs_inst1_rega_value_out),
                                           .inst1_regb_value_out(rs_inst1_regb_value_out),
                                           
                                           .inst1_opa_select_out(rs_inst1_opa_select_out),
                                           .inst1_opb_select_out(rs_inst1_opb_select_out),
                                           .inst1_alu_func_out(rs_inst1_alu_func_out),
                                           .inst1_rd_mem_out(rs_inst1_rd_mem_out), 
                                           .inst1_wr_mem_out(rs_inst1_wr_mem_out),
                                           .inst1_cond_branch_out(rs_inst1_cond_branch_out),
                                           .inst1_uncond_branch_out(rs_inst1_uncond_branch_out),
                                           .inst1_NPC_out(rs_inst1_NPC_out),
                                           .inst1_IR_out(rs_inst1_IR_out),
                                           .inst1_PPC_out(rs_inst1_PPC_out),
                                           .inst1_pht_index_out(rs_inst1_pht_index_out),
                                           .inst1_valid_out(rs_inst1_valid_out),
                                           .inst1_dest_reg_out(rs_inst1_dest_reg_out),
                                           .inst1_dest_tag_out(rs_inst1_dest_tag_out),

                                           // signals and busses out for inst2 to the ex stage
                                           .inst2_rega_value_out(rs_inst2_rega_value_out),
                                           .inst2_regb_value_out(rs_inst2_regb_value_out),
                                           
                                           .inst2_opa_select_out(rs_inst2_opa_select_out),
                                           .inst2_opb_select_out(rs_inst2_opb_select_out),
                                           .inst2_alu_func_out(rs_inst2_alu_func_out),
                                           .inst2_rd_mem_out(rs_inst2_rd_mem_out), 
                                           .inst2_wr_mem_out(rs_inst2_wr_mem_out),
                                           .inst2_cond_branch_out(rs_inst2_cond_branch_out),
                                           .inst2_uncond_branch_out(rs_inst2_uncond_branch_out),
                                           .inst2_NPC_out(rs_inst2_NPC_out),
                                           .inst2_IR_out(rs_inst2_IR_out),
                                           .inst2_PPC_out(rs_inst2_PPC_out),
                                           .inst2_pht_index_out(rs_inst2_pht_index_out),
                                           .inst2_valid_out(rs_inst2_valid_out),
                                           .inst2_dest_reg_out(rs_inst2_dest_reg_out),
                                           .inst2_dest_tag_out(rs_inst2_dest_tag_out),
                
                                           // signal outputs //
                                           .dispatch(rs_dispatch_out),
                                         
                                           // outputs for debugging //
                                           .first_empties(rs_first_empties_out),
                                           .second_empties(rs_second_empties_out),
                                           .states_out(rs_states_out),
                                           .fills(rs_fills_out), 
                                           .issue_first_states(rs_issue_first_states_out), 
                                           .issue_second_states(rs_issue_second_states_out), 
                                           .ages_out(rs_ages_out)
                                           
                                           );
  
  
  
  reorder_buffer reorder_buffer_0 (//Inputs
  
                                          .clock(clock), .reset(reset || halted || mispredict),
                                          
                                          /*these will come from decode*/
                                          .inst1_valid_in(rob_inst1_valid && ~stall_first_half_of_pipeline),
                                          .inst1_dest_in(rob_inst1_dest),

                                          .inst2_valid_in(rob_inst2_valid && ~stall_first_half_of_pipeline),
                                          .inst2_dest_in(rob_inst2_dest),

                                          // tags for reading from the MT // 
                                          .inst1_rega_tag_in(rob_inst1_taga),
                                          .inst1_regb_tag_in(rob_inst1_tagb),
                                          .inst2_rega_tag_in(rob_inst2_taga),
                                          .inst2_regb_tag_in(rob_inst2_tagb),

                                          // cdb inputs //
                                          .cdb1_tag_in(cm_tag_out_1),
                                          .cdb1_value_in(cm_value_out_1),
                                          .cdb1_mispredicted_in(cm_mispredict_out_1),
                                          .cdb1_branch_result_in(cm_branch_result_out_1),
                                          .cdb1_NPC_in(cm_NPC_out_1),
                                          .cdb1_pht_index_in(cm_pht_index_out_1),
                                          .cdb1_CPC_in(cm_CPC_out_1),
                                          .cdb2_tag_in(cm_tag_out_2),
                                          .cdb2_value_in(cm_value_out_2),
                                          .cdb2_mispredicted_in(cm_mispredict_out_2), 
                                          .cdb2_branch_result_in(cm_branch_result_out_2),
                                          .cdb2_NPC_in(cm_NPC_out_2),
                                          .cdb2_pht_index_in(cm_pht_index_out_2),
                                          .cdb2_CPC_in(cm_CPC_out_2),


                                          // outputs //
                                          
                                          //outputs to RS
                                          .inst1_tag_out(rob_inst1_tag_out),
                                          .inst2_tag_out(rob_inst2_tag_out),

                                          // values out to the rs //
                                          .inst1_rega_value_out(rob_inst1_rega_value_out),
                                          .inst1_regb_value_out(rob_inst1_regb_value_out),
                                          .inst2_rega_value_out(rob_inst2_rega_value_out),
                                          .inst2_regb_value_out(rob_inst2_regb_value_out),     

                                          // outputs to write directly to the reg file //
                                          .inst1_dest_out(rob_inst1_dest_out), .inst1_value_out(rob_inst1_value_out),
                                          .inst1_retire_tag_out(rob_inst1_retire_tag_out),
                                          .inst2_dest_out(rob_inst2_dest_out), .inst2_value_out(rob_inst2_value_out),
                                          .inst2_retire_tag_out(rob_inst2_retire_tag_out),
                                          
                                           // outputs to indicate a mispredicted branch //
                                           .inst1_mispredicted_out(rob_inst1_mispredicted_out),
                                           .inst2_mispredicted_out(rob_inst2_mispredicted_out),
                                           .inst1_branch_result_out(rob_inst1_branch_result_out),
                                           .inst2_branch_result_out(rob_inst2_branch_result_out),
                                           .inst1_NPC_out(rob_inst1_NPC_out),
                                           .inst2_NPC_out(rob_inst2_NPC_out),
                                           .inst1_pht_index_out(rob_inst1_pht_index_out),
                                           .inst2_pht_index_out(rob_inst2_pht_index_out),
                                           .inst1_CPC_out(rob_inst1_CPC_out),
                                           .inst2_CPC_out(rob_inst2_CPC_out),

                                          // signals out //
                                          .rob_full(rob_rob_full_out), .rob_empty(rob_rob_empty_out)
                                      );
  

  
  //////////////////////////////////////////////////
  //                                              //
  //        [RS/ROB] / EX Pipeline Register       //
  //                                              //
  //////////////////////////////////////////////////
  always @(posedge clock)
  begin
  
    if(reset || mispredict)
    begin
    
      ex_valid_1         <= `SD 0;
      ex_NPC_1           <= `SD 0;
      ex_PPC_1           <= `SD 0;
      ex_pht_idx_1       <= `SD 0;
      ex_IR_1            <= `SD 0;
      ex_dest_reg_1      <= `SD 0;
      ex_rega_1          <= `SD 0;
      ex_regb_1          <= `SD 0;
      ex_opa_select_1    <= `SD 0;
      ex_opb_select_1    <= `SD 0;
      ex_alu_func_1      <= `SD 0;
      ex_cond_branch_1   <= `SD 0;
      ex_uncond_branch_1 <= `SD 0;
      ex_rd_mem_1        <= `SD 0;
      ex_wr_mem_1        <= `SD 0;
      
      ex_valid_2         <= `SD 0;
      ex_NPC_2           <= `SD 0;
      ex_PPC_2           <= `SD 0;
      ex_pht_idx_2       <= `SD 0;
      ex_IR_2            <= `SD 0;
      ex_dest_reg_2      <= `SD 0;
      ex_rega_2          <= `SD 0;
      ex_regb_2          <= `SD 0;
      ex_opa_select_2    <= `SD 0;
      ex_opb_select_2    <= `SD 0;
      ex_alu_func_2      <= `SD 0;
      ex_cond_branch_2   <= `SD 0;
      ex_uncond_branch_2 <= `SD 0;
      ex_rd_mem_2        <= `SD 0;
      ex_wr_mem_2        <= `SD 0;
     
    end
    else
    begin
   
     if (ex_stall_bus_out_1)
     begin 
      ex_valid_1         <= `SD ex_valid_1;
      ex_NPC_1           <= `SD ex_NPC_1;
      ex_PPC_1           <= `SD ex_PPC_1;
      ex_pht_idx_1       <= `SD ex_pht_idx_1;
      ex_IR_1            <= `SD ex_IR_1;
      ex_dest_reg_1      <= `SD ex_dest_reg_1;
      ex_rega_1          <= `SD ex_rega_1;
      ex_regb_1          <= `SD ex_regb_1;
      ex_opa_select_1    <= `SD ex_opa_select_1;
      ex_opb_select_1    <= `SD ex_opb_select_1;
      ex_alu_func_1      <= `SD ex_alu_func_1;
      ex_cond_branch_1   <= `SD ex_cond_branch_1;
      ex_uncond_branch_1 <= `SD ex_uncond_branch_1;
      ex_rd_mem_1        <= `SD ex_rd_mem_1;
      ex_wr_mem_1        <= `SD ex_wr_mem_1;
    end
    else
    begin 
      ex_valid_1         <= `SD rs_inst1_valid_out;
      ex_NPC_1           <= `SD rs_inst1_NPC_out;
      ex_PPC_1           <= `SD rs_inst1_PPC_out;
      ex_pht_idx_1       <= `SD rs_inst1_pht_index_out;
      ex_IR_1            <= `SD rs_inst1_IR_out;
      ex_dest_reg_1      <= `SD rs_inst1_dest_tag_out;
      ex_rega_1          <= `SD rs_inst1_rega_value_out;
      ex_regb_1          <= `SD rs_inst1_regb_value_out;
      ex_opa_select_1    <= `SD rs_inst1_opa_select_out;
      ex_opb_select_1    <= `SD rs_inst1_opb_select_out;
      ex_alu_func_1      <= `SD rs_inst1_alu_func_out;
      ex_cond_branch_1   <= `SD rs_inst1_cond_branch_out;
      ex_uncond_branch_1 <= `SD rs_inst1_uncond_branch_out;
      ex_rd_mem_1        <= `SD rs_inst1_rd_mem_out;
      ex_wr_mem_1        <= `SD rs_inst1_wr_mem_out;
    end


    if (ex_stall_bus_out_2 || `NO_SUPERSCALAR)
    begin  
      ex_valid_2         <= `SD ex_valid_2;
      ex_NPC_2           <= `SD ex_NPC_2;
      ex_PPC_2           <= `SD ex_PPC_2;
      ex_pht_idx_2       <= `SD ex_pht_idx_2;
      ex_IR_2            <= `SD ex_IR_2;
      ex_dest_reg_2      <= `SD ex_dest_reg_2;
      ex_rega_2          <= `SD ex_rega_2;
      ex_regb_2          <= `SD ex_regb_2;
      ex_opa_select_2    <= `SD ex_opa_select_2;
      ex_opb_select_2    <= `SD ex_opb_select_2;
      ex_alu_func_2      <= `SD ex_alu_func_2;
      ex_cond_branch_2   <= `SD ex_cond_branch_2;
      ex_uncond_branch_2 <= `SD ex_uncond_branch_2;
      ex_rd_mem_2        <= `SD ex_rd_mem_2;
      ex_wr_mem_2        <= `SD ex_wr_mem_2;
   end
   else
   begin
      ex_valid_2         <= `SD rs_inst2_valid_out;
      ex_NPC_2           <= `SD rs_inst2_NPC_out;
      ex_PPC_2           <= `SD rs_inst2_PPC_out;
      ex_pht_idx_2       <= `SD rs_inst2_pht_index_out;
      ex_IR_2            <= `SD rs_inst2_IR_out;
      ex_dest_reg_2      <= `SD rs_inst2_dest_tag_out;
      ex_rega_2          <= `SD rs_inst2_rega_value_out;
      ex_regb_2          <= `SD rs_inst2_regb_value_out;
      ex_opa_select_2    <= `SD rs_inst2_opa_select_out;
      ex_opb_select_2    <= `SD rs_inst2_opb_select_out;
      ex_alu_func_2      <= `SD rs_inst2_alu_func_out;
      ex_cond_branch_2   <= `SD rs_inst2_cond_branch_out;
      ex_uncond_branch_2 <= `SD rs_inst2_uncond_branch_out;
      ex_rd_mem_2        <= `SD rs_inst2_rd_mem_out;
      ex_wr_mem_2        <= `SD rs_inst2_wr_mem_out;
    end
  end
 end

  //////////////////////////////////////////////////
  //                                              //
  //                  EX-Stage                    //
  //                                              //
  //////////////////////////////////////////////////
   ex_stage ex_stage_0(// Inputs
                          .clock(clock),
                          .reset(reset || halted || mispredict),
                          
                          // Input Bus 1 (contains branch logic)
                          .valid_in_1(ex_valid_1),
                          .id_ex_NPC_1(ex_NPC_1),
                          .id_ex_PPC_1(ex_PPC_1),
                          .id_ex_pht_idx_1(ex_pht_idx_1),
                          .id_ex_IR_1(ex_IR_1),
                          .id_ex_dest_reg_1(ex_dest_reg_1),
                          .id_ex_rega_1(ex_rega_1),
                          .id_ex_regb_1(ex_regb_1),
                          .id_ex_opa_select_1(ex_opa_select_1),
                          .id_ex_opb_select_1(ex_opb_select_1),
                          .id_ex_alu_func_1(ex_alu_func_1),
                          .id_ex_cond_branch_1(ex_cond_branch_1),
                          .id_ex_uncond_branch_1(ex_uncond_branch_1),
                          .id_ex_rd_mem_in_1(ex_rd_mem_1),
                          .id_ex_wr_mem_in_1(ex_wr_mem_1),

                          // Input Bus 2
                          .valid_in_2(ex_valid_2),
                          .id_ex_NPC_2(ex_NPC_2),
                          .id_ex_PPC_2(ex_PPC_2),
                          .id_ex_pht_idx_2(ex_pht_idx_2),
                          .id_ex_IR_2(ex_IR_2),
                          .id_ex_dest_reg_2(ex_dest_reg_2),
                          .id_ex_rega_2(ex_rega_2),
                          .id_ex_regb_2(ex_regb_2),
                          .id_ex_opa_select_2(ex_opa_select_2),
                          .id_ex_opb_select_2(ex_opb_select_2),
                          .id_ex_alu_func_2(ex_alu_func_2),
                          .id_ex_cond_branch_2(ex_cond_branch_2),
                          .id_ex_uncond_branch_2(ex_uncond_branch_2),
                          .id_ex_rd_mem_in_2(ex_rd_mem_2),
                          .id_ex_wr_mem_in_2(ex_wr_mem_2),
				
                          // From Mem Access
                          .MEM_tag_in(lsq_tag_out),
                          .MEM_value_in(lsq_mem_result_out),
                          .MEM_valid_in(lsq_LSQ_EX_valid_out),
                          
	                        // Outputs
	                        .stall_bus_1(ex_stall_bus_out_1),
	                        .stall_bus_2(ex_stall_bus_out_2),
	                        // Bus 1
	                        .ex_NPC_out_1(ex_NPC_out_1),
	                        .ex_dest_reg_out_1(ex_dest_reg_out_1),
	                        .ex_result_out_1(ex_result_out_1),
	                        .ex_mispredict_1(ex_mispredict_out_1),
	                        .ex_branch_result_1(ex_branch_result_out_1),
	                        .ex_pht_idx_out_1(ex_pht_idx_out_1),
	                        .ex_valid_out_1(ex_valid_out_1),
	                        .ex_CPC_out_1(ex_CPC_out_1),
	                        // Bus 2
	                        .ex_NPC_out_2(ex_NPC_out_2),
	                        .ex_dest_reg_out_2(ex_dest_reg_out_2),
	                        .ex_result_out_2(ex_result_out_2),
	                        .ex_mispredict_2(ex_mispredict_out_2),
	                        .ex_branch_result_2(ex_branch_result_out_2),
	                        .ex_pht_idx_out_2(ex_pht_idx_out_2),
	                        .ex_valid_out_2(ex_valid_out_2),
	                        .ex_CPC_out_2(ex_CPC_out_2),


                          // To LSQ
                          .LSQ_tag_out_1(ex_LSQ_tag_out_1),
                          .LSQ_address_out_1(ex_LSQ_address_out_1),
                          .LSQ_value_out_1(ex_LSQ_value_out_1),
	                        .LSQ_valid_out_1(ex_LSQ_valid_out_1),
		
	                   // why are value and valid almost the same word!? 
	                   // we need them both but they're hard to seperate!

                          .LSQ_tag_out_2(ex_LSQ_tag_out_2),
                          .LSQ_address_out_2(ex_LSQ_address_out_2),
                          .LSQ_value_out_2(ex_LSQ_value_out_2),
	                        .LSQ_valid_out_2(ex_LSQ_valid_out_2)
                        );


  //////////////////////////////////////////////////
  //                                              //
  //       EX / Complete Pipeline Register        //
  //                                              //
  //////////////////////////////////////////////////

  //Synchronous Execute to Complete Register  
  always @(posedge clock)
  begin
    if(reset || mispredict)
    begin
      cm_tag_1           <= `SD 0;
      cm_result_1        <= `SD 0;
      cm_NPC_1           <= `SD 0;
      cm_mispredict_1    <= `SD 0;
      cm_branch_result_1 <= `SD 0;
      cm_pht_index_1     <= `SD 0;
      cm_valid_1         <= `SD 0;
      cm_CPC_1           <= `SD 0;

      cm_tag_2           <= `SD 0;
      cm_result_2        <= `SD 0;
      cm_NPC_2           <= `SD 0;
      cm_mispredict_2    <= `SD 0;
      cm_branch_result_2 <= `SD 0;
      cm_pht_index_2     <= `SD 0;
      cm_valid_2         <= `SD 0;
      cm_CPC_2           <= `SD 0;

    end
    else
    begin
      cm_tag_1           <= `SD ex_dest_reg_out_1;
      cm_result_1        <= `SD ex_result_out_1;
      cm_NPC_1           <= `SD ex_NPC_out_1;
      cm_mispredict_1    <= `SD ex_mispredict_out_1;
      cm_branch_result_1 <= `SD ex_branch_result_out_1;
      cm_pht_index_1     <= `SD ex_pht_idx_out_1;
      cm_valid_1         <= `SD ex_valid_out_1;
      cm_CPC_1           <= `SD ex_CPC_out_1;

      cm_tag_2           <= `SD ex_dest_reg_out_2;
      cm_result_2        <= `SD ex_result_out_2;
      cm_NPC_2           <= `SD ex_NPC_out_2;
      cm_mispredict_2    <= `SD ex_mispredict_out_2;
      cm_branch_result_2 <= `SD ex_branch_result_out_2;
      cm_pht_index_2     <= `SD ex_pht_idx_out_2;
      cm_valid_2         <= `SD ex_valid_out_2;
      cm_CPC_2           <= `SD ex_CPC_out_2;
      
    end
    
  end

  //////////////////////////////////////////////////
  //                                              //
  //               Complete Stage                 //
  //                                              //
  //////////////////////////////////////////////////

  cm_stage cm_stage_0(// Inputs

		                  .ex_cm_tag_1(cm_tag_1),
		                  .ex_cm_result_1(cm_result_1),
                      .ex_cm_NPC_1(cm_NPC_1),
                      .ex_cm_mispredict_1(cm_mispredict_1),
                      .ex_cm_branch_result_1(cm_branch_result_1),
                      .ex_cm_pht_index_1(cm_pht_index_1),
		                  .ex_cm_valid_1(cm_valid_1),
		                  .ex_cm_CPC_1(cm_CPC_1),

		                  .ex_cm_tag_2(cm_tag_2),
		                  .ex_cm_result_2(cm_result_2),
                      .ex_cm_NPC_2(cm_NPC_2),
                      .ex_cm_mispredict_2(cm_mispredict_2),
                      .ex_cm_branch_result_2(cm_branch_result_2),
                      .ex_cm_pht_index_2(cm_pht_index_2),
		                  .ex_cm_valid_2(cm_valid_2),
		                  .ex_cm_CPC_2(cm_CPC_2),
		  
		                  // Outputs
		                  .cdb_tag_1(cm_tag_out_1),
		                  .cdb_value_1(cm_value_out_1),
		                  .cdb_NPC_1(cm_NPC_out_1),
                      .cdb_mispredict_1(cm_mispredict_out_1),
                      .cdb_branch_result_1(cm_branch_result_out_1),
                      .cdb_pht_index_1(cm_pht_index_out_1),
                      .cdb_CPC_1(cm_CPC_out_1),

		                  .cdb_tag_2(cm_tag_out_2),
		                  .cdb_value_2(cm_value_out_2),
		                  .cdb_NPC_2(cm_NPC_out_2),
                      .cdb_mispredict_2(cm_mispredict_out_2),
                      .cdb_branch_result_2(cm_branch_result_out_2),
                      .cdb_pht_index_2(cm_pht_index_out_2),
                      .cdb_CPC_2(cm_CPC_out_2)
		                  );   
		                  
  //////////////////////////////////////////////////
  //                                              //
  //               LSQ (not stage)                //
  //                                              //
  //////////////////////////////////////////////////
	
	always@*
	begin
  	if(reset || mispredict)
        begin

      lsq_ROB_head_1         = 0;
      lsq_ROB_head_2         = 0;

      lsq_ROB_tag_1          = 0;
      lsq_rd_mem_1           = 0;
      lsq_wr_mem_1           = 0;
      lsq_valid_1            = 0;

      lsq_EX_tag_1           = 0;
      lsq_value_1            = 0;
      lsq_address_1          = 0;
      lsq_EX_valid_1         = 0;

      lsq_ROB_tag_2          = 0;
      lsq_rd_mem_2           = 0;
      lsq_wr_mem_2           = 0;
      lsq_valid_2            = 0;

      lsq_EX_tag_2           = 0;
      lsq_value_2            = 0;
      lsq_address_2          = 0;
      lsq_EX_valid_2         = 0;
     
      lsq_Dmem2proc_data     = 0;
      lsq_Dmem2proc_tag      = 0;
      lsq_Dmem2proc_response = 0;
      
        end
        else
        begin

      lsq_ROB_head_1         = rob_inst1_retire_tag_out;
      lsq_ROB_head_2         = rob_inst2_retire_tag_out;

      lsq_ROB_tag_1          = rob_inst1_tag_out;
      lsq_rd_mem_1           = ff_rd_mem_1;
      lsq_wr_mem_1           = ff_wr_mem_1;
      lsq_valid_1            = ff_valid_inst1;

      lsq_EX_tag_1           = ex_LSQ_tag_out_1;
      lsq_value_1            = ex_LSQ_value_out_1;
      lsq_address_1          = ex_LSQ_address_out_1;
      lsq_EX_valid_1         = ex_LSQ_valid_out_1;

      lsq_ROB_tag_2          = rob_inst2_tag_out;
      lsq_rd_mem_2           = ff_rd_mem_2;
      lsq_wr_mem_2           = ff_wr_mem_2;
      lsq_valid_2            = ff_valid_inst2;

      lsq_EX_tag_2           = ex_LSQ_tag_out_2;
      lsq_value_2            = ex_LSQ_value_out_2;
      lsq_address_2          = ex_LSQ_address_out_2;
      lsq_EX_valid_2         = ex_LSQ_valid_out_2;
     
      lsq_Dmem2proc_data     = mem2proc_data;
      lsq_Dmem2proc_tag      = mem2proc_tag;
      lsq_Dmem2proc_response = Imem2proc_response;
        end
	  
   end
		           
		           
  LSQ LSQ_0(//Inputs
			      .clock(clock),
			      .reset(reset),
                              .miss_reset(halted || mispredict),
                        
			      //From ROB/ID
			      .ROB_head_1(lsq_ROB_head_1),
			      .ROB_head_2(lsq_ROB_head_2),

			      //1
			      .ROB_tag_1(lsq_ROB_tag_1),
			      .rd_mem_in_1(lsq_rd_mem_1),
			      .wr_mem_in_1(lsq_wr_mem_1),
			      .valid_in_1(lsq_valid_1 && ~stall_first_half_of_pipeline),

			      //2
			      .ROB_tag_2(lsq_ROB_tag_2),
			      .rd_mem_in_2(lsq_rd_mem_2),
			      .wr_mem_in_2(lsq_wr_mem_2),
			      .valid_in_2(lsq_valid_2 && ~stall_first_half_of_pipeline),

			      //From EX ALU
			      .EX_tag_1(lsq_EX_tag_1),
			      .value_in_1(lsq_value_1),
			      .address_in_1(lsq_address_1),
			      .EX_valid_1(lsq_EX_valid_1),

			      .EX_tag_2(lsq_EX_tag_2),
			      .value_in_2(lsq_value_2),
			      .address_in_2(lsq_address_2),
			      .EX_valid_2(lsq_EX_valid_2),

			      //From MEM
			      .Dmem2proc_data(mem2proc_data),
			      .Dmem2proc_tag(mem2proc_tag),
			      .Dmem2proc_response(mem2proc_response),
			
			      //Outputs
			      .tag_out(lsq_tag_out),
			      .mem_result_out(lsq_mem_result_out),
			      .proc2Dmem_command(lsq_proc2Dmem_command_out),
			      .proc2Dmem_addr(lsq_proc2Dmem_addr_out),
			      .proc2Dmem_data(lsq_proc2Dmem_data_out),
			      .LSQ_IF_stall(lsq_LSQ_IF_stall_out),
			      .LSQ_EX_valid(lsq_LSQ_EX_valid_out),
                              .LSQ_full(LSQ_full),
                              .LSQ_empty(LSQ_empty)

		        );


endmodule  // module verisimple


