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


/*! This is just the plain and simple skeleton of what we need.
*   Nothing is filled in yet.
*   I put this together based on the pipeline I saw on Mike's notes
*   from the meeting with Dreslinski.
*/
/*! Do we need anything else?
*   The cache can be added in later as a sub-module in EX & IF
*/
/*! we need a map table, I've added it.
   -Mike
*/


// main pipeline module //
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

  

  //////////////////////////////////////////////////
  //                                              //
  //                   FETCH                      //
  //                                              //
  //////////////////////////////////////////////////
   if_stage if_stage_0 (// Inputs
                       
                       // Outputs
                      );


  //////////////////////////////////////////////////
  //                                              //
  //            IF/ID Pipeline Register           //
  //                                              //
  //////////////////////////////////////////////////
  assign if_id_enable = 1'b1; // always enabled
  // synopsys sync_set_reset "reset"
  always @(posedge clock)
  begin
    if(reset)
    begin
      if_id_NPC        <= `SD 0;
      if_id_IR         <= `SD `NOOP_INST;
      if_id_valid_inst <= `SD `FALSE;
    end // if (reset)
    else if (if_id_enable)
      begin
        if_id_NPC        <= `SD if_NPC_out;
        if_id_IR         <= `SD if_IR_out;
        if_id_valid_inst <= `SD if_valid_inst_out;
      end // if (if_id_enable)
  end // always
  //////////////////////////////////////////////////
  //                                              //
  //                   DECODE                     //
  //                                              //
  //////////////////////////////////////////////////
  id_stage id_stage_0 (// Inputs
                       
                       // Outputs
                      );

  //////////////////////////////////////////////////
  //                                              //
  //            ID/DI Pipeline Register           //
  //                                              //
  //////////////////////////////////////////////////
  assign id_di_enable = 1'b1; // always enabled
  // synopsys sync_set_reset "reset"
  always @(posedge clock)
  begin
  
  end
  
  //////////////////////////////////////////////////
  //                                              //
  //                 DISTRIBUTE                   //
  //                                              //
  //////////////////////////////////////////////////
  di_stage di_stage_0 (// Inputs
                       
                       // Outputs
                      );

  //////////////////////////////////////////////////
  //                                              //
  //           DI/RS Pipeline Register            //
  //                                              //
  //////////////////////////////////////////////////
  assign di_rs_enable = 1'b1; // always enabled
  // synopsys sync_set_reset "reset"
  always @(posedge clock)
  begin
  
  end
  
  //////////////////////////////////////////////////
  //                                              //
  //             RESERVATION STATION              //
  //                                              //
  //////////////////////////////////////////////////
  rs_stage rs_stage_0 (// Inputs
                       
                       // Outputs
                      );

  //////////////////////////////////////////////////
  //                                              //
  //           RS/ISU Pipeline Register           //
  //                                              //
  //////////////////////////////////////////////////
  assign rs_is_enable = 1'b1; // always enabled
  // synopsys sync_set_reset "reset"
  always @(posedge clock)
  begin
  
  end
  
  //////////////////////////////////////////////////
  //                                              //
  //                    ISSUE                     //
  //                                              //
  //////////////////////////////////////////////////
  is_stage is_stage_0 (// Inputs
                       
                       // Outputs
                      );

  //////////////////////////////////////////////////
  //                                              //
  //           IS/EXE Pipeline Register           //
  //                                              //
  //////////////////////////////////////////////////
  assign is_ex_enable = 1'b1; // always enabled
  // synopsys sync_set_reset "reset"
  always @(posedge clock)
  begin
  
  end
  
  //////////////////////////////////////////////////
  //                                              //
  //                   EXECTUTE                   //
  //                                              //
  //////////////////////////////////////////////////
  ex_stage ex_stage_0 (// Inputs
                       
                       // Outputs
                      );

  //////////////////////////////////////////////////
  //                                              //
  //           EX/RT Pipeline Register            //
  //                                              //
  //////////////////////////////////////////////////
  assign ex_rt_enable = 1'b1; // always enabled
  // synopsys sync_set_reset "reset"
  always @(posedge clock)
  begin
  
  end
  
  //////////////////////////////////////////////////
  //                                              //
  //                    RETIRE                    //
  //                                              //
  //////////////////////////////////////////////////
  rt_stage rt_stage_0 (// Inputs
                       
                       // Outputs
                      );

  //////////////////////////////////////////////////
  //                                              //
  //           RT/Other Pipeline Register         //
  //                                              //
  //////////////////////////////////////////////////
  assign rt_other_enable = 1'b1; // always enabled
  // synopsys sync_set_reset "reset"
  always @(posedge clock)
  begin
  
  end
  
  //////////////////////////////////////////////////
  //                                              //
  //                   REGISTERS                  //
  //                                              //
  //////////////////////////////////////////////////
  register_file rf (// Inputs
                       
                       // Outputs
                      );

  //////////////////////////////////////////////////
  //                                              //
  //                 ROB                          //
  //                                              //
  //////////////////////////////////////////////////
  // Note: did some research and a history buffer //
  // will actualy be harder to impliment and not  //
  // really give us any advantages, so i think we //
  // sould go with a ROB instead. I've switched   //
  // it here.                                     //
  //////////////////////////////////////////////////
 
  reorder_buffer rob(clock,reset// Inputs
                       
                       // Outputs
                      );


   /////////////////////////////////////////////////
   //                                             //
   //          MAP TABLE                          //
   //                                             //
   /////////////////////////////////////////////////
   map_table mt(clock,reset

                );



endmodule  // module verisimple;



