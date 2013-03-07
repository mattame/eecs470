/*
Imagine I want to create a structure that keeps track of a variable X being changed, and keep a backup that gets updated at a later time 
(Imagine RAT and RRAT)

I will update the value X on eithier issue or commit, and have seperate signals for each as well as a copy signal. This may be more 
complicated for a BRAT but simmilar rules apply.

Note we could store more than just one value in the entry. See the other example page, this technique could be used with either the indexed 
or camed structure.
*/

module copy_entry(
     clk,
     reset,
     
     issue_x,
     issue_wr_en,
     issue_rd_ed,

     commit_x,
     commit_wr_en,
     commit_rd_en,
     
     copy,

     issue_x_out,
     commit_x_out
     )

input clk, reset;

input [4:0] issue_x;
input issue_wr_en, issue_rd_en;

input [4:0] commit_x;
input commit_wr_en, commit_rd_en;

input copy;

output [4:0] issue_x_out;
output [4:0] commit_x_out;

reg [4:0] issue_stored_x;
reg [4:0] commit_stored_x;

always @(posedge clk)
begin
   if (reset)
   begin
      issue_stored_x <= `SD 5'd0;
      commit_stored_x <= `SD 5'd0;
   end
   else if(copy) //Give this priority over the writes, but not over a reset
   begin
      issue_stored_x <= `SD commit_stored_x;
   end
   else //Be sure to check both wr enables
   begin
      if (issue_wr_en)
      begin
         issue_stored_x <= `SD issue_x;
      end
      if (commit_wr_en)  //Note I check both writes, not an else if just an if
      begin
         commit_stored_x <= `SD commit_x;
      end
   end
end

assign issue_x_out = issue_rd_en ? issue_stored_x : 5'd0; //WOR again at the top-level
assign commit_x_out = commit_rd_en ? commit_stored_x : 5'd0;

endmodule
