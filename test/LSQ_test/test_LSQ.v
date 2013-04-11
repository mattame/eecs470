`timescale 1ns/100ps


// reservation station testbench module //
module testbench;

	// internal wires/registers //
	reg correct;
	integer i = 0;

	// wires for testing the module //
	reg clock;
	reg reset;
			//From ROB/ID

	reg [4:0] ROB_head_1;
	reg [4:0] ROB_head_2;

			//1
	reg [4:0] ROB_tag_1;
	reg rd_mem_in_1;
	reg wr_mem_in_1;
	reg valid_in_1;

			//2
	reg [4:0] ROB_tag_2;
	reg rd_mem_in_2;
	reg wr_mem_in_2;
	reg valid_in_2;

			//From EX ALU
	reg [4:0] EX_tag_1;
	reg [63:0] value_in_1;
	reg [63:0] address_in_1;

	reg [4:0] EX_tag_2;
	reg [63:0] value_in_2;
	reg [63:0] address_in_2;

			//Outputs
	wire [4:0] tag_out;
	wire [63:0] address_out;
	wire [63:0] value_out;
	wire read_out;
	wire valid_out;

	wire stall;


        // module to be tested //	
LSQ lsqueue(//Inputs
			.clock(clock),
			.reset(reset),
			//From ROB/ID

			.ROB_head_1(ROB_head_1),
			.ROB_head_2(ROB_head_2),

			//1
			.ROB_tag_1(ROB_tag_1),
			.rd_mem_in_1(rd_mem_in_1),
			.wr_mem_in_1(wr_mem_in_1),
			.valid_in_1(valid_in_1),

			//2
			.ROB_tag_2(ROB_tag_2),
			.rd_mem_in_2(rd_mem_in_2),
			.wr_mem_in_2(wr_mem_in_2),
			.valid_in_2(valid_in_2),

			//From EX ALU
			.EX_tag_1(EX_tag_1),
			.value_in_1(value_in_1),
			.address_in_1(address_in_1),

			.EX_tag_2(EX_tag_2),
			.value_in_2(value_in_2),
			.address_in_2(address_in_2),

			//Outputs
			.tag_out(tag_out),
			.address_out(address_out),
			.value_out(value_out),
			.read_out(read_out),
			.valid_out(valid_out),

			.stall(stall)
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
	 $display("ROB tags  1: %h, 2: %h", ROB_tag_1, ROB_tag_2);
	 $display("R/W in 1: %b  %b,  2: %b  %b",rd_mem_in_1, wr_mem_in_1, rd_mem_in_2, wr_mem_in_2);
	 $display("Valids in 1: %b, 2: %b", valid_in_1, valid_in_2);
	 $display("");
	 $display("EX tags 1: %h, 2: %h", EX_tag_1, EX_tag_2);
	 $display("EX values 1: %h, 2: %h", value_in_1, value_in_2);
	 $display("EX address 1: %h, 2: %h", address_in_1, address_in_2);

      	end
      else
	begin
	 $display("");
	 $display(">>>> Pre-Clock Output %4.0f", $time); 
	 $display("Tag: %h, Address: %h, Value: %h",tag_out, address_out, value_out);
	 $display("Read: %h, Valid: %b", read_out, valid_out);
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
	ROB_head_1 = 4'h0;
	ROB_head_2 = 4'h0;
			//1
	ROB_tag_1 = 4'h0;
	rd_mem_in_1 = 1'b0;
	wr_mem_in_1 = 1'b0;
	valid_in_1 = 1'b0;
			//2
	ROB_tag_2 = 4'h0;
	rd_mem_in_2 = 1'b0;
	wr_mem_in_2 = 1'b0;
	valid_in_2 = 1'b0;
			//From EX ALU
	EX_tag_1 = 4'h0;
	value_in_1 = 64'h0;
	address_in_1 = 64'h0;
	EX_tag_2 = 4'h0;
	value_in_2 = 64'h0;
	address_in_2 = 64'h0;


        @(posedge clock);
        @(posedge clock);
        @(posedge clock);
			
	reset = 0;
// two loads being added

	ROB_head_1 = 4'h0;
	ROB_head_2 = 4'h1;
			//1
	ROB_tag_1 = 4'h0;
	rd_mem_in_1 = 1'b0;
	wr_mem_in_1 = 1'b1;
	valid_in_1 = 1'b1;
			//2
	ROB_tag_2 = 4'h1;
	rd_mem_in_2 = 1'b0;
	wr_mem_in_2 = 1'b1;
	valid_in_2 = 1'b1;
			//From EX ALU
	EX_tag_1 = 4'h0;
	value_in_1 = 64'h0;
	address_in_1 = 64'h0;
	EX_tag_2 = 4'h0;
	value_in_2 = 64'h0;
	address_in_2 = 64'h0;

        @(negedge clock);
        DISPLAY_STATE(`INPUT);
        DISPLAY_STATE(`OUTPUT);
        @(posedge clock);

// No loads or stores added, but the 

	ROB_head_1 = 4'h0;
	ROB_head_2 = 4'h1;
			//1
	ROB_tag_1 = 4'h2;
	rd_mem_in_1 = 1'b0;
	wr_mem_in_1 = 1'b0;
	valid_in_1 = 1'b0;
			//2
	ROB_tag_2 = 4'h3;
	rd_mem_in_2 = 1'b0;
	wr_mem_in_2 = 1'b0;
	valid_in_2 = 1'b0;
			//From EX ALU
	EX_tag_1 = 4'h0;
	value_in_1 = 64'h0;
	address_in_1 = 64'h100;
	EX_tag_2 = 4'h1;
	value_in_2 = 64'h0;
	address_in_2 = 64'h200;
	
        @(negedge clock);
        DISPLAY_STATE(`INPUT);
        DISPLAY_STATE(`OUTPUT);
        @(posedge clock);

// store added

	ROB_head_1 = 4'h2;
	ROB_head_2 = 4'h3;
			//1
	ROB_tag_1 = 4'h4;
	rd_mem_in_1 = 1'b0;
	wr_mem_in_1 = 1'b1;
	valid_in_1 = 1'b0;
			//2
	ROB_tag_2 = 4'h5;
	rd_mem_in_2 = 1'b0;
	wr_mem_in_2 = 1'b1;
	valid_in_2 = 1'b0;
			//From EX ALU
	EX_tag_1 = 4'h0;
	value_in_1 = 64'h0;
	address_in_1 = 64'h100;
	EX_tag_2 = 4'h1;
	value_in_2 = 64'h0;
	address_in_2 = 64'h200;

        @(negedge clock);
        DISPLAY_STATE(`INPUT);
        DISPLAY_STATE(`OUTPUT);
        @(posedge clock);

		
        @(negedge clock);
        DISPLAY_STATE(`INPUT);
        DISPLAY_STATE(`OUTPUT);
        @(posedge clock);

	
        @(negedge clock);
        DISPLAY_STATE(`INPUT);
        DISPLAY_STATE(`OUTPUT);
		@(posedge clock);
		
	// SUCCESSFULLY END TESTBENCH //
	$display("ENDING TESTBENCH : SUCCESS !\n");
	$finish;
	
   end

endmodule


