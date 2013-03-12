

// general case testbench module //
module testbench;

	// internal wires/registers //
	reg correct;
	integer i = 0;

	// wires for testing the module //
	reg clock;
	reg reset;
        reg [4:0] reg1_in,reg2_in;
        reg [7:0] tag1_in,tag2_in;
        reg write_reg1_tag,write_reg2_tag;
        wire [7:0] tag1_out,tag2_out;

        // module to be tested //	
        map_table mt(.clock(clock), .reset(reset),
                 .reg1_in(reg1_in), .reg2_in(reg2_in),
                 .tag1_in(tag1_in), .tag2_in(tag2_in),
                 .write_reg1_tag(write_reg1_tag), .write_reg2_tag(write_reg2_tag),
                 .tag1_out(tag1_out), .tag2_out(tag2_out)      );

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
         $display("  preclock: reset=%b reg1_in=%h reg2_in=%h tag1_in=%h tag2_in=%h write_reg1_tag=%b write_reg2_tag=%b tag1_out=%h tag2_out=%h ", reset, reg1_in,reg2_in,tag1_in,tag2_in,write_reg1_tag,write_reg2_tag,tag1_out,tag2_out);  
      else
         $display(" postclock: reset=%b reg1_in=%h reg2_in=%h tag1_in=%h tag2_in=%h write_reg1_tag=%b write_reg2_tag=%b tag1_out=%h tag2_out=%h ", reset, reg1_in,reg2_in,tag1_in,tag2_in,write_reg1_tag,write_reg2_tag,tag1_out,tag2_out);
   end
   endtask


   // testing segment //
   initial begin 

	$display("STARTING TESTBENCH!\n");

	// initial state //
	correct = 1;
	clock   = 0;
	reset   = 1;
	reg1_in = 5'd0;
        reg2_in = 5'd0;
        tag1_in = 8'h00;
        tag2_in = 8'h00;
        write_reg1_tag = 0;
        write_reg2_tag = 0;


        // TRANSITION TESTS //

	reset = 1;

        DISPLAY_STATE(`PRECLOCK);
        @(posedge clock);
        @(negedge clock);
        DISPLAY_STATE(`POSTCLOCK);

        reset = 0;

        DISPLAY_STATE(`PRECLOCK);
        @(posedge clock);
        @(negedge clock);
        DISPLAY_STATE(`POSTCLOCK);

        reg2_in = 5'd2;
        tag1_in = 8'hAB;
        tag2_in = 8'hCD;
        write_reg1_tag = 1;
        write_reg2_tag = 1;

        DISPLAY_STATE(`PRECLOCK);
        @(posedge clock);
        @(negedge clock);
        DISPLAY_STATE(`POSTCLOCK);

        write_reg1_tag = 0;
        write_reg2_tag = 0;

        DISPLAY_STATE(`PRECLOCK);
        @(posedge clock);
        @(negedge clock);
        DISPLAY_STATE(`POSTCLOCK);

        reg1_in = 5'd3;

        DISPLAY_STATE(`PRECLOCK);
        @(posedge clock);
        @(negedge clock);
        DISPLAY_STATE(`POSTCLOCK);                 

        tag1_in = 8'hEF;
        write_reg1_tag = 1;

        DISPLAY_STATE(`PRECLOCK);
        @(posedge clock);
        @(negedge clock);
        DISPLAY_STATE(`POSTCLOCK);

        write_reg1_tag = 0;

        DISPLAY_STATE(`PRECLOCK);
        @(posedge clock);
        @(negedge clock);
        DISPLAY_STATE(`POSTCLOCK);

        reg1_in = 5'd1;

        DISPLAY_STATE(`PRECLOCK);
        @(posedge clock);
        @(negedge clock);
        DISPLAY_STATE(`POSTCLOCK);

        reset = 1;
        write_reg1_tag = 1;
        reg1_in = 5'd3;

        DISPLAY_STATE(`PRECLOCK);
        @(posedge clock);
        @(negedge clock);
        DISPLAY_STATE(`POSTCLOCK);

	// SUCCESSFULLY END TESTBENCH //
	$display("ENDING TESTBENCH : SUCCESS !\n");
	$finish;
	
   end

endmodule


