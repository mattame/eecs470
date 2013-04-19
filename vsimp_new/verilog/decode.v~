
///////////////////////////////////////////////////////////////
//  this file is for the new decode module                   //
///////////////////////////////////////////////////////////////
//
//
//
//


/////////////////////////////////////////////////////////////////////////
//                                                                     //
//   Modulename :  id_stage.v                                          //
//                                                                     //
//  Description :  instruction decode (ID) stage of the pipeline;      // 
//                 decode the instruction fetch register operands, and // 
//                 compute immediate operand (if applicable)           // 
//                                                                     //
/////////////////////////////////////////////////////////////////////////


//`timescale 1ns/100ps


  // Decode an instruction: given instruction bits IR produce the
  // appropriate datapath control signals.
  //
  // This is a *combinational* module (basically a PLA).
  //
module decoder(// Inputs
               inst,
               valid_inst_in,  // ignore inst when low, outputs will
                               // reflect noop (except valid_inst)

               // Outputs
               opa_select,
               opb_select,
               alu_func,
               dest_reg,
               rd_mem,
               wr_mem,
               cond_branch,
               uncond_branch,
               halt,           // non-zero on a halt
               illegal,        // non-zero on an illegal instruction 
               valid_inst      // for counting valid instructions executed
                               // and for making the fetch stage die on halts/
                               // keeping track of when to allow the next
                               // instruction out of fetch
                               // 0 for HALT and illegal instructions (die on halt)
              );

  input [31:0] inst;
  input valid_inst_in;

  output [1:0] opa_select, opb_select, dest_reg; // mux selects
  output [4:0] alu_func;
  output rd_mem, wr_mem, cond_branch, uncond_branch, halt, illegal, valid_inst;

  reg [1:0] opa_select, opb_select, dest_reg; // mux selects
  reg [4:0] alu_func;
  reg rd_mem, wr_mem, cond_branch, uncond_branch, halt, illegal;

  assign valid_inst = valid_inst_in & ~illegal;
  always @*
  begin
      // default control values:
      // - valid instructions must override these defaults as necessary.
      //   opa_select, opb_select, and alu_func should be set explicitly.
      // - invalid instructions should clear valid_inst.
      // - These defaults are equivalent to a noop
      // * see sys_defs.vh for the constants used here
    opa_select = 0;
    opb_select = 0;
    alu_func = 0;
    dest_reg = `DEST_NONE;
    rd_mem = `FALSE;
    wr_mem = `FALSE;
    cond_branch = `FALSE;
    uncond_branch = `FALSE;
    halt = `FALSE;
    illegal = `FALSE;
    if(valid_inst_in)
    begin
      case ({inst[31:29], 3'b0})
        6'h0:
          case (inst[31:26])
            `PAL_INST:
               if (inst[25:0] == 26'h0555) begin
                  opa_select = 1;
                  opb_select = 1;
                 halt = `TRUE;
               end
               else
                 illegal = `TRUE;
            default: illegal = `TRUE;
          endcase // case(inst[31:26])
         
        6'h10:
          begin
            opa_select = `ALU_OPA_IS_REGA;
            opb_select = inst[12] ? `ALU_OPB_IS_ALU_IMM : `ALU_OPB_IS_REGB;
            dest_reg = `DEST_IS_REGC;
            case (inst[31:26])
              `INTA_GRP:
                 case (inst[11:5])
                   `CMPULT_INST:  alu_func = `ALU_CMPULT;
                   `ADDQ_INST:    alu_func = `ALU_ADDQ;
                   `SUBQ_INST:    alu_func = `ALU_SUBQ;
                   `CMPEQ_INST:   alu_func = `ALU_CMPEQ;
                   `CMPULE_INST:  alu_func = `ALU_CMPULE;
                   `CMPLT_INST:   alu_func = `ALU_CMPLT;
                   `CMPLE_INST:   alu_func = `ALU_CMPLE;
                    default:      illegal = `TRUE;
                  endcase // case(inst[11:5])
              `INTL_GRP:
                case (inst[11:5])
                  `AND_INST:    alu_func = `ALU_AND;
                  `BIC_INST:    alu_func = `ALU_BIC;
                  `BIS_INST:    alu_func = `ALU_BIS;
                  `ORNOT_INST:  alu_func = `ALU_ORNOT;
                  `XOR_INST:    alu_func = `ALU_XOR;
                  `EQV_INST:    alu_func = `ALU_EQV;
                  default:      illegal = `TRUE;
                endcase // case(inst[11:5])
              `INTS_GRP:
                case (inst[11:5])
                  `SRL_INST:  alu_func = `ALU_SRL;
                  `SLL_INST:  alu_func = `ALU_SLL;
                  `SRA_INST:  alu_func = `ALU_SRA;
                  default:    illegal = `TRUE;
                endcase // case(inst[11:5])
              `INTM_GRP:
                case (inst[11:5])
                  `MULQ_INST:       alu_func = `ALU_MULQ;
                  default:          illegal = `TRUE;
                endcase // case(inst[11:5])
              `ITFP_GRP:       illegal = `TRUE;       // unimplemented
              `FLTV_GRP:       illegal = `TRUE;       // unimplemented
              `FLTI_GRP:       illegal = `TRUE;       // unimplemented
              `FLTL_GRP:       illegal = `TRUE;       // unimplemented
            endcase // case(inst[31:26])
          end
           
        6'h18:
          case (inst[31:26])
            `MISC_GRP:       illegal = `TRUE; // unimplemented
            `JSR_GRP:
               begin
                 // JMP, JSR, RET, and JSR_CO have identical semantics
                 opa_select = `ALU_OPA_IS_NOT3;
                 opb_select = `ALU_OPB_IS_REGB;
                 alu_func = `ALU_AND; // clear low 2 bits (word-align)
                 dest_reg = `DEST_IS_REGA;
                 uncond_branch = `TRUE;
               end
            `FTPI_GRP:       illegal = `TRUE;       // unimplemented
           endcase // case(inst[31:26])
           
        6'h08, 6'h20, 6'h28:
          begin
            opa_select = `ALU_OPA_IS_MEM_DISP;
            opb_select = `ALU_OPB_IS_REGB;
            alu_func = `ALU_ADDQ;
            dest_reg = `DEST_IS_REGA;
            case (inst[31:26])
              `LDA_INST:  rd_mem = `TRUE;
              `LDQ_INST:
                begin
                  rd_mem = `TRUE;
                  dest_reg = `DEST_IS_REGA;
                end // case: `LDQ_INST
              `STQ_INST:
                begin
                  wr_mem = `TRUE;
                  dest_reg = `DEST_NONE;
                end // case: `STQ_INST
              default:       illegal = `TRUE;
            endcase // case(inst[31:26])
          end
           
        6'h30, 6'h38:
          begin
            opa_select = `ALU_OPA_IS_NPC;
            opb_select = `ALU_OPB_IS_BR_DISP;
            alu_func = `ALU_ADDQ;
            case (inst[31:26])
              `FBEQ_INST, `FBLT_INST, `FBLE_INST,
              `FBNE_INST, `FBGE_INST, `FBGT_INST:
                begin
                  // FP conditionals not implemented
                  illegal = `TRUE;
                end
                 
              `BR_INST, `BSR_INST:
                begin
                  dest_reg = `DEST_IS_REGA;
                  uncond_branch = `TRUE;
                end
  
              default:
                cond_branch = `TRUE; // all others are conditional
            endcase // case(inst[31:26])
          end
      endcase // case(inst[31:29] << 3)
    end // if(~valid_inst_in)
  end // always
   
endmodule // decoder


//`timescale 1ns/100ps

module id_stage(
              // Inputs
              clock,
              reset,
              if_id_IR_1,
              if_id_valid_inst_1,

              if_id_IR_2,
              if_id_valid_inst_2,

              // Outputs
              id_opa_select_out_1,
              id_opb_select_out_1,            
              id_dest_reg_idx_out_1,
              id_alu_func_out_1,
              id_rd_mem_out_1,
              id_wr_mem_out_1,
              id_cond_branch_out_1,
              id_uncond_branch_out_1,
              id_halt_out_1,
              id_illegal_out_1,
              id_valid_inst_out_1,
              
              //Registers to Map Table
              //[4:0]
              //REMOVED C
              ra_idx_1,
              rb_idx_1,

              id_opa_select_out_2,
              id_opb_select_out_2,
              id_dest_reg_idx_out_2,
              id_alu_func_out_2,
              id_rd_mem_out_2,
              id_wr_mem_out_2,
              id_cond_branch_out_2,
              id_uncond_branch_out_2,
              id_halt_out_2,
              id_illegal_out_2,
              id_valid_inst_out_2,
              ra_idx_2,
              rb_idx_2
              );


  input         clock;                // system clock
  input         reset;                // system reset

  input  [31:0] if_id_IR_1;             // incoming instruction
  input         if_id_valid_inst_1;

  input  [31:0] if_id_IR_2;             // incoming instruction
  input         if_id_valid_inst_2;


  output  [1:0] id_opa_select_out_1;    // ALU opa mux select (ALU_OPA_xxx *)
  output  [1:0] id_opb_select_out_1;    // ALU opb mux select (ALU_OPB_xxx *)
  output  [4:0] id_dest_reg_idx_out_1;  // destination (writeback) register index
                                      // (ZERO_REG if no writeback)
  output  [4:0] id_alu_func_out_1;      // ALU function select (ALU_xxx *)
  output        id_rd_mem_out_1;        // does inst read memory?
  output        id_wr_mem_out_1;        // does inst write memory?
  output        id_cond_branch_out_1;   // is inst a conditional branch?
  output        id_uncond_branch_out_1; // is inst an unconditional branch 
                                      // or jump?
  output        id_halt_out_1;
  output        id_illegal_out_1;
  output        id_valid_inst_out_1;    // is inst a valid instruction to be 
                                      // counted for CPI calculations?

  output  [1:0] id_opa_select_out_2;    // ALU opa mux select (ALU_OPA_xxx *)
  output  [1:0] id_opb_select_out_2;    // ALU opb mux select (ALU_OPB_xxx *)
  output  [4:0] id_dest_reg_idx_out_2;  // destination (writeback) register index
                                      // (ZERO_REG if no writeback)
  output  [4:0] id_alu_func_out_2;      // ALU function select (ALU_xxx *)
  output        id_rd_mem_out_2;        // does inst read memory?
  output        id_wr_mem_out_2;        // does inst write memory?
  output        id_cond_branch_out_2;   // is inst a conditional branch?
  output        id_uncond_branch_out_2; // is inst an unconditional branch 
                                      // or jump?
  output        id_halt_out_2;
  output        id_illegal_out_2;
  output        id_valid_inst_out_2;    // is inst a valid instruction to be 
                                      // counted for CPI calculations?
   
  wire    [1:0] dest_reg_select_1, dest_reg_select_2;
  reg     [4:0] id_dest_reg_idx_out_1, id_dest_reg_idx_out_2;     // not state: behavioral mux output
   
    // instruction fields read from IF/ID pipeline register
  output wire    [4:0] ra_idx_1;   // inst operand A register index
  output wire    [4:0] rb_idx_1;   // inst operand B register index
  wire    [4:0] rc_idx_1;     // inst operand C register index
  
  assign ra_idx_1 = (id_opa_select_out_1 == `ALU_OPA_IS_REGA) ? if_id_IR_1[25:21] : `ZERO_REG;
  assign rb_idx_1 = (id_opb_select_out_1 == `ALU_OPB_IS_REGB) ? if_id_IR_1[20:16] : `ZERO_REG;
  assign rc_idx_1 = if_id_IR_1[4:0];

    // instruction fields read from IF/ID pipeline register
  output wire    [4:0] ra_idx_2;   // inst operand A register index
  output wire    [4:0] rb_idx_2;   // inst operand B register index
  wire           [4:0] rc_idx_2;     // inst operand C register index

  assign ra_idx_2 = (id_opa_select_out_2 == `ALU_OPA_IS_REGA) ? if_id_IR_2[25:21]   : `ZERO_REG;
  assign rb_idx_2 = (id_opb_select_out_2 == `ALU_OPB_IS_REGB) ? if_id_IR_2[20:16] : `ZERO_REG;
  assign rc_idx_2 = if_id_IR_2[4:0];

    // instantiate the instruction decoder
  decoder decoder_1 (// Input
                     .inst(if_id_IR_1),
                     .valid_inst_in(if_id_valid_inst_1),

                     // Outputs
                     .opa_select(id_opa_select_out_1),
                     .opb_select(id_opb_select_out_1),
                     .alu_func(id_alu_func_out_1),
                     .dest_reg(dest_reg_select_1),
                     .rd_mem(id_rd_mem_out_1),
                     .wr_mem(id_wr_mem_out_1),
                     .cond_branch(id_cond_branch_out_1),
                     .uncond_branch(id_uncond_branch_out_1),
                     .halt(id_halt_out_1),
                     .illegal(id_illegal_out_1),
                     .valid_inst(id_valid_inst_out_1)
                    );

  decoder decoder_2 (// Input
                     .inst(if_id_IR_2),
                     .valid_inst_in(if_id_valid_inst_2),

                     // Outputs
                     .opa_select(id_opa_select_out_2),
                     .opb_select(id_opb_select_out_2),
                     .alu_func(id_alu_func_out_2),
                     .dest_reg(dest_reg_select_2),
                     .rd_mem(id_rd_mem_out_2),
                     .wr_mem(id_wr_mem_out_2),
                     .cond_branch(id_cond_branch_out_2),
                     .uncond_branch(id_uncond_branch_out_2),
                     .halt(id_halt_out_2),
                     .illegal(id_illegal_out_2),
                     .valid_inst(id_valid_inst_out_2)
                    );
     // mux to generate dest_reg_idx based on
     // the dest_reg_select output from decoder
  always @*
    begin
      case (dest_reg_select_1)
        `DEST_IS_REGC: id_dest_reg_idx_out_1 = rc_idx_1;
        `DEST_IS_REGA: id_dest_reg_idx_out_1 = if_id_IR_1[25:21];
        `DEST_NONE:    id_dest_reg_idx_out_1 = `ZERO_REG;
        default:       id_dest_reg_idx_out_1 = `ZERO_REG; 
      endcase
      case (dest_reg_select_2)
        `DEST_IS_REGC: id_dest_reg_idx_out_2 = rc_idx_2;
        `DEST_IS_REGA: id_dest_reg_idx_out_2 = if_id_IR_2[25:21];
        `DEST_NONE:    id_dest_reg_idx_out_2 = `ZERO_REG;
        default:       id_dest_reg_idx_out_2 = `ZERO_REG; 
      endcase
    end
   
endmodule // module id_stage













