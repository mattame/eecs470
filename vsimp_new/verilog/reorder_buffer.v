

////////////////////////////////////////////////////////////////
// This file houses modules for the inner workings of the ROB //
////////////////////////////////////////////////////////////////

// parameters //
`define ZERO_REG      5'd0
`define RSTAG_NULL    8'hFF
`define ROB_ENTRIES  32
`define UNUSED_TAG_BITS 3
`define SD #1

// rob entry states //
`define ROBE_EMPTY     2'b00
`define ROBE_INUSE     2'b01
`define ROBE_COMPLETE  2'b10
`define ROBE_UNUSED    2'b11


/***
*   Each ROB Entry needs:
*     State
*     Register to be written to
*     Value to be written
***/
module reorder_buffer_entry(

                  //inputs
                  clock, reset, write,
                  tag_in,
                  register_in, 
                  cdb1_value_in, cdb1_tag_in,
                  cdb2_value_in, cdb2_tag_in,
                  cdb1_mispredicted_in, cdb2_mispredicted_in,

                  //outputs
                  value_out, register_out, state_out, mispredicted_out
                  );


  /***  inputs  ***/
  input wire        reset;
  input wire        clock;
  input wire        write;

  input wire  [7:0] tag_in;
  input wire  [4:0] register_in;

  input wire [63:0] cdb1_value_in, cdb2_value_in;
  input wire  [7:0] cdb1_tag_in, cdb2_tag_in;
  input wire        cdb1_mispredicted_in,cdb2_mispredicted_in;

  /***  internals  ***/
  reg [63:0]  n_value;
  reg  [4:0]  n_register;
  reg  [1:0]  n_state;
  reg         n_mispredicted;

  /***  outputs  ***/
  output reg [63:0] value_out;
  output reg  [4:0] register_out;
  output reg  [1:0] state_out;
  output reg        mispredicted_out;

  // combinational assignments //  
  always @*
  begin

    //determine whether to latch dispatch
    if (write)
    begin
      n_state        = `ROBE_INUSE;
      n_value        = 64'b0;
      n_register     = register_in;
      n_mispredicted = 1'b0;  
    end

    //determine whether to latch complete 
    else if (~write && (tag_in==cdb1_tag_in))
    begin 
      n_state        = `ROBE_COMPLETE;
      n_value        = cdb1_value_in;
      n_register     = register_out;
      n_mispredicted = cdb1_mispredicted_in;
    end
    else if (~write && (tag_in==cdb2_tag_in))
    begin
      n_state        = `ROBE_COMPLETE;
      n_value        = cdb2_value_in;
      n_register     = register_out;
      n_mispredicted = cdb2_mispredicted_in; 
    end

    //default case
    else
    begin
      n_state        = state_out;
      n_value        = value_out;
      n_register     = register_out;
      n_mispredicted = mispredicted_out;
    end
  end


  // clock synchronous events //
  always@(posedge clock)
  begin
     if (reset)
     begin
        state_out        <= `SD `ROBE_EMPTY;
        value_out        <= `SD 64'h0;
        register_out     <= `SD `RSTAG_NULL;
        mispredicted_out <= `SD 1'b0;
     end
     else
     begin
        state_out        <= `SD n_state;
        value_out        <= `SD n_value;
        register_out     <= `SD n_register;
        mispredicted_out <= `SD n_mispredicted;
     end
  end

endmodule



