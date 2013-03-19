////////////////////////////////////////////////////////////////
// This file houses modules for the inner workings of the ROB //
//
// This ROB will have 32 entries. We can decide to add or     //
// subtract entries as we see fit.
// ROB consists of 32 ROB Entries                             //
////////////////////////////////////////////////////////////////

/***
*     TODO:  Combinaional logic
***/

// parameters //
`define ROB_ENTRIES 32
`define ROB_ENTRY_AVAILABLE 1
`define NO_ROB_ENTRY 0
`define SD = 1;


// rob main module //

module rob(clock, reset, rob_full, dest_reg, output_value);

/*
    /*** Leaving this in here but Matt is working on restructure ***

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
      
*/      
   

endmodule 


/***
*   Each ROB Entry needs:
*       Head/Tail bit   (To determine where the head/tail 
*       Instruction     
*       Valid bit       (Whether or not the entry is valid)
*       Value           (To know when to retire)
*       Register        (Output REgister
*       Complete bit    (To know if it is ready to retire) 
***/
module rob_entry(
                  //inputs
                  clock, reset, 
                  instruction_in, valid_in, head_in, tail_in, value_in, complete_in, register_in,

                  //outputs
                  instruction_out, valid_out, head_out, tail_out, value_out, register_out, complete_out,
                 );


  /***  inputs  ***/
  input wire        reset;
  input wire        clock;

  input wire [31:0] instruction_in;
  input wire        valid_in;
  input wire        head_in;
  input wire        tail_in;
  input wire [63:0] value_in;
  input wire        complete_in;
  input wire        register_in;

  /***  internals  ***/
  reg [31:0]  n_instruction;
  reg         n_valid;
  reg         n_tail
  reg         n_value;
  reg [63:0]  n_value;
  reg         n_complete;
  reg         n_register;

  /***  outputs  ***/
  output reg [31:0] instruction_out;
  output reg        valid_out;
  output reg        head_out;
  output reg        tail_out;
  output reg [63:0] value_out;
  output reg        complete_out;
  output reg        register_out;


  // combinational assignments //  


  // combinational logic to next state //


  // clock synchronous events //
  always@(posedge clock)
  begin
     if (reset)
     begin
        instruction_out <= `SD 32'd0;
        valid_out <= `SD 1'b0;
        head_out <= `SD 1'b0;
        tail_out <= `SD 1'b0;
        value_out <= `SD 64'h0;
        complete_out <= `SD 1'b0;
        exception_out <= `SD 1'b0;
     end
     else
     begin
        instruction_out <= `SD n_instruction;
        valid_out <= `SD n_valid;
        head_out <= `SD n_head;
        tail_out <= `SD n_tail;
        value_out <= `SD n_value;
        complete_out <= `SD n_complete;
        exception_out <= `SD n_exception;
     end


endmodule
