

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

   reg inst1_valid_in;
   reg inst2_valid_in;
   reg [4:0]  inst1_dest_in;
   reg [4:0]  inst2_dest_in;

   reg [7:0] inst1_rega_tag_in;
   reg [7:0] inst1_regb_tag_in;
   reg [7:0] inst2_rega_tag_in;
   reg [7:0] inst2_regb_tag_in;

   reg [7:0]  cdb1_tag_in;
   reg [7:0]  cdb2_tag_in;
   reg [63:0] cdb1_value_in;
   reg [63:0] cdb2_value_in;

   // outputs //
   wire [7:0] inst1_tag_out;
   wire [7:0] inst2_tag_out;

   wire [63:0] inst1_rega_value_out;
   wire [63:0] inst1_regb_value_out;
   wire [63:0] inst2_rega_value_out;
   wire [63:0] inst2_regb_value_out;

   wire [4:0]  inst1_dest_out;
   wire [63:0] inst1_value_out;
   wire [4:0]  inst2_dest_out;
   wire [63:0] inst2_value_out;

   wire rob_full,rob_empty;

   
   // module to be tested //	
   reorder_buffer rob ( .clock(clock), .reset(reset),

      .inst1_valid_in(inst1_valid_in),
      .inst1_dest_in(inst1_dest_in),

      .inst2_valid_in(inst2_valid_in),
      .inst2_dest_in(inst2_dest_in),

      // tags for reading from the rs //
      .inst1_rega_tag_in(inst1_rega_tag_in),
      .inst1_regb_tag_in(inst1_regb_tag_in),
      .inst2_rega_tag_in(inst2_rega_tag_in),
      .inst2_regb_tag_in(inst2_regb_tag_in),

      // cdb inputs //
      .cdb1_tag_in(cdb1_tag_in),
      .cdb1_value_in(cdb1_value_in),
      .cdb2_tag_in(cdb2_tag_in),
      .cdb2_value_in(cdb2_value_in),

      // outputs //
      .inst1_tag_out(inst1_tag_out),
      .inst2_tag_out(inst2_tag_out),

      // values out to the rs //
      .inst1_rega_value_out(inst1_rega_value_out),
      .inst1_regb_value_out(inst1_regb_value_out),
      .inst2_rega_value_out(inst2_rega_value_out),
      .inst2_regb_value_out(inst2_regb_value_out),

      // outputs to write directly to the reg file //
      .inst1_dest_out(inst1_dest_out),  
	  .inst1_value_out(inst1_value_out),
      .inst2_dest_out(inst2_dest_out),  
	  .inst2_value_out(inst2_value_out),

      // signals out //
      .rob_full(rob_full), .rob_empty(rob_empty)
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
         $display("  preclock: reset=%b i1_tag_o=%b i2_tag_o=%b rob_full=%b rob_empty=%b", reset,inst1_tag_out,inst2_tag_out,rob_full,rob_empty);
         $display("   i1_dest_o=%b i1_value_o=%h i2_dest_o=%b i2_value_o=%h", inst1_dest_out,inst1_value_out,inst2_dest_out,inst2_value_out);
      end
      else
      begin
         $display(" postclock: reset=%b i1_tag_o=%b i2_tag_o=%b rob_full=%b rob_empty=%b", reset,inst1_tag_out,inst2_tag_out,rob_full,rob_empty);
         $display("   i1_dest_o=%b i1_value_o=%h i2_dest_o=%b i2_value_o=%h", inst1_dest_out,inst1_value_out,inst2_dest_out,inst2_value_out);
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
	
   inst1_valid_in = 1'b0;
   inst2_valid_in = 1'b0;
   inst1_dest_in  = `ZERO_REG;
   inst2_dest_in  = `ZERO_REG;

   inst1_rega_tag_in = `RSTAG_NULL;
   inst1_regb_tag_in = `RSTAG_NULL;
   inst2_rega_tag_in = `RSTAG_NULL;
   inst2_regb_tag_in = `RSTAG_NULL;

   cdb1_tag_in = `RSTAG_NULL;
   cdb2_tag_in = `RSTAG_NULL;
   cdb1_value_in = 64'd0;
   cdb2_value_in = 64'd0;


        //////////////////////
        // TRANSITION TESTS //
        //////////////////////

        // reet and check //
        $display("resetting\n");
        reset = 1;
        CLOCK_AND_DISPLAY();
	    ASSERT(~rob_full);
		
        // hold nothing and check //
        $display("holding\n");
        reset = 0;
        CLOCK_AND_DISPLAY();
        ASSERT(~rob_full);

        // dispatch two instructions and check //
        $display("inserting 2 ins'ns\n");
      inst1_valid_in = 1'b1;
      inst2_valid_in = 1'b1;
      inst1_dest_in  = 5'd1;
      inst2_dest_in  = 5'd2;
        CLOCK_AND_DISPLAY();
        ASSERT(inst1_tag_out==8'd0 && inst2_tag_out==8'd1);  // should be slotted at spots 1 and 2

        // hold //
        $display("hold\n");
		inst1_valid_in = 1'b0;
		inst2_valid_in = 1'b0;
        CLOCK_AND_DISPLAY();
        ASSERT(~rob_full);

        // put data on cdb to force retire of ins'ns //
        $display("putting data on cdb\n");
	 cdb1_tag_in = 8'd0;
	 cdb2_tag_in = 8'd1;
	 cdb1_value_in = 64'hAAAAAAAAAAAAAAAA;
	 cdb2_value_in = 64'hBBBBBBBBBBBBBBBB;
        CLOCK_AND_DISPLAY();
        ASSERT(~rob_full);
        ASSERT(inst1_dest_out==5'd1 && inst2_dest_out==5'd2 && inst1_value_out==64'hAAAAAAAAAAAAAAAA &&inst2_value_out==64'hBBBBBBBBBBBBBBBB); 
		
        // wait //
        $display("wait\n");
	 cdb1_tag_in = `RSTAG_NULL;
	 cdb2_tag_in = `RSTAG_NULL;
        CLOCK_AND_DISPLAY();
        ASSERT(~rob_full);
		
        // reset and check //
        $display("resetting\n");
        reset = 1;	
	CLOCK_AND_DISPLAY();
        ASSERT(~rob_full);
		

	// SUCCESSFULLY END TESTBENCH //
	$display("ENDING TESTBENCH : SUCCESS !\n");
	$finish;
	
   end

endmodule


