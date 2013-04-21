
//////////////////////////////////////////////////////////////////
// this will hold the modules for our processor's register file //
//////////////////////////////////////////////////////////////////

`define ZERO_REG 5'd31

//`timescale 1ns/100ps

// regfile module //
module register_file(clock,reset,   // input signals in

                     // input busses: register indexes and values in // 
                     inst1_rega_in,inst1_regb_in, 
                     inst2_rega_in,inst2_regb_in,
                     inst1_dest_in,inst1_value_in,
                     inst2_dest_in,inst2_value_in,

                     // output busses: register values out //
                     inst1_rega_out,inst1_regb_out,
                     inst2_rega_out,inst2_regb_out,

                     // ouput signals: tell the map table when to clear //
                     clear_entries
                   );

   // inputs //
   input wire clock;
   input wire reset;
   input wire [4:0] inst1_rega_in;
   input wire [4:0] inst1_regb_in;
   input wire [4:0] inst2_rega_in;
   input wire [4:0] inst2_regb_in;
   input wire [4:0] inst1_dest_in;
   input wire [4:0] inst2_dest_in;
   input wire [63:0] inst1_value_in;
   input wire [63:0] inst2_value_in;

   // outputs //
   output wire [63:0] inst1_rega_out;
   output wire [63:0] inst1_regb_out;
   output wire [63:0] inst2_rega_out;
   output wire [63:0] inst2_regb_out;
   output wire [31:0] clear_entries;

   // internal registers/wires //
   reg [63:0]   values [31:0];
   wire [63:0] n_values [31:0];
   wire inst1_dest_nonzero;
   wire inst2_dest_nonzero;

   // combinational logic for internal signals //
   assign inst1_dest_nonzero = (inst1_dest_in!=`ZERO_REG);
   assign inst2_dest_nonzero = (inst2_dest_in!=`ZERO_REG);


   // combinational logic for reg value outputs (includes internal register forwarding) // 
   assign inst1_rega_out = (reset ? 64'd0 : 
                            ((inst2_dest_in==inst1_rega_in) && inst2_dest_nonzero) ? inst2_value_in :
                             ( ((inst1_dest_in==inst1_rega_in) && inst1_dest_nonzero) ? inst1_value_in : n_values[inst1_rega_in] )); 
   assign inst1_regb_out = (reset ? 64'd0 :
                            ((inst2_dest_in==inst1_regb_in) && inst2_dest_nonzero) ? inst2_value_in :
                             ( ((inst1_dest_in==inst1_regb_in) && inst1_dest_nonzero) ? inst1_value_in : n_values[inst1_regb_in] ));
   assign inst2_rega_out = (reset ? 64'd0 :
                            ((inst2_dest_in==inst2_rega_in) && inst2_dest_nonzero) ? inst2_value_in :
                             ( ((inst1_dest_in==inst2_rega_in) && inst1_dest_nonzero) ? inst1_value_in : n_values[inst2_rega_in] )); 
   assign inst2_regb_out = (reset ? 64'd0 :
                             ((inst2_dest_in==inst2_regb_in) && inst2_dest_nonzero) ? inst2_value_in : 
                             ( ((inst1_dest_in==inst2_regb_in) && inst1_dest_nonzero) ? inst1_value_in : n_values[inst2_regb_in] ));


   // combinational logic for n_values and clear_entries //
   assign n_values[`ZERO_REG] = 64'd0;
   assign clear_entries[31] = 0;
   genvar j;
   generate
      for (j=0; j<31; j=j+1)
      begin : NVALUESASSIGN
         assign n_values[j] = ((inst2_dest_in==j) && inst2_dest_nonzero) ? inst2_value_in :                       // inst2 takes precidence here because it comes second
                               ( ((inst1_dest_in==j) && inst1_dest_nonzero) ? inst1_value_in : values[j] );
         assign clear_entries[j] = (inst1_dest_in==j || inst2_dest_in==j); 
      end
   endgenerate

   
   // clock synchronous logic //
   genvar i;
   generate
      for (i=0; i<32; i=i+1)
      begin : VALUESASSIGN
         always @(posedge clock)
         begin
            if (reset)
               values[i] <= 64'd0;
            else
               values[i] <= n_values[i]; 
         end

      end
   endgenerate

endmodule


