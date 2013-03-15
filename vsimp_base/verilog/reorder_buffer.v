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
module rob(clock,reset, rob_full, dest_reg, output_value);

   // inputs //
   input wire clock;
   input wire reset;
   input output_value;
   input output_reg;


   // outputs //
   output rob_full;
   output  [4:0] dest_reg;
   output [63:0] output_value;
   

   // regs for the ROB //
   reg  [4:0] output_regs [31:0];    //Array of output regs for each ROB entry
   reg [63:0] output_vals [31:0];    //Array of output values for each ROB entry (initialized to zero)
   reg [31:0] valid_entry;           //Check if ROB entry is valid. If not, use entry
   



   

endmodule 
