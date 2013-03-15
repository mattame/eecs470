////////////////////////////////////////////////////////////////
// This file houses modules for the inner workings of the ROB //

// This ROB will have 32 entries. We can decide to add or      //
// subtract entries as we see fit.                             //
/////////////////////////////////////////////////////////////////

// parameters //
`define ROB_ENTRIES 32
`define ROB_ENTRY_AVAILABLE 1
`define NO_ROB_ENTRY 0



// rob main module //
module rob(clock,reset, dest_reg, output_value, rob_full);

   // inputs //
   input wire clock;
   input wire reset;
   input [63:0] output_value;
   input  [4:0] output_reg;


   // outputs //
   output rob_full;
   output  [4:0] dest_reg;
   output [63:0] output_value;
   

   // regs for the ROB //
   reg  [4:0] output_regs [31:0];    //Array of output regs for each ROB entry
   reg [63:0] output_vals [31:0];    //Array of output values for each ROB entry (no initialization since we have valid bits)
   reg [31:0] valid_entry;           //Check if ROB entry is valid. If not, use entry


   // initializing the registers //
   rob_full = 0;                     //ROB is initially empty
   valid_entry[31:0] = 32'b0;       //All ROB entries are initially invalid
   

always @(posedge clock)
begin
   if(reset)
   begin
      valid_entry <= 32'b0;
      rob_full <= 0;
   end

   else
   begin
      
      
   



   
   



   

endmodule 
