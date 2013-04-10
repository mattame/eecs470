
`define RSTAG_NULL 8'hFF

// general case testbench module //
module testbench;

	// internal wires/registers //
	reg correct;
	integer i = 0;

	// wires for testing the module //
	reg clock;
	reg reset;
        reg [4:0] inst1_rega_in;
        reg [4:0] inst1_regb_in;
        reg [4:0] inst1_dest_in;
        reg [7:0] inst1_tag_in;
        reg [4:0] inst2_rega_in;
        reg [4:0] inst2_regb_in;
        reg [4:0] inst2_dest_in;
        reg [7:0] inst2_tag_in;
        reg [31:0] clear_entries;
        reg [7:0] cdb1_tag_in;
        reg [7:0] cdb2_tag_in;
        wire [7:0] inst1_taga_out;
        wire [7:0] inst1_tagb_out;
        wire [7:0] inst2_taga_out;
        wire [7:0] inst2_tagb_out;

        // module to be tested //	
        map_table mt(.clock(clock),.reset(reset),.clear_entries(clear_entries),
                 
                 .inst1_rega_in(inst1_rega_in),
                 .inst1_regb_in(inst1_regb_in),
                 .inst1_dest_in(inst1_dest_in),
                 .inst1_tag_in(inst1_tag_in),

                 .inst2_rega_in(inst2_rega_in),
                 .inst2_regb_in(inst2_regb_in),
                 .inst2_dest_in(inst2_dest_in),
                 .inst2_tag_in(inst2_tag_in),
 
                 .cdb1_tag_in(cdb1_tag_in),
                 .cdb2_tag_in(cdb2_tag_in),                
 
                 .inst1_taga_out(inst1_taga_out),.inst1_tagb_out(inst1_tagb_out),
                 .inst2_taga_out(inst2_taga_out),.inst2_tagb_out(inst2_tagb_out)
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
   `define PRECLOCK  1'b1
   `define POSTCLOCK 1'b0
   task DISPLAY_STATE;
      input preclock;
   begin
      if (preclock==`PRECLOCK)
         $display("  preclock: reset=%b i1_taga_out=%b i1_tagb_out=%b i2_taga_out=%b i2_tagb_out=%b", reset, inst1_taga_out,inst1_tagb_out,inst2_taga_out,inst2_tagb_out);
      else
         $display(" postclock: reset=%b i1_taga_out=%b i1_tagb_out=%b i2_taga_out=%b i2_tagb_out=%b", reset, inst1_taga_out,inst1_tagb_out,inst2_taga_out,inst2_tagb_out);
   end
   endtask

   // runs the clock once and displays output before and after //
   task CLOCK_AND_DISPLAY;
   begin
      DISPLAY_STATE(`PRECLOCK);
      @(posedge clock);
      @(negedge clock);
      DISPLAY_STATE(`POSTCLOCK);
      $display("");
   end
   endtask
   
   // asserts truth of a value, exits on failure //
   task ASSERT;
   input state;
   begin
      if (~state)
	  begin
	     $display("@@@ Incorrect at time %4.0f", $time);
         $display("ENDING TESTBENCH : ERROR !");
         $finish;
      end
   end
   endtask

   // testing segment //
   initial
   begin 

	$display("STARTING TESTBENCH!\n");

	// initial state //
        correct = 1;
        clock   = 0;
        reset   = 1;
        inst1_rega_in = 5'd0;
        inst1_regb_in = 5'd0;
        inst2_rega_in = 5'd0;
        inst2_regb_in = 5'd0;
        inst1_dest_in = 5'd0;
        inst2_dest_in = 5'd0;
        inst1_tag_in = `RSTAG_NULL; 
        inst2_tag_in = `RSTAG_NULL;
        clear_entries = 32'd0;
        cdb1_tag_in = `RSTAG_NULL;
        cdb2_tag_in = `RSTAG_NULL;

		
        // TRANSITION TESTS //

		// reset //
	    $display("reset");
		reset = 1;
        CLOCK_AND_DISPLAY();
        ASSERT(inst1_taga_out==`RSTAG_NULL && inst1_tagb_out==`RSTAG_NULL && inst2_taga_out==`RSTAG_NULL && inst2_tagb_out==`RSTAG_NULL);
		
		// hold //
		$display("hold");
        reset = 0;
        CLOCK_AND_DISPLAY();
        ASSERT(inst1_taga_out==`RSTAG_NULL && inst1_tagb_out==`RSTAG_NULL && inst2_taga_out==`RSTAG_NULL && inst2_tagb_out==`RSTAG_NULL);
		
		// map reg 4 to tag 0x0A //
		$display("mapping reg 4 to 0x0A");
        inst1_dest_in   = 5'd4;
        inst1_tag_in    = 8'h0A;
        CLOCK_AND_DISPLAY();
        ASSERT(inst1_taga_out==`RSTAG_NULL && inst1_tagb_out==`RSTAG_NULL && inst2_taga_out==`RSTAG_NULL && inst2_tagb_out==`RSTAG_NULL);
      
	    // reg from recently written spot //
		$display("read from written spot");
        inst1_rega_in = 5'd4;
        CLOCK_AND_DISPLAY();
		ASSERT(inst1_taga_out==8'h0A && inst1_tagb_out==`RSTAG_NULL && inst2_taga_out==`RSTAG_NULL && inst2_tagb_out==`RSTAG_NULL);

		// read tag out on all feeds //
		$display("read tag out on all feeds");
        inst1_regb_in = 5'd4;
        inst2_rega_in = 5'd4;
        inst2_regb_in = 5'd4;
        CLOCK_AND_DISPLAY();
		ASSERT(inst1_taga_out==8'h0A && inst1_tagb_out==8'h0A && inst2_taga_out==8'h0A && inst2_tagb_out==8'h0A);

		// check forwarding when writing to reg 5 //
		$display("forwarding check - reg5");
        inst1_dest_in = 5'd4;
        inst2_dest_in = 5'd5;
        inst1_tag_in = 8'h0B;
        inst2_tag_in = 8'h0C;
        inst2_rega_in = 5'd5;
        inst2_regb_in = 5'd5;
        CLOCK_AND_DISPLAY();
		ASSERT(inst1_taga_out==8'h0B && inst1_tagb_out==8'h0B && inst2_taga_out==8'h0C && inst2_tagb_out==8'h0C);		

		// check preemption //
		$display("preemption check");
        inst1_dest_in = 5'd4;
        inst2_dest_in = 5'd4;
        inst1_tag_in = 8'h01;
        inst2_tag_in = 8'h03;
        CLOCK_AND_DISPLAY();
		ASSERT(inst1_taga_out==8'h03 && inst1_tagb_out==8'h03 && inst2_taga_out==8'h0C && inst2_tagb_out==8'h0C);
		
		// check lack of preemption when null tag on second //
        inst1_tag_in = 8'h05;
        inst2_tag_in = `RSTAG_NULL;
        CLOCK_AND_DISPLAY();
		ASSERT(inst1_taga_out==8'h05 && inst1_tagb_out==8'h05 && inst2_taga_out==8'h0C && inst2_tagb_out==8'h0C);

        // test clear functionality //
		$display("clear functionality test");
        inst1_tag_in = `RSTAG_NULL;
        inst2_tag_in = `RSTAG_NULL;
        clear_entries = 32'h00000030;   // clear tags for regs 4&5
        CLOCK_AND_DISPLAY();
        ASSERT(inst1_taga_out==`RSTAG_NULL && inst1_tagb_out==`RSTAG_NULL && inst2_taga_out==`RSTAG_NULL && inst2_tagb_out==`RSTAG_NULL);
		
        // write stuff back into map table  //
		$display("full write");
        clear_entries = 32'd0;
        inst1_dest_in = 5'd1;
        inst2_dest_in = 5'd2;
        inst1_tag_in  = 8'h01;
        inst2_tag_in  = 8'h03;
        inst1_rega_in = 5'd1;
        inst1_regb_in = 5'd1;
        inst2_rega_in = 5'd2;
        inst2_regb_in = 5'd2; 
        CLOCK_AND_DISPLAY();
		ASSERT(inst1_taga_out==8'h01 && inst1_tagb_out==8'h01 && inst2_taga_out==8'h03 && inst2_tagb_out==8'h03);

        // test ready-in-rob bit //
		$display("ready-in-ROB bit test");
        inst1_tag_in = `RSTAG_NULL;
        inst2_tag_in = `RSTAG_NULL;
        cdb1_tag_in = 8'h01;
        cdb2_tag_in = 8'h03;
        CLOCK_AND_DISPLAY();
		ASSERT(inst1_taga_out==8'h41 && inst1_tagb_out==8'h41 && inst2_taga_out==8'h43 && inst2_tagb_out==8'h43);

        // test ready-in-rob persist //
        $display("ready-in-ROB persist");
        cdb1_tag_in = `RSTAG_NULL;
        cdb2_tag_in = `RSTAG_NULL;
        CLOCK_AND_DISPLAY();
		ASSERT(inst1_taga_out==8'h41 && inst1_tagb_out==8'h41 && inst2_taga_out==8'h43 && inst2_tagb_out==8'h43);
				
		// reset //
		$display("reset test");
        reset = 1;
        CLOCK_AND_DISPLAY();
        ASSERT(inst1_taga_out==`RSTAG_NULL && inst1_tagb_out==`RSTAG_NULL && inst2_taga_out==`RSTAG_NULL && inst2_tagb_out==`RSTAG_NULL);
		
		
	// SUCCESSFULLY END TESTBENCH //
	$display("ENDING TESTBENCH : SUCCESS !\n");
	$finish;
	
   end

endmodule


