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

// defined paramters //
`define LSQ_ENTRIES	    32

`define BUS_STORE
`define BUS_LOAD
`

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

					clear,

					ROB_tag_1,
					rd_mem_in_1,
					store_ROB_1,

					addr_in_1,
					value_in_1,
					EX_tag_1,
					EX_valid_1,

					ROB_tag_2,
					rd_mem_in_2,
					store_ROB_2,

					addr_in_2,
					value_in_2,
					EX_tag_2,
					EX_valid_2,

				 //Outputs
				 	stored_tag_out,
				 	stored_address_out,
				 	stored_value_out,
				 	read_out,
				 	complete_out
				);

input clock;
input reset;

input [7:0] ROB_head_1;
input [7:0] ROB_head_2;

input clear;

input [4:0] ROB_tag_1;
input rd_mem_in_1;
input store_ROB_1;

input [63:0] addr_in_1;
input [63:0] value_in_1;
input [4:0]  EX_tag_1;
input EX_valid_1;

input [4:0] ROB_tag_2;
input rd_mem_in_2;
input store_ROB_2;

input [63:0] addr_in_2;
input [63:0] value_in_2;
input [4:0]  EX_tag_2;
input EX_valid_2;

output [4:0] stored_tag_out;
output [63:0] stored_address_out;
output [63:0] stored_value_out;
output  [1:0] read_out;
output complete_out;

reg [63:0] stored_address;
reg [63:0] stored_value;
reg [4:0]  stored_tag;
reg		   read;			//1 if it's a load, 0 if it's a store
reg		   valid;
reg		   complete;
reg   		   ROB_head_met;

wire store_EX_1;
wire store_EX_2;
wire next_complete;
wire next_valid;
wire next_read;

wire head_1_true, head_2_true;

wire [63:0] next_address;
wire [63:0] next_value;
wire [4:0]  next_tag;

assign store_EX_1 = (EX_valid_1 & (next_valid) & (EX_tag_1 == next_tag))
					? 1'b1 : 1'b0;

assign store_EX_2 = (EX_valid_2 & (next_valid) & (EX_tag_2 == next_tag))
					? 1'b1 : 1'b0;


assign next_valid = (clear) ? 1'b0: (store_ROB_1 | store_ROB_2) ? 1'b1: valid;

assign next_complete = (store_EX_1 | store_EX_2) ? 1'b1: (next_valid) ? complete: 1'b0;

		 assign head_1_true = (next_tag == ROB_head_1[4:0]) & !ROB_head_1[5] & !ROB_head_1[6] & !ROB_head_1[7];
		 assign head_2_true = (next_tag == ROB_head_2[4:0]) & !ROB_head_2[5] & !ROB_head_2[6] & !ROB_head_2[7];

