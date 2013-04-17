
`timescale 1ns/100ps

`define BRANCH_NONE      2'b00
`define BRANCH_TAKEN     2'b01
`define BRANCH_NOT_TAKEN 2'b10
`define BRANCH_UNUSED    2'b11

// reservation station testbench module //
module testbench;

	// internal wires/registers //
	reg correct;
	integer i = 0;

	// wires for testing the module //
	reg clock;
	reg reset;
		//bus 1
	reg        valid_in_1;
	reg [63:0] id_ex_NPC_1;
	reg [63:0] id_ex_PPC_1;
	reg  [4:0] id_ex_pht_idx_1;
	reg [31:0] id_ex_IR_1;
	reg  [4:0] id_ex_dest_reg_1;
    reg [63:0] id_ex_rega_1;
    reg [63:0] id_ex_regb_1;
    reg  [1:0] id_ex_opa_select_1;
    reg  [1:0] id_ex_opb_select_1;
	reg  [4:0] id_ex_alu_func_1;
    reg        id_ex_cond_branch_1;
    reg        id_ex_uncond_branch_1;
    reg        id_ex_rd_mem_in_1;
    reg        id_ex_wr_mem_in_1;
		//bus 2
	reg        valid_in_2;
	reg [63:0] id_ex_NPC_2;
	reg [63:0] id_ex_PPC_2;
	reg  [4:0] id_ex_pht_idx_2;
	reg [31:0] id_ex_IR_2;
	reg  [4:0] id_ex_dest_reg_2;
    reg [63:0] id_ex_rega_2;
    reg [63:0] id_ex_regb_2;
    reg  [1:0] id_ex_opa_select_2;
    reg  [1:0] id_ex_opb_select_2;
	reg  [4:0] id_ex_alu_func_2;
    reg        id_ex_cond_branch_2;
    reg        id_ex_uncond_branch_2;
    reg        id_ex_rd_mem_in_2;
    reg        id_ex_wr_mem_in_2;

          // From Mem Access
    reg  [4:0] MEM_tag_in;
    reg [63:0] MEM_value_in;
    reg        MEM_valid_in;


	wire stall_bus_1;
	wire stall_bus_2;
	
	wire [63:0] ex_NPC_out_1;
	wire  [4:0] ex_dest_reg_out_1;
	wire [63:0] ex_result_out_1;
	wire        ex_mispredict_1;
	wire  [1:0] ex_branch_result_1;
	wire  [4:0] ex_pht_idx_out_1;
	wire        ex_valid_out_1;

	wire [63:0] ex_NPC_out_2;
	wire  [4:0] ex_dest_reg_out_2;
	wire [63:0] ex_result_out_2;
	wire        ex_mispredict_2;
	wire  [1:0] ex_branch_result_2;
	wire  [4:0] ex_pht_idx_out_2;
	wire        ex_valid_out_2;

          // To LSQ
    wire  [4:0] LSQ_tag_out_1;
    wire [63:0] LSQ_address_out_1;
    wire [63:0] LSQ_value_out_1;
	wire        LSQ_valid_out_1;
	
    wire  [4:0] LSQ_tag_out_2;
    wire [63:0] LSQ_address_out_2;
    wire [63:0] LSQ_value_out_2;
	wire        LSQ_valid_out_2;

        // module to be tested //	

ex_stage ex_0(// Inputs
			.clock(clock),
			.reset(reset),
			// Input Bus 1 (contains branch logic)
			.valid_in_1(valid_in_1),
			.id_ex_NPC_1(id_ex_NPC_1),
			.id_ex_PPC_1(id_ex_PPC_1),
			.id_ex_pht_idx_1(id_ex_pht_idx_1),
			.id_ex_IR_1(id_ex_IR_1),
			.id_ex_dest_reg_1(id_ex_dest_reg_1),
			.id_ex_rega_1(id_ex_rega_1),
			.id_ex_regb_1(id_ex_regb_1),
			.id_ex_opa_select_1(id_ex_opa_select_1),
			.id_ex_opb_select_1(id_ex_opb_select_1),
			.id_ex_alu_func_1(id_ex_alu_func_1),
			.id_ex_cond_branch_1(id_ex_cond_branch_1),
			.id_ex_uncond_branch_1(id_ex_uncond_branch_1),
            .id_ex_rd_mem_in_1(id_ex_rd_mem_in_1),
            .id_ex_wr_mem_in_1(id_ex_wr_mem_in_1),
			// Input Bus 2
			.valid_in_2(valid_in_2),
			.id_ex_NPC_2(id_ex_NPC_2),
			.id_ex_PPC_2(id_ex_PPC_2),
			.id_ex_pht_idx_2(id_ex_pht_idx_2),
			.id_ex_IR_2(id_ex_IR_2),
			.id_ex_dest_reg_2(id_ex_dest_reg_2),
			.id_ex_rega_2(id_ex_rega_2),
			.id_ex_regb_2(id_ex_regb_2),
			.id_ex_opa_select_2(id_ex_opa_select_2),
			.id_ex_opb_select_2(id_ex_opb_select_2),
			.id_ex_alu_func_2(id_ex_alu_func_2),
			.id_ex_cond_branch_2(id_ex_cond_branch_2),
			.id_ex_uncond_branch_2(id_ex_uncond_branch_2),
            .id_ex_rd_mem_in_2(id_ex_rd_mem_in_2),
            .id_ex_wr_mem_in_2(id_ex_wr_mem_in_2),

			// From Mem Access
			.MEM_tag_in(MEM_tag_in),
			.MEM_value_in(MEM_value_in),
			.MEM_valid_in(MEM_valid_in),

			// Outputs
			.stall_bus_1(stall_bus_1),
			.stall_bus_2(stall_bus_2),
			// Bus 1
			.ex_NPC_out_1(ex_NPC_out_1),
			.ex_dest_reg_out_1(ex_dest_reg_out_1),
			.ex_result_out_1(ex_result_out_1),
			.ex_mispredict_1(mispredict_1),
			.ex_branch_result_1(ex_branch_result_1),
			.ex_pht_idx_out_1(ex_pht_idx_out_1),
			.ex_valid_out_1(ex_valid_out_1),
			// Bus 2
			.ex_NPC_out_2(ex_NPC_out_2),
			.ex_dest_reg_out_2(ex_dest_reg_out_2),
			.ex_result_out_2(ex_result_out_2),
			.ex_mispredict_2(mispredict_2),
			.ex_branch_result_2(ex_branch_result_2),
			.ex_pht_idx_out_2(ex_pht_idx_out_2),
			.ex_valid_out_2(ex_valid_out_2),

			// To LSQ
			.LSQ_tag_out_1(LSQ_tag_out_1),
			.LSQ_address_out_1(LSQ_address_out_1),
			.LSQ_value_out_1(LSQ_value_out_1),
			.LSQ_valid_out_1(LSQ_valid_out_1),

			.LSQ_tag_out_2(LSQ_tag_out_2),
			.LSQ_address_out_2(LSQ_address_out_2),
			.LSQ_value_out_2(LSQ_value_out_2),
			.LSQ_valid_out_2(LSQ_valid_out_2)
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
	 $display("COND_BRANCH1=%b, UNCOND_BRANCH1=%b, PPC1=%h, PHTIDX1=%h,", id_ex_cond_branch_1, id_ex_uncond_branch_1, id_ex_PPC_1, id_ex_pht_idx_1);
         $display("NPC1=%h, IR1=%h, DREG1=%d, REGA1=%h, REGB1=%h, OPA1=%h, OPB1=%h, FUNC1=%h", id_ex_NPC_1, id_ex_IR_1, id_ex_dest_reg_1, id_ex_rega_1, id_ex_regb_1,
		id_ex_opa_select_1, id_ex_opb_select_1, id_ex_alu_func_1);  
    
	 $display("COND_BRANCH2=%b, UNCOND_BRANCH2=%b, PPC2=%h, PHTIDX2=%h,", id_ex_cond_branch_2, id_ex_uncond_branch_2, id_ex_PPC_2, id_ex_pht_idx_2);
		 $display("NPC2=%h, IR2=%h, DREG2=%d, REGA2=%h, REGB2=%h, OPA2=%h, OPB2=%h, FUNC2=%h", id_ex_NPC_2, id_ex_IR_2, id_ex_dest_reg_2, id_ex_rega_2, id_ex_regb_2, 
		id_ex_opa_select_2, id_ex_opb_select_2, id_ex_alu_func_2);  
      	end
      else
	begin
	 $display("");
	 $display(">>>> Pre-Clock Output %4.0f", $time); 
	 $display("Stall1=%d, Stall2=%d", stall_bus_1, stall_bus_2);
	 $display("DREG1=%h, RES1=%h, VALID1=%b, MISP1=%b", ex_dest_reg_out_1, ex_result_out_1, ex_valid_out_1, mispredict_1);
	 $display("NPC1=%h, BRRES1=%b, PHTIDX1=%h", ex_NPC_out_1, ex_branch_result_1, ex_pht_idx_out_1);
	 $display("DREG2=%h, RES2=%h, VALID2=%b, MISP2=%b", ex_dest_reg_out_2, ex_result_out_2, ex_valid_out_2, mispredict_2);
	 $display("NPC2=%h, BRRES2=%b, PHTIDX2=%h", ex_NPC_out_2, ex_branch_result_2, ex_pht_idx_out_2);
	 $display("LSQ OUT");
	 $display("TAG1=%h, ADDR1=%h, VAL1=%h, VALID1=%b", LSQ_tag_out_1, LSQ_address_out_1, LSQ_value_out_1, LSQ_valid_out_1);
	 $display("TAG2=%h, ADDR2=%h, VAL2=%h, VALID2=%b", LSQ_tag_out_2, LSQ_address_out_2, LSQ_value_out_2, LSQ_valid_out_2);
	end
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
   initial begin 

	$display("STARTING TESTBENCH!\n");

	// initial state //
	correct = 1;
	clock   = 0;
	reset   = 1;


        // TRANSITION TESTS //
		//Mult Base
	valid_in_1 = 1'b0;
	id_ex_NPC_1 = 64'h0;
	id_ex_PPC_1 = 64'h0;
	id_ex_pht_idx_1 = 5'h0;
	id_ex_IR_1 = 32'h0;
	id_ex_dest_reg_1 = 5'h3;
    id_ex_rega_1 = 32'd20;
    id_ex_regb_1 = 32'd20;
    id_ex_opa_select_1 = `ALU_OPA_IS_REGA;
    id_ex_opb_select_1 = `ALU_OPB_IS_REGB;
	id_ex_alu_func_1 = `ALU_MULQ;
    id_ex_cond_branch_1 = 0;
    id_ex_uncond_branch_1 = 0;
	id_ex_rd_mem_in_1 = 0;
    id_ex_wr_mem_in_1 = 0;
		//Add Base
	valid_in_2 = 1'b0;
	id_ex_NPC_2 = 64'h0;
	id_ex_PPC_2 = 64'h0;
	id_ex_pht_idx_2 = 5'h0;
	id_ex_IR_2 = 32'h0;
	id_ex_dest_reg_2 = 5'h3;
	id_ex_rega_2 = 32'd20;
	id_ex_regb_2 = 32'd20;
	id_ex_opa_select_2 = `ALU_OPA_IS_REGA;
	id_ex_opb_select_2 = `ALU_OPB_IS_REGB;
	id_ex_alu_func_2 = `ALU_ADDQ;
    id_ex_cond_branch_2 = 0;
    id_ex_uncond_branch_2 = 0;
	id_ex_rd_mem_in_2 = 0;
    id_ex_wr_mem_in_2 = 0;
		//Branch Base
	valid_in_2 = 1'b0;
	id_ex_NPC_2 = 64'h0;
	id_ex_PPC_2 = 64'h0;
	id_ex_pht_idx_2 = 5'h0;
	id_ex_IR_2 = {12'h0,20'h0}; //don't forget the offset
	id_ex_dest_reg_2 = 5'h3;
	id_ex_rega_2 = 32'd20;
	id_ex_regb_2 = 32'd20;
	id_ex_opa_select_2 = `ALU_OPA_IS_NPC;
	id_ex_opb_select_2 = `ALU_OPB_IS_BR_DISP;
	id_ex_alu_func_2 = `ALU_ADDQ;
    id_ex_cond_branch_2 = 1;
    id_ex_uncond_branch_2 = 0;
	id_ex_rd_mem_in_2 = 0;
    id_ex_wr_mem_in_2 = 0;
		//Unconditional Branch Base
	valid_in_2 = 1'b0;
	id_ex_NPC_2 = 64'h0;
	id_ex_PPC_2 = 64'h0;
	id_ex_pht_idx_2 = 5'h0;
	id_ex_IR_2 = {12'h0,20'h0}; //don't forget the offset
	id_ex_dest_reg_2 = 5'h3;
	id_ex_rega_2 = 32'd20;
	id_ex_regb_2 = 32'd20;
	id_ex_opa_select_2 = `ALU_OPA_IS_NPC;
	id_ex_opb_select_2 = `ALU_OPB_IS_BR_DISP;
	id_ex_alu_func_2 = `ALU_ADDQ;
    id_ex_cond_branch_2 = 0;
    id_ex_uncond_branch_2 = 1;
	id_ex_rd_mem_in_2 = 0;
    id_ex_wr_mem_in_2 = 0;
		//Load Base
	valid_in_2 = 1'b0;
	id_ex_NPC_2 = 64'h0;
	id_ex_PPC_2 = 64'h0;
	id_ex_pht_idx_2 = 5'h0;
	id_ex_IR_2 = {16'h0,16'h0}; //don't forget the offset
	id_ex_dest_reg_2 = 5'h3;
	id_ex_rega_2 = 32'd20;
	id_ex_regb_2 = 32'd20;
	id_ex_opa_select_2 = `ALU_OPA_IS_MEM_DISP;
	id_ex_opb_select_2 = `ALU_OPB_IS_REGB;
	id_ex_alu_func_2 = `ALU_ADDQ;
    id_ex_cond_branch_2 = 0;
    id_ex_uncond_branch_2 = 0;
	id_ex_rd_mem_in_2 = 1;
    id_ex_wr_mem_in_2 = 0;
		//Store Base
	valid_in_2 = 1'b0;
	id_ex_NPC_2 = 64'h0;
	id_ex_PPC_2 = 64'h0;
	id_ex_pht_idx_2 = 5'h0;
	id_ex_IR_2 = {`STQ_INST, 10'h0, 16'h0};// don't forget the offset
	id_ex_dest_reg_2 = 5'h3;
	id_ex_rega_2 = 32'd20;
	id_ex_regb_2 = 32'd20;
	id_ex_opa_select_2 = `ALU_OPA_IS_MEM_DISP;
	id_ex_opb_select_2 = `ALU_OPB_IS_REGB;
	id_ex_alu_func_2 = `ALU_ADDQ;
    id_ex_cond_branch_2 = 0;
    id_ex_uncond_branch_2 = 0;
	id_ex_rd_mem_in_2 = 0;
    id_ex_wr_mem_in_2 = 1;
	
	
	MEM_tag_in = 5'h0;
	MEM_value_in = 64'h0;
	MEM_valid_in = 1'b0;

        @(posedge clock);
        @(posedge clock);
        @(posedge clock);
			
	reset = 0;
////////////////////////////TEST 1 - RUN ALL TYPES WITHOUT ARBITER INTERFERENCE
	valid_in_1 = 1'b1;
	id_ex_NPC_1 = 64'h0;
	id_ex_PPC_1 = 64'h0;
	id_ex_pht_idx_1 = 5'h0;
	id_ex_IR_1 = 32'h0;
	id_ex_dest_reg_1 = 5'h3;
	id_ex_rega_1 = 32'd20;
	id_ex_regb_1 = 32'd20;
	id_ex_opa_select_1 = `ALU_OPA_IS_REGA;
	id_ex_opb_select_1 = `ALU_OPB_IS_REGB;
	id_ex_alu_func_1 = `ALU_ADDQ;
    id_ex_cond_branch_1 = 0;
    id_ex_uncond_branch_1 = 0;

	// Two Adds
	
	valid_in_2 = 1'b1;
	id_ex_NPC_2 = 64'h0;
	id_ex_PPC_2 = 64'h0;
	id_ex_pht_idx_2 = 5'h0;
	id_ex_IR_2 = 32'h0;
	id_ex_dest_reg_2 = 5'h3;
	id_ex_rega_2 = 32'd20;
	id_ex_regb_2 = 32'd20;
	id_ex_opa_select_2 = `ALU_OPA_IS_REGA;
	id_ex_opb_select_2 = `ALU_OPB_IS_REGB;
	id_ex_alu_func_2 = `ALU_ADDQ;
    id_ex_cond_branch_2 = 0;
    id_ex_uncond_branch_2 = 0;

	
        DISPLAY_STATE(`INPUT);
        @(negedge clock);
        @(posedge clock);
        DISPLAY_STATE(`OUTPUT);

	valid_in_1 = 1'b1;
	id_ex_NPC_1 = 64'h0;
	id_ex_PPC_1 = 64'h0;
	id_ex_pht_idx_1 = 5'h0;
	id_ex_IR_1 = 32'h0;
	id_ex_dest_reg_1 = 5'h3;
    id_ex_rega_1 = 32'd20;
    id_ex_regb_1 = 32'd20;
    id_ex_opa_select_1 = `ALU_OPA_IS_REGA;
    id_ex_opb_select_1 = `ALU_OPB_IS_REGB;
	id_ex_alu_func_1 = `ALU_MULQ;
    id_ex_cond_branch_1 = 0;
    id_ex_uncond_branch_1 = 0;
	
	// Two Multiplies
	
	valid_in_2 = 1'b1;
	id_ex_NPC_2 = 64'h0;
	id_ex_PPC_2 = 64'h0;
	id_ex_pht_idx_2 = 5'h0;
	id_ex_IR_2 = 32'h0;
	id_ex_dest_reg_2 = 5'h3;
    id_ex_rega_2 = 32'd30;
    id_ex_regb_2 = 32'd30;
    id_ex_opa_select_2 = `ALU_OPA_IS_REGA;
    id_ex_opb_select_2 = `ALU_OPB_IS_REGB;
	id_ex_alu_func_2 = `ALU_MULQ;
    id_ex_cond_branch_2 = 0;
    id_ex_uncond_branch_2 = 0;

	
        DISPLAY_STATE(`INPUT);
        @(negedge clock);
        @(posedge clock);
        DISPLAY_STATE(`OUTPUT);

																		//TODO: make these taken/not taken (figure out how)
	valid_in_1 = 1'b1;
	id_ex_NPC_1 = 64'h0;
	id_ex_PPC_1 = 64'h0;
	id_ex_pht_idx_1 = 5'h0;
	id_ex_IR_1 = {12'hfff,20'h400}; //don't forget the offset
	id_ex_dest_reg_1 = 5'h3;
	id_ex_rega_1 = 64'd00;
	id_ex_regb_1 = 64'd20;
	id_ex_opa_select_1 = `ALU_OPA_IS_NPC;
	id_ex_opb_select_1 = `ALU_OPB_IS_BR_DISP;
	id_ex_alu_func_1 = `ALU_ADDQ;
    id_ex_cond_branch_1 = 1;
    id_ex_uncond_branch_1 = 0;
	
	// Two conditional branches.
	// Bus 1 hit, Bus 2 miss
	
	valid_in_2 = 1'b1;
	id_ex_NPC_2 = 64'h0;
	id_ex_PPC_2 = 64'h0;
	id_ex_pht_idx_2 = 5'h0;
	id_ex_IR_2 = {12'h0,20'h800}; //don't forget the offset
	id_ex_dest_reg_2 = 5'h3;
	id_ex_rega_2 = 32'hff;
	id_ex_regb_2 = 32'd20;
	id_ex_opa_select_2 = `ALU_OPA_IS_NPC;
	id_ex_opb_select_2 = `ALU_OPB_IS_BR_DISP;
	id_ex_alu_func_2 = `ALU_ADDQ;
    id_ex_cond_branch_2 = 1;
    id_ex_uncond_branch_2 = 0;
	
        DISPLAY_STATE(`INPUT);
        @(posedge clock);
        @(negedge clock);
        DISPLAY_STATE(`OUTPUT);
		
	valid_in_1 = 1'b1;
	id_ex_NPC_1 = 64'h0;
	id_ex_PPC_1 = 64'h0;
	id_ex_pht_idx_1 = 5'h0;
	id_ex_IR_1 = {12'h0,20'h0}; //don't forget the offset
	id_ex_dest_reg_1 = 5'h3;
	id_ex_rega_1 = 32'd20;
	id_ex_regb_1 = 32'd20;
	id_ex_opa_select_1 = `ALU_OPA_IS_NPC;
	id_ex_opb_select_1 = `ALU_OPB_IS_BR_DISP;
	id_ex_alu_func_1 = `ALU_ADDQ;
    id_ex_cond_branch_1 = 0;
    id_ex_uncond_branch_1 = 1;
	
	// Two unconditional Branches
	
	valid_in_2 = 1'b1;
	id_ex_NPC_2 = 64'h0;
	id_ex_PPC_2 = 64'h0;
	id_ex_pht_idx_2 = 5'h0;
	id_ex_IR_2 = {12'h0,20'h0}; //don't forget the offset
	id_ex_dest_reg_2 = 5'h3;
	id_ex_rega_2 = 32'd20;
	id_ex_regb_2 = 32'd20;
	id_ex_opa_select_2 = `ALU_OPA_IS_NPC;
	id_ex_opb_select_2 = `ALU_OPB_IS_BR_DISP;
	id_ex_alu_func_2 = `ALU_ADDQ;
    id_ex_cond_branch_2 = 0;
    id_ex_uncond_branch_2 = 1;
	
        DISPLAY_STATE(`INPUT);
        @(negedge clock);
        @(posedge clock);
        DISPLAY_STATE(`OUTPUT);
		
	valid_in_1 = 1'b0;
	valid_in_2 = 1'b0;
		
        DISPLAY_STATE(`INPUT);
        @(negedge clock);
        @(posedge clock);
        DISPLAY_STATE(`OUTPUT);
		
	valid_in_1 = 1'b1;
	id_ex_NPC_1 = 64'h0;
	id_ex_PPC_1 = 64'h0;
	id_ex_pht_idx_1 = 5'h0;
	id_ex_IR_1 = {`STQ_INST, 10'h0, 16'h40};// don't forget the offset
	id_ex_dest_reg_1 = 5'h3;
	id_ex_rega_1 = 32'd20;
	id_ex_regb_1 = 32'd20;
	id_ex_opa_select_1 = `ALU_OPA_IS_MEM_DISP;
	id_ex_opb_select_1 = `ALU_OPB_IS_REGB;
	id_ex_alu_func_1 = `ALU_ADDQ;
    id_ex_cond_branch_1 = 0;
    id_ex_uncond_branch_1 = 0;
	id_ex_rd_mem_in_1 = 0;
    id_ex_wr_mem_in_1 = 1;
	
	// Two stores
	
	valid_in_2 = 1'b1;
	id_ex_NPC_2 = 64'h0;
	id_ex_PPC_2 = 64'h0;
	id_ex_pht_idx_2 = 5'h0;
	id_ex_IR_2 = {`STQ_INST, 10'h0, 16'h80};// don't forget the offset
	id_ex_dest_reg_2 = 5'h3;
	id_ex_rega_2 = 32'd20;
	id_ex_regb_2 = 32'd20;
	id_ex_opa_select_2 = `ALU_OPA_IS_MEM_DISP;
	id_ex_opb_select_2 = `ALU_OPB_IS_REGB;
	id_ex_alu_func_2 = `ALU_ADDQ;
    id_ex_cond_branch_2 = 0;
    id_ex_uncond_branch_2 = 0;
	id_ex_rd_mem_in_2 = 0;
    id_ex_wr_mem_in_2 = 1;
	

        DISPLAY_STATE(`INPUT);
	    @(negedge clock);
        @(posedge clock);
        DISPLAY_STATE(`OUTPUT);
		
	valid_in_1 = 1'b1;
	id_ex_NPC_1 = 64'h0;
	id_ex_PPC_1 = 64'h0;
	id_ex_pht_idx_1 = 5'h0;
	id_ex_IR_1 = {16'h0,16'h40}; //don't forget the offset
	id_ex_dest_reg_1 = 5'h3;
	id_ex_rega_1 = 32'd20;
	id_ex_regb_1 = 32'd20;
	id_ex_opa_select_1 = `ALU_OPA_IS_MEM_DISP;
	id_ex_opb_select_1 = `ALU_OPB_IS_REGB;
	id_ex_alu_func_1 = `ALU_ADDQ;
    id_ex_cond_branch_1 = 0;
    id_ex_uncond_branch_1 = 0;
	id_ex_rd_mem_in_1 = 1;
    id_ex_wr_mem_in_1 = 0;
	
	// Two loads
	
	valid_in_2 = 1'b1;
	id_ex_NPC_2 = 64'h0;
	id_ex_PPC_2 = 64'h0;
	id_ex_pht_idx_2 = 5'h0;
	id_ex_IR_2 = {16'h0,16'h80}; //don't forget the offset
	id_ex_dest_reg_2 = 5'h3;
	id_ex_rega_2 = 32'd20;
	id_ex_regb_2 = 32'd20;
	id_ex_opa_select_2 = `ALU_OPA_IS_MEM_DISP;
	id_ex_opb_select_2 = `ALU_OPB_IS_REGB;
	id_ex_alu_func_2 = `ALU_ADDQ;
    id_ex_cond_branch_2 = 0;
    id_ex_uncond_branch_2 = 0;
	id_ex_rd_mem_in_2 = 1;
    id_ex_wr_mem_in_2 = 0;
		
		
        DISPLAY_STATE(`INPUT);
		@(negedge clock);
        @(posedge clock);
        DISPLAY_STATE(`OUTPUT);
		
		
	 $display("---------------------------------------------------------------");

	
	
///////////////////////////////////////////////////////END OF TEST 1
		
		
		
	// SUCCESSFULLY END TESTBENCH //
	$display("ENDING TESTBENCH : SUCCESS !\n");
	$finish;
	
   end

endmodule


