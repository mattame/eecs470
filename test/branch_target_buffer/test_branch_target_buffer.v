

// defines //
`define RSTAG_NULL      8'hFF     
`define ZERO_REG     5'd0
`define NUM_RSES 16

// reservation station testbench module //
module testbench;

	// internal wires/registers //
	wire correct;
	integer i = 0;

   // input regs for testing the module //
   reg clock;
   reg reset;

   reg         write_in;
   reg [63:0]  write_NPC_in;
   reg [63:0]  write_dest_in;
   reg [63:0]  NPC_in;

   wire [63:0] PPC_out;
   
        // module to be tested //	
        branch_target_buffer( .clock(clock), .reset(reset),

         .write_in(write_in),
         .write_NPC_in(write_NPC_in),
         .write_dest_in(write_dest_in),

         .NPC_in(NPC_in),
         .PPC_out(PPC_out)

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
         $display("  preclock: reset=%b PPC=%h ", reset,PPC_out );
      end
      else
      begin
         $display(" postclock: reset=%b PPC=%h ", reset,PPC_out );
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

    write_in  = 1'b0;
    write_NPC_in = 64'hDEADBEEFBAADBEEF;
    write_dest_in = 64'hAAAAAAAAAAAAAAAA;
    NPC_in = 64'd0;


        //////////////////////
        // TRANSITION TESTS //
        //////////////////////

        // reet and check //
        $display("resetting\n");
        reset = 1;
        CLOCK_AND_DISPLAY();
        ASSERT(PPC_out==64'd0);	
	
        // hold nothing and check //
        $display("holding\n");
        reset = 0;
	CLOCK_AND_DISPLAY();
        ASSERT(PPC_out==64'd0);

        // write to buffer //
        $display("writing to BTB\n");
        write_in = 1'b1;
        CLOCK_AND_DISPLAY();
        ASSERT(PPC_out==64'd0);

        // read written btb //
        $display("reading written from BTB\n");
        write_in = 1'b0;
        NPC_in = 64'h123412341234123A;
        CLOCK_AND_DISPLAY();
        ASSERT(PPC_out==64'hDEADBEEFBAADBEEF);

        // read from another (equivalent) NPC //
        $display("reading again\n");
        NPC_in = 64'hAAAAAAAAAAAAAAAA;
        CLOCK_AND_DISPLAY();
        ASSERT(PPC_out==64'hDEADBEEFBAADBEEF);

        // change while reading //
        $display("changing while reading\n");
        write_in = 1'b1;
        write_NPC_in = 64'hABCDABCDABCDABCD;
        CLOCK_AND_DISPLAY();
        ASSERT(PPC_out==64'hABCDABCDABCDABCD);   

        // read nothing //
        $display("read nothing\n");
        write_in = 1'b1;
        NPC_in = 64'hBBBBBBBBBBBBBBBB;
        CLOCK_AND_DISPLAY();
        ASSERT(PPC_out==64'd0);

        // reet and check //
        $display("resetting\n");
        reset = 1;
        CLOCK_AND_DISPLAY();
        ASSERT(PPC_out==64'd0);
		

	// SUCCESSFULLY END TESTBENCH //
	$display("ENDING TESTBENCH : SUCCESS !\n");
	$finish;
	
   end

endmodule


