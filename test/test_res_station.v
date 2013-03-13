

// reservation station testbench module //
module testbench;

	// internal wires/registers //
	reg correct;
	integer i = 0;

	// wires for testing the module //
	reg clock;
	reg reset;
	reg fill;
        reg [4:0] dest_reg_in;
        reg [7:0] waiting_taga_in, waiting_tagb_in, cdb_tag_in;
        reg [63:0] rega_value_in, regb_value_in, cdb_value_in;
        
        wire [2:0]  status_out;
        wire [4:0]  dest_reg_out;
        wire [63:0] rega_value_out, regb_value_out;

   
        // module to be tested //	
        reservation_station rs(.clock(clock), .reset(reset), .fill(fill), 
                 .dest_reg_in(dest_reg_in), .waiting_taga_in(waiting_taga_in),
                 .waiting_tagb_in(waiting_tagb_in), .cdb_tag_in(cdb_tag_in), .rega_value_in(rega_value_in),
                 .regb_value_in(regb_value_in), .cdb_value_in(cdb_value_in), .status_out(status_out), .dest_reg_out(dest_reg_out), .rega_value_out(rega_value_out),
                 .regb_value_out(regb_value_out)      );


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
         $display("  preclock: reset=%b fill=%b dest_reg_in=%h waiting_taga_in=%h waiting_tagb_in=%h cdb_tag_in=%h rega_value_in=%b regb_value_in=%b cdb_value_in=%h status_out=%h dest_reg_out=%h rega_value_out=%h regb_value_out=%h ", reset,
         fill,dest_reg_in,waiting_taga_in,waiting_tagb_in,cdb_tag_in,rega_value_in,regb_value_in, cdb_value_in, status_out, dest_reg_out, rega_value_out, regb_value_out);  
      else
         $display(" postclock: reset=%b fill=%b dest_reg_in=%h waiting_taga_in=%h waiting_tagb_in=%h cdb_tag_in=%h rega_value_in=%b regb_value_in=%b cdb_value_in=%h status_out=%h dest_reg_out=%h rega_value_out=%h regb_value_out=%h ", reset,
         fill,dest_reg_in,waiting_taga_in,waiting_tagb_in,cdb_tag_in,rega_value_in,regb_value_in, cdb_value_in, status_out, dest_reg_out, rega_value_out, regb_value_out);  
   end
   endtask


   // testing segment //
   initial begin 

	$display("STARTING TESTBENCH!\n");

	// initial state //
	correct = 1;
	clock   = 0;
	reset   = 1;
	fill    = 0;
  dest_reg_in = 5'b0;
  waiting_taga_in, waiting_tagb_in, cdb_tag_in = 8'b0;
  rega_value_in, regb_value_in, cdb_value_in = 64'b0;


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

        dest_reg_in = 5'd2;
        waiting_taga_in, waiting_tagb_in = 8'hAB;
        cdb_tag_in = 8'hCD;
        

        DISPLAY_STATE(`PRECLOCK);
        @(posedge clock);
        @(negedge clock);
        DISPLAY_STATE(`POSTCLOCK);

        

        DISPLAY_STATE(`PRECLOCK);
        @(posedge clock);
        @(negedge clock);
        DISPLAY_STATE(`POSTCLOCK);

        dest_reg_in = 5'd3;

        DISPLAY_STATE(`PRECLOCK);
        @(posedge clock);
        @(negedge clock);
        DISPLAY_STATE(`POSTCLOCK);                 

        waiting_taga_in = 8'hEF;
     

        DISPLAY_STATE(`PRECLOCK);
        @(posedge clock);
        @(negedge clock);
        DISPLAY_STATE(`POSTCLOCK);

        

        DISPLAY_STATE(`PRECLOCK);
        @(posedge clock);
        @(negedge clock);
        DISPLAY_STATE(`POSTCLOCK);

        dest_reg_in = 5'd1;

        DISPLAY_STATE(`PRECLOCK);
        @(posedge clock);
        @(negedge clock);
        DISPLAY_STATE(`POSTCLOCK);

        reset = 1;
       
        dest_reg_in = 5'd3;

        DISPLAY_STATE(`PRECLOCK);
        @(posedge clock);
        @(negedge clock);
        DISPLAY_STATE(`POSTCLOCK);

	// SUCCESSFULLY END TESTBENCH //
	$display("ENDING TESTBENCH : SUCCESS !\n");
	$finish;
	
   end

endmodule


