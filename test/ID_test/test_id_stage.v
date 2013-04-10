`timescale 1ns/100ps


// reservation station testbench module //
module testbench;

	// internal wires/registers //
	reg correct;
	integer i = 0;

	// wires for testing the module //
	  // Inputs
	  reg clock;
	  reg reset;

	  reg [31:0] if_id_IR_1;
	  reg if_id_valid_inst_1;

	  reg [31:0] if_id_IR_2;
	  reg if_id_valid_inst_2;

	  // Outputs
	  wire [1:0] id_opa_select_out_1;
	  wire [1:0] id_opb_select_out_1;
	  wire [4:0] id_dest_reg_idx_out_1;
	  wire [4:0] id_alu_func_out_1;
	  wire id_rd_mem_out_1;
	  wire id_wr_mem_out_1;
	  wire id_cond_branch_out_1;
	  wire id_uncond_branch_out_1;
	  wire id_halt_out_1;
	  wire id_illegal_out_1;
	  wire id_valid_inst_out_1;
	  wire [4:0] ra_idx_1;
	  wire [4:0] rb_idx_1;
	  wire [4:0] rc_idx_1;

	  wire [1:0] id_opa_select_out_2;
	  wire [1:0] id_opb_select_out_2;
	  wire [4:0] id_dest_reg_idx_out_2;
	  wire [4:0] id_alu_func_out_2;
	  wire id_rd_mem_out_2;
	  wire id_wr_mem_out_2;
	  wire id_cond_branch_out_2;
	  wire id_uncond_branch_out_2;
	  wire id_halt_out_2;
	  wire id_illegal_out_2;
	  wire id_valid_inst_out_2;
	  wire [4:0] ra_idx_2;
	  wire [4:0] rb_idx_2;
	  wire [4:0] rc_idx_2;


        // module to be tested //	
id_stage decode(
              // Inputs
              .clock(clock),
              .reset(reset),

              .if_id_IR_1(if_id_IR_1),
              .if_id_valid_inst_1(if_id_valid_inst_1),

              .if_id_IR_2(if_id_IR_2),
              .if_id_valid_inst_2(if_id_valid_inst_2),

              // Outputs
              .id_opa_select_out_1(id_opa_select_out_1),
              .id_opb_select_out_1(id_opb_select_out_1),
              .id_dest_reg_idx_out_1(id_dest_reg_idx_out_1),
              .id_alu_func_out_1(id_alu_func_out_1),
              .id_rd_mem_out_1(id_rd_mem_out_1),
              .id_wr_mem_out_1(id_wr_mem_out_1),
              .id_cond_branch_out_1(id_cond_branch_out_1),
              .id_uncond_branch_out_1(id_uncond_branch_out_1),
              .id_halt_out_1(id_halt_out_1),
              .id_illegal_out_1(id_illegal_out_1),
              .id_valid_inst_out_1(id_valid_inst_out_1),
              .ra_idx_1(ra_idx_1),
              .rb_idx_1(rb_idx_1),
              .rc_idx_1(rc_idx_1),

              .id_opa_select_out_2(id_opa_select_out_2),
              .id_opb_select_out_2(id_opb_select_out_2),
              .id_dest_reg_idx_out_2(id_dest_reg_idx_out_2),
              .id_alu_func_out_2(id_alu_func_out_2),
              .id_rd_mem_out_2(id_rd_mem_out_2),
              .id_wr_mem_out_2(id_wr_mem_out_2),
              .id_cond_branch_out_2(id_cond_branch_out_2),
              .id_uncond_branch_out_2(id_uncond_branch_out_2),
              .id_halt_out_2(id_halt_out_2),
              .id_illegal_out_2(id_illegal_out_2),
              .id_valid_inst_out_2(id_valid_inst_out_2),
              .ra_idx_2(ra_idx_2),
              .rb_idx_2(rb_idx_2),
              .rc_idx_2(rc_idx_2)
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
	 $display("**-----------------------------------------------------------**");
	 $display(">>>> Pre-Clock Input   %4.0f", $time); 
	 $display("IR 1: %h, 2: %h", if_id_IR_1, if_id_IR_2);
	 $display("Valid 1: %b, 2: %b", if_id_valid_inst_1, if_id_valid_inst_2);
      	end
      else
	begin
	 $display("");
	 $display(">>>> Pre-Clock Output %4.0f", $time); 
	 $display("");
	 $display("");
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



        @(posedge clock);
        @(posedge clock);
        @(posedge clock);
			
	reset = 0;


        @(negedge clock);
        DISPLAY_STATE(`INPUT);
        DISPLAY_STATE(`OUTPUT);
        @(posedge clock);
		

	
        @(negedge clock);
        DISPLAY_STATE(`INPUT);
        DISPLAY_STATE(`OUTPUT);
        @(posedge clock);


		
        @(negedge clock);
        DISPLAY_STATE(`INPUT);
        DISPLAY_STATE(`OUTPUT);
        @(posedge clock);
		
        @(negedge clock);
        DISPLAY_STATE(`INPUT);
        DISPLAY_STATE(`OUTPUT);
        @(posedge clock);

	
        @(negedge clock);
        DISPLAY_STATE(`INPUT);
        DISPLAY_STATE(`OUTPUT);
		@(posedge clock);
		
	// SUCCESSFULLY END TESTBENCH //
	$display("ENDING TESTBENCH : SUCCESS !\n");
	$finish;
	
   end

endmodule


