`timescale 1ns/100ps


// reservation station testbench module //
module testbench;

	// internal wires/registers //
	reg correct;
	integer i = 0;

	// wires for testing the module //
	reg clock;
	reg reset;
	
	//Inputs
		//From IF
  reg [63:0] if_mem_req_addr;

		//From LSQ	
  reg [63:0] LSQ_mem_req_addr;
  reg [63:0] LSQ_mem_req_value;
  reg        LSQ_mem_read;
  reg  [4:0] LSQ_tag;
	reg        LSQ_valid;

		//From Memory
  reg [63:0] MEM_value_in;

	//Outputs
		//To IF
	wire [63:0] if_mem_out_value;
	wire        if_stall;

		//To LSQ
	wire [63:0] EX_mem_value;
	wire  [4:0] EX_tag;
	wire        EX_valid;

		//To Memory
	wire [63:0] MEM_address;
	wire [63:0] MEM_value;
	wire  [1:0] MEM_command;

        // module to be tested //	
module memory_arbiter(
	//Inputs
		.clock(clock),
		.reset(reset),
		//From IF
		.if_mem_req_addr(if_mem_req_addr),

		//From LSQ	
		.LSQ_mem_req_addr(LSQ_mem_req_addr),
		.LSQ_mem_req_value(LSQ_mem_req_value),
		.LSQ_mem_read(LSQ_mem_read),
		.LSQ_tag_in(LSQ_tag),
		.LSQ_valid_in(LSQ_valid),

		//From Memory
		.MEM_value_in(MEM_value_in),

	//Outputs
		//To IF
		.if_mem_out_value(if_mem_out_value),
		.if_stall(if_stall),

		//To LSQ
		.EX_mem_value(EX_mem_value),
		.EX_tag_out(EX_tag),
		.EX_valid_out(EX_valid),

		//To Memory
		.MEM_address(MEM_address),
		.MEM_value(MEM_value),
		.MEM_command(MEM_command)
	);


   // run the clock //
   always
   begin 
      #5; //clock "interval" ... AKA 1/2 the period
      clock=~clock; 
   end 

   // task to exit if there is an error //
   task exit_on_error;
   begin
      $display("@@@ Incorrect at time %4.0f", $time);
      $display("@@@ Time:%4.0f clock:%b reset:%h ", $time, clock, reset   );
      $display("ENDING TESTBENCH : ERROR !");
      $finish;
   end
   endtask


   // exit if not correct //
   always@(posedge clock)
   begin
      #2
      if(!correct)
         exit_on_error();
   end 

   // task to check correctness of the module state currently // 
   task CHECK_CORRECT;
      input [1:0] tb_state;
      begin
         if( tb_state == 2'b00 ) correct = 1;
         else                    correct = 0;
      end
   endtask

   // displays the current state of all wires //
   `define INPUT  1'b1
   `define OUTPUT 1'b0
   task DISPLAY_STATE;
      input preclock;
   begin
      if (preclock==`INPUT)
	begin
	 $display("---------------------------------------------------------------");
	 $display(">>>> Pre-Clock Input   %4.0f", $time); 
         $display("IF_addr: %h, LSQ_addr: %h, LSQ_value: %h, LSQ_valid: %h, LSQ_read: %h", 
				if_mem_req_addr, LSQ_mem_req_addr, LSQ_mem_req_value, LSQ_valid_in, LSQ_mem_read);
		 $display("MEM_value_in: %h", MEM_value_in);
      	end
      else
	begin
	 $display("");
	 $display(">>>> Pre-Clock Output %4.0f", $time); 
	 $display("IF_out: %h, IF_stall: %d", if_mem_out_value, if_stall);
	 $display("EX_out: %h, EX_tag: %h, EX_valid: %h", EX_mem_value, EX_tag_out, EX_valid_out);
      end
  endtask


   // testing segment //
   initial begin 

	$display("STARTING TESTBENCH!\n");

	// initial state //
	correct = 1;
	clock   = 0;
	reset   = 1;
	
///////////////////////////////////////////////////////
//***************************************************//
///////////////////////////////////////////////////////

        //From IF
    if_mem_req_addr = 64'h1;

		//From LSQ	
    LSQ_mem_req_addr = 64'h0000000000000100;
    LSQ_mem_req_value = 64'h0000000000001000;
    LSQ_mem_read = 1'b0;
    LSQ_tag = 5'h4;
	LSQ_valid = 1'b0;

		//From Memory
    MEM_value_in = 64'h1000000000000000;
	
