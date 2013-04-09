

////////////////////////////////////////////////////////////////
// This file houses modules for the inner workings of the ROB //
////////////////////////////////////////////////////////////////

/***
*     TODO:  Combinaional logic
***/

// parameters //
`define RSTAG_NULL    8'hFF
`define ROB_ENTRIES 8'd16
`define ROB_ENTRY_AVAILABLE 1
`define NO_ROB_ENTRY 0
`define SD #1


// rob entry states //
`define ROBE_EMPTY     2'b00
`define ROBE_INUSE     2'b01
`define ROBE_COMPLETE  2'b10
`define ROBE_UNUSED    2'b11



/// this part is outdated - see below ///
/*
module rob(clock, reset, rob_full, dest_reg, output_value);


    /// Leaving this in here but Matt is working on restructure ///

module rob(clock,reset);


  ///  inputs  ///


  ///  internals ///

  /// Keep track of the tail ///
  reg  [4:0]  tail, n_tail;
  reg  [4:0]  head, n_head;
    


  ///  outputs ///
  //what outputs do we need
  output reg  [64:0] value1_out, value2_out;
  output reg  [4:0] register1_out, register2_out;

  //initialize rob entries
  rob_entry[31:0](
   

  //we need to set each rob entries' write_enable
  always@ *
  begin
    



  end

   

always @(posedge clock)
begin
   if(reset)
   begin

   end

   else
   begin
         
   

endmodule 
*/





/***
*   Each ROB Entry needs:
*       Instruction     
*       Valid bit       (Whether or not the entry is valid)
*       Value           (To know when to retire)
*       Register        (Output REgister
*       Complete bit    (To know if it is ready to retire) 
***/
module reorder_buffer_entry(
                  //inputs
                  clock, reset,
                  instruction_in1, valid_in1, head_in1, tail_in1, value_in1, complete_in1, register_in1, 
                  instruction_in2, valid_in2, head_in2, tail_in2, value_in2, complete_in2, register_in2,

                  //outputs
                  instruction_out, valid_out, head_out, tail_out, value_out, register_out, complete_out,
                 );


  /***  inputs  ***/
  input wire        reset;
  input wire        clock;

  input wire [31:0] instruction_in;
  input wire        valid_in;
  input wire [63:0] value_in;
  input wire        complete_in;
  input wire  [4:0] register_in;

  /***  internals  ***/
  reg [31:0]  n_instruction;
  reg         n_valid;
  reg [63:0]  n_value;
  reg         n_complete;
  reg  [4:0]  n_register;

  reg write_enable1, write_enable2;
  reg n_write_enable1, n_write_enable2;

  /***  outputs  ***/
  output reg [31:0] instruction_out;
  output reg        valid_out;
  output reg [63:0] value_out;
  output reg        complete_out;
  output reg  [4:0] register_out;


  // combinational assignments //  
  always @*
  begin
    if (write_enable_1)
    begin
      n_instruction = instruction_in1;
      n_valid = valid_in1;
      n_value = 64'b0;
      n_register = register_in1;
      n_complete = 1'b0;
    end
    else if (write_enable_2)
      begin
      n_instruction = instruction_in2;
      n_valid = valid_in2;
      n_value = 64'b0;
      n_register = register_in2;
      n_complete = 1'b0;
    end
    else
    begin 
      n_instruction = instruction_out;
      n_valid = valid_out;
      n_value = value_out;
      n_register = register_out;
      n_complete = complete_out;
    end

  end


  // combinational logic to next state //


  // clock synchronous events //
  always@(posedge clock)
  begin
     if (reset)
     begin
        instruction_out <= `SD 32'd0;
        valid_out <= `SD 1'b0;
        value_out <= `SD 64'h0;
        register_out <= `SD 5'b0;
        complete_out <= `SD 1'b0;
     end
     else
     begin
        instruction_out <= `SD n_instruction;
        valid_out <= `SD n_valid;
        value_out <= `SD n_value;
        register_out <= `SD n_exception;
        complete_out <= `SD n_complete;
     end


endmodule


/////////////////////
// mian ROB module //
/////////////////////
// todo: integrate with rob entry module and set correct inputs for latching
// instruction 
// also, forwarding for the case of a full rob and trying to add instructions
// while retiring is not added, probably should be
module reorder_buffer( clock,reset,

      inst1_valid_in,
      inst1_dest_reg,

      inst2_valid_in,
      inst2_dest_reg,

      cdb1_tag_in,
      cdb2_tag_in,  

      inst1_tag_out,
      inst2_tag_out,

      rob_full
                 );


   // inputs //
   input wire clock;
   input wire reset; 
   input wire inst1_valid_in;
   input wire inst2_valid_in;
   input wire [4:0] inst1_dest_reg;
   input wire [4:0] inst2_dest_reg;
   input wire [7:0] cdb1_tag_in;
   input wire [7:0] cdb2_tag_in;


   // outputs //
   output wire [7:0] inst1_tag_out;
   output wire [7:0] inst2_tag_out;
   output wire rob_full;


   // internal regs/wires //
   wire [1:0] statuses [(`ROB_ENTRIES-1):0];
   wire [7:0] tail_plus_one; 
   wire [7:0] tail_plus_two;
   reg [7:0]   head;
   reg [7:0] n_head;
   reg [7:0]   tail;
   reg [7:0] n_tail;
   reg   rob_empty;
   reg n_rob_empty;


   // combinational assignments for head/tail plus one and two. accounts //
   // for overflow  //
   assign head_plus_one = (head==(`ROB_ENTRIES-1)) ? 8'd0 : head+8'd1;
   assign head_plus_two = (head==(`ROB_ENTRIES-1)) ? 8'd1 : ( (head==(`ROB_ENTRIES-2)) ? 8'd0 : head+8'd2 );
   assign tail_plus_one = (tail==(`ROB_ENTRIES-1)) ? 8'd0 : tail+8'd1;                                         
   assign tail_plus_two = (tail==(`ROB_ENTRIES-1)) ? 8'd1 : ( (tail==(`ROB_ENTRIES-2)) ? 8'd0 : tail+8'd2 ); 

   // combinational assignments for signals //
   assign rob_full       = (tail_plus_one==head || tail_plus_two==head); 
   assign inst1_retire   =                  (statuses[head         ]==`ROBE_COMPLETE);
   assign inst2_retire   = (inst1_retire && (statuses[head_plus_one]==`ROBE_COMPLETE) );
   assign inst1_dispatch = ( ~rob_full && (inst1_valid || (~inst1_valid && inst2_valid)) ); 
   assign inst2_dispatch = ( ~rob_full && (inst1_valid && inst2_valid) );


   // combinational assignments for next state signals //
   assign n_head = ( inst1_retire   ? (inst2_retire   ? head_plus_two : head_plus_one) : head );   // if retiring one inst, inc by one. if two, inc by two
   assign n_tail = ( inst1_dispatch ? (inst2_dispatch ? tail_plus_two : tail_plus_one) : tail );   // if dispatching one inst, inc by one. if two, inc by two
   assign n_rob_empty = rob_empty ? ~(tail_plus_one!=head) : 1'b0;   // if empty remain empty unless tail plus one != head, otherwise remain not-empty


   // for tag outputs //
   assign inst1_tag_out = (inst1_dispatch ? tail_plus_one : `RSTAG_NULL);
   assign inst2_tag_out = (inst2_dispatch ? tail_plus_two : `RSTAG_NULL);


   // internal modules for ROB entries //
   genvar i;
   generate 
      for (i=0; i<`ROB_ENTRIES; i=i+1)
      begin

      reservation_station_entry entries ( clock,reset,


                         );

      end
   endgenerate


   // clock-synchronouse assignments for //
   always@(posedge clock)
   begin
      if (reset)
      begin
         head      <= 8'd0;
         tail      <= 8'd0;
         rob_empty <= 1'b1;
      end
      else
      begin
         head      <= n_head;
         tail      <= n_tail;
         rob_empty <= n_rob_empty;
      end
   end

endmodule


