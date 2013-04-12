// general case testbench module //
module testbench;

// internal wires/registers //
 reg correct;
 integer i = 0;

// regs for testing the module //
 reg clock;
 reg reset;
 reg [31:0]pc;
 reg [31:0]new_pc;
 reg [4:0]pht_index_in;
 reg [63:0]instruction;
 reg result;

 wire prediction;
 wire [4:0] pht_index_out;

        // module to be tested //
        branch_predictor bp(.clock(clock), .reset(reset),
                 
                 .pc(pc),
                 .pht_index_in(pht_index_in),
                 .instruction(instruction),
                 .result(result)
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
         $display(" preclock: reset=%b  prediction=%d pht_index_out=%d " , reset, prediction, pht_index_out);
      else
         $display(" postclock: reset=%b  prediction=%d pht_index_out=%d ", reset, prediction, pht_index_out);
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

   // testing segment //
   initial
   begin

$display("STARTING TESTBENCH!\n");

				// initial state //
        correct = 1;
        clock = 0;
        reset = 1;

				pc = 32'b0;
				pht_index_in = 5'b0;
				instruction = 64'b0;
				result = 0;


        // TRANSITION TESTS //
				#20
				reset = 1;

        CLOCK_AND_DISPLAY();

        reset = 0;

				CLOCK_AND_DISPLAY();
				#20
        instruction =   {6'h30,58'b0};	//br
        pht_index_in = 5'd5;
        result = 0;
				pc = 32'd1;

        CLOCK_AND_DISPLAY();
				#20
        instruction = {6'h34,58'b0};  //bsr 
        pht_index_in = 5'b1;
				result = 1;
				pc = 32'd2;

        CLOCK_AND_DISPLAY();
      	#20
        instruction = {6'h38,58'b0};	//blbc
        pht_index_in = 5'd3;
				result = 1;
				pc = 32'd3;

        CLOCK_AND_DISPLAY();
				#20
        instruction =   {6'h39,58'b0};	//beq
        pht_index_in = 5'd5;
        result = 0;
				pc = 32'd4;
				
				CLOCK_AND_DISPLAY();
				#20
        instruction =   {6'h3a,58'b0};	//blt
        pht_index_in = 5'd5;
        result = 0;
				pc = 32'd5;
				
				CLOCK_AND_DISPLAY();
				#20
        instruction =   {6'h3b,58'b0};	//ble
        pht_index_in = 5'd5;
        result = 0;
				pc = 32'd6;
				
				CLOCK_AND_DISPLAY();
				#20
        instruction =   {6'h3c,58'b0};	//blbs
        pht_index_in = 5'd5;
        result = 0;
				pc = 32'd7;
				
				CLOCK_AND_DISPLAY();
				#20
        instruction =   {6'h3d,58'b0};	//bne
        pht_index_in = 5'd5;
        result = 0;
				pc = 32'd8;
				
				CLOCK_AND_DISPLAY();
				#20
        instruction =   {6'h3e,58'b0};	//bge
        pht_index_in = 5'd5;
        result = 1;
				pc = 32'd9;
								
				CLOCK_AND_DISPLAY();
				#20
        instruction =   {6'h3f,58'b0};	//bgt
        pht_index_in = 5'd5;
        result = 0;
				pc = 32'd10;

// SUCCESSFULLY END TESTBENCH //
$display("ENDING TESTBENCH : SUCCESS !\n");
$finish;

   end

endmodule


