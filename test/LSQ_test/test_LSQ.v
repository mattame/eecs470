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

	reg [7:0] ROB_head_1;
	reg [7:0] ROB_head_2;

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
	reg EX_valid_1;

	reg [4:0] EX_tag_2;
	reg [63:0] value_in_2;
	reg [63:0] address_in_2;
	reg EX_valid_2;

	//From MEM
	reg [63:0] Dmem2proc_data;
	reg [3:0] Dmem2proc_tag;
	reg [3:0] Dmem2proc_response;
	
	//Outputs
	wire [4:0] tag_out;
	wire [63:0] mem_result_out;
	wire [1:0] proc2Dmem_command;
	wire [63:0] proc2Dmem_addr;
	wire [63:0] proc2Dmem_data;
	wire LSQ_IF_stall;
	wire LSQ_EX_valid;


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
			.EX_valid_1(EX_valid_1),

			.EX_tag_2(EX_tag_2),
			.value_in_2(value_in_2),
			.address_in_2(address_in_2),
			.EX_valid_2(EX_valid_2),

			//From MEM
			.Dmem2proc_data(Dmem2proc_data),
			.Dmem2proc_tag(Dmem2proc_tag),
			.Dmem2proc_response(Dmem2proc_response),
			
			//Outputs
			.tag_out(tag_out),
			.mem_result_out(mem_result_out),
			.proc2Dmem_command(proc2Dmem_command),
			.proc2Dmem_addr(proc2Dmem_addr),
			.proc2Dmem_data(proc2Dmem_data),
			.LSQ_IF_stall(LSQ_IF_stall),
			.LSQ_EX_valid(LSQ_EX_valid)
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
	 $display("EX valid 1: %b, 2: %b", EX_valid_1, EX_valid_2);
	 $display("EX tags 1: %h, 2: %h", EX_tag_1, EX_tag_2);
	 $display("EX values 1: %h, 2: %h", value_in_1, value_in_2);
	 $display("EX address 1: %h, 2: %h", address_in_1, address_in_2);
	 $display("");
	 $display("MEM response: %h, tag: %h, data: %h", Dmem2proc_response, Dmem2proc_tag, Dmem2proc_data);

      	end
      else
	begin
	 $display("");
	 $display(">>>> Pre-Clock Output %4.0f", $time); 
	 $display("Stall IF: %b", LSQ_IF_stall);
	 $display("To EX Valid: %b, Tag: %h, Data: %h", LSQ_EX_valid, tag_out, mem_result_out);
	 $display("To MEM Cmmd: %h, Addr: %h, Data: %h", proc2Dmem_command, proc2Dmem_addr, proc2Dmem_data);
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
	ROB_head_1 = 8'h04;
	ROB_head_2 = 8'h05;

	//1
	ROB_tag_1 = 5'h00;
	rd_mem_in_1 = 1'b0;
	wr_mem_in_1 = 1'b0;
	valid_in_1 = 1'b0;

	//2
	ROB_tag_2 = 5'h00;
	rd_mem_in_2 = 1'b0;
	wr_mem_in_2 = 1'b0;
	valid_in_2 = 1'b0;

	//From EX ALU
	EX_tag_1 = 5'h0;
	value_in_1 = 64'h0;
	address_in_1 = 64'h0000000000000000;
	EX_valid_1 = 1'b0;

	EX_tag_2 = 5'h0;
	value_in_2 = 64'h0;
	address_in_2 = 64'h0000000000000000;
	EX_valid_2 = 1'b0;

	//From MEM
	Dmem2proc_data = 64'h0;
	Dmem2proc_tag = 4'h0;
	Dmem2proc_response = 4'h0;


        @(posedge clock);
        @(posedge clock);
        @(posedge clock);
