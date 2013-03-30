

///////////////////////////////////////////////////////////////////////////////
// This file will hold module definitions of the reservation station table.  //
// The main module utilizes multiple individual reservation station modules. //
///////////////////////////////////////////////////////////////////////////////

`define SD #1

// defined paramters //
`define RESERVATION_STATIONS 8
`define RS_EMPTY        3'b000
`define RS_WAITING_A    3'b001
`define RS_WAITING_B    3'b010
`define RS_WAITING_BOTH 3'b011
`define RS_READY        3'b100
`define RSTAG_NULL      8'hFF           


// individual reservation station entry module //
module reservation_station_entry(clock,reset,fill,                               // signals in

                           // input busses //
                           dest_reg_in,
                           rega_value_in,
                           regb_value_in,
                           waiting_taga_in,
                           waiting_tagb_in,                

                           // generic signals to just be passed on //
                           opa_select_in,
                           opb_select_in,
                           alu_func_in,
                           rd_mem_in,
                           wr_mem_in,
                           cond_branch_in,
                           uncond_branch_in,

                           // cdbs in //
                           cdb1_tag_in,cdb1_value_in,                
                           cdb2_tag_in,cdb2_value_in,

                           // outputs //
                           status_out,                                           // signals out
                           dest_reg_out,
                           rega_value_out,
                           regb_value_out, 

                           // outputs for signals to simply be passed through
                           opa_select_out,
                           opb_select_out,
                           alu_func_out,
                           rd_mem_out,
                           wr_mem_out,
                           cond_branch_out,
                           uncond_branch_out

                           );

   // inputs //
   input wire clock;
   input wire reset;
   input wire fill;
   input wire [4:0]  dest_reg_in;
   input wire [63:0] rega_value_in;
   input wire [63:0] regb_value_in;
   input wire [7:0]  waiting_taga_in;
   input wire [7:0]  waiting_tagb_in;

   input wire [7:0]  cdb1_tag_in;
   input wire [7:0]  cdb2_tag_in;
   input wire [63:0] cdb1_value_in;
   input wire [63:0] cdb2_value_in;

   input wire [1:0] opa_select_in;
   input wire [1:0] opb_select_in;
   input wire [4:0] alu_func_in;
   input wire       rd_mem_in;
   input wire       wr_mem_in;
   input wire       cond_branch_in;
   input wire       uncond_branch_in;


   // outputs //
   output reg  [2:0]  status_out;
   output reg  [4:0]  dest_reg_out;
   output reg  [63:0] rega_value_out;
   output reg  [63:0] regb_value_out;

   output reg  [1:0]  opa_select_out;
   output reg  [1:0]  opb_select_out;
   output reg  [4:0]  alu_func_out;
   output reg         rd_mem_out;
   output reg         wr_mem_out;
   output reg         cond_branch_out;
   output reg         uncond_branch_out;


   // internal registers and wires //
   reg  [2:0]  n_status;
   reg  [4:0]  n_dest_reg;
   reg  [7:0]    waiting_taga;
   reg  [7:0]  n_waiting_taga;
   reg  [7:0]    waiting_tagb;
   reg  [7:0]  n_waiting_tagb; 
   reg  [63:0] n_rega_value;
   reg  [63:0] n_regb_value;

   reg [1:0]  n_opa_select_out;
   reg [1:0]  n_opb_select_out;
   reg [4:0]  n_alu_func_out;
   reg        n_rd_mem_out;
   reg        n_wr_mem_out;
   reg        n_cond_branch_out;
   reg        n_uncond_branch_out;

   wire taga_in_nonnull;     
   wire tagb_in_nonnull;
   wire taga_cur_nonnull;
   wire tagb_cur_nonnull;
   wire taga_in_match_cdb1_in;
   wire taga_in_match_cdb2_in;
   wire tagb_in_match_cdb1_in;
   wire tagb_in_match_cdb2_in;
   wire taga_cur_match_cdb1_cur;
   wire taga_cur_match_cdb2_cur;
   wire tagb_cur_match_cdb1_cur;
   wire tagb_cur_match_cdb2_cur;

   // combinational assignments //
   assign taga_in_nonnull        = (waiting_taga_in!=`RSTAG_NULL);
   assign tagb_in_nonnull        = (waiting_tagb_in!=`RSTAG_NULL);
   assign taga_cur_nonnull       = (waiting_taga!=`RSTAG_NULL);
   assign tagb_cur_nonnull       = (waiting_tagb!=`RSTAG_NULL);
   assign taga_in_match_cdb1_in  = (waiting_taga_in==cdb1_tag_in);
   assign taga_in_match_cdb2_in  = (waiting_taga_in==cdb2_tag_in);
   assign tagb_in_match_cdb1_in  = (waiting_tagb_in==cdb1_tag_in);
   assign tagb_in_match_cdb2_in  = (waiting_tagb_in==cdb2_tag_in); 
   assign taga_cur_match_cdb1_in = (waiting_taga==cdb1_tag_in);
   assign taga_cur_match_cdb2_in = (waiting_taga==cdb2_tag_in);
   assign tagb_cur_match_cdb1_in = (waiting_tagb==cdb1_tag_in);
   assign tagb_cur_match_cdb2_in = (waiting_tagb==cdb2_tag_in);


   // combinational logic to set next states //
   always@*
   begin

      if (fill)
      begin

         // stuff based on logic //
         n_waiting_taga = (taga_in_match_cdb1_in && taga_in_nonnull) ? `RSTAG_NULL  :
                         ((taga_in_match_cdb2_in && taga_in_nonnull) ? `RSTAG_NULL : waiting_taga_in);
         n_waiting_tagb = (tagb_in_match_cdb1_in && tagb_in_nonnull) ? `RSTAG_NULL  :
                         ((tagb_in_match_cdb2_in && tagb_in_nonnull) ? `RSTAG_NULL :  waiting_tagb_in);
         n_rega_value   = (taga_in_match_cdb1_in && taga_in_nonnull) ? cdb1_value_in :
                         ((taga_in_match_cdb2_in && taga_in_nonnull) ? cdb2_value_in : rega_value_in);
         n_regb_value   = (tagb_in_match_cdb1_in && tagb_in_nonnull) ? cdb1_value_in :
                         ((tagb_in_match_cdb2_in && tagb_in_nonnull) ? cdb2_value_in : regb_value_in);
         case ({ (n_waiting_taga!=`RSTAG_NULL), (n_waiting_tagb!=`RSTAG_NULL) })
            2'b00: n_status = `RS_READY;
            2'b01: n_status = `RS_WAITING_B;
            2'b10: n_status = `RS_WAITING_A;
            2'b11: n_status = `RS_WAITING_BOTH;
         endcase
         
         // pass-throughs //
         n_dest_reg          = dest_reg_in;
         n_opa_select_out    = opa_select_in; 
         n_opb_select_out    = opb_select_in; 
         n_alu_func_out      = alu_func_in;
         n_rd_mem_out        = rd_mem_in;
         n_wr_mem_out        = wr_mem_in;
         n_cond_branch_out   = cond_branch_in;
         n_uncond_branch_out = uncond_branch_in;

      end
      else
      begin

         // stuff based on logic //
         n_waiting_taga = (taga_cur_match_cdb1_in && taga_cur_nonnull) ? `RSTAG_NULL : 
                         ((taga_cur_match_cdb2_in && taga_cur_nonnull) ? `RSTAG_NULL : waiting_taga);
         n_waiting_tagb = (tagb_cur_match_cdb1_in && tagb_cur_nonnull) ? `RSTAG_NULL : 
                         ((tagb_cur_match_cdb2_in && tagb_cur_nonnull) ? `RSTAG_NULL : waiting_tagb);
         n_rega_value   = (taga_cur_match_cdb1_in && taga_cur_nonnull) ? cdb1_value_in :
                         ((taga_cur_match_cdb2_in && taga_cur_nonnull) ? cdb2_value_in : rega_value_out);
         n_regb_value   = (tagb_cur_match_cdb1_in && tagb_cur_nonnull) ? cdb1_value_in : 
                         ((tagb_cur_match_cdb2_in && tagb_cur_nonnull) ? cdb2_value_in : regb_value_out);
         case ({ (n_waiting_taga!=`RSTAG_NULL), (n_waiting_tagb!=`RSTAG_NULL) })
            2'b00: n_status = `RS_READY;
            2'b01: n_status = `RS_WAITING_B;
            2'b10: n_status = `RS_WAITING_A;
            2'b11: n_status = `RS_WAITING_BOTH;
         endcase

         // pass-throughs //
         n_dest_reg          = dest_reg_out;
         n_opa_select_out    = opa_select_out;
         n_opb_select_out    = opb_select_out;
         n_alu_func_out      = alu_func_out;
         n_rd_mem_out        = rd_mem_out;
         n_wr_mem_out        = wr_mem_out;
         n_cond_branch_out   = cond_branch_out;
         n_uncond_branch_out = uncond_branch_out;

      end
   end

   // clock synchronous events //
   always@(posedge clock)
   begin
      if (reset)
      begin
         status_out        <= `SD `RS_EMPTY;
         dest_reg_out      <= `SD 5'd0;
         waiting_taga      <= `SD `RSTAG_NULL;
         waiting_tagb      <= `SD `RSTAG_NULL;
         rega_value_out    <= `SD 64'd0;
         regb_value_out    <= `SD 64'd0;
         opa_select_out    <= `SD 2'b00;
         opb_select_out    <= `SD 2'b00;
         alu_func_out      <= `SD 5'd0;
         rd_mem_out        <= `SD 1'b0;
         wr_mem_out        <= `SD 1'b0;
         cond_branch_out   <= `SD 1'b0;
         uncond_branch_out <= `SD 1'b0;
      end
      else
      begin
         status_out        <= `SD n_status;
         dest_reg_out      <= `SD n_dest_reg;
         waiting_taga      <= `SD n_waiting_taga;
         waiting_tagb      <= `SD n_waiting_tagb;
         rega_value_out    <= `SD n_rega_value;
         regb_value_out    <= `SD n_regb_value;
         opa_select_out    <= `SD n_opa_select_out;
         opb_select_out    <= `SD n_opb_select_out;
         alu_func_out      <= `SD n_alu_func_out;
         rd_mem_out        <= `SD n_rd_mem_out;
         wr_mem_out        <= `SD n_wr_mem_out;
         cond_branch_out   <= `SD n_cond_branch_out;
         uncond_branch_out <= `SD n_uncond_branch_out;
      end
   end

endmodule



// needed outputs from decode stage: //
//
// wire [63:0] id_rega_out;
// wire [63:0] id_regb_out;
// wire  [1:0] id_opa_select_out;
// wire  [1:0] id_opb_select_out;
// wire  [4:0] id_dest_reg_idx_out;
// wire  [4:0] id_alu_func_out;
// wire        id_rd_mem_out;
// wire        id_wr_mem_out;
// wire        id_cond_branch_out;
// wire        id_uncond_branch_out;
// wire        id_halt_out;
// wire        id_illegal_out;
// wire        id_valid_inst_out;
//
// FROM SCOTT:  //
//
// opa_select
// opb_select
// alu_func
// dest_reg
// cond_branch
// uncond_branch
// valid_inst
//


// the actual reservation station module //
module reservation_station(clock,reset,               // signals in

                           // signals and busses in for inst 1 (from id1) //
                           inst1_rega_value_in,
                           inst1_regb_value_in,
                           inst1_rega_tag_in,
                           inst1_regb_tag_in,
                           inst1_dest_reg_in,
                           inst1_dest_tag_in,
                           inst1_opa_select_in,
                           inst1_opb_select_in,
                           inst1_alu_func_in,
                           inst1_rd_mem_in,
                           inst1_wr_mem_in,
                           inst1_cond_branch_in,
                           inst1_uncond_branch_in,
                           inst1_valid,

                           // signals and busses in for inst 2 (from id2) //
                           inst2_rega_value_in,
                           inst2_regb_value_in,
                           inst2_rega_tag_in,
                           inst2_regb_tag_in,
                           inst2_dest_reg_in,
                           inst2_dest_tag_in,
                           inst2_opa_select_in,
                           inst2_opb_select_in,
                           inst2_alu_func_in,
                           inst2_rd_mem_in,
                           inst2_wr_mem_in,
                           inst2_cond_branch_in,
                           inst2_uncond_branch_in,
                           inst2_valid,

                           // cdb inputs //
                           cdb1_tag_in,
                           cdb2_tag_in,
                           cdb1_value_in,
                           cdb2_value_in,

                           // signals and busses out for inst1 to the ex stage
                           inst1_rega_value_out,inst1_regb_value_out,
                           inst1_opa_select_out,inst1_opb_select_out,
                           inst1_alu_func_out,
                           inst1_rd_mem_out,inst1_wr_mem_out,
                           inst1_cond_branch_out,inst1_uncond_branch_out,
                           inst1_valid_out,
                           inst1_dest_reg_out,
                           inst1_dest_tag_out,

                           // signals and busses out for inst2 to the ex stage
                           inst2_rega_value_out,inst2_regb_value_out,
                           inst2_opa_select_out,inst2_opb_select_out,
                           inst2_alu_func_out,
                           inst2_rd_mem_out,inst2_wr_mem_out,
                           inst2_cond_branch_out,inst2_uncond_branch_out,
                           inst2_valid_out,
                           inst2_dest_reg_out,
                           inst2_dest_tag_out,

                           // signal outputs //
                           inst1_dispatch,
                           inst2_dispatch,
                           table_full    
                         
                           // outputs for debugging //
                           rs_ready_by_age_decoded     );


   // inputs //
   input wire clock;
   input wire reset;

   input wire [63:0] inst1_rega_value_in,inst1_regb_value_in;
   input wire [63:0] inst2_rega_value_in,inst2_regb_value_in;
   input wire [7:0]  inst1_rega_tag_in,inst1_regb_tag_in;
   input wire [7:0]  inst2_rega_tag_in,inst2_regb_tag_in;
   input wire [4:0]  inst1_dest_reg_in;
   input wire [4:0]  inst2_dest_reg_in;
   input wire [7:0]  inst1_dest_tag_in;
   input wire [7:0]  inst2_dest_tag_in;
   input wire [1:0]  inst1_opa_select_in,inst1_opb_select_in;
   input wire [1:0]  inst2_opa_select_in,inst2_opb_select_in;
   input wire [4:0]  inst1_alu_func_in;
   input wire [4:0]  inst2_alu_func_in;
   input wire        inst1_rd_mem_in,inst1_wr_mem_in;
   input wire        inst2_rd_mem_in,inst2_wr_mem_in;
   input wire        inst1_cond_branch_in,inst1_uncond_branch_in;
   input wire        inst2_cond_branch_in,inst2_uncond_branch_in;
   input wire        inst1_valid;
   input wire        inst2_valid;

   input wire [7:0] cdb1_tag_in;
   input wire [7:0] cdb2_tag_in;
   input wire [63:0] cdb1_value_in;
   input wire [63:0] cdb2_value_in;


   // outputs //
   output wire inst1_dispatch;
   output wire inst2_dispatch;
   output wand table_full; 

   output wire [63:0] inst1_rega_value_out,inst1_regb_value_out;
   output wire [1:0]  inst1_opa_select_out,inst1_opb_select_out;
   output wire [4:0]  inst1_alu_func_out;
   output wire        inst1_rd_mem_out,inst1_wr_mem_out;
   output wire        inst1_cond_branch_out,inst1_uncond_branch_out;
   output wire        inst1_valid_out;
   output wire [4:0]  inst1_dest_reg_out;
   output wire [7:0]  inst1_dest_tag_out;

   output wire [63:0] inst2_rega_value_out,inst2_regb_value_out;
   output wire [1:0]  inst2_opa_select_out,inst2_opb_select_out;
   output wire [4:0]  inst2_alu_func_out;
   output wire        inst2_rd_mem_out,inst2_wr_mem_out;
   output wire        inst2_cond_branch_out,inst2_uncond_branch_out;
   output wire        inst2_valid_out;
   output wire [4:0]  inst2_dest_reg_out;
   output wire [7:0]  inst2_dest_tag_out;


   // internal wires //
   wire [2:0] rs_statuses      [(`RESERVATION_STATIONS-1):0];
   wire [7:0] rs_waiting_tags1 [(`RESERVATION_STATIONS-1):0];
   wire [7:0] rs_waiting_tags2 [(`RESERVATION_STATIONS-1):0]; 

   reg  [5:0]   rs_ages          [(`RESERVATION_STATIONS-1):0];
   wire [5:0] n_rs_ages          [(`RESERVATION_STATIONS-1):0];
   wire [5:0]   rs_ages_plus_one [(`RESERVATION_STATIONS-1):0];
   output wor [(`RESERVATION_STATIONS-1):0] rs_ready_by_age_decoded;


   // combinational logic for assigning rs age values //
   genvar i;
   generate
      for (i=0; i<`RESERVATION_STATIONS; i=i+1)
      begin : ASSIGNRSAGESPLUSONE
         assign rs_ages_plus_one[i] = rs_ages[i] + 6'd1;
      end
   endgenerate
 
      assign n_rs_ages[i] = (rs_statuses[i]==`RS_EMPTY &&   )



   // combination logic for assigning rs_ready_by_age_decoded //
   // this bus indicates which rs entries are ready to be issued, in order //
   // of their currently assigned age //
   genvar i;
   generate
      for (i=0; i<`RESERVATION_STATIONS; i=i+1)
      begin : ASSIGNREADYBYAGEDECODED
         assign = rs_ready_by_age_decoded = ( {(`RESERVATION_STATIONS-1){1'b0},(rs_statuses[i]==`RS_READY)} << rs_ages[i] );
      end
   end


   // combinational logic to determine if table is table full //
   always @*
   begin
      genvar i;
      generate
         for (i=0; i<`RESERVATION_STATIONS; i=i+1)
            table_full = (rs_statuses[i]==`RS_READY);
      generate
   end


   // internal modules //
   reservation_station rses [(`RESERVATION_STATIONS-1):0] ( .clock(`RESERVATION_STATIONS{clock}), .reset(`RESERVATION_STATIONS{reset}),
                                                            .status(rs_statuses), .waiting_tag1(rs_waiting_tags1), .waiting_tag2(rs_waiting_tags2)
                                                                                                                                                    );


endmodule



