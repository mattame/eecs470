

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

	wire stall_bus_1;
	wire stall_bus_2;
	wire ex_branch_taken;
	
	wire ex_IR_out_1;
	wire ex_NPC_out_1;
	wire ex_dest_reg_out_1;
	wire ex_result_out_1;
	wire ex_valid_out_1;

	wire ex_IR_out_2;
	wire ex_NPC_out_2;
	wire ex_dest_reg_out_2;
	wire ex_result_out_2;
	wire ex_valid_out_2;

        // module to be tested //	
	ex_stage ex_0(// Inputs
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
		.stall_bus_1(stall_bus_1),
		.stall_bus_2(stall_bus_2),
		.ex_branch_taken(ex_branch_taken),
				// Bus 1
		.ex_IR_out_1(ex_IR_out_1),
		.ex_NPC_out_1(ex_NPC_out_1),
		.ex_dest_reg_out_1(ex_dest_reg_out_1),
		.ex_result_out_1(ex_result_out_1),
		.ex_valid_out_1(ex_valid_out_1),
				// Bus 2
		.ex_IR_out_2(ex_IR_out_2),
		.ex_NPC_out_2(ex_NPC_out_2),
		.ex_dest_reg_out_2(ex_dest_reg_out_2),
		.ex_result_out_2(ex_result_out_2),
		.ex_valid_out_2(ex_valid_out_2)
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
	begin
	 $display("---------------------------------------------------------------");
	 $display("Pre-Clock Input %4.0f", $time); 
	 $display("COND_BRANCH=%b, UNCOND_BRANCH=%b", id_ex_cond_branch, id_ex_uncond_branch);
         $display("NPC1=%h, IR1=%h, DREG1=%d, REGA1=%d, REGB1=%d, OPA1=%h, OPB1=%h, FUNC1=%h", id_ex_NPC_1, id_ex_IR_1, id_ex_dest_reg_1, id_ex_rega_1, id_ex_regb_1,
		id_ex_opa_select_1, id_ex_opb_select_1, id_ex_alu_func_1);  
         $display("NPC2=%h, IR2=%h, DREG2=%d, REGA2=%d, REGB2=%d, OPA2=%h, OPB2=%h, FUNC2=%h", id_ex_NPC_2, id_ex_IR_2, id_ex_dest_reg_2, id_ex_rega_2, id_ex_regb_2, 
		id_ex_opa_select_2, id_ex_opb_select_2, id_ex_alu_func_2);  
      	end
      else
	begin
	 $display("Post-Clock Output %4.0f", $time); 
	 $display("Stall1=%d, Stall2=%d", stall_bus_1, stall_bus_2);
	 $display("NPC1=%h, IR1=%h, DREG1=%d, RES1=%d, VALID1=%b", ex_NPC_out_1, ex_IR_out_1, ex_dest_reg_out_1, ex_result_out_1, ex_valid_out_1);
	 $display("NPC2=%h, IR2=%h, DREG2=%d, RES2=%d, VALID2=%b", ex_NPC_out_2, ex_IR_out_2, ex_dest_reg_out_2, ex_result_out_2, ex_valid_out_2);
	end
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

		//Mult Base
	id_ex_NPC_1 = 64'h0; // Increase for each instruction to keep track of each one. useless otherwise.
	id_ex_IR_1 = 32'h0; // Doesn't matter, really. We're not testing whether the ALU can take immediates right now
	id_ex_dest_reg_1 = 5'h3;
    id_ex_rega_1 = 32'h20;
    id_ex_regb_1 = 32'h20;
    id_ex_opa_select_1 = `ALU_OPA_IS_REGA;
    id_ex_opb_select_1 = `ALU_OPB_IS_REGB;
	id_ex_alu_func_1 = `ALU_MULQ;
    id_ex_cond_branch = 0;
    id_ex_uncond_branch = 0;
		//Add Base
	id_ex_NPC_2 = 64'h0;
	id_ex_IR_2 = 32'h0;
	id_ex_dest_reg_2 = 5'h3;
	id_ex_rega_2 = 32'h20;
	id_ex_regb_2 = 32'h20;
	id_ex_opa_select_2 = `ALU_OPA_IS_REGA;
	id_ex_opb_select_2 = `ALU_OPB_IS_REGB;
	id_ex_alu_func_2 = `ALU_ADDQ;
	
	reset = 1;

        DISPLAY_STATE(`PRECLOCK);
        @(posedge clock);
        @(negedge clock);
        DISPLAY_STATE(`POSTCLOCK);
		
	//TEST 1 - Simple double add test
		id_ex_NPC_1 = 64'h1;
		id_ex_IR_1 = 32'h0;
		id_ex_dest_reg_1 = 5'h3;
		id_ex_rega_1 = 32'h20;
		id_ex_regb_1 = 32'h20;
		id_ex_opa_select_1 = `ALU_OPA_IS_REGA;
		id_ex_opb_select_1 = `ALU_OPB_IS_REGB;
		id_ex_alu_func_1 = `ALU_ADDQ;
		id_ex_cond_branch = 0;
		id_ex_uncond_branch = 0;
		
		id_ex_NPC_2 = 64'h2;
		id_ex_IR_2 = 32'h0;
		id_ex_dest_reg_2 = 5'h3;
		id_ex_rega_2 = 32'h20;
		id_ex_regb_2 = 32'h20;
		id_ex_opa_select_2 = `ALU_OPA_IS_REGA;
		id_ex_opb_select_2 = `ALU_OPB_IS_REGB;
		id_ex_alu_func_2 = `ALU_ADDQ;
	
        reset = 0;

        DISPLAY_STATE(`PRECLOCK);
        @(posedge clock);
        @(negedge clock);
        DISPLAY_STATE(`POSTCLOCK);
		
	//TEST 2 - Two multiplies, then three adds.

		id_ex_NPC_1 = 64'h3;
		id_ex_IR_1 = 32'h0;
		id_ex_dest_reg_1 = 5'h3;
		id_ex_rega_1 = 32'h20;
		id_ex_regb_1 = 32'h20;
		id_ex_opa_select_1 = `ALU_OPA_IS_REGA;
		id_ex_opb_select_1 = `ALU_OPB_IS_REGB;
		id_ex_alu_func_1 = `ALU_MULQ;
		id_ex_cond_branch = 0;
		id_ex_uncond_branch = 0;
		
		id_ex_NPC_2 = 64'h4;
		id_ex_IR_2 = 32'h0;
		id_ex_dest_reg_2 = 5'h3;
		id_ex_rega_2 = 32'h20;
		id_ex_regb_2 = 32'h20;
		id_ex_opa_select_2 = `ALU_OPA_IS_REGA;
		id_ex_opb_select_2 = `ALU_OPB_IS_REGB;
		id_ex_alu_func_2 = `ALU_MULQ;
	
        DISPLAY_STATE(`PRECLOCK);
        @(posedge clock);
        @(negedge clock);
        DISPLAY_STATE(`POSTCLOCK);

		// 1
		id_ex_NPC_1 = 64'h5;
		id_ex_IR_1 = 32'h0;
		id_ex_dest_reg_1 = 5'h3;
		id_ex_rega_1 = 32'h20;
		id_ex_regb_1 = 32'h20;
		id_ex_opa_select_1 = `ALU_OPA_IS_REGA;
		id_ex_opb_select_1 = `ALU_OPB_IS_REGB;
		id_ex_alu_func_1 = `ALU_ADDQ;
		id_ex_cond_branch = 0;
		id_ex_uncond_branch = 0;
		
		id_ex_NPC_2 = 64'h6;
		id_ex_IR_2 = 32'h0;
		id_ex_dest_reg_2 = 5'h3;
		id_ex_rega_2 = 32'h20;
		id_ex_regb_2 = 32'h20;
		id_ex_opa_select_2 = `ALU_OPA_IS_REGA;
		id_ex_opb_select_2 = `ALU_OPB_IS_REGB;
		id_ex_alu_func_2 = `ALU_ADDQ;
		
	
        DISPLAY_STATE(`PRECLOCK);
        @(posedge clock);
        @(negedge clock);
        DISPLAY_STATE(`POSTCLOCK);
		
		// 2
		id_ex_NPC_1 = 64'h7;
		id_ex_IR_1 = 32'h0;
		id_ex_dest_reg_1 = 5'h3;
		id_ex_rega_1 = 32'h20;
		id_ex_regb_1 = 32'h20;
		id_ex_opa_select_1 = `ALU_OPA_IS_REGA;
		id_ex_opb_select_1 = `ALU_OPB_IS_REGB;
		id_ex_alu_func_1 = `ALU_ADDQ;
		id_ex_cond_branch = 0;
		id_ex_uncond_branch = 0;
		
		id_ex_NPC_2 = 64'h8;
		id_ex_IR_2 = 32'h0;
		id_ex_dest_reg_2 = 5'h3;
		id_ex_rega_2 = 32'h20;
		id_ex_regb_2 = 32'h20;
		id_ex_opa_select_2 = `ALU_OPA_IS_REGA;
		id_ex_opb_select_2 = `ALU_OPB_IS_REGB;
		id_ex_alu_func_2 = `ALU_ADDQ;
		
	
        DISPLAY_STATE(`PRECLOCK);
        @(posedge clock);
        @(negedge clock);
        DISPLAY_STATE(`POSTCLOCK);
		
		// 3
		id_ex_NPC_1 = 64'h9;
		id_ex_IR_1 = 32'h0;
		id_ex_dest_reg_1 = 5'h3;
		id_ex_rega_1 = 32'h20;
		id_ex_regb_1 = 32'h20;
		id_ex_opa_select_1 = `ALU_OPA_IS_REGA;
		id_ex_opb_select_1 = `ALU_OPB_IS_REGB;
		id_ex_alu_func_1 = `ALU_ADDQ;
		id_ex_cond_branch = 0;
		id_ex_uncond_branch = 0;
		
		id_ex_NPC_2 = 64'hA;
		id_ex_IR_2 = 32'h0;
		id_ex_dest_reg_2 = 5'h3;
		id_ex_rega_2 = 32'h20;
		id_ex_regb_2 = 32'h20;
		id_ex_opa_select_2 = `ALU_OPA_IS_REGA;
		id_ex_opb_select_2 = `ALU_OPB_IS_REGB;
		id_ex_alu_func_2 = `ALU_ADDQ;
	// Should output the multiplies, not the adds.	
	
        DISPLAY_STATE(`PRECLOCK);
        @(posedge clock);
        @(negedge clock);
        DISPLAY_STATE(`POSTCLOCK);
		
		
	// SUCCESSFULLY END TESTBENCH //
	$display("ENDING TESTBENCH : SUCCESS !\n");
	$finish;
	
   end

endmodule


