

// reservation station testbench module //
module testbench;

	// internal wires/registers //
	reg correct;
	integer i = 0;

	// wires for testing the module //
	reg clock;
	reg reset;
		//bus 1
	wire id_ex_NPC_1;
	wire id_ex_IR_1;
	wire id_ex_dest_reg_1;
        wire id_ex_rega_1;
        wire id_ex_regb_1;
        wire id_ex_opa_select_1;
        wire id_ex_opb_select_1;
	wire id_ex_alu_func_1;
        wire id_ex_cond_branch;
        wire id_ex_uncond_branch;
		//bus 2
	wire id_ex_NPC_2;
	wire id_ex_IR_2;
	wire id_ex_dest_reg_2;
	wire id_ex_rega_2;
	wire id_ex_regb_2;
	wire id_ex_opa_select_2;
	wire id_ex_opb_select_2;
	wire id_ex_alu_func_2;

	wire ex_take_branch_out;
		// ALU 1 Bus
	wire ex_alu_result_out_1;
	wire ex_alu_valid_out_1;
		// ALU 2 Bus
	wire ex_alu_result_out_2;
	wire ex_alu_valid_out_2;
		// Multiplier 1 Bus
	wire ex_mult_IR_out_1;
	wire ex_mult_NPC_out_1;
	wire ex_mult_dest_reg_out_1;
	wire ex_mult_result_out_1;
	wire ex_mult_valid_out_1;
		// Multiplier 2 Bus
	wire ex_mult_IR_out_2;
	wire ex_mult_NPC_out_2;
	wire ex_mult_dest_reg_out_2;
	wire ex_mult_result_out_2;
	wire ex_mult_valid_out_2;

        // module to be tested //	
        ex_stage ex_0(	// Inputs
                		.clock(clock),
                		.reset(reset),
			// Input Bus 1 (contains branch logic)
        		        .id_ex_NPC_1(id_ex_NPC_1),
        		        .id_ex_IR_1(id_ex_IR_1),
				.id_ex_dest_reg_1(id_ex_dest_reg_1),
        		        .id_ex_rega_1(id_ex_rega_1),
        		        .id_ex_regb_1(id_ex_regb_1),
        		        .id_ex_opa_select_1(id_ex_opa_select_1),
        		        .id_ex_opb_select_1(id_ex_opb_select_1),
                		.id_ex_alu_func_1(id_ex_alu_func_1),
           		        .id_ex_cond_branch(id_ex_cond_branch),
          		        .id_ex_uncond_branch(id_ex_uncond_branch),
			// Input Bus 2
				.id_ex_NPC_2(id_ex_NPC_2),
				.id_ex_IR_2(id_ex_IR_2),
				.id_ex_dest_reg_2(id_ex_dest_reg_2),
				.id_ex_rega_2(id_ex_rega_2),
				.id_ex_regb_2(id_ex_regb_2),
				.id_ex_opa_select_2(id_ex_opa_select_2),
				.id_ex_opb_select_2(id_ex_opb_select_2),
				.id_ex_alu_func_2(id_ex_alu_func_2),
                
                	// Outputs
                		.ex_take_branch_out(ex_take_branch_out),
			// ALU 1 Bus
                		.ex_alu_result_out_1(ex_alu_result_out_1),
				.ex_alu_valid_out_1(ex_alu_valid_out_1),
			// ALU 2 Bus
				.ex_alu_result_out_2(ex_alu_result_out_2),
				.ex_alu_valid_out_2(ex_alu_valid_out_2),
			// Multiplier 1 Bus
				.ex_mult_IR_out_1(ex_mult_IR_out_1),
				.ex_mult_NPC_out_1(ex_mult_NPC_out_1),
				.ex_mult_dest_reg_out_1(ex_mult_dest_reg_out_1),
				.ex_mult_result_out_1(ex_mult_result_out_1),
				.ex_mult_valid_out_1(ex_mult_valid_out_1),
			// Multiplier 2 Bus
				.ex_mult_IR_out_2(ex_mult_IR_out_2),
				.ex_mult_NPC_out_2(ex_mult_NPC_out_2),
				.ex_mult_dest_reg_out_2(ex_mult_dest_reg_out_2),
				.ex_mult_result_out_2(ex_mult_result_out_2),
				.ex_mult_valid_out_2(ex_mult_valid_out_2)
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
         $display();  
      else
	 $display();
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
        waiting_taga_in = 8'hAA;
        waiting_tagb_in = 8'hBB;
        cdb_tag_in = 8'hCD;
        fill = 1; 

        DISPLAY_STATE(`PRECLOCK);
        @(posedge clock);
        @(negedge clock);
        DISPLAY_STATE(`POSTCLOCK);

        fill = 0; 

        DISPLAY_STATE(`PRECLOCK);
        @(posedge clock);
        @(negedge clock);
        DISPLAY_STATE(`POSTCLOCK);

        cdb_tag_in = 8'hAA;
        cdb_value_in = 64'hDEADBEEFBAADBEEF;

        DISPLAY_STATE(`PRECLOCK);
        @(posedge clock);
        @(negedge clock);
        DISPLAY_STATE(`POSTCLOCK);                 

        cdb_tag_in = 8'hBB;
        cdb_value_in = 64'hA000000AA000000A;

        DISPLAY_STATE(`PRECLOCK);
        @(posedge clock);
        @(negedge clock);
        DISPLAY_STATE(`POSTCLOCK);

        dest_reg_in = 5'd1;
        waiting_taga_in = 8'hFF;
        waiting_tagb_in = 8'hFF;
        cdb_tag_in      = 8'hFF;
        cdb_value_in    = 64'hFFFFFFFFFFFFFFFF;
        fill = 1;

        DISPLAY_STATE(`PRECLOCK);
        @(posedge clock);
        @(negedge clock);
        DISPLAY_STATE(`POSTCLOCK);


        DISPLAY_STATE(`PRECLOCK);
        @(posedge clock);
        @(negedge clock);
        DISPLAY_STATE(`POSTCLOCK);

        reset = 1;
       
        DISPLAY_STATE(`PRECLOCK);
        @(posedge clock);
        @(negedge clock);
        DISPLAY_STATE(`POSTCLOCK);

	// SUCCESSFULLY END TESTBENCH //
	$display("ENDING TESTBENCH : SUCCESS !\n");
	$finish;
	
   end

endmodule


