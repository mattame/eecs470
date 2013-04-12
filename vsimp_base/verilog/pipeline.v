/////////////////////////////////////////////////////////////////////////
//                                                                     //
//   Modulename :  pipeline.v                                          //
//                                                                     //
//  Description :  Top-level module of the verisimple pipeline;        //
//                 This instantiates and connects the 5 stages of the  //
//                 Verisimple pipeline togeather.                      //
//                                                                     //
//                                                                     //
/////////////////////////////////////////////////////////////////////////
//t

`timescale 1ns/100ps

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
                 if_IR_out,
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
  output [31:0] if_IR_out;
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
  wire [63:0] if_NPC_out_1;
  wire [31:0] if_IR_out_1;
  wire        if_valid_inst_out_1;

  wire [63:0] if_NPC_out_2;
  wire [31:0] if_IR_out_2;
  wire        if_valid_inst_out_2;

  wire [63:0] proc2Imem_addr;

  // Outputs from IF/ID Pipeline Register
  reg  [63:0] if_id_NPC;
  reg  [31:0] if_id_IR;
  reg         if_id_valid_inst;
   
  // Outputs from ID stage
  wire [63:0] id_rega_out;
  wire [63:0] id_regb_out;
  wire  [1:0] id_opa_select_out;
  wire  [1:0] id_opb_select_out;
  wire  [4:0] id_dest_reg_idx_out;
  wire  [4:0] id_alu_func_out;
  wire        id_rd_mem_out;
  wire        id_wr_mem_out;
  wire        id_cond_branch_out;
  wire        id_uncond_branch_out;
  wire        id_halt_out;
  wire        id_illegal_out;
  wire        id_valid_inst_out;

  // Outputs from ID/EX Pipeline Register
  reg  [63:0] id_ex_NPC;
  reg  [31:0] id_ex_IR;
  reg  [63:0] id_ex_rega;
  reg  [63:0] id_ex_regb;
  reg   [1:0] id_ex_opa_select;
  reg   [1:0] id_ex_opb_select;
  reg   [4:0] id_ex_dest_reg_idx;
  reg   [4:0] id_ex_alu_func;
  reg         id_ex_rd_mem;
  reg         id_ex_wr_mem;
  reg         id_ex_cond_branch;
  reg         id_ex_uncond_branch;
  reg         id_ex_halt;
  reg         id_ex_illegal;
  reg         id_ex_valid_inst;
   
  // Outputs from EX-Stage
  wire [63:0] ex_alu_result_out;
  wire        ex_take_branch_out;

  // Outputs from EX/MEM Pipeline Register
  reg  [63:0] ex_mem_NPC;
  reg  [31:0] ex_mem_IR;
  reg   [4:0] ex_mem_dest_reg_idx;
  reg         ex_mem_rd_mem;
  reg         ex_mem_wr_mem;
  reg         ex_mem_halt;
  reg         ex_mem_illegal;
  reg         ex_mem_valid_inst;
  reg  [63:0] ex_mem_rega;
  reg  [63:0] ex_mem_alu_result;
  reg         ex_mem_take_branch;
  
  // Outputs from MEM-Stage
  wire [63:0] mem_result_out;

  wire [63:0] proc2Dmem_addr;
  wire [1:0]  proc2Dmem_command;

  // Outputs from MEM/WB Pipeline Register
  reg  [63:0] mem_wb_NPC;
  reg  [31:0] mem_wb_IR;
  reg         mem_wb_halt;
  reg         mem_wb_illegal;
  reg         mem_wb_valid_inst;
  reg   [4:0] mem_wb_dest_reg_idx;
  reg  [63:0] mem_wb_result;
  reg         mem_wb_take_branch;

  // Outputs from WB-Stage  (These loop back to the register file in ID)
  wire [63:0] wb_reg_wr_data_out;
  wire  [4:0] wb_reg_wr_idx_out;
  wire        wb_reg_wr_en_out;
  
  reg stall;
 
  //include memory arbiter 
  assign stall = stall_RS | stall_ROB;

  assign pipeline_completed_insts = {3'b0, mem_wb_valid_inst};
  assign pipeline_error_status = 
    mem_wb_illegal ? `HALTED_ON_ILLEGAL
                   : mem_wb_halt ? `HALTED_ON_HALT
                                 : (mem2proc_response==4'h0) 
                                   ? `HALTED_ON_MEMORY_ERROR 
                                   : `NO_ERROR;

  assign pipeline_commit_wr_idx = wb_reg_wr_idx_out;
  assign pipeline_commit_wr_data = wb_reg_wr_data_out;
  assign pipeline_commit_wr_en = wb_reg_wr_en_out;
  assign pipeline_commit_NPC = mem_wb_NPC;

  assign proc2mem_command =
           (proc2Dmem_command==`BUS_NONE)?`BUS_LOAD:proc2Dmem_command;
  assign proc2mem_addr =
           (proc2Dmem_command==`BUS_NONE)?proc2Imem_addr:proc2Dmem_addr;

  

  //////////////////////////////////////////////////
  //                                              //
  //                  IF-Stage                    //
  //                                              //
  //////////////////////////////////////////////////
  if_stage if_stage_0 (// Inputs
                       .clock (clock),
                       .reset (reset),
                       
                       
                       //What does stall do or where does it come from
                       .stall (stall),
                       
                       //this was not in our IF stage
                       //.mem_wb_valid_inst(mem_wb_valid_inst),
                       
                       .ex_mem_take_branch(ex_mem_take_branch),
                       .ex_mem_target_pc(ex_mem_alu_result),
                       .Imem2proc_data(Imem2proc_data),
                       
                       // Outputs
                       .if_NPC_out_1(if_NPC_1), 
                       .if_IR_out_1(if_IR_1),
                       .if_valid_inst_out1(if_valid_inst_1),
                       
                       .if_NPC_out_2(if_NPC_2), 
                       .if_IR_out_2(if_IR_2),
                       .if_valid_inst_out2(if_valid_inst_2),

                       .proc2Imem_addr(proc2Imem_addr),
                   
                      );

  wire [63:0] if_NPC_1, if_NPC_2;
  wire [31:0] if_IR_1, if_IR_2;
  wire if_valid_inst_1, if_valid_inst_2;


  //////////////////////////////////////////////////
  //                                              //
  //            IF/ID Pipeline Register           //
  //                                              //
  //////////////////////////////////////////////////
  always @(posedge clock)
  begin
    if(reset)
    begin
      if_id_NPC_1        <= `SD 0;
      if_id_IR_1         <= `SD `NOOP_INST;
      if_id_valid_inst_1 <= `SD `FALSE;
      
      if_id_NPC_2        <= `SD 0;
      if_id_IR_2         <= `SD `NOOP_INST;
      if_id_valid_inst_2 <= `SD `FALSE;
    end // if (reset)
    else
      begin
      if_id_NPC_1        <= `SD if_NPC_1;
      if_id_IR_1         <= `SD if_IR_1;
      if_id_valid_inst_1 <= `SD if_valid_inst_1;
      
      if_id_NPC_2        <= `SD if_NPC_2;
      if_id_IR_2         <= `SD if_IR_2;
      if_id_valid_inst_2 <= `SD if_valid_inst_2;
      end // if (if_id_enable)
  end // always

   
  //////////////////////////////////////////////////
  //                                              //
  //                  ID-Stage                    //
  //                                              //
  //////////////////////////////////////////////////

  
  id_stage id_stage0(
              // Inputs
              .clock(clock),
              .reset(reset),
              if_id_IR_1(if_IR_1),
              if_id_valid_inst_1(if_valid_inst_1),

              if_id_IR_2(if_IR_2),
              if_id_valid_inst_2(if_valid_inst2),



              // Outputs
              .id_opa_select_out_1,
              .id_opb_select_out_1,
              .id_alu_func_out_1,
              .id_rd_mem_out_1,
              .id_wr_mem_out_1,
              .id_cond_branch_out_1,
              .id_uncond_branch_out_1,
              .id_halt_out_1,
              .id_illegal_out_1,
              .id_valid_inst_out_1,
              
              .ra_idx_1(rega_1_out),
              .rb_idx_1(regb_1_out),
              .id_dest_reg_idx_out_1,

              .id_opa_select_out_2,
              .id_opb_select_out_2,
              .id_alu_func_out_2,
              .id_rd_mem_out_2,
              .id_wr_mem_out_2,
              .id_cond_branch_out_2,
              .id_uncond_branch_out_2,
              .id_halt_out_2,
              .id_illegal_out_2,
              .id_valid_inst_out_2,
              
              .ra_idx_2(rega_2_out),
              .rb_idx_2(regb_2_out),
              .id_dest_reg_idx_out_2
              
              );
                      
  //Outputs from ID Stage 
  wire  [4:0] id_rega_1_out, id_regb_1_out, id_dest_reg_1_out;
  wire  [1:0] id_opa_select_out_1, id_opb_select_out_1;
  wire  [4:0] id_alu_func_out_1;
  wire        id_rd_mem_out_1;
  wire        id_wr_mem_out_1;
  wire        id_cond_branch_out_1;
  wire        id_uncond_branch_out_1;
  wire        id_halt_out_1;
  wire        id_illegal_out_1;
  wire        id_valid_inst_out_1; 
  
  wire  [4:0] id_rega_2_out, id_regb_2_out, id_dest_reg_2_out;
  wire  [1:0] id_opa_select_out_2, id_opb_select_out_2;
  wire  [4:0] id_alu_func_out_2;
  wire        id_rd_mem_out_2;
  wire        id_wr_mem_out_2;
  wire        id_cond_branch_out_2;
  wire        id_uncond_branch_out_2;
  wire        id_halt_out_2;
  wire        id_illegal_out_2;
  wire        id_valid_inst_out_2;  
  
  //Outputs from ID/Map Table Regsiter
  reg  [4:0] mt_rega_1, mt_regb_1, mt_dest_reg_1;
  reg  [1:0] mt_opa_select_1, mt_opb_select_1;
  reg  [4:0] mt_alu_func_1;
  reg        mt_rd_mem_1;
  reg        mt_wr_mem_1;
  reg        mt_cond_branch_1;
  reg        mt_uncond_branch_1;
  reg        mt_halt_1;
  reg        mt_illegal_1;
  reg        mt_valid_inst_1; 
 
  reg  [4:0] mt_rega_2, mt_regb_2, mt_dest_reg_2;  
  reg  [1:0] mt_opa_select_out_2, mt_opb_select_2;
  reg  [4:0] mt_alu_func_2;
  reg        mt_rd_mem_2;
  reg        mt_wr_mem_2;
  reg        mt_cond_branch_2;
  reg        mt_uncond_branch_2;
  reg        mt_halt_2;
  reg        mt_illegal_2;
  reg        mt_valid_inst_2;  

  //////////////////////////////////////////////////
  //                                              //
  //             ID/Map Table Register            //
  //                                              //
  //////////////////////////////////////////////////
  always @(posedge clock)
  begin
    if(reset)
    begin
      mt_rega_1           <= `SD 0;
      mt_regb_1           <= `SD 0;
      mt_dest_reg_1       <= `SD 0;
      mt_opa_select_1     <= `SD 0;
      mt_alu_func_1       <= `SD 0;
      mt_rd_mem_1         <= `SD 0;
      mt_wr_mem_1         <= `SD 0;
      mt_cond_branch_1    <= `SD 0;
      mt_uncond_branch_1  <= `SD 0;
      mt_halt_1           <= `SD 0;
      mt_illegal_1        <= `SD 0;
      mt_valid_inst_1     <= `SD 0;
      
      mt_rega_2           <= `SD 0;
      mt_regb_2           <= `SD 0;
      mt_dest_reg_2       <= `SD 0;
      mt_opa_select_2     <= `SD 0;
      mt_alu_func_2       <= `SD 0;
      mt_rd_mem_2         <= `SD 0;
      mt_wr_mem_2         <= `SD 0;
      mt_cond_branch_2    <= `SD 0;
      mt_uncond_branch_2  <= `SD 0;
      mt_halt_2           <= `SD 0;
      mt_illegal_2        <= `SD 0;
      mt_valid_inst_2     <= `SD 0;

    end
    else
    begin
           
      mt_rega_1           <= `SD id_rega_1_out;
      mt_regb_1           <= `SD id_regb_1_out;
      mt_dest_reg_1       <= `SD id_dest_reg_1_out;
      mt_opa_select_1     <= `SD id_opa_select_1_out;
      mt_alu_func_1       <= `SD id_alu_func_1_out;
      mt_rd_mem_1         <= `SD id_rd_mem_1_out;
      mt_wr_mem_1         <= `SD id_wr_mem_1_out;
      mt_cond_branch_1    <= `SD id_cond_branch_1_out;
      mt_uncond_branch_1  <= `SD id_uncond_branch_1_out;
      mt_halt_1           <= `SD id_halt_1_out;
      mt_illegal_1        <= `SD id_illegal_1_out;
      mt_valid_inst_1     <= `SD id_valid_inst_1_out;
      
      mt_rega_2           <= `SD id_rega_2_out;
      mt_regb_2           <= `SD id_regb_2_out;
      mt_dest_reg_2       <= `SD id_dest_reg_2_out;
      mt_opa_select_2     <= `SD id_opa_select_2_out;
      mt_alu_func_2       <= `SD id_alu_func_2_out;
      mt_rd_mem_2         <= `SD id_rd_mem_2_out;
      mt_wr_mem_2         <= `SD id_wr_mem_2_out;
      mt_cond_branch_2    <= `SD id_cond_branch_2_out;
      mt_uncond_branch_2  <= `SD id_uncond_branch_2_out;
      mt_halt_2           <= `SD id_halt_2_out;
      mt_illegal_2        <= `SD id_illegal_2_out;
      mt_valid_inst_2     <= `SD id_valid_inst_2_out;          
 
    end
  end
  
  
  //////////////////////////////////////////////////
  //                                              //
  //                Map Table Stage               //
  //                                              //
  ////////////////////////////////////////////////// 
   map_table map_table_0 (//Inputs
  
                           .clock(clock), .reset(reset), .clear_entries(clear_entries),


                           // instruction 1 access inputs //
                           //THESE COME FROM DECODE
                           .inst1_rega_in(rega_1),
                           .inst1_regb_in(regb_1),
                           
                           //THESE COME FROM ROB
                           .inst1_dest_in,
                           .inst1_tag_in,

                           // instruction 2 access inputs //
                           .inst2_rega_in(rega_1),
                           .inst2_regb_in(regb_2),
                           
                           .inst2_dest_in,
                           .inst2_tag_in,

                           // cdb inputs //
                           .cdb1_tag_in(cdb_tag_1),
                           .cdb2_tag_in(cdb_tag_2),
                          
                           // tag outputs //
                           .inst1_taga_out(mt_inst1_taga), .inst1_tagb_out(mt_inst1_tagb),
                           .inst2_taga_out(mt_inst2_taga), .inst2_tagb_out(mt_inst2_tagb)  
                           
                           );                    

  wire rob_full, rob_empty;

  //from Map Table to ROB
  wire [7:0] mt_inst1_taga_in, mt_inst1_tagb_in, mt_inst2_taga_in, mt_inst2_tagb_in;
  reg [7:0] rob_inst1_taga_out, rob_inst1_tagb_out, rob_inst2_taga_out, rob_inst2_tagb_out;
  
  //////////////////////////////////////////////////
  //                                              //
  //           Map Table to ROB Register          //
  //                                              //
  //////////////////////////////////////////////////
  
  always @(posedge clock)
  begin
    if (reset)
    begin
      rob_inst1_taga_out <= `SD 7'b0;
      rob_inst1_tagb_out <= `SD 7'b0;
      rob_inst2_taga_out <= `SD 7'b0;
      rob_inst2_tagb_out <= `SD 7'b0;
    
    end
    else
      rob_inst1_taga_out <= `SD mt_inst1_taga_in;
      rob_inst1_tagb_out <= `SD mt_inst1_tagb_in;
      rob_inst2_taga_out <= `SD mt_inst2_taga_in;
      rob_inst2_tagb_out <= `SD mt_inst2_tagb_in;
  
  end
  
  
  //from ROB to Register
  wire  [4:0] inst1_dest, inst2_dest;
  wire [63:0] inst1_value, inst2_value;

  //from ROB to Reservation Station
  wire [63:0] rob_inst1_rega_value, rob_inst1_regb_value, rob_inst2_rega_value, rob_inst2_regb_value;
  wire  [7:0] inst1_tag, inst2_tag;


  //////////////////////////////////////////////////
  //                                              //
  //                  ROB Stage                   //
  //                                              //
  //////////////////////////////////////////////////

  reorder_buffer reorder_buffer_0 (//Inputs
  
                                          .clock(clock), .reset(reset),
                                          
                                          /*these will come from decode*/
                                          .inst1_valid_in,
                                          .inst1_dest_in,

                                          .inst2_valid_in,
                                          .inst2_dest_in,

                                          // tags for reading from the rs // 
                                          .inst1_rega_tag_in(inst1_taga_out),
                                          .inst1_regb_tag_in(inst1_tagb_out),
                                          .inst2_rega_tag_in(inst2_taga_out),
                                          .inst2_regb_tag_in(inst2_tagb_out),

                                          // cdb inputs //
                                          .cdb1_tag_in(cdb_tag_1),
                                          .cdb1_value_in(cdb_value_1),
                                          .cdb2_tag_in(cdb_tag_2),
                                          .cdb2_value_in(cdb_value_2), 

                                          // outputs //
                                          
                                          //outputs to RS
                                          .inst1_tag_out(inst1_tag),
                                          .inst2_tag_out(inst2_tag),

                                          // values out to the rs //
                                          .inst1_rega_value_out(rob_inst1_rega_value),
                                          .inst1_regb_value_out(rob_inst1_regb_value),
                                          .inst2_rega_value_out(rob_inst2_rega_value),
                                          .inst2_regb_value_out(rob_inst2_regb_value),     

                                          // outputs to write directly to the reg file //
                                          .inst1_dest_out(inst1_dest), .inst1_value_out(inst1_value),
                                          .inst2_dest_out(inst2_dest), .inst2_value_out(inst2_value),

                                          // signals out //
                                          .rob_full(rob_full), .rob_empty(rob_empty)
                                      );
                                      


  //////////////////////////////////////////////////
  //                                              //
  //           Map Table to RS Register           //
  //                                              //
  //////////////////////////////////////////////////
  
  reg  [4:0] rs_rega_1, rs_regb_1, rs_dest_reg_1;
  reg  [1:0] rs_opa_select_1, rs_opb_select_1;
  reg  [4:0] rs_alu_func_1;
  reg        rs_rd_mem_1;
  reg        rs_wr_mem_1;
  reg        rs_cond_branch_1;
  reg        rs_uncond_branch_1;
  reg        rs_halt_1;
  reg        rs_illegal_1;
  reg        rs_valid_inst_1; 
 
  reg  [4:0] mt_rega_2, mt_regb_2, mt_dest_reg_2;  
  reg  [1:0] mt_opa_select_out_2, mt_opb_select_2;
  reg  [4:0] mt_alu_func_2;
  reg        mt_rd_mem_2;
  reg        mt_wr_mem_2;
  reg        mt_cond_branch_2;
  reg        mt_uncond_branch_2;
  reg        mt_halt_2;
  reg        mt_illegal_2;
  reg        mt_valid_inst_2;  
  
  always @(posedge clock)
  begin
    if(reset) 
    begin
    
    rs_
    
    
    end
    else
    begin
    
  
  
    end
  end
                         
  //////////////////////////////////////////////////
  //                                              //
  //                   RS Stage                   //
  //                                              //
  //////////////////////////////////////////////////             
                                      
  reservation_station reservation_station_0(//Inputs
  
                           // signals and busses in for inst 1 (from id1) //
                           //Values from ROB
                           .inst1_rega_value_in(inst1_rega_value),
                           .inst1_regb_value_in(inst1_regb_value),
                        
                           //Tags from Map Table
                           .inst1_rega_tag_in(inst1_taga),
                           .inst1_regb_tag_in(inst1_tagb),


                           //Tag from ROB                           
                           .inst1_dest_tag_in(inst1_tag), 
                           
                           
                           
                           //Instruction signals from Decode                         
                           .inst1_dest_reg_in,
                           .inst1_opa_select_in,
                           .inst1_opb_select_in,
                           .inst1_alu_func_in,
                           .inst1_rd_mem_in,
                           .inst1_wr_mem_in,
                           .inst1_cond_branch_in,
                           .inst1_uncond_branch_in,
                           .inst1_valid,

                           // signals and busses in for inst 2 (from id2) //
                           //Values from DECODE
                           .inst2_rega_value_in(),
                           .inst2_regb_value_in(),
                           
                           //Tags from Map Table
                           .inst2_rega_tag_in(inst2_taga),
                           .inst2_regb_tag_in(inst2_tagb),
                           
                           //Tag from ROB
                           .inst2_dest_tag_in(inst2_tag),
                           
                           //Instruction signals from Decode
                           .inst2_dest_reg_in,
                           .inst2_opa_select_in,
                           .inst2_opb_select_in,
                           .inst2_alu_func_in,
                           .inst2_rd_mem_in,
                           .inst2_wr_mem_in,
                           .inst2_cond_branch_in,
                           .inst2_uncond_branch_in,
                           .inst2_valid,

                           // cdb inputs //
                           .cdb1_tag_in(cdb_tag_1),
                           .cdb2_tag_in(cdb_tag_2),
                           .cdb1_value_in(cdb_value_1),
                           .cdb2_value_in(cdb_value_2),

                           // inputs from the ROB //
                           .inst1_rega_rob_value_in(rob_inst1_rega_value),
                           .inst1_regb_rob_value_in(rob_inst1_regb_value),
                           .inst2_rega_rob_value_in(rob_inst2_rega_value),
                           .inst2_regb_rob_value_in(rob_inst2_regb_value),

                           // signals and busses out for inst1 to the ex stage
                           .inst1_rega_value_out, .inst1_regb_value_out,
                           .inst1_opa_select_out, .inst1_opb_select_out,
                           .inst1_alu_func_out,
                           .inst1_rd_mem_out, .inst1_wr_mem_out,
                           .inst1_cond_branch_out, .inst1_uncond_branch_out,
                           .inst1_valid_out,
                           .inst1_dest_reg_out,
                           .inst1_dest_tag_out,

                           // signals and busses out for inst2 to the ex stage
                           .inst2_rega_value_out, .inst2_regb_value_out,
                           .inst2_opa_select_out, .inst2_opb_select_out,
                           .inst2_alu_func_out,
                           .inst2_rd_mem_out, .inst2_wr_mem_out,
                           .inst2_cond_branch_out, .inst2_uncond_branch_out,
                           .inst2_valid_out,
                           .inst2_dest_reg_out,
                           .inst2_dest_tag_out,

                           // signal outputs //
                           .dispatch(stall_RS),
                         
                           // outputs for debugging //
                           .first_empties, .second_empties, .states_out, .fills, .issue_first_states, .issue_second_states, .ages_out
                           
                           );

  //////////////////////////////////////////////////
  //                                              //
  //              RS/EX Register                  //
  //                                              //
  //////////////////////////////////////////////////    


  wire [4:0] inst1_rega, inst1_regb, inst2_rega, inst2_regb;
      
  //from Register File to Reservation Station                         
  wire [63:0] inst1_rega, inst1_regb, inst2_rega, inst2_regb;
 
 
  //from Register File to Map Table
  wire [31:0] clear_entries;
  
  
  wire  [7:0] cdb_tag_1, cdb_tag_2;
  wire [63:0] cdb_value_1, cdb_value_2;
 
 
 
  //Execute to Complete Register 
  reg  [7:0] cm_tag_1, cm_tag_2;
  reg [63:0] cm_value_1, cm_value_2;
  reg cm_valid_1, cm_valid_2;
  
  wire  [7:0] ex_tag_1, ex_tag_2;
  wire [63:0] ex_value_1, ex_value_2;
  wire ex_valid_1, ex_valid_2;
  

  //////////////////////////////////////////////////
  //                                              //
  //             EX to Complete                   //
  //                                              //
  //////////////////////////////////////////////////

  //Synchronous Execute to Complete Register  
  always @(posedge clock)
  begin
    if(reset)
    begin
      cm_tag_1 <= `SD 7'b0;
      cm_value_1 <= `SD 63'b0;
      cm_valid_1 <= `SD 1'b0;
      
      cm_tag_2 <= `SD 7'b0;
      cm_value_2 <= `SD 63'b0;
      cm_valid_2 <= `SD 1'b0;

    end
    else
    begin
      cm_tag_1 <= `SD ex_tag_1;
      cm_value_1 <= `SD ex_value_1;
      cm_valid_1 <= `SD ex_valid_1;
      
      cm_tag_2 <= `SD ex_tag_2;
      cm_value_2 <= `SD ex_value_2;
      cm_valid_2 <= `SD ex_valid_2;
      
    end
    
  end
  
  
  //////////////////////////////////////////////////
  //                                              //
  //               Complete Stage                 //
  //                                              //
  //////////////////////////////////////////////////
  cm_stage cm_stage_0(// Inputs

		ex_cm_tag_1,
		ex_cm_result_1,
		ex_cm_valid_1,
		
		ex_cm_tag_2,
		ex_cm_result_2,
		ex_cm_valid_2,
		
		// Outputs
		.cdb_tag_1(cdb_tag_1),
		.cdb_value_1(cdb_value_1),

		.cdb_tag_2(cdb_tag_2),
		.cdb_value_2(cdb_value_2)
		);
  
  
  //////////////////////////////////////////////////
  //                                              //
  //                  ROB Stage                   //
  //                                              //
  //////////////////////////////////////////////////

  
  register_file register_file0(//Inputs
                      
                     .clock(clock), .reset(reset),

                     // input busses: register indexes and values in // 
                     .inst1_rega_in, .inst1_regb_in, 
                     .inst2_rega_in, .inst2_regb_in,
                     
                     //Destination and Value to write
                     .inst1_dest_in(inst1_dest), .inst1_value_in(inst1_value),
                     .inst2_dest_in(inst2_dest), .inst2_value_in(inst2_value),

                     // output busses: register values out //
                     .inst1_rega_out(inst1_rega), .inst1_regb_out(inst1_regb),
                     .inst2_rega_out(inst2_regb), .inst2_regb_out(inst2_regb),

                     // ouput signals: tell the map table when to clear //
                     .clear_entries(clear_entries)
                     );
  

  //////////////////////////////////////////////////
  //                                              //
  //            ID/EX Pipeline Register           //
  //                                              //
  //////////////////////////////////////////////////
  assign id_ex_enable = 1'b1; // always enabled
  // synopsys sync_set_reset "reset"
  always @(posedge clock)
  begin
    if (reset)
    begin
      id_ex_NPC           <= `SD 0;
      id_ex_IR            <= `SD `NOOP_INST;
      id_ex_rega          <= `SD 0;
      id_ex_regb          <= `SD 0;
      id_ex_opa_select    <= `SD 0;
      id_ex_opb_select    <= `SD 0;
      id_ex_dest_reg_idx  <= `SD `ZERO_REG;
      id_ex_alu_func      <= `SD 0;
      id_ex_rd_mem        <= `SD 0;
      id_ex_wr_mem        <= `SD 0;
      id_ex_cond_branch   <= `SD 0;
      id_ex_uncond_branch <= `SD 0;
      id_ex_halt          <= `SD 0;
      id_ex_illegal       <= `SD 0;
      id_ex_valid_inst    <= `SD 0;
    end // if (reset)
    else
    begin
      if (id_ex_enable)
      begin
        id_ex_NPC           <= `SD if_id_NPC;
        id_ex_IR            <= `SD if_id_IR;
        id_ex_rega          <= `SD id_rega_out;
        id_ex_regb          <= `SD id_regb_out;
        id_ex_opa_select    <= `SD id_opa_select_out;
        id_ex_opb_select    <= `SD id_opb_select_out;
        id_ex_dest_reg_idx  <= `SD id_dest_reg_idx_out;
        id_ex_alu_func      <= `SD id_alu_func_out;
        id_ex_rd_mem        <= `SD id_rd_mem_out;
        id_ex_wr_mem        <= `SD id_wr_mem_out;
        id_ex_cond_branch   <= `SD id_cond_branch_out;
        id_ex_uncond_branch <= `SD id_uncond_branch_out;
        id_ex_halt          <= `SD id_halt_out;
        id_ex_illegal       <= `SD id_illegal_out;
        id_ex_valid_inst    <= `SD id_valid_inst_out;
      end // if
    end // else: !if(reset)
  end // always


  //////////////////////////////////////////////////
  //                                              //
  //                  EX-Stage                    //
  //                                              //
  //////////////////////////////////////////////////
   ex_stage ex_stage_0(// Inputs
                          .clock(clock),
                          .reset(reset),
				                  // Input Bus 1 (contains branch logic)
                          .id_ex_NPC_1,
                          .id_ex_IR_1,
                          .id_ex_dest_reg_1,
                          .id_ex_rega_1,
                          .id_ex_regb_1,
                          .id_ex_opa_select_1,
                          .id_ex_opb_select_1,
                          .id_ex_alu_func_1,
                          .id_ex_cond_branch,
                          .id_ex_uncond_branch,

				                  // Input Bus 2
				                  .id_ex_NPC_2,
				                  .id_ex_IR_2,
				                  .id_ex_dest_reg_2,
				                  .id_ex_rega_2,
				                  .id_ex_regb_2,
				                  .id_ex_opa_select_2,
				                  .id_ex_opb_select_2,
				                  .id_ex_alu_func_2,
				
                          // From Mem Access
                          .MEM_tag_in,
                          .MEM_value_in,
                          .MEM_valid_in,
                          
			                    // Outputs
				                  .stall_bus_1,
				                  .stall_bus_2,
				                  .ex_branch_taken,
				                  
				                  // Bus 1
				                  .ex_IR_out_1,
				                  .ex_NPC_out_1,
				                  .ex_dest_reg_out_1(ex_tag_1),
				                  .ex_result_out_1(ex_value_1),
				                  .ex_valid_out_1(ex_valid_1),
				                  // Bus 2
				                  .ex_IR_out_2,
				                  .ex_NPC_out_2,
				                  .ex_dest_reg_out_2(ex_tag_1),
				                  .ex_result_out_2(ex_value_1),
				                  .ex_valid_out_2(ex_value_1),

                            // To LSQ
                          .LSQ_tag_out_1,
                          .LSQ_address_out_1,
                          .LSQ_value_out_1,

                          .LSQ_tag_out_2,
                          .LSQ_address_out_2,
                          .LSQ_value_out_2
                        );

  //////////////////////////////////////////////////
  //                                              //
  //           EX/MEM Pipeline Register           //
  //                                              //
  //////////////////////////////////////////////////
  assign ex_mem_enable = 1'b1; // always enabled
  // synopsys sync_set_reset "reset"
  always @(posedge clock)
  begin
    if (reset)
    begin
      ex_mem_NPC          <= `SD 0;
      ex_mem_IR           <= `SD `NOOP_INST;
      ex_mem_dest_reg_idx <= `SD `ZERO_REG;
      ex_mem_rd_mem       <= `SD 0;
      ex_mem_wr_mem       <= `SD 0;
      ex_mem_halt         <= `SD 0;
      ex_mem_illegal      <= `SD 0;
      ex_mem_valid_inst   <= `SD 0;
      ex_mem_rega         <= `SD 0;
      ex_mem_alu_result   <= `SD 0;
      ex_mem_take_branch  <= `SD 0;
    end
    else
    begin
      if (ex_mem_enable)
      begin
        // these are forwarded directly from ID/EX latches
        ex_mem_NPC          <= `SD id_ex_NPC;
        ex_mem_IR           <= `SD id_ex_IR;
        ex_mem_dest_reg_idx <= `SD id_ex_dest_reg_idx;
        ex_mem_rd_mem       <= `SD id_ex_rd_mem;
        ex_mem_wr_mem       <= `SD id_ex_wr_mem;
        ex_mem_halt         <= `SD id_ex_halt;
        ex_mem_illegal      <= `SD id_ex_illegal;
        ex_mem_valid_inst   <= `SD id_ex_valid_inst;
        ex_mem_rega         <= `SD id_ex_rega;
        // these are results of EX stage
        ex_mem_alu_result   <= `SD ex_alu_result_out;
        ex_mem_take_branch  <= `SD ex_take_branch_out;
      end // if
    end // else: !if(reset)
  end // always

   
  //////////////////////////////////////////////////
  //                                              //
  //                 MEM-Stage                    //
  //                                              //
  //////////////////////////////////////////////////
  mem_stage mem_stage_0 (// Inputs
                         .clock(clock),
                         .reset(reset),
                         .ex_mem_rega(ex_mem_rega),
                         .ex_mem_alu_result(ex_mem_alu_result), 
                         .ex_mem_rd_mem(ex_mem_rd_mem),
                         .ex_mem_wr_mem(ex_mem_wr_mem),
                         .Dmem2proc_data(mem2proc_data),
                         
                         // Outputs
                         .mem_result_out(mem_result_out),
                         .proc2Dmem_command(proc2Dmem_command),
                         .proc2Dmem_addr(proc2Dmem_addr),
                         .proc2Dmem_data(proc2mem_data)
                        );


  //////////////////////////////////////////////////
  //                                              //
  //           MEM/WB Pipeline Register           //
  //                                              //
  //////////////////////////////////////////////////
  assign mem_wb_enable = 1'b1; // always enabled
  // synopsys sync_set_reset "reset"
  always @(posedge clock)
  begin
    if (reset)
    begin
      mem_wb_NPC          <= `SD 0;
      mem_wb_IR           <= `SD `NOOP_INST;
      mem_wb_halt         <= `SD 0;
      mem_wb_illegal      <= `SD 0;
      mem_wb_valid_inst   <= `SD 0;
      mem_wb_dest_reg_idx <= `SD `ZERO_REG;
      mem_wb_take_branch  <= `SD 0;
      mem_wb_result       <= `SD 0;
    end
    else
    begin
      if (mem_wb_enable)
      begin
        // these are forwarded directly from EX/MEM latches
        mem_wb_NPC          <= `SD ex_mem_NPC;
        mem_wb_IR           <= `SD ex_mem_IR;
        mem_wb_halt         <= `SD ex_mem_halt;
        mem_wb_illegal      <= `SD ex_mem_illegal;
        mem_wb_valid_inst   <= `SD ex_mem_valid_inst;
        mem_wb_dest_reg_idx <= `SD ex_mem_dest_reg_idx;
        mem_wb_take_branch  <= `SD ex_mem_take_branch;
        // these are results of MEM stage
        mem_wb_result       <= `SD mem_result_out;
      end // if
    end // else: !if(reset)
  end // always


  //////////////////////////////////////////////////
  //                                              //
  //                  WB-Stage                    //
  //                                              //
  //////////////////////////////////////////////////
  wb_stage wb_stage_0 (// Inputs
                       .clock(clock),
                       .reset(reset),
                       .mem_wb_NPC(mem_wb_NPC),
                       .mem_wb_result(mem_wb_result),
                       .mem_wb_dest_reg_idx(mem_wb_dest_reg_idx),
                       .mem_wb_take_branch(mem_wb_take_branch),
                       .mem_wb_valid_inst(mem_wb_valid_inst),

                       // Outputs
                       .reg_wr_data_out(wb_reg_wr_data_out),
                       .reg_wr_idx_out(wb_reg_wr_idx_out),
                       .reg_wr_en_out(wb_reg_wr_en_out)
                      );

endmodule  // module verisimple


