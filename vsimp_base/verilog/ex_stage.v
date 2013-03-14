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

//
// The Multiplier Stage
//
// given the command code CMD and proper operands A and B, compute the
// result of the instruction
//
// This module is 
//


module mult_stage(clock, reset,
                  IR_in, NPC_in, dest_reg_in, product_in,  mplier_in,  mcand_in,  start,
                  IR_out, NPC_out, dest_reg_out, product_out, mplier_out, mcand_out, done);

  input clock, reset, start;
  input [63:0] product_in, mplier_in, mcand_in, NPC_in;
  input [31:0] IR_in;
  input [4:0]  dest_reg_in;

  output done;
  output [63:0] product_out, mplier_out, mcand_out;
  output [31:0] IR_out;
  output [4:0]  dest_reg_out;

  reg  [63:0] prod_in_reg, partial_prod_reg;
  wire [63:0] partial_product, next_mplier, next_mcand;

  reg [63:0] mplier_out, mcand_out;
  reg done;

  assign product_out = prod_in_reg + partial_prod_reg;

  assign partial_product = mplier_in[15:0] * mcand_in;

  assign next_mplier = {16'b0,mplier_in[63:16]};
  assign next_mcand = {mcand_in[47:0],16'b0};

  always @(posedge clock)
  begin
    prod_in_reg      <= #1 product_in;
    partial_prod_reg <= #1 partial_product;
    mplier_out       <= #1 next_mplier;
    mcand_out        <= #1 next_mcand;
	IR_out			 <= #1 IR_in;
	NPC_out			 <= #1 NPC_in;
	dest_reg_out	 <= #1 dest_reg_in;
  end

  always @(posedge clock)
  begin
    if(reset)
      done <= #1 1'b0;
    else
      done <= #1 start;
  end

endmodule                                                                                                                                                                

//
// The Multiplier
//
// given the command code CMD and proper operands A and B, compute the
// product of A and B
//
// This module has four stages, propogating a "done" throughout.
// When the third stage outputs "done", it signals a stall command
// which stalls the pipeline behind it and prevents a structural hazard
// at the end of the EX stage.
//


module mult(clock, reset, IR_in, NPC_in, dest_reg_in, mplier, mcand, valid_in, IR_out, NPC_out, dest_reg_out, product, valid_out);

  input clock, reset, valid_in;
  input [63:0] mcand, mplier, NPC_in;
  input [31:0] IR_in;
  input [4:0]  dest_reg_in;

  output [63:0] product, NPC_out;
  output [31:0] IR_out;
  output [4:0]  dest_reg_out;
  output valid_out;

  wire [63:0] mcand_out, mplier_out;
  wire [(3*64)-1:0] internal_products, internal_mcands, internal_mpliers, internal_NPCs;
  wire [(3*32)-1:0] internal_IRs;
  wire [(3*5)-1:0]  internal_dest_regs;
  wire [2:0] internal_dones;

  mult_stage mstage [3:0]
    (//Input
	 .clock(clock),
     .reset(reset),
	 .IR_in({internal_IRs,IR_in}),
	 .NPC_in({internal_NPCs,NPC_in}),
	 .dest_reg_in({internal_dest_regs,dest_reg_in}),
     .product_in({internal_products,64'h0}),
     .mplier_in({internal_mpliers,mplier}),
     .mcand_in({internal_mcands,mcand}),
     .start({internal_dones,valid_in}),
	 //Outputs
	 .IR_out({IR_out,internal_IRs}),
	 .NPC_out({NPC_out,internal_NPCs}),
	 .dest_reg_out({dest_reg_out,internal_dest_regs}),
     .product_out({product,internal_products}),
     .mplier_out({mplier_out,internal_mpliers}),
     .mcand_out({mcand_out,internal_mcands}),
     .done({valid_out,internal_dones})
    );

endmodule

//
// The ALU
//
// given the command code CMD and proper operands A and B, compute the
// result of the instruction
//
// This module is purely combinational
//

module alu(//Inputs
           opa,
           opb,
           func,
           
           // Output
           result
          );

  input  [63:0] opa;
  input  [63:0] opb;
  input   [4:0] func;
  output [63:0] result;

  reg    [63:0] result;

    // This function computes a signed less-than operation
  function signed_lt;
    input [63:0] a, b;
    
    if (a[63] == b[63]) 
      signed_lt = (a < b); // signs match: signed compare same as unsigned
    else
      signed_lt = a[63];   // signs differ: a is smaller if neg, larger if pos
  endfunction

  always @*
  begin
    case (func)
      `ALU_ADDQ:   result = opa + opb;
      `ALU_SUBQ:   result = opa - opb;
      `ALU_AND:    result = opa & opb;
      `ALU_BIC:    result = opa & ~opb;
      `ALU_BIS:    result = opa | opb;
      `ALU_ORNOT:  result = opa | ~opb;
      `ALU_XOR:    result = opa ^ opb;
      `ALU_EQV:    result = opa ^ ~opb;
      `ALU_SRL:    result = opa >> opb[5:0];
      `ALU_SLL:    result = opa << opb[5:0];
      `ALU_SRA:    result = (opa >> opb[5:0]) | ({64{opa[63]}} << (64 -
                             opb[5:0])); // arithmetic from logical shift
      // `ALU_MULQ:   result = opa * opb;
      `ALU_CMPULT: result = { 63'd0, (opa < opb) };
      `ALU_CMPEQ:  result = { 63'd0, (opa == opb) };
      `ALU_CMPULE: result = { 63'd0, (opa <= opb) };
      `ALU_CMPLT:  result = { 63'd0, signed_lt(opa, opb) };
      `ALU_CMPLE:  result = { 63'd0, (signed_lt(opa, opb) || (opa == opb)) };
      default:     result = 64'hdeadbeefbaadbeef; // here only to force
                                                  // a combinational solution
                                                  // a casex would be better
    endcase
  end
endmodule // alu

//
// BrCond module
//
// Given the instruction code, compute the proper condition for the
// instruction; for branches this condition will indicate whether the
// target is taken.
//
// This module is purely combinational
//
module brcond(// Inputs
              opa,        // Value to check against condition
              func,       // Specifies which condition to check

              // Output
              cond        // 0/1 condition result (False/True)
             );

  input   [2:0] func;
  input  [63:0] opa;
  output        cond;
  
  reg           cond;

  always @*
  begin
    case (func[1:0]) // 'full-case'  All cases covered, no need for a default
      2'b00: cond = (opa[0] == 0);  // LBC: (lsb(opa) == 0) ?
      2'b01: cond = (opa == 0);     // EQ: (opa == 0) ?
      2'b10: cond = (opa[63] == 1); // LT: (signed(opa) < 0) : check sign bit
      2'b11: cond = (opa[63] == 1) || (opa == 0); // LE: (signed(opa) <= 0)
    endcase
  
     // negate cond if func[2] is set
    if (func[2])
      cond = ~cond;
  end
endmodule // brcond


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
                id_ex_opa_select_1,
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
                ex_take_branch_out,
				// ALU 1 Bus
                ex_alu_result_out_1,
				ex_alu_valid_out_1,
				// ALU 2 Bus
				ex_alu_result_out_2,
				ex_alu_valid_out_2,
				// Multiplier 1 Bus
				ex_mult_IR_out_1,
				ex_mult_NPC_out_1,
				ex_mult_dest_reg_out_1,
				ex_mult_result_out_1,
				ex_mult_valid_out_1,
				// Multiplier 2 Bus
				ex_mult_IR_out_2,
				ex_mult_NPC_out_2,
				ex_mult_dest_reg_out_2,
				ex_mult_result_out_2,
				ex_mult_valid_out_2
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
  
  output        ex_take_branch_out;    // is this a taken branch?
  
  output [63:0] ex_alu_result_out_1;   // ALU result
  output 		ex_alu_valid_out_1;    // Valid Output
  
  output [63:0] ex_alu_result_out_2;   // ALU result
  output 		ex_alu_valid_out_1;	   // Valid Output
  
  output [31:0] ex_mult_IR_out_1;	   // 32 bit instruction
  output [63:0] ex_mult_NPC_out_1;	   // PC+4
  output  [4:0] ex_mult_dest_reg_out_1;// Destination Reg
  output [63:0] ex_mult_result_out_1;  // Mult result
  output 		ex_mult_valid_out_1;   // Valid Output
  
  output [31:0] ex_mult_IR_out_2;	   // 32 bit instruction
  output [63:0] ex_mult_NPC_out_2;	   // PC+4
  output  [4:0] ex_mult_dest_reg_out_2;// Destination Reg
  output [63:0] ex_mult_result_out_2;  // Mult result
  output 		ex_mult_valid_out_2;   // Valid Output
  
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
  
  wire mult_valid_in_1, mult_valid_in_2, alu_valid_in_1, alu_valid_in_2;
   
   //
   // Check if we use the ALU or the Multiplier for each channel
   //
  assign mult_valid_in_1 = (id_ex_alu_func_1 == `ALU_MULQ) ? 1'b1: 1'b0;
  assign alu_valid_in_1  = ~mult_valid_in_1;
  
  assign mult_valid_in_2 = (id_ex_alu_func_2 == `ALU_MULQ) ? 1'b1: 1'b0;
  assign alu_valid_in_2  = ~mult_valid_in_2;
   
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
    opb_mux_out = 64'hbaadbeefdeadbeef;
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

   // ultimate "take branch" signal:
   //    unconditional, or conditional and the condition is true
  assign ex_take_branch_out = id_ex_uncond_branch
                          | (id_ex_cond_branch & brcond_result);

endmodule // module ex_stage