assign next_head_met = (next_valid & next_complete) ? ((head_1_true | head_2_true) ? 1'b1: ROB_head_met): 1'b0;

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
		ROB_head_met <= `SD 1'b0;
		read <= `SD 1'b0;		
		valid <= `SD 1'b0;
		complete <= `SD 1'b0;
		stored_tag <= `SD 5'h0;
		stored_value <= `SD 64'h0;
		stored_address <= `SD 64'h0;
	end	
	else begin
		ROB_head_met <= `SD next_head_met;
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
assign read_out = read;
assign complete_out = complete & (read_out | ROB_head_met);

endmodule

/*
****************************
		Main Module
****************************
*/
module LSQ(//Inputs
			clock,
			reset,
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
			EX_tag_1,
			value_in_1,
			address_in_1,
			EX_valid_1,

			EX_tag_2,
			value_in_2,
			address_in_2,
			EX_valid_2,

			//Outputs
			tag_out,
			address_out,
			value_out,
			read_out,
			valid_out,

			stall
		  );

 input clock;
 input reset;

 input [7:0] ROB_head_1;
 input [7:0] ROB_head_2;

 input [4:0] ROB_tag_1;
 input       rd_mem_in_1;
 input 		 wr_mem_in_1;
 input 		 valid_in_1;

 input [4:0]  EX_tag_1;
 input [63:0] value_in_1;
 input [63:0] address_in_1;
 input        EX_valid_1;

 input [4:0] ROB_tag_2;
 input       rd_mem_in_2;
 input 		 wr_mem_in_2;
 input 		 valid_in_2;

 input [4:0]  EX_tag_2;
 input [63:0] value_in_2;
 input [63:0] address_in_2;
 input        EX_valid_2;

 output [4:0]  tag_out;
 output [63:0] address_out;
 output [63:0] value_out;
 output 	   read_out;
 output        valid_out;

 output stall;

 reg [4:0] LSQ_head;
 reg [4:0] LSQ_tail;

 wire valid_ROB_in_1, valid_ROB_in_2;

 assign valid_ROB_in_1 = ((rd_mem_in_1 | wr_mem_in_1) & valid_in_1) ? 1'b1: 1'b0;
 assign valid_ROB_in_2 = ((rd_mem_in_2 | wr_mem_in_2) & valid_in_2) ? 1'b1: 1'b0;

 wire [4:0] next_head, next_tail, next_entry_1, next_entry_2;

 wire [4:0]  tags_out [(`LSQ_ENTRIES-1):0];
 wire [63:0] addrs_out [(`LSQ_ENTRIES-1):0];
 wire [63:0] values_out [(`LSQ_ENTRIES-1):0];
 wire 	     reads_out [(`LSQ_ENTRIES-1):0];
 wire 		 completes_out [(`LSQ_ENTRIES-1):0];

// ----------- ENTRY INPUT LOGIC ----------
 wire clears [(`LSQ_ENTRIES-1):0];
 wire stores_1 [(`LSQ_ENTRIES-1):0];
 wire stores_2 [(`LSQ_ENTRIES-1):0];

 generate
 	genvar i;
 	for(i=0; i<`LSQ_ENTRIES; i=i+1) begin : ASSIGNLSQINPUTS
 		assign clears[i]   = (reset | (i == LSQ_head & completes_out[i] == 1'b1)) ? 1'b1: 1'b0;
 		assign stores_1[i] = (i == next_entry_1 & valid_ROB_in_1) ? 1'b1: 1'b0;
 		assign stores_2[i] = ((i == next_entry_1 & !valid_ROB_in_1 & valid_ROB_in_2) | 
 							  (i == next_entry_2 & valid_ROB_in_1 & valid_ROB_in_2)) ? 1'b1: 1'b0;
 	end
 endgenerate

// --------------- ENTRIES ----------------

 generate
 	//genvar i;
 	for(i=0; i<`LSQ_ENTRIES; i=i+1) begin : LSQENTRIES
 		LSQ_entry entries(
 						//Inputs
						.clock(clock),
						.reset(reset),

						.ROB_head_1(ROB_head_1),
						.ROB_head_2(ROB_head_2),

						.clear(clears[i]),

						.ROB_tag_1(ROB_tag_1),
						.rd_mem_in_1(rd_mem_in_1),
						.store_ROB_1(stores_1[i]),

						.addr_in_1(address_in_1),
						.value_in_1(value_in_1),
						.EX_tag_1(EX_tag_1),
						.EX_valid_1(EX_valid_1),

						.ROB_tag_2(ROB_tag_2),
						.rd_mem_in_2(rd_mem_in_2),
						.store_ROB_2(stores_2[i]),

						.addr_in_2(address_in_2),
						.value_in_2(value_in_2),
						.EX_tag_2(EX_tag_2),
						.EX_valid_2(EX_valid_2),

						//Outputs
						.stored_tag_out(tags_out[i]),
						.stored_address_out(addrs_out[i]),
						.stored_value_out(values_out[i]),
						.read_out(reads_out[i]),
						.complete_out(completes_out[i])
					    );
 	end
 endgenerate

 
// --------- ENTRY OUPUT LOGIC -----------
 assign address_out = addrs_out[LSQ_head];

 assign value_out = values_out[LSQ_head];

 assign tag_out = tags_out[LSQ_head];

 assign read_out = (reads_out[LSQ_head]) ? `BUS_LOAD : `BUS_STORE;
 
		 wire head_2_true, reset_invalid; //wires to help compute valid out
		 

		 assign head_2_true = (tag_out == ROB_head_2[4:0]) & !ROB_head_2[5] & !ROB_head_2[6] & !ROB_head_2[7];

		 assign reset_invalid = reset & head_2_true;
		 
 
 assign valid_out = completes_out[LSQ_head] & read_out & !reset_invalid;
 
//----------- POINTER KEEPING ------------
 assign next_head = (valid_out) ? (LSQ_head + 1):LSQ_head;

 assign next_tail = (valid_ROB_in_1) ? ((valid_ROB_in_2) ? next_entry_2: next_entry_1): (valid_ROB_in_2) ? next_entry_1 : LSQ_tail;

 assign next_entry_1 = LSQ_tail + 1;

 assign next_entry_2 = LSQ_tail + 2;

 assign stall = ((LSQ_head == next_entry_1) | (LSQ_head == next_entry_2)) ? 1'b1: 1'b0;

always @(posedge clock) begin
	if(reset) begin
		LSQ_head <= `SD 5'h1; //so that it matches up with next_entry_1
		LSQ_tail <= `SD 5'h0;
	end
	else begin
		LSQ_head <= `SD next_head;
		LSQ_tail <= `SD next_tail;	
	end

end


endmodule
