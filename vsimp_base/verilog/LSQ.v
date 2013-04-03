//////////////////////////////////////////////////////////////////////////
//                                                                      //
//   Modulename :  LSQ.v                                                //
//                                                                      //
//  Description :  takes in load and store commands synchronously       //
//                 with the ROB. Gathers address and values to store    //
//                 from the EX stage. Outputs ROB tag, address, value,  //
//                 and rd/wr enable to a module that interfaces with    //
//                 the memory.                                          // 
//                                                                      //
//                                                                      //
//////////////////////////////////////////////////////////////////////////

`timescale 1ns/100ps

/*
***************************
		Entry Module
***************************
*/
module LSQ_entry(//Inputs
					clock,
					reset,

					ROB_head_1,
					ROB_head_2,

					LSQ_head,

					clear,

					ROB_tag_1,
					rd_mem_in_1,
					store_ROB_1,

					addr_in_1,
					value_in_1,
					EX_tag_1,

					ROB_tag_2,
					rd_mem_in_2,
					store_ROB_2,

					addr_in_2,
					value_in_2,
					EX_tag_2,

				 //Outputs
				 	stored_tag_out,
				 	stored_address_out,
				 	stored_value_out,
				 	ready_out
				);

input clock;
input reset;

input [4:0] ROB_head_1;
input [4:0] ROB_head_2;

input [4:0] LSQ_head;

input clear;

input [4:0] ROB_tag_1;
input rd_mem_in_1;
input store_ROB_1;

input [63:0] addr_in_1;
input [63:0] value_in_1;
input [4:0]  EX_tag_1;

input [4:0] ROB_tag_2;
input rd_mem_in_2;
input store_ROB_2;

input [63:0] addr_in_2;
input [63:0] value_in_2;
input [4:0]  EX_tag_2;

output [4:0] stored_tag_out;
output [63:0] stored_address_out;
output [63:0] stored_value_out;
output ready_out;

reg [63:0] stored_address;
reg [63:0] stored_value;
reg [4:0]  stored_tag;
reg		   read;			//1 if it's a load, 0 if it's a store
reg		   valid;
reg		   complete;

wire store_EX_1;
wire store_EX_2;
wire next_complete;
wire next_valid;
wire next_read;

wire [63:0] next_address;
wire [63:0] next_value;
wire [4:0]  next_tag;

assign store_EX_1 = (EX_tag_1 == stored_tag);

assign store_EX_2 = (EX_tag_2 == stored_tag);

assign next_valid = (clear) ? 1'b0: (store_ROB_1 | store_ROB_2) ? 1'b1: valid;

assign next_complete = (store_EX_1 | store_EX_2) ? 1'b1: (valid) ? complete: 1'b0;

assign next_read = (store_ROB_1) ? rd_mem_in_1:
				   (store_ROB_2) ? rd_mem_in_2:
				   read;

assign next_tag = (store_ROB_1) ? ROB_tag_1:
				  (store_ROB_2) ? ROB_tag_2:
				  stored_tag;

assign next_address = (store_EX_1) ? addr_in_1:
					  (store_EX_2) ? addr_in_2:
					  stored_address;


assign next_value = (store_EX_1) ? value_in_1:
					(store_EX_2) ? value_in_2:
					stored_value;

always @(posedge clock) begin
	if(reset) begin
		read <= `SD 1'b0;		
		valid <= `SD 1'b0;
		complete <= `SD 1'b0;
		stored_tag <= `SD 5'h0;
		stored_value <= `SD 64'h0;
		stored_address <= `SD 64'h0;
	end	
	else begin
		read <= `SD next_read;			
		valid <= `SD next_valid;
		complete <= `SD next_complete;	
		stored_tag <= `SD next_tag;
		stored_value <= `SD next_value;
		stored_address <= `SD next_address;
	end

end

assign stored_address_out = stored_address;
assign stored_value_out = stored_value;
assign stored_tag_out = stored_tag;
assign ready_out = ((!read | (read & (stored_tag == ROB_head_1 | stored_tag == ROB_head_2))) & complete) ? 1'b1: 1'b0;

endmodule

/*
****************************
		Main Module
****************************
*/
module LSQ(//Inputs
			//From ROB/ID

			ROB_head_1,
			ROB_head_2,

			//1
			ROB_tag_1,
			rd_mem_in_1,
			wr_mem_in_1,
			valid_in_1,

			//2
			ROB_tag_2,
			rd_mem_in_2,
			wr_mem_in_2,
			valid_in_2,

			//From EX ALU
			tag_match_1,
			value_in_1,
			address_in_1,

			tag_match_2,
			value_in_2,
			address_in_2,

			//Outputs
			tag_out,
			address_out,
			value_out,
			rd_out,
			wr_out
		  );

 input [4:0] ROB_head_1;
 input [4:0] ROB_head_2;

 input [4:0] ROB_tag_1;
 input       rd_mem_in_1;
 input 		 wr_mem_in_1;
 input 		 valid_in_1;

 input [4:0] ROB_tag_2;
 input       rd_mem_in_2;
 input 		 wr_mem_in_2;
 input 		 valid_in_2;

 input [4:0] tag_match_1;
 input [63:0] value_in_1;
 input [63:0] address_in_1;

 input [4:0] tag_match_1;
 input [63:0] value_in_1;
 input [63:0] address_in_1;

 output [4:0] tag_out;
 output [63:0] address_out;
 output [63:0] value_out;
 output 	   rd_out;
 output        wr_out;

 reg [4:0] LSQ_head;
 reg [4:0] LSQ_tail;
 reg [4:0] _1;
 reg [4:0] _2;

always @(posedge clock) begin
	if(reset) begin
		LSQ_head <= `SD 5'h0;
		LSQ_tail <= `SD 5'h0;
		_1 <= `SD 5'h0;
		_2 <= `SD 5'h1;
	end
	else begin
		LSQ_head <= `SD next_head;
		LSQ_tail <= `SD next_tail;
		_1 <= `SD next__1;
		_2 <= `SD next__2;		
	end

end



endmodule