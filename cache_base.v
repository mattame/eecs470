// EECS 470 - Winter 2009
// 128 line cache
//
// NOTE: this cache only looks at 32 bits for the index and tag (line size of
// 1).  This works because our while our addressable memory is 64 bits, the
// real size of our memory is 64k (check sys_defs.vh to verify).  You may wish
// to change this assumption.

`define SD #1

module cachemem128x64(clock, reset, 
			wr1_en, wr1_tag, wr1_idx, wr1_data,
			rd1_tag, rd1_idx, rd1_data, rd1_valid);

input clock, reset, wr1_en;
input [6:0] wr1_idx, rd1_idx;
input [21:0] wr1_tag, rd1_tag;
input [63:0] wr1_data; 
output [63:0] rd1_data;
output rd1_valid;

reg [63:0] data [127:0];
reg [21:0] tags [127:0]; 
reg [127:0] valids;

assign rd1_data = data[rd1_idx];
assign rd1_valid = valids[rd1_idx]&&(tags[rd1_idx] == rd1_tag);

always @(posedge clock)
begin
  if(reset) valids <= `SD 128'b0;
  else if(wr1_en) 
    valids[wr1_idx] <= `SD 1;
end

always @(posedge clock)
begin
  if(wr1_en)
  begin
    data[wr1_idx] <= `SD wr1_data;
    tags[wr1_idx] <= `SD wr1_tag;
  end
end

endmodule