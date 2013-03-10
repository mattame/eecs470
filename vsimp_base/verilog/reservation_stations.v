
///////////////////////////////////////////////////////////////////////////////
// This file will hold module definitions of the reservation station table.  //
// The main module utilizes multiple individual reservation station modules. //
///////////////////////////////////////////////////////////////////////////////


// defined paramters //
`define RESERVATION_STATIONS 8
`define RESERVATION_STATION_EMPTY        3'b000
`define RESERVATION_STATION_WAITING_1    3'b001
`define RESERVATION_STATION_WAITING_2    3'b010
`define RESERVATION_STATION_WAITING_BOTH 3'b011
`define RESERVATION_STATION_READY        3'b100


// individual reservation station module //
module reservation_station(clock,reset,
                            status,waiting_tag1,waiting_tag2
                           );

   // inputs //
   input wire clock;
   input wire register; 

   // outputs //
   output wire [1:0] status_out;
   output wire [4:0] waiting_tag1_out;
   output wire [7:0] waiting_tag2_out;

   // internal registers //
   reg [7:0] waiting_tag1_reg;
   reg [7:0] waiting_tag2_reg;







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
      for (i=0; i<`RESERVATION_STATIONS; i=i+1)
         table_full = (rs_statuses[i]==`RESERVATION_STATION_WAITING || rs_statuses[i]==`RESERVATION_STATION_READY);
   end


   // internal modules //
   reservation_station rses [(`RESERVATION_STATIONS-1):0] ( .clock(`RESERVATION_STATIONS{clock}), .reset(`RESERVATION_STATIONS{reset}),
                                                            .status(rs_statuses), .waiting_tag1(rs_waiting_tags1), .waiting_tag2(rs_waiting_tags2)
                                                                                                                                                    );


endmodule


