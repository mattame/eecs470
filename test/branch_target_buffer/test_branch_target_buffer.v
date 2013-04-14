

// defines //
`define RSTAG_NULL      8'hFF     
`define ZERO_REG     5'd0
`define BRANCH_NONE      2'b00
`define BRANCH_TAKEN     2'b01
`define BRANCH_NOT_TAKEN 2'b10
`define BRANCH_UNUSED    2'b11


// reservation station testbench module //
module testbench;

	// internal wires/registers //
	wire correct;
	integer i = 0;

   // input regs for testing the module //
   reg clock;
   reg reset;

   reg [1:0]   inst1_result_in,inst2_result_in;
   reg [63:0]  inst1_write_NPC_in,inst2_write_NPC_in;
   reg [63:0]  inst1_write_dest_in,inst2_write_dest_in;
   reg [63:0]  inst1_NPC_in,inst2_NPC_in;

   // outputs //
   wire [63:0] inst1_PPC_out,inst2_PPC_out;
   
        // module to be tested //	
        branch_target_buffer( .clock(clock), .reset(reset),

         .inst1_result_in(inst1_result_in),.inst2_result_in(inst2_result_in),
         .inst1_write_NPC_in(inst1_write_NPC_in),.inst2_write_NPC_in(inst2_write_NPC_in),
         .inst1_write_dest_in(inst1_write_dest_in),.inst2_write_dest_in(inst2_write_dest_in),

         .inst1_NPC_in(inst1_NPC_in),.inst2_NPC_in(inst2_NPC_in),
         .inst1_PPC_out(inst1_PPC_out),.inst2_PPC_out(inst2_PPC_out)

            );


   // run the clock //
   always
   begin 
      #10; //clock "interval" ... AKA 1/2 the period
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

   // displays the current state of all wires //
   `define PRECLOCK  1'b1
   `define POSTCLOCK 1'b0
   task DISPLAY_STATE;
      input preclock;
   begin
      if (preclock==`PRECLOCK)
      begin
         $display("  preclock: reset=%b i1_PPC=%h i2_PPC=%h ", reset,inst1_PPC_out,inst2_PPC_out );
      end
      else
      begin
         $display(" postclock: reset=%b i1_PPC=%h i2_PPC=%h ", reset,inst1_PPC_out,inst2_PPC_out );
      end
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
    clock = 0;
    reset = 1;

    inst1_result_in = `BRANCH_NONE;
    inst2_result_in = `BRANCH_NONE;
    inst1_write_NPC_in = 64'hDEADBEEFBAADBEEF;
    inst2_write_NPC_in = 64'hDEADBEEFBAADBEEF;
    inst1_write_dest_in = 64'hAAAAAAAAAAAAAAAA;
    inst2_write_dest_in = 64'hAAAAAAAAAAAAAAAA;
    inst1_NPC_in = 64'd0;
    inst2_NPC_in = 64'd0;


        //////////////////////
        // TRANSITION TESTS //
        //////////////////////

        // reet and check //
        $display("resetting\n");
        reset = 1;
        CLOCK_AND_DISPLAY();
        ASSERT(inst1_PPC_out==64'd0);	
	
        // hold nothing and check //
        $display("holding\n");
        reset = 0;
	CLOCK_AND_DISPLAY();
        ASSERT(inst1_PPC_out==64'd0);

        // write to buffer //
        $display("writing to BTB\n");
        inst1_result_in = `BRANCH_TAKEN;
        CLOCK_AND_DISPLAY();
        ASSERT(inst1_PPC_out==64'd0);

        // read written btb //
        $display("reading written from BTB\n");
        inst1_result_in = `BRANCH_NONE;
        inst1_NPC_in = 64'h12341234123412EF;
        CLOCK_AND_DISPLAY();
        ASSERT(inst1_PPC_out==64'hAAAAAAAAAAAAAAAA);

        // read from another (equivalent) NPC //
        $display("reading again\n");
        inst2_NPC_in = 64'hEEEEEEEEEEEEEEEF;
        CLOCK_AND_DISPLAY();
        ASSERT(inst2_PPC_out==64'hAAAAAAAAAAAAAAAA && inst1_PPC_out==64'hAAAAAAAAAAAAAAAA);

        // change while reading //
        $display("changing while reading\n");
        inst1_result_in = `BRANCH_NOT_TAKEN;
        inst1_write_NPC_in = 64'hABCDABCDABCDABEF;
        inst1_write_dest_in = 64'hBBBBBBBBBBBBBBBB;
        CLOCK_AND_DISPLAY();
        ASSERT(inst1_PPC_out==64'hBBBBBBBBBBBBBBBB);

        // read nothing //
        $display("read nothing\n");
        inst1_result_in = `BRANCH_TAKEN;
        inst1_NPC_in = 64'hBBBBBBBBBBBBBBBB;
        CLOCK_AND_DISPLAY();
        ASSERT(inst1_PPC_out==64'd0);

        // reet and check //
        $display("resetting\n");
        reset = 1;
        CLOCK_AND_DISPLAY();
        ASSERT(inst1_PPC_out==64'd0);
		

	// SUCCESSFULLY END TESTBENCH //
	$display("ENDING TESTBENCH : SUCCESS !\n");
	$finish;
	
   end

endmodule


