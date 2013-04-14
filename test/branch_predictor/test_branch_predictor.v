
`define HISTORY_BITS 8
`define BRANCH_NONE      2'b00
`define BRANCH_TAKEN     2'b01
`define BRANCH_NOT_TAKEN 2'b10
`define BRANCH_UNUSED    2'b11

// general case testbench module //
module testbench;


// internal wires/registers //
 reg correct;
 integer i = 0;

// regs for testing the module //
 reg clock;
 reg reset;

   reg [63:0] inst1_PC_in,inst2_PC_in;

   reg [1:0]                 inst1_result_in,inst2_result_in;
   reg [(`HISTORY_BITS-1):0] inst1_pht_index_in,inst2_pht_index_in;

   wire inst1_prediciton_out,inst2_prediction_out;
   wire [(`HISTORY_BITS-1):0] inst1_pht_index_out,inst2_pht_index_out;

   wire [(`HISTORY_BITS-1):0]     ghr;
   
        // module to be tested //
        branch_predictor bp(
                          .clock(clock), .reset(reset),
    
                          // pc of instruction in //
                          .inst1_PC_in(inst1_PC_in),
                          .inst2_PC_in(inst2_PC_in),

			  // for writing back the history after the branch is evaluated //
                          .inst1_result_in(inst1_result_in),
                          .inst1_pht_index_in(inst1_pht_index_in),
                          .inst2_result_in(inst2_result_in),
                          .inst2_pht_index_in(inst2_pht_index_in),                        
 
                          // output prediction and index //
                          .inst1_prediction_out(inst1_prediction_out),
                          .inst1_pht_index_out(inst1_pht_index_out),
                          .inst2_prediction_out(inst2_prediction_out),
                          .inst2_pht_index_out(inst2_pht_index_out),

                          .ghr(ghr)

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
      $display("@@@ Time:%4.0f clock:%b reset:%h ", $time, clock, reset );
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
         else correct = 0;
      end
   endtask


   // displays the current state of all wires //
`define PRECLOCK 1'b1
`define POSTCLOCK 1'b0
   task DISPLAY_STATE;
      input preclock;
   begin
      if (preclock==`PRECLOCK)
         $display("  preclock: reset=%b  prediction1=%b pht_index_out1=%d prediction2=%b pht_index_out2=%d ghr=%b " , reset, inst1_prediction_out, inst1_pht_index_out,inst2_prediction_out,inst2_pht_index_out,ghr);
      else
         $display(" postclock: reset=%b  prediction1=%b pht_index_out1=%d prediction2=%b pht_index_out2=%d ghr=%b " , reset, inst1_prediction_out, inst1_pht_index_out,inst2_prediction_out,inst2_pht_index_out,ghr);
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
        clock = 0;
        reset = 1;

        inst1_PC_in=64'd0;
	inst2_PC_in=64'd0;

        inst1_result_in=`BRANCH_NONE;
	inst2_result_in=`BRANCH_NONE;
	
        inst1_pht_index_in = 8'd0;
	inst2_pht_index_in = 8'd0;


        // TRANSITION TESTS //

	reset = 1;
        CLOCK_AND_DISPLAY();
        ASSERT(inst1_prediction_out==1'b0 && inst2_prediction_out==1'b0);
	
        reset = 0;
        inst1_result_in = `BRANCH_TAKEN;
	inst1_pht_index_in = 8'd0;
	CLOCK_AND_DISPLAY();
	ASSERT(inst1_pht_index_out==8'd1);

        inst1_result_in = `BRANCH_NONE;	
	inst1_PC_in = 64'd1;
        CLOCK_AND_DISPLAY();
	ASSERT(inst1_pht_index_out==8'd0 && inst1_prediciton_out==1'b1);
	

// SUCCESSFULLY END TESTBENCH //
$display("ENDING TESTBENCH : SUCCESS !\n");
$finish;

   end

endmodule

