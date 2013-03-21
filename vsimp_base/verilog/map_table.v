
/////////////////////////////////////////////////////////
// this file is for the map table for our processor    //
/////////////////////////////////////////////////////////


`define SD #1
`define RSTAG_NULL 8'd0
`define ZERO_REG   5'd0

// main map table module //
module map_table(clock,reset,        // signal inputs
                 inst1_write_tag,    // 
                 inst2_write_tag,    //

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

                 // tag outputs //
                 inst1_taga_out,inst1_tagb_out,
                 inst2_taga_out,inst2_tagb_out  );

   // inputs //
   input wire clock;
   input wire reset;
   input wire inst1_write_tag;
   input wire inst2_write_tag;
   input wire [4:0] inst1_rega_in,inst1_regb_in;
   input wire [4:0] inst2_rega_in,inst2_regb_in;
   input wire [4:0] inst1_dest_in;
   input wire [4:0] inst2_dest_in;
   input wire [7:0] inst1_tag_in;
   input wire [7:0] inst2_tag_in;

   // outputs //
   output wire [7:0] inst1_taga_out,inst1_tagb_out;
   output wire [7:0] inst2_tag2_out,inst2_tagb_out;


   // internal registers and wires //
   wire [7:0] n_tag_table [4:0];
   reg  [7:0]   tag_table [4:0];

   // combinational assignments for the tag outputs //
   assign inst1_taga_out = tag_table[inst1_rega_in];
   assign inst1_tagb_out = tag_table[inst1_regb_in];
   assign inst2_taga_out = ((inst2_rega_in==inst1_dest_in) && (inst1_dest_in!=`ZERO_REG)) ? inst1_tag_in : tag_table[inst2_rega_in];  // forward from inst1
   assign inst2_tagb_out = ((inst2_regb_in==inst1_dest_in) && (inst1_dest_in!=`ZERO_REG)) ? inst1_tag_in : tag_table[inst2_regb_in];  // forward from inst1

   // combinational logic for next states in tag table //
   genvar i;
   generate
      for (i=0; i<32; i=i+1)
      begin : NTAGTABLEASSIGN
         assign n_tag_table[i] = ((inst2_dest_in==i) && (inst2_dest_in!=`ZERO_REG)) ? inst2_tag_in :                       // inst2 takes precidence here
                                    ( ((inst1_dest_in==i) && (inst1_dest_in!=`ZERO_REG)) ? inst1_tag_in : tag_table[i] );  // because it comes after inst1
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
         inat2_taga_out <= `SD n_inst2_taga_out;
         inst2_tagb_out <= `SD n_inst2_tagb_out;
      end
   end

endmodule 


