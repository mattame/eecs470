/////////////////////////////////////////////////////////////////////////
//                                                                     //
//   Modulename :  mem_stage.v                                         //
//                                                                     //
//  Description :  memory access (MEM) stage of the pipeline;          //
//                 this stage accesses memory for stores and loads,    // 
//                 and selects the proper next PC value for branches   // 
//                 based on the branch condition computed in the       //
//                 previous stage.                                     // 
//                                                                     //
//                                                                     //
/////////////////////////////////////////////////////////////////////////

`timescale 1ns/100ps

module mem_stage(// Inputs
                 clock,
                 reset,
                 ex_mem_rega,
                 ex_mem_alu_result,
                 ex_mem_rd_mem,
                 ex_mem_wr_mem,
                 Dmem2proc_data,
                 
                 // Outputs
                 mem_result_out,
                 proc2Dmem_command,
                 proc2Dmem_addr,
                 proc2Dmem_data
                );

  input         clock;             // system clock
  input         reset;             // system reset
  input  [63:0] ex_mem_rega;       // regA value from reg file (store data)
  input  [63:0] ex_mem_alu_result; // incoming ALU result from EX
  input         ex_mem_rd_mem;     // read memory? (from decoder)
  input         ex_mem_wr_mem;     // write memory? (from decoder)
  input  [63:0] Dmem2proc_data;

  output [63:0] mem_result_out;    // outgoing instruction result (to MEM/WB)
  output [1:0]  proc2Dmem_command;
  output [63:0] proc2Dmem_addr;     // Address sent to data-memory
  output [63:0] proc2Dmem_data;     // Data sent to data-memory


   // Determine the command that must be sent to mem
  assign proc2Dmem_command =
    ex_mem_wr_mem ? `BUS_STORE 
                  : ex_mem_rd_mem ? `BUS_LOAD
                                  : `BUS_NONE;

   // The memory address is calculated by the ALU
  assign proc2Dmem_data = ex_mem_rega;

  assign proc2Dmem_addr = ex_mem_alu_result;

   // Assign the result-out for next stage
  assign mem_result_out = (ex_mem_rd_mem) ? Dmem2proc_data : ex_mem_alu_result;

endmodule // module mem_stage
