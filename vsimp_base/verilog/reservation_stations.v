
///////////////////////////////////////////////////////////////////////////////
// This file will hold module definitions of the reservation station table.  //
// The main module utilizes multiple individual reservation station modules. //
///////////////////////////////////////////////////////////////////////////////


// defined paramters //
`define RESERVATION_STATIONS 8
`define RESERVATION_STATION_EMPTY   2'b00
`define RESERVATION_STATION_WAITING 2'b01
`define RESERVATION_STATION_READY   2'b10


// individual reservation station module //
module reservation_station(clock,reset,

                            status,waiting_register

                           );

   // inputs //
   input wire clock;
   input wire register; 

   // outputs //
   output wire [1:0] status;
   output wire [4:0] waiting_register;






endmodule



// the actual reservation table module //
module reservation_station_table(clock,reset,
                                 inst1_rega_value_in,inst1_regb_value_in,
                                 inst2_rega_vlaue_in,inst2_regb_value_in,
                                 table_full );



   // inputs //
   input wire clock;
   input wire reset;
   input wire [63:0] inst1_rega_value_in,inst1_regb_value_in;
   input wire [63:0] inst2_rega_value_in,inst2_regb_value_in;


   // outputs //
   output wand table_full; 


   // internal wires //
   wire [1:0] rs_statuses [(`RESERVATION_STATIONS-1):0];
  
   // variable for combinational logic loops //
   integer i;


   // combinational logic to determine if table is table full //
   always @*
   begin
      for (i=0; i<`RESERVATION_STATIONS; i=i+1)
         table_full = (rs_statuses[i]==`RESERVATION_STATION_WAITING || rs_statuses[i]==`RESERVATION_STATION_READY);
   end


   // internal modules //
   reservation_station reservation_stations [(`RESERVATION_STATIONS-1):0] ( .clock(`RESERVATION_STATIONS{clock}), .reset(`RESERVATION_STATIONS{reset}),
                                                                            .status(rs_statuses), .waiting_register(rs_waiting_registers)     );


endmodule


