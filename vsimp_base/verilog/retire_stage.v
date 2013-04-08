module retire_stage(
                clock, reset, 
                //inputs
                rob_register_in1, rob_register_in2, rob_value_in1, rob_value_in2, instruction_in1, instruction_in2,
                complete_head1, complete_head2,

                //outputs
                register_out1, register_out2, value_out1, value_out2
              );

  input wire clock;
  input wire reset;

  input  [4:0] rob_register_in1;
  input  [4:0] rob_register_in2;
  input [63:0] rob_value_in1;
  input [63:0] rob_value_in2;
  input [31:0] instruction_in1;
  input [31:0] instruction_in2;

  input complete_head1;
  input complete_head2;


  output  [4:0] register_out1;
  output  [4:0] register_out2;
  output [63:0] value_out1;
  output [63:0] value_out2;


  /*** internals ***/
  reg next_state0; //next state bits
  reg next_state1;
  
  reg current_state0; //current state bits
  reg current_state1;

  reg [1:0] state;



  /*** parameters ***/
  parameter INITIAL       = 2'b00;    //Initial state
  parameter BOTH_COMPLETE = 2'b01;    //Both heads are complete and can retire
  parameter HEAD1_ONLY    = 2'b10;    //Only the head1 is complete and can retire
  parameter NONE          = 2'b11;    //Neither head can retire



  assign next_state1 = !(complete_head1 && complete_head2);
  assign next_state0 = !(complete_head1 && !complete_head2);
  

  always @(posedge clock)
  begin
    if(reset)
    begin
      current_state1 <= 0;
      current_state0 <= 0;
      state          <= 2'b00;
    end
    
    else
    begin
      current_state1 <= next_state1;
      current_state0 <= next_state0;
      state          <= {next_state1, next_state0};
    end
  end



  /*** output logic ***/
  always @*
  begin
    case(state)
  
    INITIAL: begin
        register_out1 = 
        register_out2 = 
        value_out1    =
        value_out2    =
    end
      
    BOTH: begin
        register_out1 = rob_register_in1;
        register_out2 = rob_register_in2;
        value_out1    = rob_value_in1;
        value_out2    = rob_value_in2;
    end

    HEAD1_ONLY: begin
        register_out1 = rob_register_in1;
        register_out2 = 
        value_out1    = rob_value_in1;
        value_out2    = 
      

  
