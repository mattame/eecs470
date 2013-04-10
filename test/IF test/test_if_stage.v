`define SD #1

`timescale 1ns/100ps
// reservation station testbench module //
module testbench;

	// internal wires/registers //
	reg correct;
	integer i = 0;

	// wires for testing the module //
	reg clock;
	reg reset;
	reg take_branch;
	reg [63:0] branch_target;
	reg [63:0] mem2proc_data;
	
	wire [63:0] proc2mem_addr;

	reg stall;
	
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
                .stall(stall),
                .ex_mem_take_branch(take_branch),
                .ex_mem_target_pc(branch_target),
                .Imem2proc_data(mem2proc_data),
                    
                // Outputs
                .proc2Imem_addr(proc2mem_addr),

                .if_NPC_out_1(NPC_out_1),        // PC+4 of fetched instruction
                .if_IR_out_1(IR_out_1),         // fetched instruction out
                .if_valid_inst_out_1(valid_out_1),  // when low, instruction is garbage
		
				.if_NPC_out_2(NPC_out_2),
				.if_IR_out_2(IR_out_2),
				.if_valid_inst_out_2(valid_out_2)
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
   `define INPUT  1'b1
   `define OUTPUT 1'b0
   task DISPLAY_STATE;
      input preclock;
   begin
      if (preclock==`INPUT)
	begin
	 $display("---------------------------------------------------------------");
	 $display(">>>> Pre-Clock Input   %4.0f", $time); 
	 $display("Memory Line: %h, Take Branch: %b, Branch Target: %h", mem2proc_data, take_branch, branch_target); 
      	end
      else
	begin
	 $display(">>>> Pre-Clock Output %4.0f, Next Mem Addr: %h", $time, proc2mem_addr); 
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

	stall   = 0;
	take_branch = 0;
	branch_target = 64'h0;
	mem2proc_data = 64'hffffffffffffffff;
	
	
	reset = 1;
	    @(negedge clock);
        DISPLAY_STATE(`INPUT);
        DISPLAY_STATE(`OUTPUT);
        @(posedge clock);
		
	take_branch = 0;
	branch_target = 64'h0;
	mem2proc_data = 64'h0000000011111111;
	
	
        reset = 0;
	    @(negedge clock);
        DISPLAY_STATE(`INPUT);
        DISPLAY_STATE(`OUTPUT);
        @(posedge clock);

	take_branch = 1;
	branch_target = 64'h0000000000000004;
	mem2proc_data = 64'h2222222233333333;
	
	    @(negedge clock);	
        DISPLAY_STATE(`INPUT);
        DISPLAY_STATE(`OUTPUT);
        @(posedge clock);


	take_branch = 0;
	branch_target = 64'h0;
	mem2proc_data = 64'h0000000011111111;
	
	    @(negedge clock);
        DISPLAY_STATE(`INPUT);
        DISPLAY_STATE(`OUTPUT);		
        @(posedge clock);
		
	take_branch = 1;
	branch_target = 64'hFFFFFFFFFFFFFFF0;
	mem2proc_data = 64'h2222222233333333;
	
	    @(negedge clock);	
        DISPLAY_STATE(`INPUT);
        DISPLAY_STATE(`OUTPUT);
        @(posedge clock);
		
	take_branch = 0;
	branch_target = 64'h0;
	mem2proc_data = 64'h4444444455555555;
	
	    @(negedge clock);
        DISPLAY_STATE(`INPUT);
        DISPLAY_STATE(`OUTPUT);		
        @(posedge clock);

    stall = 1;
	take_branch = 0;
	branch_target = 64'h0;
	mem2proc_data = 64'h6666666677777777;
	
	    @(negedge clock);
        DISPLAY_STATE(`INPUT);
        DISPLAY_STATE(`OUTPUT);		
        @(posedge clock);
		
    stall = 0;
	take_branch = 0;
	branch_target = 64'hFFFFFFFFFFFFFFF0;
	mem2proc_data = 64'h123456789abcdef0;
	
	    @(negedge clock);	
        DISPLAY_STATE(`INPUT);
        DISPLAY_STATE(`OUTPUT);
        @(posedge clock);
		
	take_branch = 0;
	branch_target = 64'h0;
	mem2proc_data = 64'h8888888899999999;
	
	    @(negedge clock);
        DISPLAY_STATE(`INPUT);
        DISPLAY_STATE(`OUTPUT);		
        @(posedge clock);     

    stall = 0;
	take_branch = 0;
	branch_target = 64'h0;
	mem2proc_data = 64'haaaaaaaabbbbbbbb;
	
	    @(negedge clock);
        DISPLAY_STATE(`INPUT);
        DISPLAY_STATE(`OUTPUT);		
        @(posedge clock);
		
    stall = 1;
	take_branch = 1;
	branch_target = 64'h0000000000000004;
	mem2proc_data = 64'hccccccccdddddddd;
	
	    @(negedge clock);	
        DISPLAY_STATE(`INPUT);
        DISPLAY_STATE(`OUTPUT);
        @(posedge clock);
		
	take_branch = 0;
	branch_target = 64'h0;
	mem2proc_data = 64'h0fedcba987654321;
	
	    @(negedge clock);
        DISPLAY_STATE(`INPUT);
        DISPLAY_STATE(`OUTPUT);		
        @(posedge clock);     


	// SUCCESSFULLY END TESTBENCH //
	$display("ENDING TESTBENCH : SUCCESS !\n");
	$finish;
	
   end

endmodule


