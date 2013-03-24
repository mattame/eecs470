

// reservation station testbench module //
module testbench;

	// internal wires/registers //
	reg correct;
	integer i = 0;

	// wires for testing the module //
	wire clock;
	wire reset;
	wire take_branch;
	wire [31:0] branch_target;
	wire [63:0] mem2proc_data;
	
	wire [63:0] proc2mem_addr;
	
	wire [63:0] NPC_out_1;
	wire [31:0] IR_out_1;
	wire valid_out_1;
	
	wire [63:0] NPC_out_2;
	wire [31:0] IR_out_2;
	wire valid_out_2;
	

        // module to be tested //	
if_stage if0(// Inputs
                .clock(clock),
                .reset(reset),
                .ex_mem_take_branch(take_branch),
                .ex_mem_target_pc(branch_target),
                .Imem2proc_data(mem2proc_data),
                    
                // Outputs
                .proc2Imem_addr(proc2mem_addr),

                .if_NPC_out_1(NPC_out_1),        // PC+4 of fetched instruction
                .if_IR_out_1(IR_out_1),         // fetched instruction out
                .if_valid_inst_out_1(valid_out_1),  // when low, instruction is garbage
		
				if_NPC_out_2(NPC_out_2),
				if_IR_out_2(IR_out_2),
				if_valid_inst_out_2(valid_out_2)
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
	 $display("Memory Line: %h, Take Branch: %b, Branch Target: %h", mem2proc_data, take_branch, branch_target); 
      	end
      else
	begin
	 $display("Post-Clock Output %4.0f", $time); 
	 $display("NPC1: %h, IR1: %h, Valid1: %b", NPC_out_1, IR_out_1, valid_out_1);
	 $display("NPC2: %h, IR2: %h, Valid2: %b", NPC_out_2, IR_out_2, valid_out_2);
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

	take_branch = 0;
	branch_target = 64'h0;
	mem2proc_data = 64'h0000000011111111;
	
	reset = 1;

        DISPLAY_STATE(`PRECLOCK);
        @(posedge clock);
        @(negedge clock);
        DISPLAY_STATE(`POSTCLOCK);
		
	take_branch = 0;
	branch_target = 64'h0;
	mem2proc_data = 64'h1111111122222222;
	
        reset = 0;

        DISPLAY_STATE(`PRECLOCK);
        @(posedge clock);
        @(negedge clock);
        DISPLAY_STATE(`POSTCLOCK);

	take_branch = 1;
	branch_target = 64'h0000000000000100;
	mem2proc_data = 64'h2222222233333333;
	
        DISPLAY_STATE(`PRECLOCK);
        @(posedge clock);
        @(negedge clock);
        DISPLAY_STATE(`POSTCLOCK);


	take_branch = 0;
	branch_target = 64'h0;
	mem2proc_data = 64'h4444444455555555;
	
        DISPLAY_STATE(`PRECLOCK);
        @(posedge clock);
        @(negedge clock);
        DISPLAY_STATE(`POSTCLOCK);		
		
	// SUCCESSFULLY END TESTBENCH //
	$display("ENDING TESTBENCH : SUCCESS !\n");
	$finish;
	
   end

endmodule


