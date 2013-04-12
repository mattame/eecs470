/////////////////////////////////////////////////////////////////////////
//                                                                     //
//   Modulename :  regfile.v                                           //
//                                                                     //
//  Description :  This module creates the Regfile used by the ID and  // 
//                 WB Stages of the Pipeline.                          //
//                                                                     //
/////////////////////////////////////////////////////////////////////////


`timescale 1ns/100ps


module regfile(rda_idx, rda_out,                // read port A
               rdb_idx, rdb_out,                // read port B
               wr_idx, wr_data, wr_en, wr_clk); // write port

  input   [4:0] rda_idx, rdb_idx, wr_idx;
  input  [63:0] wr_data;
  input         wr_en, wr_clk;

  output [63:0] rda_out, rdb_out;
  
  reg    [63:0] rda_out, rdb_out;
  reg    [63:0] registers[31:0];   // 32, 64-bit Registers

  wire   [63:0] rda_reg = registers[rda_idx];
  wire   [63:0] rdb_reg = registers[rdb_idx];

  //
  // Read port A
  //
  always @*
    if (rda_idx == `ZERO_REG)
      rda_out = 0;
    else if (wr_en && (wr_idx == rda_idx))
      rda_out = wr_data;  // internal forwarding
    else
      rda_out = rda_reg;

  //
  // Read port B
  //
  always @*
    if (rdb_idx == `ZERO_REG)
      rdb_out = 0;
    else if (wr_en && (wr_idx == rdb_idx))
      rdb_out = wr_data;  // internal forwarding
    else
      rdb_out = rdb_reg;

  //
  // Write port
  //
  always @(posedge wr_clk)
    if (wr_en)
    begin
      registers[wr_idx] <= `SD wr_data;
    end

endmodule // regfile