#1
	reset = 0;
	
	ROB_tag_1 = 5'h04;
	rd_mem_in_1 = 1'b1;
	wr_mem_in_1 = 1'b0;
	valid_in_1 = 1'b1;

	ROB_tag_2 = 5'h05;
	rd_mem_in_2 = 1'b0;
	wr_mem_in_2 = 1'b1;
	valid_in_2 = 1'b1;

        @(negedge clock);
        DISPLAY_STATE(`INPUT);
        DISPLAY_STATE(`OUTPUT);
        @(posedge clock);
#1
	ROB_tag_1 = 5'h06;
	rd_mem_in_1 = 1'b1;
	wr_mem_in_1 = 1'b0;
	valid_in_1 = 1'b1;

	ROB_tag_2 = 5'h07;
	rd_mem_in_2 = 1'b1;
	wr_mem_in_2 = 1'b0;
	valid_in_2 = 1'b1;

	
        @(negedge clock);
        DISPLAY_STATE(`INPUT);
        DISPLAY_STATE(`OUTPUT);
        @(posedge clock);
#1
	EX_tag_1 = 5'h05;
	value_in_1 = 64'h0123456789abcdef;
	address_in_1 = 64'h1111000011110000;
	EX_valid_1 = 1'b0;

	EX_tag_2 = 5'h04;
	value_in_2 = 64'hfedcba9876543210;
	address_in_2 = 64'h2222111122221111;
	EX_valid_2 = 1'b0;


        @(negedge clock);
        DISPLAY_STATE(`INPUT);
        DISPLAY_STATE(`OUTPUT);
        @(posedge clock);
#1
	EX_tag_1 = 5'h05;
	value_in_1 = 64'h0123456789abcdef;
	address_in_1 = 64'h1111000011110000;
	EX_valid_1 = 1'b1;

	EX_tag_2 = 5'h04;
	value_in_2 = 64'hfedcba9876543210;
	address_in_2 = 64'h2222111122221111;
	EX_valid_2 = 1'b1;
	
        @(negedge clock);
        DISPLAY_STATE(`INPUT);
        DISPLAY_STATE(`OUTPUT);
        @(posedge clock);
#1

	EX_tag_1 = 5'h05;
	value_in_1 = 64'h0123456789abcdef;
	address_in_1 = 64'h1111000011110000;
	EX_valid_1 = 1'b0;

	EX_tag_2 = 5'h04;
	value_in_2 = 64'hfedcba9876543210;
	address_in_2 = 64'h2222111122221111;
	EX_valid_2 = 1'b0;

	Dmem2proc_response = 4'h7;
	
        @(negedge clock);
        DISPLAY_STATE(`INPUT);
        DISPLAY_STATE(`OUTPUT);
		@(posedge clock);
#1		
	Dmem2proc_response = 4'h0;

	Dmem2proc_data = 64'h1234123443214321;
	Dmem2proc_tag = 4'h7;
	
        @(negedge clock);
        DISPLAY_STATE(`INPUT);
        DISPLAY_STATE(`OUTPUT);
		@(posedge clock);
#1
		
	Dmem2proc_tag = 4'h0;
		@(negedge clock);
        DISPLAY_STATE(`INPUT);
        DISPLAY_STATE(`OUTPUT);
		@(posedge clock);
#1
	
	Dmem2proc_response = 4'h2;
	
		@(negedge clock);
        DISPLAY_STATE(`INPUT);
        DISPLAY_STATE(`OUTPUT);
		@(posedge clock);
	
#1
	Dmem2proc_response = 4'h0;
	
	Dmem2proc_tag = 4'h2;
	
	Dmem2proc_data = 64'habcdeeffabcdeeff;
	
		@(negedge clock);
        DISPLAY_STATE(`INPUT);
        DISPLAY_STATE(`OUTPUT);
		@(posedge clock);
	
#1
	Dmem2proc_tag = 4'h0;

		@(negedge clock);
        DISPLAY_STATE(`INPUT);
        DISPLAY_STATE(`OUTPUT);
		@(posedge clock);
	
#1
	$display("**-----------------------------------------------------------**");
	// SUCCESSFULLY END TESTBENCH //
	$display("ENDING TESTBENCH : SUCCESS !\n");
	$finish;
	
   end

endmodule