/////////////////////
// main ROB module //
/////////////////////
// todo: integrate with rob entry module and set correct inputs for latching
// instruction 
// also, forwarding for the case of a full rob and trying to add instructions
// while retiring is not added, probably should be
module reorder_buffer( clock,reset,
                      
                      inst1_valid_in,
                      inst1_dest_in,

                      inst2_valid_in,
                      inst2_dest_in,

                      // tags for reading from the rs // 
                      inst1_rega_tag_in,
                      inst1_regb_tag_in,
                      inst2_rega_tag_in,
                      inst2_regb_tag_in,

                      // cdb inputs //
                      cdb1_tag_in,
                      cdb1_value_in,
                      cdb2_tag_in,
                      cdb2_value_in, 
                      cdb1_mispredicted_in,
                      cdb2_mispredicted_in,

                      // outputs //
                      inst1_tag_out,
                      inst2_tag_out,

                      // values out to the rs //
                      inst1_rega_value_out,
                      inst1_regb_value_out,
                      inst2_rega_value_out,
                      inst2_regb_value_out,     

                      // outputs to write directly to the reg file //
                      inst1_dest_out,inst1_value_out,
                      inst2_dest_out,inst2_value_out,

                      // outputs to indicate a mispredicted branch //
                      inst1_mispredicted_out,inst2_mispredicted_out,

                      // signals out //
                      rob_full,rob_empty
                      );


   // inputs //
   input wire clock;
   input wire reset; 

   input wire        inst1_valid_in;
   input wire        inst2_valid_in;
   input wire  [4:0] inst1_dest_in;
   input wire  [4:0] inst2_dest_in;

   input wire  [7:0] inst1_rega_tag_in;
   input wire  [7:0] inst1_regb_tag_in;
   input wire  [7:0] inst2_rega_tag_in;
   input wire  [7:0] inst2_regb_tag_in;

   input wire  [7:0] cdb1_tag_in;
   input wire  [7:0] cdb2_tag_in;
   input wire [63:0] cdb1_value_in;
   input wire [63:0] cdb2_value_in;
   input wire        cdb1_mispredicted_in;
   input wire        cdb2_mispredicted_in;


   // outputs //
   output wire [7:0] inst1_tag_out;
   output wire [7:0] inst2_tag_out;

   output wire [63:0] inst1_rega_value_out;
   output wire [63:0] inst1_regb_value_out;
   output wire [63:0] inst2_rega_value_out;
   output wire [63:0] inst2_regb_value_out;

   output wire [4:0]  inst1_dest_out;
   output wire [63:0] inst1_value_out;
   output wire [4:0]  inst2_dest_out;
   output wire [63:0] inst2_value_out;

   output wire inst1_mispredicted_out;
   output wire inst2_mispredicted_out;

   output wand rob_full;


   // internal regs/wires //
   wire [7:0] head_plus_one;
   wire [7:0] head_plus_two;
   wire [7:0] tail_plus_one; 
   wire [7:0] tail_plus_two;
   wire [7:0] tail_minus_one;
   reg  [7:0]   head;
   wire [7:0] n_head;
   reg  [7:0]   tail;
   wire [7:0] n_tail;
   output wand    rob_empty;


   // regs/wires for talking directly to the reorder buffer entries //
   wire [(`ROB_ENTRIES-1):0] resets;
   wire [(`ROB_ENTRIES-1):0] writes;
   wire [7:0]  tags_in       [(`ROB_ENTRIES-1):0];
   wire [4:0]  registers_in  [(`ROB_ENTRIES-1):0];
   wire [63:0] values_out    [(`ROB_ENTRIES-1):0];
   wire [4:0]  registers_out [(`ROB_ENTRIES-1):0];
   wire [1:0]  states_out    [(`ROB_ENTRIES-1):0]; 
   wire [(`ROB_ENTRIES-1):0] mispredicteds_out; 

   // combinational assignments for head/tail plus one and two. accounts //
   // for overflow  //
   assign head_plus_one  = (head==(`ROB_ENTRIES-1)) ? 8'd0 : head+8'd1;
   assign head_plus_two  = (head==(`ROB_ENTRIES-1)) ? 8'd1 : ( (head==(`ROB_ENTRIES-2)) ? 8'd0 : head+8'd2 );
   assign tail_plus_one  = (tail==(`ROB_ENTRIES-1)) ? 8'd0 : tail+8'd1;                                         
   assign tail_plus_two  = (tail==(`ROB_ENTRIES-1)) ? 8'd1 : ( (tail==(`ROB_ENTRIES-2)) ? 8'd0 : tail+8'd2 );
   assign tail_minus_one = (tail==8'd0) ? (`ROB_ENTRIES-1) : tail-8'd1;

   // combinational assignments for signals //
   assign inst1_retire   =                  (states_out[head         ]==`ROBE_COMPLETE);
   assign inst2_retire   = (inst1_retire && (states_out[head_plus_one]==`ROBE_COMPLETE) );
   assign inst1_dispatch = ( ~rob_full && (inst1_valid_in || (~inst1_valid_in && inst2_valid_in)) ); 
   assign inst2_dispatch = ( ~rob_full && (inst1_valid_in && inst2_valid_in) );


   // insternal assignments for tag comparisions //
   //assign head_lt_tail = (head<tail);   


   // combinational assignments for next state signals //
   assign n_head = ( inst1_retire   ? (inst2_retire   ? head_plus_two : head_plus_one) : head );   // if retiring one inst, inc by one. if two, inc by two
   assign n_tail = ( inst1_dispatch ? (inst2_dispatch ? tail_plus_two : tail_plus_one) : tail );   // if dispatching one inst, inc by one. if two, inc by two


   // for tag outputs (to rs) //
   assign inst1_tag_out = (inst1_dispatch ? tail_minus_one : `RSTAG_NULL);
   assign inst2_tag_out = (inst2_dispatch ? tail           : `RSTAG_NULL);

   // assign appropriate outputs for from-rob values //
   // tags in are broken down to remove the ready-in-rob-bit //
   assign inst1_rega_value_out = values_out[ { {`UNUSED_TAG_BITS{1'b0}}, inst1_rega_tag_in[(7-`UNUSED_TAG_BITS):0] } ]; 
   assign inst1_regb_value_out = values_out[ { {`UNUSED_TAG_BITS{1'b0}}, inst1_regb_tag_in[(7-`UNUSED_TAG_BITS):0] } ];
   assign inst2_rega_value_out = values_out[ { {`UNUSED_TAG_BITS{1'b0}}, inst2_rega_tag_in[(7-`UNUSED_TAG_BITS):0] } ];
   assign inst2_regb_value_out = values_out[ { {`UNUSED_TAG_BITS{1'b0}}, inst2_regb_tag_in[(7-`UNUSED_TAG_BITS):0] } ];


   // assignments for reg file outputs //
   assign inst1_dest_out  = (inst1_retire ? registers_out[head         ] : `ZERO_REG);
   assign inst1_value_out = (inst1_retire ? values_out[   head         ] : 64'd0);
   assign inst2_dest_out  = (inst2_retire ? registers_out[head_plus_one] : `ZERO_REG);
   assign inst2_value_out = (inst2_retire ? values_out[   head_plus_one] : 64'd0);

   // mispredicted out assignments //
   assign inst1_mispredicted_out = (inst1_retire ? mispredicteds_out[head         ] : 1'b0);
   assign inst2_mispredicted_out = (inst2_retire ? mispredicteds_out[head_plus_one] : 1'b0);

   // assignments for rob entry inputs //
   genvar i;
   generate
      for (i=0; i<`ROB_ENTRIES; i=i+1)
      begin : ASSIGNROBEINPUTS
         assign resets[i]       = (reset || (head==i && inst1_retire) || (head_plus_one==i && inst2_retire));
         assign writes[i]       = (tail_plus_one==i && inst1_dispatch) || (tail_plus_two==i && inst2_dispatch); 
         assign registers_in[i] = (tail_plus_one==i) ? inst1_dest_in : ((tail_plus_two==i) ? inst2_dest_in : `ZERO_REG);
      end
   endgenerate
   
   
   // assignments for rob empty/full states //
   generate
      for (i=0; i<`ROB_ENTRIES; i=i+1)
	  begin : ASSIGNEMPTYFULLSTATES
	     assign rob_empty = (states_out[i]==`ROBE_EMPTY);                                    // this is a wand
	     assign rob_full  = (states_out[i]==`ROBE_INUSE || states_out[i]==`ROBE_COMPLETE);   // again, a wand
	  end
   endgenerate

   // internal modules for ROB entries //
   generate 
      for (i=0; i<`ROB_ENTRIES; i=i+1)
      begin : CREATEROBES

      reorder_buffer_entry entries ( .clock(clock), .reset(resets[i]), .write(writes[i]),
                                       
                    .tag_in( i[7:0] ),
                    .register_in(registers_in[i]),       
               
                    .cdb1_tag_in(cdb1_tag_in), .cdb1_value_in(cdb1_value_in),
                    .cdb2_tag_in(cdb2_tag_in), .cdb2_value_in(cdb2_value_in),
                    .cdb1_mispredicted_in(cdb1_mispredicted_in), .cdb2_mispredicted_in(cdb2_mispredicted_in),

                    .value_out(values_out[i]),
                    .register_out(registers_out[i]),
                    .state_out(states_out[i]),
                    .mispredicted_out(mispredicteds_out[i])

                         );

      end
   endgenerate


   // clock-synchronouse assignments for //
   always@(posedge clock)
   begin
      if (reset)
      begin
         head      <= `SD 8'd0;
         tail      <= `SD (`ROB_ENTRIES-1);
      end
      else
      begin
         head      <= `SD n_head;
         tail      <= `SD n_tail;
      end
   end

endmodule



