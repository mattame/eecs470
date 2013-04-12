


// parameter definitions. note that if you change PC_bits you should //
// also change BTB_ENTRIES accordingly. BTB_ENTRIES = 2^PC_BITS //
`define BTB_PC_BITS 4
`define BTB_ENTRIES 16 

`define SD #1

// branch target buffer module //
module branch_target_buffer( clock,reset,

         write_in,
         write_NPC_in,
         write_dest_in,

         NPC_in,
         PPC_out  

   );

   // inputs //
   input wire         clock;
   input wire         reset;
   input wire         write_in;
   input wire [63:0]  write_NPC_in;  
   input wire [63:0]  write_dest_in;
   input wire [63:0]  NPC_in; 

   // outputs //
   output wire [63:0] PPC_out;

   // internal registers and wires //
   reg [63:0]   branch_PCs [ (`BTB_ENTRIES-1):0 ];
   reg [63:0] n_branch_PCs [ (`BTB_ENTRIES-1):0 ];


   // combinational assignments //
   assign PPC_out = branch_PCs[ NPC_in[(`BTB_PC_BITS-1):0] ];


   // combination assignments for next branch PCs //
   genvar i;
   generate
      for (i=0; i<`BTB_ENTRIES; i=i+1)
      begin : ASSIGNNBRANCHPCS
         always@*
         begin
            n_branch_PCs[i] = (write_in && (write_dest_in[(`BTB_PC_BITS-1):0]==i)) ? write_NPC_in : branch_PCs[i];
         end
      end
   endgenerate


   // clock synchronous assignments //
   genvar i;
   generate
      for (i=0; i<`BTB_ENTRIES; i=i+1)
      begin : ASSIGNBRANCHPCS
         always@(posedge clock)
         begin
            if (reset)
               branch_PCs[i] <= `SD 64'd0;
            else
               branch_PCs[i] <= `SD n_branch_PCs[i];
         end
      end
   endgenerate

endmodule



