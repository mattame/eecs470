/////////////////////////////////////////////////////////////////////////
//                                                                     //
//                                                                     //
//   Modulename :  testbench.v                                         //
//                                                                     //
//  Description :  Testbench module for the verisimple pipeline;       //
//                                                                     //
//                                                                     //
/////////////////////////////////////////////////////////////////////////

`timescale 1ns/100ps

extern void print_header(string str);
extern void print_cycles();
extern void print_stage(string div, int inst, int npc, int valid_inst);
extern void print_reg(int wb_reg_wr_data_out_hi, int wb_reg_wr_data_out_lo,
                      int wb_reg_wr_idx_out, int wb_reg_wr_en_out);
extern void print_membus(int proc2mem_command, int mem2proc_response,
                         int proc2mem_addr_hi, int proc2mem_addr_lo,
                         int proc2mem_data_hi, int proc2mem_data_lo);
extern void print_close();


module testbench;

// Registers and wires used in the testbench
reg        clock;
reg        reset;
reg [31:0] clock_count;
reg [31:0] instr_count;
integer    wb_fileno;

wire [1:0]  proc2mem_command;
wire [63:0] proc2mem_addr;
wire [63:0] proc2mem_data;
wire [3:0]  mem2proc_response;
wire [63:0] mem2proc_data;
wire [3:0]  mem2proc_tag;

wire [3:0]  pipeline_completed_insts;
wire [3:0]  pipeline_error_status;
wire [4:0]  pipeline_commit_wr_idx;
wire [63:0] pipeline_commit_wr_data;
wire        pipeline_commit_wr_en;
wire [63:0] pipeline_commit_NPC;


wire [63:0] if_NPC_out;
wire [31:0] if_IR_out;
wire        if_valid_inst_out;
wire [63:0] if_id_NPC;
wire [31:0] if_id_IR;
wire        if_id_valid_inst;
wire [63:0] id_ex_NPC;
wire [31:0] id_ex_IR;
wire        id_ex_valid_inst;
wire [63:0] ex_mem_NPC;
wire [31:0] ex_mem_IR;
wire        ex_mem_valid_inst;
wire [63:0] mem_wb_NPC;
wire [31:0] mem_wb_IR;
wire        mem_wb_valid_inst;

// Instantiate the Pipeline
pipeline pipeline_0 (// Inputs
                     .clock             (clock),
                     .reset             (reset),
                     .mem2proc_response (mem2proc_response),
                     .mem2proc_data     (mem2proc_data),
                     .mem2proc_tag      (mem2proc_tag),
                     
     
                      // Outputs
                     .proc2mem_command  (proc2mem_command),
                     .proc2mem_addr     (proc2mem_addr),
                     .proc2mem_data     (proc2mem_data),
     
                     .pipeline_completed_insts(pipeline_completed_insts),
                     .pipeline_error_status(pipeline_error_status),
                     .pipeline_commit_wr_data(pipeline_commit_wr_data),
                     .pipeline_commit_wr_idx(pipeline_commit_wr_idx),
                     .pipeline_commit_wr_en(pipeline_commit_wr_en),
                     .pipeline_commit_NPC(pipeline_commit_NPC),

                     .if_NPC_out(if_NPC_out),
                     .if_IR_out(if_IR_out),
                     .if_valid_inst_out(if_valid_inst_out),
                     .if_id_NPC(if_id_NPC),
                     .if_id_IR(if_id_IR),
                     .if_id_valid_inst(if_id_valid_inst),
                     .id_ex_NPC(id_ex_NPC),
                     .id_ex_IR(id_ex_IR),
                     .id_ex_valid_inst(id_ex_valid_inst),
                     .ex_mem_NPC(ex_mem_NPC),
                     .ex_mem_IR(ex_mem_IR),
                     .ex_mem_valid_inst(ex_mem_valid_inst),
                     .mem_wb_NPC(mem_wb_NPC),
                     .mem_wb_IR(mem_wb_IR),
                     .mem_wb_valid_inst(mem_wb_valid_inst)
                    );


// Instantiate the Data Memory
mem memory (// Inputs
          .clk               (clock),
          .proc2mem_command  (proc2mem_command),
          .proc2mem_addr     (proc2mem_addr),
          .proc2mem_data     (proc2mem_data),

           // Outputs

          .mem2proc_response (mem2proc_response),
          .mem2proc_data     (mem2proc_data),
          .mem2proc_tag      (mem2proc_tag)
         );

// Generate System Clock
always
begin
  #(`VERILOG_CLOCK_PERIOD/2.0);
  clock = ~clock;
end

