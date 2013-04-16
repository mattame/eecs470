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

//`timescale 1ns/100ps


module ex_stage(// Inputs
			clock,
			reset,
			// Input Bus 1 (contains branch logic)
			valid_in_1,
			id_ex_NPC_1,
			id_ex_PPC_1,
			id_ex_pht_idx_1,
			id_ex_IR_1,
			id_ex_dest_reg_1,
			id_ex_rega_1,
			id_ex_regb_1,
			id_ex_opa_select_1,
			id_ex_opb_select_1,
			id_ex_alu_func_1,
			id_ex_cond_branch_1,
			id_ex_uncond_branch_1,
      id_ex_rd_mem_in_1,
      id_ex_wr_mem_in_1,

			// Input Bus 2
			valid_in_2,
			id_ex_NPC_2,
			id_ex_PPC_2,
			id_ex_pht_idx_2,
			id_ex_IR_2,
			id_ex_dest_reg_2,
			id_ex_rega_2,
			id_ex_regb_2,
			id_ex_opa_select_2,
			id_ex_opb_select_2,
			id_ex_alu_func_2,
			id_ex_cond_branch_2,
			id_ex_uncond_branch_2,
      id_ex_rd_mem_in_2,
      id_ex_wr_mem_in_2,

			// From Mem Access
			MEM_tag_in,
			MEM_value_in,
			MEM_valid_in,

			// Outputs
			stall_bus_1,
			stall_bus_2,
			// Bus 1
      ex_NPC_out_1,
			ex_dest_reg_out_1,
			ex_result_out_1,
			ex_mispredict_1,
			ex_branch_result_1,
			ex_pht_idx_out_1,
			ex_valid_out_1,
			// Bus 2
      ex_NPC_out_2,
			ex_dest_reg_out_2,
			ex_result_out_2,
			ex_mispredict_2,
			ex_branch_result_2,
			ex_pht_idx_out_2,
			ex_valid_out_2,

			// To LSQ
			LSQ_tag_out_1,
			LSQ_address_out_1,
			LSQ_value_out_1,
			LSQ_valid_out_1,

			// why are value and valid almost the same word!? 
			// we need them both but they're hard to seperate!

			LSQ_tag_out_2,
			LSQ_address_out_2,
			LSQ_value_out_2,
			LSQ_valid_out_2
               );

  input         clock;               // system clock
  input         reset;               // system reset
  
  input         valid_in_1;
  input  [63:0] id_ex_NPC_1;         // incoming instruction PC+4
  input  [63:0] id_ex_PPC_1;		 // Predicted PC for branches
  input  [(`HISTORY_BITS-1):0] id_ex_pht_idx_1;
  input  [31:0] id_ex_IR_1;          // incoming instruction
  input   [4:0] id_ex_dest_reg_1;	 // destination register
  input  [63:0] id_ex_rega_1;        // register A value from reg file
  input  [63:0] id_ex_regb_1;        // register B value from reg file
  input   [1:0] id_ex_opa_select_1;  // opA mux select from decoder
  input   [1:0] id_ex_opb_select_1;  // opB mux select from decoder
  input   [4:0] id_ex_alu_func_1;    // ALU function select from decoder
  input         id_ex_cond_branch_1;   // is this a cond br? from decoder
  input         id_ex_uncond_branch_1; // is this an uncond br? from decoder
  input         id_ex_rd_mem_in_1;
  input         id_ex_wr_mem_in_1;

  input         valid_in_2;
  input  [63:0] id_ex_NPC_2;         // incoming instruction PC+4
  input  [63:0] id_ex_PPC_2;		 // Predicted PC for branches
  input  [(`HISTORY_BITS-1):0] id_ex_pht_idx_2;
  input  [31:0] id_ex_IR_2;          // incoming instruction
  input   [4:0] id_ex_dest_reg_2;	 // destination register
  input  [63:0] id_ex_rega_2;        // register A value from reg file
  input  [63:0] id_ex_regb_2;        // register B value from reg file
  input   [1:0] id_ex_opa_select_2;  // opA mux select from decoder
  input   [1:0] id_ex_opb_select_2;  // opB mux select from decoder
  input   [4:0] id_ex_alu_func_2;    // ALU function select from decoder
  input         id_ex_cond_branch_2;   // is this a cond br? from decoder
  input         id_ex_uncond_branch_2; // is this an uncond br? from decoder
  input         id_ex_rd_mem_in_2;
  input         id_ex_wr_mem_in_2;
 
  input   [4:0] MEM_tag_in;
  input  [63:0] MEM_value_in;
  input         MEM_valid_in;  

  output        stall_bus_1;    // Should input bus 1 stall?
  output        stall_bus_2;    // Should input bus 2 stall?
  
				// Bus 1
  output [63:0] ex_NPC_out_1;
  output  [4:0] ex_dest_reg_out_1;
  output [63:0] ex_result_out_1;
  output ex_mispredict_1;
  output  [1:0] ex_branch_result_1;
  output [(`HISTORY_BITS-1):0] ex_pht_idx_out_1;
  output ex_valid_out_1;
  
				// Bus 2
  output [63:0] ex_NPC_out_2;
  output  [4:0] ex_dest_reg_out_2;
  output [63:0] ex_result_out_2;
  output ex_mispredict_2;
  output  [1:0] ex_branch_result_2;
  output [(`HISTORY_BITS-1):0] ex_pht_idx_out_2;
  output ex_valid_out_2;
  
  output  [4:0] LSQ_tag_out_1;
  output [63:0] LSQ_address_out_1;
  output [63:0] LSQ_value_out_1;
  output        LSQ_valid_out_1;

  output  [4:0] LSQ_tag_out_2;
  output [63:0] LSQ_address_out_2;
  output [63:0] LSQ_value_out_2;
  output        LSQ_valid_out_2;
  
  // Inputs to the arbiter
  wire [63:0] ex_alu_result_out_1;   // ALU result
  wire		  ex_alu_valid_out_1;    // Valid Output
  
  wire [63:0] ex_alu_result_out_2;   // ALU result
  wire		  ex_alu_valid_out_2;	 // Valid Output
  
  wire  [4:0] ex_mult_dest_reg_out_1;// Destination Reg
  wire [63:0] ex_mult_result_out_1;  // Mult result
  wire 		  ex_mult_valid_out_1;   // Valid Output
  
  wire  [4:0] ex_mult_dest_reg_out_2;// Destination Reg
  wire [63:0] ex_mult_result_out_2;  // Mult result
  wire 		  ex_mult_valid_out_2;   // Valid Output
  
  // Internal wires and definitions

  reg  [63:0] opa_mux_out_1, opa_mux_out_2, opb_mux_out_1, opb_mux_out_2;
  wire		branch_valid_out_1, branch_valid_out_2;
  wire      brcond_result_1, brcond_result_2;
  wire      branch_taken_1, branch_taken_2;
  
  wire stall_mult_2;
   
  wire ex_mult_valid_in_1, ex_mult_valid_in_2;
  
  wire [63:0] ex_mult_NPC_out_1, ex_mult_NPC_out_2;

