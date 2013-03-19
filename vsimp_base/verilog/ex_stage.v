//////////////////////////////////////////////////////////////////////////
//                                                                      //
//   Modulename :  ex_stage.v                                           //
//                                                                      //
//  Description :  instruction execute (EX) stage of the pipeline;      //
//                 given the instruction command code CMD, select the   //
//                 proper input A and B for the ALU, compute the result,// 
//                 and compute the condition for branches, and pass all //
//                 the results down the pipeline. MWB                   // 
//                                                                      //
//                                                                      //
//////////////////////////////////////////////////////////////////////////

`timescale 1ns/100ps


module ex_stage(// Inputs
                clock,
                reset,
				// Input Bus 1 (contains branch logic)
                id_ex_NPC_1,
                id_ex_IR_1,
				id_ex_dest_reg_1,
                id_ex_rega_1,
                id_ex_regb_1,
                id_ex_opa_select_1,
                id_ex_opb_select_1,
                id_ex_alu_func_1,
                id_ex_cond_branch,
                id_ex_uncond_branch,
				// Input Bus 2
				id_ex_NPC_2,
				id_ex_IR_2,
				id_ex_dest_reg_2,
				id_ex_rega_2,
				id_ex_regb_2,
				id_ex_opa_select_2,
				id_ex_opb_select_2,
				id_ex_alu_func_2,
				
			    // Outputs
				stall_bus_1,
				stall_bus_2,
				ex_branch_taken,
				// Bus 1
				ex_IR_out_1,
				ex_NPC_out_1,
				ex_dest_reg_out_1,
				ex_result_out_1,
				ex_valid_out_1,
				// Bus 2
				ex_IR_out_2,
				ex_NPC_out_2,
				ex_dest_reg_out_2,
				ex_result_out_2,
				ex_valid_out_2
               );

  input         clock;               // system clock
  input         reset;               // system reset
  
  input  [63:0] id_ex_NPC_1;         // incoming instruction PC+4
  input  [31:0] id_ex_IR_1;          // incoming instruction
  input   [4:0] id_ex_dest_reg_1;	 // destination register
  input  [63:0] id_ex_rega_1;        // register A value from reg file
  input  [63:0] id_ex_regb_1;        // register B value from reg file
  input   [1:0] id_ex_opa_select_1;  // opA mux select from decoder
  input   [1:0] id_ex_opb_select_1;  // opB mux select from decoder
  input   [4:0] id_ex_alu_func_1;    // ALU function select from decoder
  input         id_ex_cond_branch;   // is this a cond br? from decoder
  input         id_ex_uncond_branch; // is this an uncond br? from decoder

  input  [63:0] id_ex_NPC_2;         // incoming instruction PC+4
  input  [31:0] id_ex_IR_2;          // incoming instruction
  input   [4:0] id_ex_dest_reg_2;	 // destination register
  input  [63:0] id_ex_rega_2;        // register A value from reg file
  input  [63:0] id_ex_regb_2;        // register B value from reg file
  input   [1:0] id_ex_opa_select_2;  // opA mux select from decoder
  input   [1:0] id_ex_opb_select_2;  // opB mux select from decoder
  input   [4:0] id_ex_alu_func_2;    // ALU function select from decoder
  

  output        stall_bus_1;	     // Should input bus 1 stall?
  output	stall_bus_2;	     // Should input bus 2 stall?
  output        ex_take_branch_out;  // is this a taken branch?
  
				// Bus 1
  output [31:0]	ex_IR_out_1,		 // 32 bit instruction out
  output [63:0] ex_NPC_out_1,		 // PC+4
  output  [4:0] ex_dest_reg_out_1,	 // Destination Reg
  output [63:0] ex_result_out_1,	 // Bus 1 Result
  output		ex_valid_out_1,		 // Valid Output
  
				// Bus 2
  output [31:0]	ex_IR_out_2,		 // 32 bit instruction
  output [63:0] ex_NPC_out_2,		 // PC+4
  output  [4:0] ex_dest_reg_out_2,   // Desitnation Reg
  output [63:0] ex_result_out_2,	 // Bus 2 result
  output		ex_valid_out_2,		 // Valid Output
  
  
  // Inputs to the arbiter
  wire [63:0] ex_alu_result_out_1;   // ALU result
  wire		  ex_alu_valid_out_1;    // Valid Output
  
  wire [63:0] ex_alu_result_out_2;   // ALU result
  wire		  ex_alu_valid_out_1;	 // Valid Output
  
  wire [31:0] ex_mult_IR_out_1;	  	 // 32 bit instruction
  wire [63:0] ex_mult_NPC_out_1;	 // PC+4
  wire  [4:0] ex_mult_dest_reg_out_1;// Destination Reg
  wire [63:0] ex_mult_result_out_1;  // Mult result
  wire 		  ex_mult_valid_out_1;   // Valid Output
  
  wire [31:0] ex_mult_IR_out_2;	   	 // 32 bit instruction
  wire [63:0] ex_mult_NPC_out_2;	 // PC+4
  wire  [4:0] ex_mult_dest_reg_out_2;// Destination Reg
  wire [63:0] ex_mult_result_out_2;  // Mult result
  wire 		  ex_mult_valid_out_2;   // Valid Output
  
  reg    [63:0] opa_mux_out_1, opa_mux_out_2, opb_mux_out_1, opb_mux_out_2;
  wire          brcond_result;
   
   // set up possible immediates:
   //   mem_disp: sign-extended 16-bit immediate for memory format
   //   br_disp: sign-extended 21-bit immediate * 4 for branch displacement
   //   alu_imm: zero-extended 8-bit immediate for ALU ops
  wire [63:0] mem_disp_1 = { {48{id_ex_IR_1[15]}}, id_ex_IR_1[15:0] };
  wire [63:0] br_disp_1  = { {41{id_ex_IR_1[20]}}, id_ex_IR_1[20:0], 2'b00 };
  wire [63:0] alu_imm_1  = { 56'b0, id_ex_IR_1[20:13] };
  
  wire [63:0] mem_disp_2 = { {48{id_ex_IR_2[15]}}, id_ex_IR_2[15:0] };
  wire [63:0] br_disp_2  = { {41{id_ex_IR_2[20]}}, id_ex_IR_2[20:0], 2'b00 };
  wire [63:0] alu_imm_2  = { 56'b0, id_ex_IR_2[20:13] };
  
  wire mult_valid_in_1, mult_valid_in_2;
   
   //
   // Check if we use the ALU or the Multiplier for each channel
   //
  assign mult_valid_in_1 = (id_ex_alu_func_1 == `ALU_MULQ) ? 1'b1: 1'b0;
  assign alu_valid_out_1  = (ex_alu_result_out_1 == 64'hdeadbeefbaadbeef) ? 1'b0: 1'b1;
  
  assign mult_valid_in_2 = (id_ex_alu_func_2 == `ALU_MULQ) ? 1'b1: 1'b0;
  assign alu_valid_out_2  = (ex_alu_result_out_2 == 64'hdeadbeefbaadbeef) ? 1'b0: 1'b1;
   
   //
   // ALU opA mux
   //
  always @*
  begin
    case (id_ex_opa_select_1)
      `ALU_OPA_IS_REGA:     opa_mux_out_1 = id_ex_rega_1;
      `ALU_OPA_IS_MEM_DISP: opa_mux_out_1 = mem_disp_1;
      `ALU_OPA_IS_NPC:      opa_mux_out_1 = id_ex_NPC_1;
      `ALU_OPA_IS_NOT3:     opa_mux_out_1 = ~64'h3;
    endcase
    case (id_ex_opa_select_2)
      `ALU_OPA_IS_REGA:     opa_mux_out_2 = id_ex_rega_2;
      `ALU_OPA_IS_MEM_DISP: opa_mux_out_2 = mem_disp_2;
      `ALU_OPA_IS_NPC:      opa_mux_out_2 = id_ex_NPC_2;
      `ALU_OPA_IS_NOT3:     opa_mux_out_2 = ~64'h3;
    endcase
  end

   //
   // ALU opB mux
   //
  always @*
  begin
     // Default value, Set only because the case isnt full.  If you see this
     // value on the output of the mux you have an invalid opb_select
    opb_mux_out_1 = 64'hbaadbeefdeadbeef;
    case (id_ex_opb_select_1)
      `ALU_OPB_IS_REGB:    opb_mux_out_1 = id_ex_regb_1;
      `ALU_OPB_IS_ALU_IMM: opb_mux_out_1 = alu_imm_1;
      `ALU_OPB_IS_BR_DISP: opb_mux_out_1 = br_disp_1;
    endcase 
    opb_mux_out_2 = 64'hbaadbeefdeadbeef;
    case (id_ex_opb_select)
      `ALU_OPB_IS_REGB:    opb_mux_out_2 = id_ex_regb_2;
      `ALU_OPB_IS_ALU_IMM: opb_mux_out_2 = alu_imm_2;
      `ALU_OPB_IS_BR_DISP: opb_mux_out_2 = br_disp_2;
    endcase 
  end

   //
   // instantiate the ALU
   //
  alu alu_1 (// Inputs
             .opa(opa_mux_out_1),
             .opb(opb_mux_out_1),
             .func(id_ex_alu_func_1),

             // Output
             .result(ex_alu_1_result_out_1),
            );
  alu alu_2 (// Inputs
             .opa(opa_mux_out_2),
             .opb(opb_mux_out_2),
             .func(id_ex_alu_func_2),

             // Output
             .result(ex_alu_result_out_2),
            );
    //
    // instantiate the multiplier
    //
  mult mult_1 (// Inputs
               .clock(clock),
               .reset(reset),
			   .IR_in(id_ex_IR_1),
			   .NPC_out(id_ex_NPC_1),
			   .dest_reg_in(id_ex_dest_reg_1),
               .mplier(opa_mux_out_1),
               .mcand(opb_mux_out_1),
               .valid_in(mult_valid_in_1),
           
               // Outputs
			   .IR_out(ex_mult_IR_out_1),
			   .NPC_out(ex_mult_NPC_out_1),
			   .dest_reg_out(ex_mult_dest_reg_out_1),
               .product(ex_mult_result_out_1),
               .valid_out(mult_valid_out_1)
              );
  mult mult_2 (// Inputs
               .clock(clock),
               .reset(reset),
			   .IR_in(id_ex_IR_2),
			   .NPC_in(id_ex_NPC_2),
			   .dest_reg_in(id_ex_dest_reg_2),
               .mplier(opa_mux_out_2),
               .mcand(opb_mux_out_2),
               .valid_in(mult_valid_in_2),
           
               // Outputs
			   .IR_out(ex_mult_IR_out_2),
			   .NPC_out(ex_mult_NPC_out_2),
			   .dest_reg_out(ex_mult_dest_reg_out_2),
               .product(ex_mul_result_out_2),
               .valid_out(mult_valid_out_2)
              );
   //
   // instantiate the branch condition tester
   //
  brcond brcond (// Inputs
                .opa(id_ex_rega_1),       // always check regA value
                .func(id_ex_IR_1[28:26]), // inst bits to determine check

                // Output
                .cond(brcond_result)
               );
  arbiter arb_0 (// Inputs
					.ex_alu_IR_out_1(ex_alu_IR_out_1),
					.ex_alu_NPC_out_1(ex_alu_NPC_out_1),
					.ex_alu_dest_reg_out_1(ex_alu_dest_reg_out_1),
					.ex_alu_result_out_1(ex_alu_result_out_1),
					.ex_alu_valid_out_1(ex_alu_valid_out_1),
					// ALU 2 Bus
					.ex_alu_IR_out_2(ex_alu_IR_out_2),
					.ex_alu_NPC_out_2(ex_alu_NPC_out_2),
					.ex_alu_dest_reg_out_2(ex_alu_dest_reg_out_2),
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
					.ex_mult_valid_out_2(ex_mult_valid_out_2),
					
				   // Outputs
					.stall_bus_1(stall_bus_1),
					.stall_bus_2(stall_bus_2,
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
   // ultimate "take branch" signal:
   //    unconditional, or conditional and the condition is true
  assign ex_take_branch_out = id_ex_uncond_branch
                          | (id_ex_cond_branch & brcond_result);

endmodule // module ex_stage

