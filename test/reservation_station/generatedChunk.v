   assign ready_states[0]     = (statuses[0]==`RS_READY);
   assign issue_first_states[0]  = ready_states[0]
          && (~ready_states[1] || comp_table[1][0]) 
          && (~ready_states[2] || comp_table[2][0]) 
          && (~ready_states[3] || comp_table[3][0]) 
   ;
   assign issue_second_states[0] = ready_states[0] && ~issue_first_states[0] 
          && (~ready_states[1] || comp_table[1][0] || issue_first_states[1]) 
          && (~ready_states[2] || comp_table[2][0] || issue_first_states[2]) 
          && (~ready_states[3] || comp_table[3][0] || issue_first_states[3]) 
   ;
   assign comp_table[0][0]       = (ages[0]<ages[0]); 
   assign comp_table[0][1]       = (ages[0]<ages[1]); 
   assign comp_table[0][2]       = (ages[0]<ages[2]); 
   assign comp_table[0][3]       = (ages[0]<ages[3]); 
   assign ready_states[1]     = (statuses[1]==`RS_READY);
   assign issue_first_states[1]  = ready_states[1]
          && (~ready_states[0] || comp_table[0][1]) 
          && (~ready_states[2] || comp_table[2][1]) 
          && (~ready_states[3] || comp_table[3][1]) 
   ;
   assign issue_second_states[1] = ready_states[1] && ~issue_first_states[1] 
          && (~ready_states[0] || comp_table[0][1] || issue_first_states[0]) 
          && (~ready_states[2] || comp_table[2][1] || issue_first_states[2]) 
          && (~ready_states[3] || comp_table[3][1] || issue_first_states[3]) 
   ;
   assign comp_table[1][0]       = (ages[1]<ages[0]); 
   assign comp_table[1][1]       = (ages[1]<ages[1]); 
   assign comp_table[1][2]       = (ages[1]<ages[2]); 
   assign comp_table[1][3]       = (ages[1]<ages[3]); 
   assign ready_states[2]     = (statuses[2]==`RS_READY);
   assign issue_first_states[2]  = ready_states[2]
          && (~ready_states[0] || comp_table[0][2]) 
          && (~ready_states[1] || comp_table[1][2]) 
          && (~ready_states[3] || comp_table[3][2]) 
   ;
   assign issue_second_states[2] = ready_states[2] && ~issue_first_states[2] 
          && (~ready_states[0] || comp_table[0][2] || issue_first_states[0]) 
          && (~ready_states[1] || comp_table[1][2] || issue_first_states[1]) 
          && (~ready_states[3] || comp_table[3][2] || issue_first_states[3]) 
   ;
   assign comp_table[2][0]       = (ages[2]<ages[0]); 
   assign comp_table[2][1]       = (ages[2]<ages[1]); 
   assign comp_table[2][2]       = (ages[2]<ages[2]); 
   assign comp_table[2][3]       = (ages[2]<ages[3]); 
   assign ready_states[3]     = (statuses[3]==`RS_READY);
   assign issue_first_states[3]  = ready_states[3]
          && (~ready_states[0] || comp_table[0][3]) 
          && (~ready_states[1] || comp_table[1][3]) 
          && (~ready_states[2] || comp_table[2][3]) 
   ;
   assign issue_second_states[3] = ready_states[3] && ~issue_first_states[3] 
          && (~ready_states[0] || comp_table[0][3] || issue_first_states[0]) 
          && (~ready_states[1] || comp_table[1][3] || issue_first_states[1]) 
          && (~ready_states[2] || comp_table[2][3] || issue_first_states[2]) 
   ;
   assign comp_table[3][0]       = (ages[3]<ages[0]); 
   assign comp_table[3][1]       = (ages[3]<ages[1]); 
   assign comp_table[3][2]       = (ages[3]<ages[2]); 
   assign comp_table[3][3]       = (ages[3]<ages[3]); 
