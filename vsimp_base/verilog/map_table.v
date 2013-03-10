
/////////////////////////////////////////////////////////
// this file is for the map table for our processor    //
/////////////////////////////////////////////////////////



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

   // outputs //
   output wire [7:0] tag1_out;
   output wire [7:0] tag2_out;


   // internal registers and wires //
   wire [7:0] n_tag_table [4:0];
   reg  [7:0]   tag_table [4:0];


   // combinational assignments //
   assign tag1_out = tag_table[reg1_in];
   assign tag2_out = tag_table[reg2_in];


   // combinational assignment of next tag //
   always @*
   begin
      genvar i;
      generate
         for (i=0; i<32; i=i+1)
         begin
            if (reg1_in==i && write_reg1_tag)
               n_tag_table[i] = tag1_in;
            else
               n_tag_table[i] = tag_table[i];

         end
      endgenerate
   end 


   // clock synchronous stuff //
   always @(posedge clock)
   begin
      genvar j;
      generate
         for (j=0; j<32; j=j+1)
            tag_table[i] = n_tag_table[i];
      endgenerate
   end

endmodule 


