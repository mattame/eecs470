

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
        reg [7:0] waiting_taga_in, waiting_tagb_in, cdb1_tag_in, cdb2_tag_in;
        reg [63:0] rega_value_in, regb_value_in, cdb1_value_in, cdb2_value_in;
       
        reg [1:0] opa_select_in;
        reg [1:0] opb_select_in;
        reg [4:0] alu_func_in;
        reg       rd_mem_in;
        reg       wr_mem_in;
        reg       cond_branch_in;
        reg       uncond_branch_in;

        wire [1:0] opa_select_out;
        wire [1:0] opb_select_out;
        wire [4:0] alu_func_out;
        wire       rd_mem_out;
        wire       wr_mem_out;
        wire       cond_branch_out;
        wire       uncond_branch_out;
 
        wire [2:0]  status_out;
        wire [4:0]  dest_reg_out;
        wire [63:0] rega_value_out, regb_value_out;

   
        // module to be tested //	
        reservation_station_entry rs(.clock(clock), .reset(reset), .fill(fill), 

                 .dest_reg_in(dest_reg_in),
                 .waiting_taga_in(waiting_taga_in),
                 .waiting_tagb_in(waiting_tagb_in),
                 .cdb1_tag_in(cdb1_tag_in),
                 .cdb2_tag_in(cdb2_tag_in),
                 .rega_value_in(rega_value_in),
                 .regb_value_in(regb_value_in),
                 .cdb1_value_in(cdb1_value_in),
                 .cdb2_value_in(cdb2_value_in),

                 .opa_select_in(opa_select_in),
                 .opb_select_in(opb_select_in),
                 .alu_func_in(alu_func_in),
                 .rd_mem_in(rd_mem_in),
                 .wr_mem_in(wr_mem_in),
                 .cond_branch_in(cond_branch_in),
                 .uncond_branch_in(uncond_branch_in),

                 .opa_select_out(opa_select_out),
                 .opb_select_out(opb_select_out),
                 .alu_func_out(alu_func_out),
                 .rd_mem_out(rd_mem_out),
                 .wr_mem_out(wr_mem_out),
                 .cond_branch_out(cond_branch_out),
                 .uncond_branch_out(uncond_branch_out),

                 .status_out(status_out),
                 .dest_reg_out(dest_reg_out),
                 .rega_value_out(rega_value_out),
                 .regb_value_out(regb_value_out)

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
         $display("  preclock: reset=%b fill=%b status_out=%h dest_reg_out=%h rega_value_out=%h regb_value_out=%h opaselo=%b opbselo=%b aluo=%b cbo=%b ubo=%b ", reset, fill, status_out, dest_reg_out, rega_value_out, regb_value_out, opa_select_out, opb_select_out, alu_func_out, rd_mem_out, wr_mem_out, cond_branch_out, uncond_branch_out);  
      else
         $display(" postclock: reset=%b fill=%b status_out=%h dest_reg_out=%h rega_value_out=%h regb_value_out=%h opaselo=%b opbselo=%b aluo=%b cbo=%b ubo=%b ", reset, fill, status_out, dest_reg_out, rega_value_out, regb_value_out, opa_select_out, opb_select_out, alu_func_out, rd_mem_out, wr_mem_out, cond_branch_out, uncond_branch_out);
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

  dest_reg_in = 5'd0;
  waiting_taga_in = 8'd0;
  waiting_tagb_in = 8'd0;
  cdb1_tag_in = 8'd0;
  cdb2_tag_in = 8'd0;
  rega_value_in = 64'd0;
  regb_value_in = 64'd0;
  cdb1_value_in = 64'd0;
  cdb2_value_in = 64'd0;

     opa_select_in    = 2'b10;
     opb_select_in    = 2'b01;
     alu_func_in      = 5'b10101;
     rd_mem_in        = 1'b0;
     wr_mem_in        = 1'b0;
     cond_branch_in   = 1'b0;
     uncond_branch_in = 1'b0;


        // TRANSITION TESTS //

	reset = 1;

        DISPLAY_STATE(`PRECLOCK);
        @(posedge clock);
        @(negedge clock);
        DISPLAY_STATE(`POSTCLOCK);
        $display("");
        reset = 0;

        DISPLAY_STATE(`PRECLOCK);
        @(posedge clock);
        @(negedge clock);
        DISPLAY_STATE(`POSTCLOCK);
        $display("");

        dest_reg_in = 5'd2;
        waiting_taga_in = 8'hAA;
        waiting_tagb_in = 8'hBB;
        cdb1_tag_in = 8'hCD;
        fill = 1; 

        DISPLAY_STATE(`PRECLOCK);
        @(posedge clock);
        @(negedge clock);
        DISPLAY_STATE(`POSTCLOCK);
        $display("");

        fill = 0; 

        DISPLAY_STATE(`PRECLOCK);
        @(posedge clock);
        @(negedge clock);
        DISPLAY_STATE(`POSTCLOCK);
        $display("");

        cdb1_tag_in = 8'hAA;
        cdb1_value_in = 64'hDEADBEEFBAADBEEF;
        cdb2_tag_in = 8'hBB;
        cdb2_value_in = 64'hFFFFFFFFFFFFFFFF;

        DISPLAY_STATE(`PRECLOCK);
        @(posedge clock);
        @(negedge clock);
        DISPLAY_STATE(`POSTCLOCK);                 
        $display("");

        cdb1_tag_in = 8'hBB;
        cdb1_value_in = 64'hA000000AA000000A;

        DISPLAY_STATE(`PRECLOCK);
        @(posedge clock);
        @(negedge clock);
        DISPLAY_STATE(`POSTCLOCK);
        $display("");

        dest_reg_in = 5'd1;
        waiting_taga_in = 8'hFF;
        waiting_tagb_in = 8'hFF;
        cdb1_tag_in      = 8'hFF;
        cdb1_value_in    = 64'hFFFFFFFFFFFFFFFF;
        fill = 1;

        DISPLAY_STATE(`PRECLOCK);
        @(posedge clock);
        @(negedge clock);
        DISPLAY_STATE(`POSTCLOCK);
        $display("");

        DISPLAY_STATE(`PRECLOCK);
        @(posedge clock);
        @(negedge clock);
        DISPLAY_STATE(`POSTCLOCK);
        $display("");

        reset = 1;
       
        DISPLAY_STATE(`PRECLOCK);
        @(posedge clock);
        @(negedge clock);
        DISPLAY_STATE(`POSTCLOCK);
        $display("");

	// SUCCESSFULLY END TESTBENCH //
	$display("ENDING TESTBENCH : SUCCESS !\n");
	$finish;
	
   end

endmodule


