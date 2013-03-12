
/////////////////////////////////////////////////////////
// this file is for the map table for our processor    //
/////////////////////////////////////////////////////////


`define SD #1
`define RSTAG_NULL 8'd0

// main map table module //
module map_table(clock,reset,
                 reg1_in,reg2_in,
                 tag1_in,tag2_in,
                 write_reg1_tag,write_reg2_tag,
                 tag1_out,tag2_out);

   // inputs //
   input wire clock;
   input wire reset;
   input wire [4:0] reg1_in;
   input wire [4:0] reg2_in;
   input wire [7:0] tag1_in;
   input wire [7:0] tag2_in;
   input wire write_reg1_tag;
   input wire write_reg2_tag;

   // outputs //
   output reg [7:0] tag1_out;
   output reg [7:0] tag2_out;


   // internal registers and wires //
   wire [7:0] n_tag_table [4:0];
   reg  [7:0]   tag_table [4:0];
   wire  [7:0] n_tag1_out;
   wire  [7:0] n_tag2_out;

   // combinational assignments for the next tag output //
   assign n_tag1_out = n_tag_table[reg1_in];
   assign n_tag2_out = n_tag_table[reg2_in];


   // combinational assignment of next tag //
   genvar i;
   generate
      for (i=0; i<32; i=i+1)
      begin : NTAGTABLEASSIGN
         assign n_tag_table[i] = (reg1_in==i && write_reg1_tag) ? tag1_in :
                               ( (reg2_in==i && write_reg2_tag) ? tag2_in : tag_table[i] );
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
         tag1_out <= `SD `RSTAG_NULL;
         tag2_out <= `SD `RSTAG_NULL;
      end
      else
      begin
         tag1_out <= `SD n_tag1_out;
         tag2_out <= `SD n_tag2_out;
      end
   end

endmodule 


