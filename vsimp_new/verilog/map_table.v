
/////////////////////////////////////////////////////////
// this file is for the map table for our processor    //
/////////////////////////////////////////////////////////


// defines //
`define SD #1
`define RSTAG_NULL 8'hFF
`define ZERO_REG   5'h1f

//`timescale 1ns/100ps

// main map table module //
module map_table(clock,reset,clear_entries,        // signal inputs

                 // instruction 1 access inputs //
                 inst1_rega_in,
                 inst1_regb_in,
                 inst1_dest_in,
                 inst1_tag_in,

                 // instruction 2 access inputs //
                 inst2_rega_in,
                 inst2_regb_in,
                 inst2_dest_in,
                 inst2_tag_in,

                 // cdb inputs //
                 cdb1_tag_in,
                 cdb2_tag_in,
                
                 // tag outputs //
                 inst1_taga_out,inst1_tagb_out,
                 inst2_taga_out,inst2_tagb_out  );

   // inputs //
   input wire clock;
   input wire reset;
   input wire [31:0] clear_entries;
   input wire [4:0] inst1_rega_in,inst1_regb_in;
   input wire [4:0] inst2_rega_in,inst2_regb_in;
   input wire [4:0] inst1_dest_in;
   input wire [4:0] inst2_dest_in;
   input wire [7:0] inst1_tag_in;
   input wire [7:0] inst2_tag_in;
   input wire [7:0] cdb1_tag_in;
   input wire [7:0] cdb2_tag_in;

   // outputs //
   output wire [7:0] inst1_taga_out,inst1_tagb_out;
   output wire [7:0] inst2_taga_out,inst2_tagb_out;


   // internal registers and wires //
   wire [31:0] n_ready_in_rob;
   wire [7:0]  n_tag_table [31:0];
   reg  [7:0]    tag_table [31:0];
   wire inst1_dest_nonzero;
   wire inst2_dest_nonzero;
   wire inst1_tag_nonnull;
   wire inst2_tag_nonnull;

   // combinational assignment for internal wires //
   assign inst1_dest_nonzero = (inst1_dest_in!=`ZERO_REG);
   assign inst2_dest_nonzero = (inst2_dest_in!=`ZERO_REG);
   assign inst1_tag_nonnull = (inst1_tag_in!=`RSTAG_NULL);
   assign inst2_tag_nonnull = (inst2_tag_in!=`RSTAG_NULL);

   // combinational assignments for the tag outputs //
   assign inst1_taga_out = (reset ? `RSTAG_NULL : tag_table[inst1_rega_in]);
   assign inst1_tagb_out = (reset ? `RSTAG_NULL : tag_table[inst1_regb_in]);
   assign inst2_taga_out = (reset ? `RSTAG_NULL : ((inst2_rega_in==inst1_dest_in) && inst1_dest_nonzero && inst1_tag_nonnull) ? inst1_tag_in : tag_table[inst2_rega_in] );  // forward from inst1
   assign inst2_tagb_out = (reset ? `RSTAG_NULL : ((inst2_regb_in==inst1_dest_in) && inst1_dest_nonzero && inst1_tag_nonnull) ? inst1_tag_in : tag_table[inst2_regb_in] );  // forward from inst1

   // combinational logic for next states in tag table //
   assign n_ready_in_rob[`ZERO_REG] = 1'b0;
   assign n_tag_table[`ZERO_REG]    = `RSTAG_NULL;
   genvar i;
   generate
      for (i=0; i<31; i=i+1)
      begin : NTAGTABLEASSIGN
         assign n_ready_in_rob[i] = ( tag_table[i][6] || (cdb1_tag_in==tag_table[i] && cdb1_tag_in!=`RSTAG_NULL) || (cdb2_tag_in==tag_table[i] && cdb2_tag_in!=`RSTAG_NULL) );
         assign n_tag_table[i] = ((inst2_dest_in==i) && inst2_dest_nonzero && inst2_tag_nonnull) ? inst2_tag_in :            // inst2 takes precidence here
                                   (  ((inst1_dest_in==i) && inst1_dest_nonzero && inst1_tag_nonnull) ? inst1_tag_in :        // because it comes after inst1
                                         ((clear_entries[i] || tag_table[i]==`RSTAG_NULL) ? `RSTAG_NULL : {1'b0,n_ready_in_rob[i],tag_table[i][5:0]} )  );
      end
   endgenerate


   // assign the next values for the tag_table on the clock edge //
   genvar j;
   generate 
      for (j=0; j<32; j=j+1)
      begin : NTAGTABLEALWAYS
         always @(posedge clock)
         begin
            if (reset)
               tag_table[j] <= `SD `RSTAG_NULL;
            else
               tag_table[j] <= `SD n_tag_table[j];
         end
      end
   endgenerate

/*
   // clock synchronous stuff for assigning the output tags //
   always@(posedge clock)
   begin
      if (reset)
      begin    
         inst1_taga_out <= `SD `RSTAG_NULL;
         inst1_tagb_out <= `SD `RSTAG_NULL;
         inst2_taga_out <= `SD `RSTAG_NULL;
         inst2_tagb_out <= `SD `RSTAG_NULL;
      end
      else
      begin
         inst1_taga_out <= `SD n_inst1_taga_out;
         inst1_tagb_out <= `SD n_inst1_tagb_out;
         inst2_taga_out <= `SD n_inst2_taga_out;
         inst2_tagb_out <= `SD n_inst2_tagb_out;
      end
   end
*/

endmodule 


