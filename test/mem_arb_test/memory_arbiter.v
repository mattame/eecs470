///////////////////////////////////////////////
//                                           //
//  file: memory_arbiter.v                   //
//                                           //
//  desc: Acts as a barrier between the pipe //
//        and the memory.                    //
//                                           //
///////////////////////////////////////////////
`define SD			   #1

`define BUS_NONE       2'h0
`define BUS_LOAD       2'h1
`define BUS_STORE      2'h2

module memory_arbiter(
	//Inputs
		clock,
		reset,
		//From IF
		if_mem_req_addr,

		//From LSQ	
		LSQ_mem_req_addr,
		LSQ_mem_req_value,
		LSQ_mem_read,
		LSQ_tag_in,
		LSQ_valid_in,

		//From Memory
		MEM_value_in,

	//Outputs
		//To IF
		if_mem_out_value,
		if_stall,

		//To LSQ
		EX_mem_value,
		EX_tag_out,
		EX_valid_out,

		//To Memory
		MEM_address,
		MEM_value,
		MEM_command
	);

	//Inputs
		//From IF
input clock;
input reset;

input [63:0] if_mem_req_addr;

		//From LSQ	
input [63:0] LSQ_mem_req_addr;
input [63:0] LSQ_mem_req_value;
input        LSQ_mem_read;
input  [4:0] LSQ_tag_in;
input        LSQ_valid_in;

		//From Memory
input [63:0] MEM_value_in;

	//Outputs
		//To IF
output [63:0] if_mem_out_value;
output        if_stall;

		//To EX
output [63:0] EX_mem_value;
output  [4:0] EX_tag_out;
output        EX_valid_out;

		//To Memory
output [63:0] MEM_address;
output [63:0] MEM_value_out;
output  [1:0] MEM_command;

reg LSQ_valid;
reg [4:0] LSQ_tag;

assign MEM_address = (LSQ_valid_in) ? LSQ_mem_req_addr: if_mem_req_addr;

assign MEM_value_out = (LSQ_valid_in) ? LSQ_mem_req_value: 64'h0;

assign MEM_command = (LSQ_mem_read & LSQ_valid_in) ? `BUS_LOAD: `BUS_STORE;

assign if_stall = LSQ_valid_in;

assign EX_mem_value = MEM_value_in;
assign if_mem_out_value = MEM_value_in;

assign EX_valid_out = LSQ_valid;
assign EX_tag_out = LSQ_tag;

always @(posedge clock) begin
	if(reset) begin
		LSQ_valid <= `SD 1'b0;
		LSQ_tag <= `SD 5'h0;
	end
	else begin
		LSQ_valid <= `SD LSQ_valid_in;
		LSQ_tag <= `SD LSQ_tag_in;
	end
end

endmodule


