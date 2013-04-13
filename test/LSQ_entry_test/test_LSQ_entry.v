`timescale 1ns/100ps


// reservation station testbench module //
module testbench;

	// internal wires/registers //
	reg correct;
	integer i = 0;

	// wires for testing the module //
	reg clock;
	reg reset;

	reg [4:0] ROB_head_1;
	reg [4:0] ROB_head_2;

	reg [4:0] LSQ_head;

	reg clear;

	reg [4:0] ROB_tag_1;
	reg rd_mem_in_1;
	reg store_ROB_1;

	reg [63:0] addr_in_1;
	reg [63:0] value_in_1;
	reg  [4:0] EX_tag_1;
	reg EX_valid_1;

	reg [4:0] ROB_tag_2;
	reg rd_mem_in_2;
	reg store_ROB_2;

	reg [63:0] addr_in_2;
	reg [63:0] value_in_2;
	reg  [4:0] EX_tag_2;
	reg EX_valid_2;
	
 //Outputs
	wire  [4:0] stored_tag_out;
	wire [63:0] stored_address_out;
	wire [63:0] stored_value_out;
	wire read_out;
	wire complete;


        // module to be tested //	
LSQ_entry ent0(//Inputs
			.clock(clock),
			.reset(reset),

			.ROB_head_1(ROB_head_1),
			.ROB_head_2(ROB_head_2),

			.LSQ_head(LSQ_head),

			.clear(clear),

			.ROB_tag_1(ROB_tag_1),
			.rd_mem_in_1(rd_mem_in_1),
			.store_ROB_1(store_ROB_1),

			.addr_in_1(addr_in_1),
			.value_in_1(value_in_1),
			.EX_tag_1(EX_tag_1),
			.EX_valid_1(EX_valid_1),

			.ROB_tag_2(ROB_tag_2),
			.rd_mem_in_2(rd_mem_in_2),
			.store_ROB_2(store_ROB_2),

			.addr_in_2(addr_in_2),
			.value_in_2(value_in_2),
			.EX_tag_2(EX_tag_2),
			.EX_valid_2(EX_valid_2),

		 //Outputs
			.stored_tag_out(stored_tag_out),
			.stored_address_out(stored_address_out),
			.stored_value_out(stored_value_out),
			.read_out(read_out),
			.complete_out(complete)
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
	 $display("**-----------------------------------------------------------**");
	 $display(">>>> Pre-Clock Input   %4.0f", $time); 
	 $display("ROB heads 1: %h, 2: %h", ROB_head_1, ROB_head_2);
	 $display("LSQ head: %h", LSQ_head);
	 $display("ROB tags 1: %h, 2: %h", ROB_tag_1, ROB_tag_2);
	 $display("clear: %b, read1: %b, store1: %b, read2: %b, store2: %b",
				clear, rd_mem_in_1, store_ROB_1, rd_mem_in_2, store_ROB_2);
	 $display("");
	 $display("EX tags 1:%h, 2: %h   Valids 1: %b, 2: %b", EX_tag_1, EX_tag_2, EX_valid_1, EX_tag_2);
	 $display("Addrs in 1: %h, 2: %h", addr_in_1, addr_in_2);
	 $display("Values in 1: %h, 2: %h", value_in_1, value_in_2);
      	end
      else
	begin
	 $display("");
	 $display("");
	 $display(">>>> Post-Clock Output %4.0f", $time); 
	 $display("Tag: %h, Address: %h\n Value: %h, Read: %b, Complete: %b", 
				stored_tag_out, stored_address_out, stored_value_out, read_out, complete);
	end
      end
  endtask


   // testing segment //
   initial begin 

	$display("STARTING TESTBENCH!\n");

	// initial state //
	correct = 1;
	clock   = 0;
	reset   = 1;


        // TRANSITION TESTS //
	ROB_head_1 = 5'h0;
	ROB_head_2 = 5'h0;

	LSQ_head = 5'h0;

	clear = 1'b0;

	ROB_tag_1 = 5'h0;
	rd_mem_in_1 = 1'b0;
	store_ROB_1 = 1'b0;

	addr_in_1 = 64'h0;
	value_in_1 = 64'h0;
	EX_tag_1 = 5'h0;
	EX_valid_1 = 1'b0;

	ROB_tag_2 = 5'h0;
	rd_mem_in_2 = 1'b0;
	store_ROB_2 = 1'b0;

	addr_in_2 = 64'h0;
	value_in_2 = 64'h0;
	EX_tag_2 = 5'h0;
	EX_valid_2 = 1'b0;


        @(posedge clock);
        @(posedge clock);
        @(posedge clock);

		//Take in a tag
    ROB_head_1 = 5'h0;
	ROB_head_2 = 5'h0;

	LSQ_head = 5'h0;

	clear = 1'b0;

	ROB_tag_1 = 5'h4;
	rd_mem_in_1 = 1'b1;
	store_ROB_1 = 1'b1;

	addr_in_1 = 64'h0;
	value_in_1 = 64'h0;
	EX_tag_1 = 5'h0;
	EX_valid_1 = 1'b0;

	ROB_tag_2 = 5'h1;
	rd_mem_in_2 = 1'b0;
	store_ROB_2 = 1'b0;

	addr_in_2 = 64'h0;
	value_in_2 = 64'h0;
	EX_tag_2 = 5'h0;
	EX_valid_2 = 1'b0;
			
			
	reset = 0;


        DISPLAY_STATE(`INPUT);
        @(posedge clock);
        @(negedge clock);
        DISPLAY_STATE(`OUTPUT);
		
	ROB_head_1 = 5'h0;
	ROB_head_2 = 5'h0;

	LSQ_head = 5'h0;

	clear = 1'b0;

	ROB_tag_1 = 5'h0;
	rd_mem_in_1 = 1'b0;
	store_ROB_1 = 1'b0;

	addr_in_1 = 64'hffffffffffffffff;
	value_in_1 = 64'hffffffffffffffff;
	EX_tag_1 = 5'h0;
	EX_valid_1 = 1'b1;

	ROB_tag_2 = 5'h1;
	rd_mem_in_2 = 1'b0;
	store_ROB_2 = 1'b0;

	addr_in_2 = 64'h0;
	value_in_2 = 64'h0;
	EX_tag_2 = 5'h0;
	EX_valid_2 = 1'b0;


        DISPLAY_STATE(`INPUT);
        @(posedge clock);
        @(negedge clock);
        DISPLAY_STATE(`OUTPUT);
		
	ROB_head_1 = 5'h0;
	ROB_head_2 = 5'h0;

	LSQ_head = 5'h4;

	clear = 1'b0;

	ROB_tag_1 = 5'h0;
	rd_mem_in_1 = 1'b0;
	store_ROB_1 = 1'b0;

	addr_in_1 = 64'hffffffffffffffff;
	value_in_1 = 64'hffffffffffffffff;
	EX_tag_1 = 5'h4;
	EX_valid_1 = 1'b1;

	ROB_tag_2 = 5'h1;
	rd_mem_in_2 = 1'b0;
	store_ROB_2 = 1'b0;

	addr_in_2 = 64'h0;
	value_in_2 = 64'h0;
	EX_tag_2 = 5'h0;
	EX_valid_2 = 1'b0;

	
        DISPLAY_STATE(`INPUT);
        @(posedge clock);
        @(negedge clock);
        DISPLAY_STATE(`OUTPUT);
		
	ROB_head_1 = 5'h0;
	ROB_head_2 = 5'h4;

	LSQ_head = 5'h4;

	clear = 1'b0;

	ROB_tag_1 = 5'h0;
	rd_mem_in_1 = 1'b0;
	store_ROB_1 = 1'b0;

	addr_in_1 = 64'hffffffffffffffff;
	value_in_1 = 64'hffffffffffffffff;
	EX_tag_1 = 5'h4;
	EX_valid_1 = 1'b1;

	ROB_tag_2 = 5'h1;
	rd_mem_in_2 = 1'b0;
	store_ROB_2 = 1'b0;

	addr_in_2 = 64'h0;
	value_in_2 = 64'h0;
	EX_tag_2 = 5'h0;
	EX_valid_2 = 1'b0;	

        DISPLAY_STATE(`INPUT);
        @(posedge clock);
        @(negedge clock);
        DISPLAY_STATE(`OUTPUT);
		
		
	ROB_head_1 = 5'h0;
	ROB_head_2 = 5'h0;

	LSQ_head = 5'h0;

	clear = 1'b1;

	ROB_tag_1 = 5'h0;
	rd_mem_in_1 = 1'b0;
	store_ROB_1 = 1'b0;

	addr_in_1 = 64'h0;
	value_in_1 = 64'h0;
	EX_tag_1 = 5'h0;
	EX_valid_1 = 1'b0;

	ROB_tag_2 = 5'h1;
	rd_mem_in_2 = 1'b0;
	store_ROB_2 = 1'b0;

	addr_in_2 = 64'h0;
	value_in_2 = 64'h0;
	EX_tag_2 = 5'h0;
	EX_valid_2 = 1'b0;

        DISPLAY_STATE(`INPUT);
        @(posedge clock);
        @(negedge clock);
        DISPLAY_STATE(`OUTPUT);
		
		
	ROB_head_1 = 5'h0;
	ROB_head_2 = 5'h0;

	LSQ_head = 5'h0;

	clear = 1'b0;

	ROB_tag_1 = 5'h3;
	rd_mem_in_1 = 1'b0;
	store_ROB_1 = 1'b1;

	addr_in_1 = 64'h123456789abcdef0;
	value_in_1 = 64'hffffffffffff1234;
	EX_tag_1 = 5'h3;
	EX_valid_1 = 1'b1;

	ROB_tag_2 = 5'h1;
	rd_mem_in_2 = 1'b0;
	store_ROB_2 = 1'b0;

	addr_in_2 = 64'h0;
	value_in_2 = 64'h0;
	EX_tag_2 = 5'h0;
	EX_valid_2 = 1'b0;


        DISPLAY_STATE(`INPUT);
        @(posedge clock);
        @(negedge clock);
        DISPLAY_STATE(`OUTPUT);
	
		
	// SUCCESSFULLY END TESTBENCH //
	$display("ENDING TESTBENCH : SUCCESS !\n");
	$finish;
	
   end

endmodule


