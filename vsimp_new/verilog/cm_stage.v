//////////////////////////////////////////////////////////////////////////
//                                                                      //
//   Modulename :  cm_stage.v                                           //
//                                                                      //
//  Description :  Broadcast which two instructions are complete	//
//		   on the CDB.						//
//                                                                      //
//                                                                      //
//////////////////////////////////////////////////////////////////////////

`timescale 1ns/100ps

// complete stage. purely combinational (needs latches outside)  //
module cm_stage(// Inputs

                ex_cm_tag_1,
                ex_cm_result_1,
                ex_cm_NPC_1,
                ex_cm_mispredict_1,
                ex_cm_branch_result_1,
                ex_cm_pht_index_1,
                ex_cm_valid_1,

                ex_cm_tag_2,
                ex_cm_result_2,
                ex_cm_NPC_2,
                ex_cm_mispredict_2,
                ex_cm_branch_result_2,
                ex_cm_pht_index_2,
                ex_cm_valid_2,
		
                // Outputs
                cdb_tag_1,
                cdb_value_1,
                cdb_NPC_1,
                cdb_mispredict_1,
                cdb_branch_result_1,
                cdb_pht_index_1,

                cdb_tag_2,
                cdb_value_2,
                cdb_NPC_2,
                cdb_mispredict_2,
                cdb_branch_result_2,
                cdb_pht_index_2,

		            );

   // inputs //
   input wire [4:0]  ex_cm_tag_1;
   input wire [63:0] ex_cm_result_1;
   input wire [63:0] ex_cm_NPC_1;
   input wire        ex_cm_mispredict_1;
   input wire [1:0]  ex_cm_branch_result_1;
   input wire [(`HISTORY_BITS-1):0] ex_cm_pht_index_1;
   input wire        ex_cm_valid_1;

   input wire  [4:0] ex_cm_tag_2;
   input wire [63:0] ex_cm_result_2;
   input wire [63:0] ex_cm_NPC_2;
   input wire        ex_cm_mispredict_2;
   input wire [1:0]  ex_cm_branch_result_2;
   input wire [(`HISTORY_BITS-1):0] ex_cm_pht_index_2;
   input wire        ex_cm_valid_2;

   // outputs //
   output wire  [4:0] cdb_tag_1;
   output wire [63:0] cdb_value_1;
   output wire [63:0] cdb_NPC_1;
   output wire        cdb_mispredict_1;
   output wire [1:0]  cdb_branch_result_1;
   output wire [(`HISTORY_BITS-1):0] cdb_pht_index_1;

   output wire  [4:0] cdb_tag_2;
   output wire [63:0] cdb_value_2;
   output wire [63:0] cdb_NPC_2;
   output wire        cdb_mispredict_2;
   output wire [1:0]  cdb_branch_result_2;
   output wire [(`HISTORY_BITS-1):0] cdb_pht_index_2;

   // assigns //
   assign cdb_tag_1           = (ex_cm_valid_1 ? ex_cm_tag_1    : `RSTAG_NULL);
   assign cdb_value_1         = (ex_cm_valid_1 ? ex_cm_result_1 : 64'h0);
   assign cdb_NPC_1           = ex_cm_NPC_1;
   assign cdb_mispredict_1    = ex_cm_mispredict_1;
   assign cdb_branch_result_1 = ex_cm_branch_predict_1;
   assign cdb_pht_index_1     = ex_cm_pht_index_1;

   assign cdb_tag_2           = (ex_cm_valid_2 ? ex_cm_tag_2    : `RSTAG_NULL);
   assign cdb_value_2         = (ex_cm_valid_2 ? ex_cm_result_2 : 64'h0);
   assign cdb_NPC_2           = ex_cm_NPC_2;
   assign cdb_mispredict_2    = ex_cm_mispredict_2;
   assign cdb_branch_result_2 = ex_cm_branch_predict_2;
   assign cdb_pht_index_2     = ex_cm_pht_index_2;

endmodule