// To do: use rd/wr mem inputs for each bus

  assign LSQ_valid_out_1 = (id_ex_wr_mem_in_1 | id_ex_rd_mem_in_1);
  assign LSQ_valid_out_2 = (id_ex_wr_mem_in_2 | id_ex_rd_mem_in_2);
   
   // Check if we use the ALU or the Multiplier for each channel
  assign ex_mult_valid_in_1  =  (valid_in_1 & id_ex_alu_func_1 == `ALU_MULQ) ? 1'b1:  1'b0;
  assign ex_alu_valid_out_1  = (valid_in_1 & (ex_alu_result_out_1 != 64'hdeadbeefbaadbeef) & (!id_ex_rd_mem_in_1)) ? 1'b1: 1'b0;
  
  assign ex_mult_valid_in_2 =  (valid_in_2 & id_ex_alu_func_2 == `ALU_MULQ) ?  1'b1:  1'b0;
  assign ex_alu_valid_out_2  = (valid_in_2 & (ex_alu_result_out_2 != 64'hdeadbeefbaadbeef) & (!id_ex_rd_mem_in_2)) ? 1'b1: 1'b0;
   
  assign branch_valid_out_1 = (valid_in_1 & (id_ex_uncond_branch_1 | id_ex_cond_branch_1)) ? 1'b1: 1'b0;
  assign branch_valid_out_2 = (valid_in_2 & (id_ex_uncond_branch_2 | id_ex_cond_branch_2)) ? 1'b1: 1'b0;

   // Set the outputs to the LSQ
  assign LSQ_tag_out_1 = id_ex_dest_reg_2;
  assign LSQ_address_out_1 = ex_alu_result_out_1;
  assign LSQ_value_out_1 = id_ex_rega_1;
  
  assign LSQ_tag_out_2 = id_ex_dest_reg_2;
  assign LSQ_address_out_2 = ex_alu_result_out_2;
  assign LSQ_value_out_2 = id_ex_rega_2;
  
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
    case (id_ex_opb_select_2)
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
             .result(ex_alu_result_out_1)
            );
  alu alu_2 (// Inputs
             .opa(opa_mux_out_2),
             .opb(opb_mux_out_2),
             .func(id_ex_alu_func_2),

             // Output
             .result(ex_alu_result_out_2)
            );
    //
    // instantiate the multiplier
  mult mult_1 (// Inputs
               .clock(clock),
               .reset(reset),
			   .NPC_in(id_ex_NPC_1),
			   .dest_reg_in(id_ex_dest_reg_1),
               .mplier(opa_mux_out_1),
               .mcand(opb_mux_out_1),
               .valid_in(ex_mult_valid_in_1),
               .stall(1'b0),
           
               // Outputs
			   .NPC_out(ex_mult_NPC_out_1),
			   .dest_reg_out(ex_mult_dest_reg_out_1),
               .product(ex_mult_result_out_1),
               .valid_out(ex_mult_valid_out_1)
              );
  mult mult_2 (// Inputs
               .clock(clock),
               .reset(reset),
			   .NPC_in(id_ex_NPC_2),
			   .dest_reg_in(id_ex_dest_reg_2),
               .mplier(opa_mux_out_2),
               .mcand(opb_mux_out_2),
               .valid_in(ex_mult_valid_in_2),
               .stall(stall_mult_2),
           
               // Outputs
			   .NPC_out(ex_mult_NPC_out_2),
			   .dest_reg_out(ex_mult_dest_reg_out_2),
               .product(ex_mult_result_out_2),
               .valid_out(ex_mult_valid_out_2)
              );
   //
   // instantiate the branch condition tester
   //
  brcond brcond_1 (// Inputs
                .opa(id_ex_rega_1),       // always check regA value
                .func(id_ex_IR_2[28:26]), // inst bits to determine check

                // Output
                .cond(brcond_result_1)
               );
  brcond brcond_2 (// Inputs
                .opa(id_ex_rega_2),       // always check regA value
                .func(id_ex_IR_2[28:26]), // inst bits to determine check

                // Output
                .cond(brcond_result_2)
               );

  assign branch_taken_1 = (id_ex_uncond_branch_1 | (brcond_result_1 & id_ex_cond_branch_1));
  assign branch_taken_2 = (id_ex_uncond_branch_2 | (brcond_result_2 & id_ex_cond_branch_2));
  
  assign mispredict_1 = branch_taken_1 & (ex_alu_result_out_1 != id_ex_PPC_1);
  assign mispredict_2 = branch_taken_2 & (ex_alu_result_out_2 != id_ex_PPC_2);
			   
  arbiter arb_0 (//Ins
    .ex_branch_valid_out_1(branch_valid_out_1),
    .ex_branch_taken_1(branch_taken_1),
    .ex_branch_mispredict_1(mispredict_1),
    .ex_branch_pht_idx_1(id_ex_pht_idx_1),
    .ex_alu_NPC_out_1(id_ex_NPC_1),

    .ex_alu_dest_reg_out_1(id_ex_dest_reg_1),
    .ex_alu_result_out_1(ex_alu_result_out_1),
    .ex_alu_valid_out_1(ex_alu_valid_out_1),

    .ex_mult_NPC_out_1(ex_mult_NPC_out_1),
    .ex_mult_dest_reg_out_1(ex_mult_dest_reg_out_1),
    .ex_mult_result_out_1(ex_mult_result_out_1),
    .ex_mult_valid_out_1(ex_mult_valid_out_1),

    .mem_tag_in(MEM_tag_in),
    .mem_value_in(MEM_value_in),
    .mem_valid_in(MEM_valid_in),

    .ex_branch_valid_out_2(branch_valid_out_2),
    .ex_branch_taken_2(branch_taken_2),
    .ex_branch_mispredict_2(mispredict_2),
    .ex_branch_pht_idx_2(id_ex_pht_idx_2),
    .ex_alu_NPC_out_2(id_ex_NPC_2),

    .ex_alu_dest_reg_out_2(id_ex_dest_reg_2),
    .ex_alu_result_out_2(ex_alu_result_out_2),
    .ex_alu_valid_out_2(ex_alu_valid_out_2),

    .ex_mult_NPC_out_2(ex_mult_NPC_out_2),
    .ex_mult_dest_reg_out_2(ex_mult_dest_reg_out_2),
    .ex_mult_result_out_2(ex_mult_result_out_2),
    .ex_mult_valid_out_2(ex_mult_valid_out_2),

//Outs
    .stall_bus_1(stall_bus_1),
    .ex_NPC_out_1(ex_NPC_out_1),
    .ex_dest_reg_out_1(ex_dest_reg_out_1),
    .ex_result_out_1(ex_result_out_1),
    .ex_mispredict_1(ex_mispredict_1),
    .ex_branch_result_1(ex_branch_result_1),
    .ex_pht_idx_out_1(ex_pht_idx_out_1),
    .ex_valid_out_1(ex_valid_out_1),

    .stall_bus_2(stall_bus_2),
    .stall_mult_2(stall_mult_2),
    .ex_NPC_out_2(ex_NPC_out_2),
    .ex_dest_reg_out_2(ex_dest_reg_out_2),
    .ex_result_out_2(ex_result_out_2),
    .ex_mispredict_2(ex_mispredict_2),
    .ex_branch_result_2(ex_branch_result_2),
    .ex_pht_idx_out_2(ex_pht_idx_out_2),
    .ex_valid_out_2(ex_valid_out_2)
				  );
	
	

endmodule // module ex_stage

