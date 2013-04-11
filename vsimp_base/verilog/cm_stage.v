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

`define	NO_BROADCAST ; 

module cm_stage(// Inputs

		ex_cm_tag_1,
		ex_cm_result_1,
		ex_cm_valid_1,
		
		ex_cm_tag_2,
		ex_cm_result_2,
		ex_cm_valid_2,
		
		// Outputs
		cdb_tag_1,
		cdb_value_1,

		cdb_tag_2,
		cdb_value_2
		);

input  [4:0] ex_cm_tag_1;
input [63:0] ex_cm_result_1;
input        ex_cm_valid_1;

input  [4:0] ex_cm_tag_2;
input [63:0] ex_cm_result_2;
input        ex_cm_valid_2;

output  [4:0] cdb_tag_1;
output [63:0] cdb_value_1;

output  [4:0] cdb_tag_2;
output [63:0] cdb_value_2;

assign cdb_tag_1 = ex_cm_valid_1 ? ex_cm_tag_1: `NO_BROADCAST;
assign cdb_value_1 = ex_cm_valid_1 ? ex_cm_result_1: 64'h0;

assign cdb_tag_2 = ex_cm_valid_2 ? ex_cm_tag_2: `NO_BROADCAST;
assign cdb_value_2 = ex_cm_valid_2 ? ex_cm_result_2: 64'h0;

endmodule
