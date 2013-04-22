


// parameter definitions. note that if you change PC_bits you should //
// also change BTB_ENTRIES accordingly. BTB_ENTRIES = 2^PC_BITS //
//`define BTB_PC_BITS 8
//`define BTB_ENTRIES 256 
//`define BRANCH_NONE      2'b00
//`define BRANCH_TAKEN     2'b01
//`define BRANCH_NOT_TAKEN 2'b10
//`define BRANCH_UNUSED    2'b11
//`define SD #1

// branch target buffer module //
module branch_target_buffer( clock,reset,

         inst1_result_in,inst2_result_in,
         inst1_write_NPC_in,inst2_write_NPC_in,
         inst1_write_dest_in,inst2_write_dest_in,

         inst1_NPC_in,inst2_NPC_in,
         inst1_PPC_out,inst2_PPC_out

   );

   // inputs //
   input wire         clock;
   input wire         reset;
   input wire [1:0]   inst1_result_in,inst2_result_in;
   input wire [63:0]  inst1_write_NPC_in,inst2_write_NPC_in;  
   input wire [63:0]  inst1_write_dest_in,inst2_write_dest_in;
   input wire [63:0]  inst1_NPC_in,inst2_NPC_in; 

   // outputs //
   output wire [63:0] inst1_PPC_out;
   output wire [63:0] inst2_PPC_out;

   // internal registers and wires //
   reg [63:0]   branch_PCs [ (`BTB_ENTRIES-1):0 ];
   reg [63:0] n_branch_PCs [ (`BTB_ENTRIES-1):0 ];
   wire inst1_is_branch;
   wire inst2_is_branch;
   reg [(`BTB_ENTRIES-1):0] inst1_matches;
   reg [(`BTB_ENTRIES-1):0] inst2_matches;

   // combinational assignments //
   assign inst1_PPC_out = branch_PCs[ inst1_NPC_in[(`BTB_PC_BITS-1):0] ];
   assign inst2_PPC_out = branch_PCs[ inst2_NPC_in[(`BTB_PC_BITS-1):0] ];
   assign inst1_is_branch = (inst1_result_in==`BRANCH_TAKEN || inst1_result_in==`BRANCH_NOT_TAKEN);
   assign inst2_is_branch = (inst2_result_in==`BRANCH_TAKEN || inst2_result_in==`BRANCH_NOT_TAKEN);
 
   // combination assignments for next branch PCs //
   genvar i;
   generate
      for (i=0; i<`BTB_ENTRIES; i=i+1)
      begin : ASSIGNNBRANCHPCS
         always@*
         begin
            inst1_matches[i] = (inst1_is_branch && (inst1_write_NPC_in[(`BTB_PC_BITS-1):0]==i));
            inst2_matches[i] = (inst2_is_branch && (inst2_write_NPC_in[(`BTB_PC_BITS-1):0]==i));
            n_branch_PCs[i] = (inst1_matches[i]) ? inst1_write_dest_in : ((inst2_matches[i]) ? inst2_write_dest_in : branch_PCs[i] );
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