// Task to display # of elapsed clock edges
task show_clk_count;
      real cpi;

      begin
	 cpi = (clock_count + 1.0) / instr_count;
	 $display("@@  %0d cycles / %0d instrs = %f CPI\n@@",
		  clock_count+1, instr_count, cpi);
         $display("@@  %4.2f ns total time to execute\n@@\n",
                  clock_count*`VIRTUAL_CLOCK_PERIOD);
      end
      
endtask  // task show_clk_count 

// Show contents of a range of Unified Memory, in both hex and decimal
task show_mem_with_decimal;
 input [31:0] start_addr;
 input [31:0] end_addr;
 integer k;
 integer showing_data;
 begin
  $display("@@@");
  showing_data=0;
  for(k=start_addr;k<=end_addr; k=k+1)
    if (memory.unified_memory[k] != 0)
    begin
      $display("@@@ mem[%5d] = %x : %0d", k*8, memory.unified_memory[k], 
                                               memory.unified_memory[k]);
      showing_data=1;
    end
    else if(showing_data!=0)
    begin
      $display("@@@");
      showing_data=0;
    end
  $display("@@@");
 end
endtask  // task show_mem_with_decimal

initial
begin
    
  clock = 1'b0;
  reset = 1'b0;

  // Pulse the reset signal
  $display("@@\n@@\n@@  %t  Asserting System reset......", $realtime);
  reset = 1'b1;
  @(posedge clock);
  @(posedge clock);

  $readmemh("program.mem", memory.unified_memory);

  @(posedge clock);
  @(posedge clock);
  `SD;
  // This reset is at an odd time to avoid the pos & neg clock edges

  reset = 1'b0;
  $display("@@  %t  Deasserting System reset......\n@@\n@@", $realtime);

  wb_fileno = $fopen("writeback.out");
  
  //Open header AFTER throwing the reset otherwise the reset state is displayed
  print_header("                                                                            D-MEM Bus &\n");
  print_header("Cycle:      IF      |     ID      |     EX      |     MEM     |     WB      Reg Result");
end


// Count the number of posedges and number of instructions completed
// till simulation ends
always @(posedge clock)
begin
  if(reset)
  begin
    clock_count <= `SD 0;
    instr_count <= `SD 0;
  end
  else
  begin
    clock_count <= `SD (clock_count + 1);
    instr_count <= `SD (instr_count + pipeline_completed_insts);
  end
end  


always @(negedge clock)
begin
  if(reset)
    $display("@@\n@@  %t : System STILL at reset, can't show anything\n@@",
             $realtime);
  else
  begin
    `SD;
    `SD;
    
     // print the piepline stuff via c code to the pipeline.out
     print_cycles();
     print_stage(" ", if_IR_out, if_NPC_out[31:0], {31'b0,if_valid_inst_out});
     print_stage("|", if_id_IR, if_id_NPC[31:0], {31'b0,if_id_valid_inst});
     print_stage("|", id_ex_IR, id_ex_NPC[31:0], {31'b0,id_ex_valid_inst});
     print_stage("|", ex_mem_IR, ex_mem_NPC[31:0], {31'b0,ex_mem_valid_inst});
     print_stage("|", mem_wb_IR, mem_wb_NPC[31:0], {31'b0,mem_wb_valid_inst});
     print_reg(pipeline_commit_wr_data[63:32], pipeline_commit_wr_data[31:0],
               {27'b0,pipeline_commit_wr_idx}, {31'b0,pipeline_commit_wr_en});
     print_membus({30'b0,proc2mem_command}, {28'b0,mem2proc_response},
                  proc2mem_addr[63:32], proc2mem_addr[31:0],
                  proc2mem_data[63:32], proc2mem_data[31:0]);


     // print the writeback information to writeback.out
     if(pipeline_completed_insts>0) begin
       if(pipeline_commit_wr_en)
         $fdisplay(wb_fileno, "PC=%x, REG[%d]=%x",
                   pipeline_commit_NPC-4,
                   pipeline_commit_wr_idx,
                   pipeline_commit_wr_data);
      else
        $fdisplay(wb_fileno, "PC=%x, ---",pipeline_commit_NPC-4);
    end

    // deal with any halting conditions
    if(pipeline_error_status!=`NO_ERROR)
    begin
      $display("@@@ Unified Memory contents hex on left, decimal on right: ");
      show_mem_with_decimal(0,`MEM_64BIT_LINES - 1); 
        // 8Bytes per line, 16kB total

      $display("@@  %t : System halted\n@@", $realtime);

      case(pipeline_error_status)
        `HALTED_ON_MEMORY_ERROR:  
            $display("@@@ System halted on memory error");
        `HALTED_ON_HALT:          
            $display("@@@ System halted on HALT instruction");
        `HALTED_ON_ILLEGAL:
            $display("@@@ System halted on illegal instruction");
        default: 
            $display("@@@ System halted on unknown error code %x",
                     pipeline_error_status);
      endcase
      $display("@@@\n@@");
      show_clk_count;
      print_close(); // close the pipe_print output file
      $fclose(wb_fileno);
      #100 $finish;
    end

  end  // if(reset)	 
end 

endmodule  // module testbench