///////////////////////////////////////////////////////
//***************************************************//
///////////////////////////////////////////////////////

        @(posedge clock);
        @(posedge clock);
        @(posedge clock);
			
	reset = 0;
///////////////////////////////////////////////////////
//***************************************************//
///////////////////////////////////////////////////////

        //From IF
    if_mem_req_addr = 64'h0000000000000002;

		//From LSQ	
    LSQ_mem_req_addr = 64'h0000000000000100;
    LSQ_mem_req_value = 64'h0000000000001000;
    LSQ_mem_read = 1'b0;
    LSQ_tag = 5'h2;
	LSQ_valid = 1'b0;

		//From Memory
    MEM_value_in = 64'h2000000000000000;
	
///////////////////////////////////////////////////////
//***************************************************//
///////////////////////////////////////////////////////

        @(negedge clock);
        DISPLAY_STATE(`INPUT);
        DISPLAY_STATE(`OUTPUT);
        @(posedge clock);
///////////////////////////////////////////////////////
//***************************************************//
///////////////////////////////////////////////////////

        //From IF
    if_mem_req_addr = 64'h0000000000000003;

		//From LSQ	
    LSQ_mem_req_addr = 64'h0000000000000200;
    LSQ_mem_req_value = 64'h0000000000002000;
    LSQ_mem_read = 1'b1;
    LSQ_tag = 5'h4;
	LSQ_valid = 1'b1;

		//From Memory
    MEM_value_in = 64'h3000000000000000;
	
///////////////////////////////////////////////////////
//***************************************************//
///////////////////////////////////////////////////////
	
        @(negedge clock);
        DISPLAY_STATE(`INPUT);
        DISPLAY_STATE(`OUTPUT);
        @(posedge clock);
///////////////////////////////////////////////////////
//***************************************************//
///////////////////////////////////////////////////////

        //From IF
    if_mem_req_addr = 64'h0000000000000003;

		//From LSQ	
    LSQ_mem_req_addr = 64'h0000000000000100;
    LSQ_mem_req_value = 64'h0000000000001000;
    LSQ_mem_read = 1'b0;
    LSQ_tag = 5'h9;
	LSQ_valid = 1'b1;

		//From Memory
    MEM_value_in = 64'h0000000000000000;
	
///////////////////////////////////////////////////////
//***************************************************//
///////////////////////////////////////////////////////
		
        @(negedge clock);
        DISPLAY_STATE(`INPUT);
        DISPLAY_STATE(`OUTPUT);
        @(posedge clock);
///////////////////////////////////////////////////////
//***************************************************//
///////////////////////////////////////////////////////

        //From IF
    if_mem_req_addr = 64'h0000000000000003;

		//From LSQ	
    LSQ_mem_req_addr = 64'h0000000000000100;
    LSQ_mem_req_value = 64'h0000000000001000;
    LSQ_mem_read = 1'b0;
    LSQ_tag = 5'h5;
	LSQ_valid = 1'b0;

		//From Memory
    MEM_value_in = 64'hfedcba9876543210;
	
///////////////////////////////////////////////////////
//***************************************************//
///////////////////////////////////////////////////////
		
        @(negedge clock);
        DISPLAY_STATE(`INPUT);
        DISPLAY_STATE(`OUTPUT);
        @(posedge clock);
///////////////////////////////////////////////////////
//***************************************************//
///////////////////////////////////////////////////////

        //From IF
    if_mem_req_addr = 64'h0000000000000004;

		//From LSQ	
    LSQ_mem_req_addr = 64'h0000000000000100;
    LSQ_mem_req_value = 64'h0000000000001000;
    LSQ_mem_read = 1'b0;
    LSQ_tag = 5'h0;
	LSQ_valid = 1'b0;

		//From Memory
    MEM_value_in = 64'h3000000000000000;
	
///////////////////////////////////////////////////////
//***************************************************//
///////////////////////////////////////////////////////
	
        @(negedge clock);
        DISPLAY_STATE(`INPUT);
        DISPLAY_STATE(`OUTPUT);
		@(posedge clock);
		
	// SUCCESSFULLY END TESTBENCH //
	$display("ENDING TESTBENCH : SUCCESS !\n");
	$finish;
	
   end

endmodule


