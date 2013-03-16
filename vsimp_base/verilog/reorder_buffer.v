////////////////////////////////////////////////////////////////
// This file houses modules for the inner workings of the ROB //
//
// This ROB will have 32 entries. We can decide to add or     //
// subtract entries as we see fit.
// ROB consists of 32 ROB Entries                             //
////////////////////////////////////////////////////////////////

// parameters //
`define ROB_ENTRIES 32
`define ROB_ENTRY_AVAILABLE 1
`define NO_ROB_ENTRY 0



// rob main module //
module rob(clock, reset, rob_full, dest_reg, output_value);

/*
    //Leaving this in here but Matt is working on restructure

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
*/   



   

endmodule 


/***
*   Each ROB Entry needs:
* Head/Tail bit   (To determine where the head/tail 
*   Instruction
*       Valid bit       (Whether or not the entry is valid)
*       Value           (To know when to retire)
*       Register 
*       Complete bit    (To know if it is ready to retire) 
*       Exception       (Will add more detail later)
***/
module rob_entry(
                  //inputs
                  clock, reset, 
                  instruction_in, valid_in, head_in, tail_in, value_in, register_in, complete_in, exception_in

                  //outputs
                  instruction_out, valid_out, head_out, tail_out, value_out, register_out, complete_out, exception_out
                 );


  //inputs
  input wire [31:0] instruction_in;
  input wire        valid_in;
  input wire        head_in;
  input wire        tail_in;
  input wire [63:0] value_in;
  input wire        complete_in;
  input wire        exception_in;


/***  WORKING HERE ***/

  //internals
  reg [31:0]  n_instruction;
  


  //outputs
  output reg [31:0] instruction_out;
  output reg        valid_out;
  output reg        head_out;
  output reg        tail_out;
  output reg [63:0] value_out;
  output reg        complete_in;
  output reg        exception_in;




endmodule
