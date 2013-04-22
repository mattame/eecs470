
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

                 // inst1 writing inputs //
                 inst1_dest_in,
                 inst1_tag_in,

                 // instruction 2 access inputs //
                 inst2_rega_in,
                 inst2_regb_in,

                 // inst2 writing inputs //
                 inst2_dest_in,
                 inst2_tag_in,

                 // cdb inputs //
                 cdb1_tag_in,
                 cdb2_tag_in,

                 // retire tag inputs //
                 inst1_retire_tag_in,
                 inst2_retire_tag_in,
                
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

   input wire [7:0] inst1_retire_tag_in;
   input wire [7:0] inst2_retire_tag_in;

   // outputs //
   output reg [7:0] inst1_taga_out,inst1_tagb_out;
   output reg [7:0] inst2_taga_out,inst2_tagb_out;


   // internal registers and wires //
   wire [31:0] n_ready_in_rob;
   reg  [7:0]  n_tag_table [31:0];
   reg  [7:0]    tag_table [31:0];
   wire inst1_dest_nonzero;
   wire inst2_dest_nonzero;
   wire inst1_tag_nonnull;
   wire inst2_tag_nonnull;
   wire [31:0] clear_entries_real;

   // combinational assignment for internal wires //
   assign inst1_dest_nonzero = (inst1_dest_in!=`ZERO_REG);
   assign inst2_dest_nonzero = (inst2_dest_in!=`ZERO_REG);
   assign inst1_tag_nonnull = (inst1_tag_in!=`RSTAG_NULL);
   assign inst2_tag_nonnull = (inst2_tag_in!=`RSTAG_NULL);

   // combinational assignments for the tag outputs //
/*
   assign inst1_taga_out = (reset ? `RSTAG_NULL : ((inst1_dest_in==inst1_rega_in && inst1_dest_nonzero) ? tag_table[inst1_rega_in] : tag_table[inst1_rega_in]));
   assign inst1_tagb_out = (reset ? `RSTAG_NULL : ((inst1_dest_in==inst1_regb_in && inst1_dest_nonzero) ? tag_table[inst1_regb_in] : tag_table[inst1_regb_in]));
   assign inst2_taga_out = (reset ? `RSTAG_NULL : (inst2_rega_in==inst1_dest_in && inst1_dest_nonzero && inst1_tag_nonnull) ? inst1_tag_in : 
                                                        (((inst2_dest_in==inst2_rega_in && inst2_dest_nonzero)) ? tag_table[inst2_rega_in] : n_tag_table[inst2_rega_in]) );  // forward from inst1
   assign inst2_tagb_out = (reset ? `RSTAG_NULL : (inst2_regb_in==inst1_dest_in && inst1_dest_nonzero && inst1_tag_nonnull) ? inst1_tag_in : 
                                                        (((inst2_dest_in==inst2_regb_in && inst2_dest_nonzero)) ? tag_table[inst2_regb_in] : n_tag_table[inst2_regb_in]) );  // forward from inst1
*/


   // combinational logic for assigning output tags //
   always @*
   begin
      // inst1_taga //
            inst1_taga_out = `RSTAG_NULL;
      if (~reset)
      begin
            inst1_taga_out = tag_table[inst1_rega_in];   
         if (clear_entries_real[inst1_rega_in])
            inst1_taga_out = `RSTAG_NULL;
      end

      // inst1_tagb //
            inst1_tagb_out = `RSTAG_NULL;
      if (~reset)
      begin
            inst1_tagb_out = tag_table[inst1_regb_in];
         if (clear_entries_real[inst1_regb_in])
            inst1_tagb_out = `RSTAG_NULL;
      end

      // inst2_taga //
            inst2_taga_out = `RSTAG_NULL;
      if (~reset)
      begin
            inst2_taga_out = tag_table[inst2_rega_in];
         if (clear_entries_real[inst2_rega_in])
            inst2_taga_out = `RSTAG_NULL;
         if (inst2_rega_in==inst1_dest_in && inst1_dest_nonzero && inst1_tag_nonnull)
            inst2_taga_out = inst1_tag_in;
      end

      // inst2_tagb //
            inst2_tagb_out = `RSTAG_NULL;
      if (~reset)
      begin
            inst2_tagb_out = tag_table[inst2_regb_in];
         if (clear_entries_real[inst2_regb_in])
            inst2_tagb_out = `RSTAG_NULL;
         if (inst2_regb_in==inst1_dest_in && inst1_dest_nonzero && inst1_tag_nonnull)   
            inst2_tagb_out = inst1_tag_in;
      end

   end

   // combinational logic for assigning next tag values //
   genvar i;
   generate
      for (i=0; i<32; i=i+1)
      begin : ASSIGNNTAGTABLEALWAYS
         always @*
         begin
               n_tag_table[i] = {1'b0,n_ready_in_rob[i],tag_table[i][5:0]};
            if (clear_entries_real[i] || tag_table[i]==`RSTAG_NULL)
               n_tag_table[i] = `RSTAG_NULL; 
            if (inst1_dest_in==i && inst1_tag_nonnull)
               n_tag_table[i] = inst1_tag_in;
            if (inst2_dest_in==i && inst2_tag_nonnull)
               n_tag_table[i] = inst2_tag_in;
            if (i==`ZERO_REG)
               n_tag_table[i] = `RSTAG_NULL;
         end
      end
   endgenerate


   // combinational logic for next states in tag table //
   assign n_ready_in_rob[`ZERO_REG] = 1'b0;
  // assign n_tag_table[`ZERO_REG]    = `RSTAG_NULL;
   assign clear_entries_real[`ZERO_REG] = 1'b0;
   genvar i;
   generate
      for (i=0; i<31; i=i+1)
      begin : NTAGTABLEASSIGN
         assign clear_entries_real[i] = ({2'b0,tag_table[i][5:0]}==inst1_retire_tag_in || {2'b0,tag_table[i][5:0]}==inst2_retire_tag_in);
         assign n_ready_in_rob[i] = ( tag_table[i][6] || (cdb1_tag_in==tag_table[i] && cdb1_tag_in!=`RSTAG_NULL) || (cdb2_tag_in==tag_table[i] && cdb2_tag_in!=`RSTAG_NULL) );

/*
         assign n_tag_table[i] = ((inst2_dest_in==i) && inst2_dest_nonzero && inst2_tag_nonnull) ? inst2_tag_in :            // inst2 takes precidence here
                                   (  ((inst1_dest_in==i) && inst1_dest_nonzero && inst1_tag_nonnull) ? inst1_tag_in :        // because it comes after inst1
                                         ((clear_entries_real[i] || tag_table[i]==`RSTAG_NULL) ? `RSTAG_NULL : {1'b0,n_ready_in_rob[i],tag_table[i][5:0]} )  );
*/
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

endmodule 


