////////////////////////////////////////////////////////////////
// This file houses modules for the inner workings of the ROB //
//
// This ROB will have 32 entries. We can decide to add or     //
// subtract entries as we see fit.
// ROB consists of 32 ROB Entries                             //
////////////////////////////////////////////////////////////////


// parameters //
`define ROB_ENTRIES 32
`define ROB_ENTRY_AVAILABLE 1
`define NO_ROB_ENTRY 0
`define SD #1

/***
*   Each ROB Entry needs:
*       Head/Tail bit   (To determine where the head/tail 
*       Instruction     
*       Valid bit       (Whether or not the entry is valid)
*       Value           (To know when to retire)
*       Register        (Output REgister
*       Complete bit    (To know if it is ready to retire) 
***/
module reorder_buffer(
                  //inputs
                  //clock, reset, 
                  value_in1, value_in2, register_in1, register_in2, rob_entry_in1, rob_entry_in2, wrt_en_in1, wrt_en_in2,

                  //outputs
                  head_out, value_out, complete_out,register_out, rob_full, rob_entry_number
                 );


  /***  inputs  ***/
  input wire        reset;
  input wire        clock;
  input wire [63:0] value_in1;      //comes from CDB
	input wire [63:0] value_in2;
  //input wire        complete_in;     //not sure if this is needed                         
  input wire [4:0]  register_in1;   //comes from decode stage
	input wire [4:0]  register_in2;
	input wire [4:0]	rob_entry_in1;  //comes from CDB
	input wire [4:0]  rob_entry_in2;
	input wire 				wrt_en_in1;			 //comes from CDB
	input wire				wrt_en_in2;

  /***  internals  ***/
	reg				 [`ROB_ENTRIES-1:0] valid;
	reg				 [63:0] values		[`ROB_ENTRIES-1:0];   //2-D ARRAY OF VALUES IN ROB
	reg				 [5:0]  registers	[`ROB_ENTRIES-1:0];		//2-D ARRAY OF REGISTERS IN ROB
	//reg				 [`ROB_ENTRIES-1:0] head;
	//reg				 [`ROB_ENTRIES-1:0] tail;
	reg				 [4:0]	head_location;
	reg 			 [4:0] 	tail_location;	
	reg 			 [`ROB_ENTRIES-1:0] complete;
	reg				 [4:0]  counter;    
	reg				 [4:0]	previous_tail

	/***  outputs  ***/
  output reg        head_out;
  output reg [63:0] value_out;
  output reg        complete_out;
  output reg [4:0]  register_out;
	output reg 				rob_full;
	output reg [4:0]	rob_entry_number;	

	
	

  // combinational logic for ROB entry allocation // 
  always @*
	begin
  	begin : Loop
			integer i;
			counter = 5'b0;
			for(i = 0; i < `ROB_ENTRIES; i = i + 1)
			begin
				if(valid[i] == 0)		  			//if this entry in the ROB is invalid, allocate the new entry in this ROB #
				begin							
					valid[i]      		=  1;
					registers[i]  		=  register_in; 
					counter       		=  counter + 5'b1;
					rob_entry_number	=  i;  //tells Map table which ROB # corresponds to the destReg(should convert integer into register)
					//tail[i]						=	 1;
					tail_location 		=  i; 
					
					if(i == 0) //deallocates previous tail
					begin
						previous_tail 						=  5'd31;
						//tail[previous_tail]				=  0
					end
			
					else
					begin
						previous_tail 						= i - 1;
						//tail[previous_tail] 			= 0;
					end

					disable Loop;
				end
				
				else	
				begin	
					counter   		=  counter + 5'b1;

					if(counter == 32) //assumes ROB is full if all valid bits are 1 (all ROB entries are being used)
					begin
						rob_full 		=  1;
					end

					else
					begin
						rob_full 		=  0;
					end
				end
			end
		end
	end



	// combinational logic for when inputs come from CDB //
	always @*
	begin
		if(wrt_en_in)
		begin
			values[rob_entry_in] 		= value_in;
			complete[rob_entry_in]  = 1'b1;
		end
	end


	// writing to the register file & free ROB entry //
	always @*	
	begin
		if(complete[head_location] == 1)
		begin
			register_out 					= registers[head_location];
			value_out 	 					= values[head_location];
			//head[head_location] 	= 0;
			valid[head_location]	= 0;

			if(head_location == 5'd31)
			begin
				head_location 			= 5'b0;
				//head[head_location] = 1'b1;
			end

			else
			begin
				head_location				= head_location + 1'b1;
				//head[head_location] = 1'b1;
			end
		end
	end

	// if we need to empty the ROB for some reason //
	always @*
	begin
		if(reset)
		begin
			valid  				= 32'b0;
			//head	 				= 32'b0;
			//tail					= 32'b0;
			head_location = 0;
			tail_location = 0;
			previous_tail = 0;
		end
	end
	
    

  // clock synchronous events //
/*  always @(posedge clock)	
  begin
     if (reset)
     begin
        valid		        <= `SD 32'b0;
        head_out        <= `SD 5'b0;
        value_out       <= `SD 64'h0;
        complete_out    <= `SD 1'b0;
       // exception_out   <= `SD 1'b0;
				register_out 		<= `SD 5'b0;
				rob_full				<= `SD 1'b0;
				counter					<= `SD 5'b0;
     end

     else
     begin
        //head_out        <= `SD n_head;
        //tail_out        <= `SD n_tail;
        //complete_out    <= `SD n_complete;
        //exception_out   <= `SD n_exception;

		 		if(complete[head_location] == 1 && n_head == 1) //Retiring an entry in the ROB
				begin
		 			register_out 		<= `SD n_register;  //needs to be written to the regfile
					value_out       <= `SD n_value;
					//make sure to change the head of ROB here
				end

				else
		 		begin
		 			register_out		<= `SD 5'b0;
					value_out       <= `SD 64'h0;
		 		end
		end
*/
endmodule
