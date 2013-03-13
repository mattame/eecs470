
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
module reservation_station(clock,reset,fill,                                     // signals in
                           dest_reg_in,rega_value_in,regb_value_in,              // busses in
                           waiting_taga_in,waiting_tagb_in,                      // more busses in
                           cdb_tag_in,cdb_value_in,                              // yet more busses in
                           status_out,                                           // signals out
                           dest_reg_out,rega_value_out,regb_value_out            // busses out
                           );

   // inputs //
   input wire clock;
   input wire reset;
   input wire fill;
   input wire [4:0]  dest_reg_in;
   input wire [63:0] rega_value_in;
   input wire [63:0] regb_value_in;
   input wire [7:0]  waiting_taga_in;
   input wire [7:0]  waiting_tagb_in;
   input wire [7:0]  cdb_tag_in;
   input wire [63:0] cdb_value_in;

   // outputs //
   output reg  [2:0]  status_out;
   output reg  [4:0]  dest_reg_out;
   output reg  [63:0] rega_value_out;
   output reg  [63:0] regb_value_out;

   // internal registers and wires //
   reg  [2:0]  n_status;
   reg  [4:0]  n_dest_reg;
   reg  [7:0]    waiting_taga;
   reg  [7:0]  n_waiting_taga;
   reg  [7:0]    waiting_tagb;
   reg  [7:0]  n_waiting_tagb; 
   reg  [63:0] n_rega_value;
   reg  [63:0] n_regb_value;
   wire taga_in_nonnull;     
   wire tagb_in_nonnull;
   wire taga_cur_nonnull;
   wire tagb_cur_nonnull;
   wire taga_in_match_cdb_in;
   wire tagb_in_match_cdb_in;
   wire taga_cur_match_cdb_cur;
   wire tagb_cur_match_cdb_cur;

   // combinational assignments //
   assign taga_in_nonnull       = (waiting_taga_in!=`RSTAG_NULL);
   assign tagb_in_nonnull       = (waiting_tagb_in!=`RSTAG_NULL);
   assign taga_cur_nonnull      = (waiting_taga!=`RSTAG_NULL);
   assign tagb_cur_nonnull      = (waiting_tagb!=`RSTAG_NULL);
   assign taga_in_match_cdb_in  = (waiting_taga_in==cdb_tag_in);
   assign tagb_in_match_cdb_in  = (waiting_tagb_in==cdb_tag_in); 
   assign taga_cur_match_cdb_in = (waiting_taga==cdb_tag_in);
   assign tagb_cur_match_cdb_in = (waiting_tagb==cdb_tag_in);


   // combinational logic to set next states //
   always@*
   begin
      if (fill)
      begin
         n_dest_reg     = dest_reg_in;
         n_waiting_taga = (taga_in_match_cdb_in && taga_in_nonnull) ? `RSTAG_NULL  : waiting_taga_in;
         n_waiting_tagb = (tagb_in_match_cdb_in && tagb_in_nonnull) ? `RSTAG_NULL  : waiting_tagb_in;
         n_rega_value   = (taga_in_match_cdb_in && taga_in_nonnull) ? cdb_value_in : rega_value_in;
         n_regb_value   = (tagb_in_match_cdb_in && tagb_in_nonnull) ? cdb_value_in : regb_value_in;
         case ({ (n_waiting_taga!=`RSTAG_NULL), (n_waiting_tagb!=`RSTAG_NULL) })
            2'b00: n_status = `RS_READY;
            2'b10: n_status = `RS_WAITING_A;
            2'b01: n_status = `RS_WAITING_B;
            2'b11: n_status = `RS_WAITING_BOTH;
         endcase
      end
      else
      begin
         n_dest_reg     = dest_reg_out;
         n_waiting_taga = (taga_cur_match_cdb_in && taga_cur_nonnull) ? `RSTAG_NULL : waiting_taga;
         n_waiting_tagb = (tagb_cur_match_cdb_in && tagb_cur_nonnull) ? `RSTAG_NULL : waiting_tagb;
         n_rega_value   = (taga_cur_match_cdb_in && taga_cur_nonnull) ? cdb_value_in : rega_value_out;
         n_regb_value   = (tagb_cur_match_cdb_in && tagb_cur_nonnull) ? cdb_value_in : regb_value_out;
         case ({ (n_waiting_taga!=`RSTAG_NULL), (n_waiting_tagb!=`RSTAG_NULL) })
            2'b00: n_status = `RS_READY;
            2'b01: n_status = `RS_WAITING_A;
            2'b10: n_status = `RS_WAITING_B;
            2'b11: n_status = `RS_WAITING_BOTH;
         endcase
      end
   end

   // clock synchronous events //
   always@(posedge clock)
   begin
      if (reset)
      begin
         status_out      <= `SD `RS_EMPTY;
         dest_reg_out    <= `SD 5'd0;
         waiting_taga    <= `SD 8'd0;
         waiting_tagb    <= `SD 8'd0;
         rega_value_out  <= `SD 64'd0;
         regb_value_out  <= `SD 64'd0;
      end
      else
      begin
         status_out      <= `SD n_status;
         dest_reg_out    <= `SD n_dest_reg;
         waiting_taga    <= `SD n_waiting_taga;
         waiting_tagb    <= `SD n_waiting_tagb;
         rega_value_out  <= `SD n_rega_value;
         regb_value_out  <= `SD n_regb_value;
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



