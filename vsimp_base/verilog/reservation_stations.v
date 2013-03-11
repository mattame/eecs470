
///////////////////////////////////////////////////////////////////////////////
// This file will hold module definitions of the reservation station table.  //
// The main module utilizes multiple individual reservation station modules. //
///////////////////////////////////////////////////////////////////////////////


// defined paramters //
`define RESERVATION_STATIONS 8
`define RS_EMPTY        3'b000
`define RS_WAITING_A    3'b001
`define RS_WAITING_B    3'b010
`define RS_WAITING_BOTH 3'b011
`define RS_READY        3'b100
`define RSTAG_NULL      8'd0           


// individual reservation station module //
module reservation_station(clock,reset,fill,set_rega_value,set_regb_value,       // signals in
                           dest_reg_in,rega_value_in,regb_value_in,              // busses in
                           waiting_taga_in,waiting_tagb_in,                      // more busses in
                           status,                                               // signals out
                           waiting_taga_out,waiting_tagb_out,dest_reg_out,       // busses out
                           rega_value_out,regb_value_out                         // more busses out
                           );

   // inputs //
   input wire clock;
   input wire reset;
   input wire fill;
   input wire set_rega_value;
   input wire set_regb_value;
   input wire [63:0] rega_value_in;
   input wire [63:0] regb_value_in;
   input wire [7:0]  waiting_taga_in;
   input wire [7:0]  waiting_tagb_in;

   // outputs //
   output wire [2:0]  status_out;
   output wire [7:0]  waiting_taga_out;
   output wire [7:0]  waiting_tagb_out;
   output wire [4:0]  dest_reg_out;
   output wire [63:0] rega_value_out;
   output wire [63:0] regb_value_out;

   // internal registers and wires //
   reg  [2:0]    status;
   reg  [2:0]  n_status;
   reg  [4:0]    dest_reg;
   wire [4:0]  n_dest_reg;
   reg  [7:0]    waiting_taga;
   wire [7:0]  n_waiting_taga;
   reg  [7:0]    waiting_tagb;
   wire [7:0]  n_waiting_tagb; 
   reg  [63:0]   rega_value;
   wire [63:0] n_rega_value;
   reg  [63:0]   regb_value;
   wire [63:0] n_regb_value;
   wire waiting_on_taga;     // this is only used when filling the rs, it is not reflective of the current tag statuses
   wire waiting_on_tagb;     // this is only used when filling the rs, it is not reflective of the current tag statuses

   // combinational assignments //
   assign waiting_on_taga = (waiting_taga_in!=`RSTAG_NULL);
   assign waiting_on_tagb = (waiting_tagb_in!=`RSTAG_NULL);

 
   // combinational logic //
   always@*
   begin
      if (fill)
      begin
         case ({waiting_on_taga,waiting_on_tagb})
            2'b00: n_status = `RS_READY;
            2'b10: n_status = `RS_WAITING_A;
            2'b01: n_status = `RS_WAITING_B;
            2'b11: n_status = `RS_WAITING_BOTH;
         endcase
         n_dest_reg     = dest_reg_in;
         n_waiting_taga = waiting_taga_in;
         n_waiting_tagb = waiting_tagb_in;
         n_rega_value   = rega_value_in;
         n_regb_value   = regb_value_in;        
      end
      else if (set_rega_value)
      begin
      

      end
      else if (set_regb_value)
      begin



      end
      else
      begin
         n_dest_reg     = dest_reg;
         n_waiting_taga = waiting_taga;
         n_waiting_tagb = waiting_tagb;
         n_rega_value   = rega_value;
         n_regb_value   = regb_value;
      end
   end

   // clock synchronous events //
   always@(posedge clock)
   begin
      if (reset)
      begin
         status        <= `SD `RS_EMPTY;
         dest_reg      <= `SD 5'd0;
         waiting_taga  <= `SD 8'd0;
         waiting_tagb  <= `SD 8'd0;
         rega_value    <= `SD 64'd0;
         regb_value    <= `SD 64'd0;
      end
      else
      begin
         status        <= `SD n_status;
         dest_reg      <= `SD n_dest_reg;
         waiting_taga  <= `SD n_waiting_taga;
         waiting_tagb  <= `SD n_waiting_tagb;
         rega_value    <= `SD n_rega_value;
         regb_value    <= `SD n_regb_value;
      end
   end

endmodule



// the actual reservation table module //
module reservation_station_table(clock,reset,
                                 inst1_rega_value_in,inst1_regb_value_in,
                                 inst2_rega_value_in,inst2_regb_value_in,
                                 tag1_in,tag2_in,
                                 common_data_bus_in,
                                 reg1_out,reg2_out,
                                 table_full );


   // inputs //
   input wire clock;
   input wire reset;
   input wire [63:0] inst1_rega_value_in,inst1_regb_value_in;
   input wire [63:0] inst2_rega_value_in,inst2_regb_value_in;
   input wire [7:0]  tag1_in;
   input wire [7:0]  tag2_in;
   input wire [63:0] common_data_bus_in;

   // outputs //
   output wire reg1_out;
   output wire reg2_out;
   output wand table_full; 

   // internal wires //
   wire [2:0] rs_statuses      [(`RESERVATION_STATIONS-1):0];
   wire [7:0] rs_waiting_tags1 [(`RESERVATION_STATIONS-1):0];
   wire [7:0] rs_waiting_tags2 [(`RESERVATION_STATIONS-1):0]; 
 
   // variable for combinational logic loops //
   integer i;


   // combinational logic to determine if table is table full //
   always @*
   begin
      genvar i;
      generate
         for (i=0; i<`RESERVATION_STATIONS; i=i+1)
            table_full = (rs_statuses[i]==`RESERVATION_STATION_WAITING || rs_statuses[i]==`RESERVATION_STATION_READY);
      generate
   end


   // internal modules //
   reservation_station rses [(`RESERVATION_STATIONS-1):0] ( .clock(`RESERVATION_STATIONS{clock}), .reset(`RESERVATION_STATIONS{reset}),
                                                            .status(rs_statuses), .waiting_tag1(rs_waiting_tags1), .waiting_tag2(rs_waiting_tags2)
                                                                                                                                                    );


endmodule



