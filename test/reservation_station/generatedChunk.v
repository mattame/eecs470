   assign ready_states[0]     = (statuses[0]==`RS_READY);
   assign issue_first_states[0]  = ready_states[0]
          && (~ready_states[1] || comp_table[1][0]) 
          && (~ready_states[2] || comp_table[2][0]) 
          && (~ready_states[3] || comp_table[3][0]) 
          && (~ready_states[4] || comp_table[4][0]) 
          && (~ready_states[5] || comp_table[5][0]) 
          && (~ready_states[6] || comp_table[6][0]) 
          && (~ready_states[7] || comp_table[7][0]) 
          && (~ready_states[8] || comp_table[8][0]) 
          && (~ready_states[9] || comp_table[9][0]) 
          && (~ready_states[10] || comp_table[10][0]) 
          && (~ready_states[11] || comp_table[11][0]) 
          && (~ready_states[12] || comp_table[12][0]) 
          && (~ready_states[13] || comp_table[13][0]) 
          && (~ready_states[14] || comp_table[14][0]) 
          && (~ready_states[15] || comp_table[15][0]) 
   ;
   assign issue_second_states[0] = ready_states[0] && ~issue_first_states[0] 
          && (~ready_states[1] || comp_table[1][0] || issue_first_states[1]) 
          && (~ready_states[2] || comp_table[2][0] || issue_first_states[2]) 
          && (~ready_states[3] || comp_table[3][0] || issue_first_states[3]) 
          && (~ready_states[4] || comp_table[4][0] || issue_first_states[4]) 
          && (~ready_states[5] || comp_table[5][0] || issue_first_states[5]) 
          && (~ready_states[6] || comp_table[6][0] || issue_first_states[6]) 
          && (~ready_states[7] || comp_table[7][0] || issue_first_states[7]) 
          && (~ready_states[8] || comp_table[8][0] || issue_first_states[8]) 
          && (~ready_states[9] || comp_table[9][0] || issue_first_states[9]) 
          && (~ready_states[10] || comp_table[10][0] || issue_first_states[10]) 
          && (~ready_states[11] || comp_table[11][0] || issue_first_states[11]) 
          && (~ready_states[12] || comp_table[12][0] || issue_first_states[12]) 
          && (~ready_states[13] || comp_table[13][0] || issue_first_states[13]) 
          && (~ready_states[14] || comp_table[14][0] || issue_first_states[14]) 
          && (~ready_states[15] || comp_table[15][0] || issue_first_states[15]) 
   ;
   assign comp_table[0][0]       = (ages[0]<ages[0]); 
   assign comp_table[0][1]       = (ages[0]<ages[1]); 
   assign comp_table[0][2]       = (ages[0]<ages[2]); 
   assign comp_table[0][3]       = (ages[0]<ages[3]); 
   assign comp_table[0][4]       = (ages[0]<ages[4]); 
   assign comp_table[0][5]       = (ages[0]<ages[5]); 
   assign comp_table[0][6]       = (ages[0]<ages[6]); 
   assign comp_table[0][7]       = (ages[0]<ages[7]); 
   assign comp_table[0][8]       = (ages[0]<ages[8]); 
   assign comp_table[0][9]       = (ages[0]<ages[9]); 
   assign comp_table[0][10]       = (ages[0]<ages[10]); 
   assign comp_table[0][11]       = (ages[0]<ages[11]); 
   assign comp_table[0][12]       = (ages[0]<ages[12]); 
   assign comp_table[0][13]       = (ages[0]<ages[13]); 
   assign comp_table[0][14]       = (ages[0]<ages[14]); 
   assign comp_table[0][15]       = (ages[0]<ages[15]); 
   assign ready_states[1]     = (statuses[1]==`RS_READY);
   assign issue_first_states[1]  = ready_states[1]
          && (~ready_states[0] || comp_table[0][1]) 
          && (~ready_states[2] || comp_table[2][1]) 
          && (~ready_states[3] || comp_table[3][1]) 
          && (~ready_states[4] || comp_table[4][1]) 
          && (~ready_states[5] || comp_table[5][1]) 
          && (~ready_states[6] || comp_table[6][1]) 
          && (~ready_states[7] || comp_table[7][1]) 
          && (~ready_states[8] || comp_table[8][1]) 
          && (~ready_states[9] || comp_table[9][1]) 
          && (~ready_states[10] || comp_table[10][1]) 
          && (~ready_states[11] || comp_table[11][1]) 
          && (~ready_states[12] || comp_table[12][1]) 
          && (~ready_states[13] || comp_table[13][1]) 
          && (~ready_states[14] || comp_table[14][1]) 
          && (~ready_states[15] || comp_table[15][1]) 
   ;
   assign issue_second_states[1] = ready_states[1] && ~issue_first_states[1] 
          && (~ready_states[0] || comp_table[0][1] || issue_first_states[0]) 
          && (~ready_states[2] || comp_table[2][1] || issue_first_states[2]) 
          && (~ready_states[3] || comp_table[3][1] || issue_first_states[3]) 
          && (~ready_states[4] || comp_table[4][1] || issue_first_states[4]) 
          && (~ready_states[5] || comp_table[5][1] || issue_first_states[5]) 
          && (~ready_states[6] || comp_table[6][1] || issue_first_states[6]) 
          && (~ready_states[7] || comp_table[7][1] || issue_first_states[7]) 
          && (~ready_states[8] || comp_table[8][1] || issue_first_states[8]) 
          && (~ready_states[9] || comp_table[9][1] || issue_first_states[9]) 
          && (~ready_states[10] || comp_table[10][1] || issue_first_states[10]) 
          && (~ready_states[11] || comp_table[11][1] || issue_first_states[11]) 
          && (~ready_states[12] || comp_table[12][1] || issue_first_states[12]) 
          && (~ready_states[13] || comp_table[13][1] || issue_first_states[13]) 
          && (~ready_states[14] || comp_table[14][1] || issue_first_states[14]) 
          && (~ready_states[15] || comp_table[15][1] || issue_first_states[15]) 
   ;
   assign comp_table[1][0]       = (ages[1]<ages[0]); 
   assign comp_table[1][1]       = (ages[1]<ages[1]); 
   assign comp_table[1][2]       = (ages[1]<ages[2]); 
   assign comp_table[1][3]       = (ages[1]<ages[3]); 
   assign comp_table[1][4]       = (ages[1]<ages[4]); 
   assign comp_table[1][5]       = (ages[1]<ages[5]); 
   assign comp_table[1][6]       = (ages[1]<ages[6]); 
   assign comp_table[1][7]       = (ages[1]<ages[7]); 
   assign comp_table[1][8]       = (ages[1]<ages[8]); 
   assign comp_table[1][9]       = (ages[1]<ages[9]); 
   assign comp_table[1][10]       = (ages[1]<ages[10]); 
   assign comp_table[1][11]       = (ages[1]<ages[11]); 
   assign comp_table[1][12]       = (ages[1]<ages[12]); 
   assign comp_table[1][13]       = (ages[1]<ages[13]); 
   assign comp_table[1][14]       = (ages[1]<ages[14]); 
   assign comp_table[1][15]       = (ages[1]<ages[15]); 
   assign ready_states[2]     = (statuses[2]==`RS_READY);
   assign issue_first_states[2]  = ready_states[2]
          && (~ready_states[0] || comp_table[0][2]) 
          && (~ready_states[1] || comp_table[1][2]) 
          && (~ready_states[3] || comp_table[3][2]) 
          && (~ready_states[4] || comp_table[4][2]) 
          && (~ready_states[5] || comp_table[5][2]) 
          && (~ready_states[6] || comp_table[6][2]) 
          && (~ready_states[7] || comp_table[7][2]) 
          && (~ready_states[8] || comp_table[8][2]) 
          && (~ready_states[9] || comp_table[9][2]) 
          && (~ready_states[10] || comp_table[10][2]) 
          && (~ready_states[11] || comp_table[11][2]) 
          && (~ready_states[12] || comp_table[12][2]) 
          && (~ready_states[13] || comp_table[13][2]) 
          && (~ready_states[14] || comp_table[14][2]) 
          && (~ready_states[15] || comp_table[15][2]) 
   ;
   assign issue_second_states[2] = ready_states[2] && ~issue_first_states[2] 
          && (~ready_states[0] || comp_table[0][2] || issue_first_states[0]) 
          && (~ready_states[1] || comp_table[1][2] || issue_first_states[1]) 
          && (~ready_states[3] || comp_table[3][2] || issue_first_states[3]) 
          && (~ready_states[4] || comp_table[4][2] || issue_first_states[4]) 
          && (~ready_states[5] || comp_table[5][2] || issue_first_states[5]) 
          && (~ready_states[6] || comp_table[6][2] || issue_first_states[6]) 
          && (~ready_states[7] || comp_table[7][2] || issue_first_states[7]) 
          && (~ready_states[8] || comp_table[8][2] || issue_first_states[8]) 
          && (~ready_states[9] || comp_table[9][2] || issue_first_states[9]) 
          && (~ready_states[10] || comp_table[10][2] || issue_first_states[10]) 
          && (~ready_states[11] || comp_table[11][2] || issue_first_states[11]) 
          && (~ready_states[12] || comp_table[12][2] || issue_first_states[12]) 
          && (~ready_states[13] || comp_table[13][2] || issue_first_states[13]) 
          && (~ready_states[14] || comp_table[14][2] || issue_first_states[14]) 
          && (~ready_states[15] || comp_table[15][2] || issue_first_states[15]) 
   ;
   assign comp_table[2][0]       = (ages[2]<ages[0]); 
   assign comp_table[2][1]       = (ages[2]<ages[1]); 
   assign comp_table[2][2]       = (ages[2]<ages[2]); 
   assign comp_table[2][3]       = (ages[2]<ages[3]); 
   assign comp_table[2][4]       = (ages[2]<ages[4]); 
   assign comp_table[2][5]       = (ages[2]<ages[5]); 
   assign comp_table[2][6]       = (ages[2]<ages[6]); 
   assign comp_table[2][7]       = (ages[2]<ages[7]); 
   assign comp_table[2][8]       = (ages[2]<ages[8]); 
   assign comp_table[2][9]       = (ages[2]<ages[9]); 
   assign comp_table[2][10]       = (ages[2]<ages[10]); 
   assign comp_table[2][11]       = (ages[2]<ages[11]); 
   assign comp_table[2][12]       = (ages[2]<ages[12]); 
   assign comp_table[2][13]       = (ages[2]<ages[13]); 
   assign comp_table[2][14]       = (ages[2]<ages[14]); 
   assign comp_table[2][15]       = (ages[2]<ages[15]); 
   assign ready_states[3]     = (statuses[3]==`RS_READY);
   assign issue_first_states[3]  = ready_states[3]
          && (~ready_states[0] || comp_table[0][3]) 
          && (~ready_states[1] || comp_table[1][3]) 
          && (~ready_states[2] || comp_table[2][3]) 
          && (~ready_states[4] || comp_table[4][3]) 
          && (~ready_states[5] || comp_table[5][3]) 
          && (~ready_states[6] || comp_table[6][3]) 
          && (~ready_states[7] || comp_table[7][3]) 
          && (~ready_states[8] || comp_table[8][3]) 
          && (~ready_states[9] || comp_table[9][3]) 
          && (~ready_states[10] || comp_table[10][3]) 
          && (~ready_states[11] || comp_table[11][3]) 
          && (~ready_states[12] || comp_table[12][3]) 
          && (~ready_states[13] || comp_table[13][3]) 
          && (~ready_states[14] || comp_table[14][3]) 
          && (~ready_states[15] || comp_table[15][3]) 
   ;
   assign issue_second_states[3] = ready_states[3] && ~issue_first_states[3] 
          && (~ready_states[0] || comp_table[0][3] || issue_first_states[0]) 
          && (~ready_states[1] || comp_table[1][3] || issue_first_states[1]) 
          && (~ready_states[2] || comp_table[2][3] || issue_first_states[2]) 
          && (~ready_states[4] || comp_table[4][3] || issue_first_states[4]) 
          && (~ready_states[5] || comp_table[5][3] || issue_first_states[5]) 
          && (~ready_states[6] || comp_table[6][3] || issue_first_states[6]) 
          && (~ready_states[7] || comp_table[7][3] || issue_first_states[7]) 
          && (~ready_states[8] || comp_table[8][3] || issue_first_states[8]) 
          && (~ready_states[9] || comp_table[9][3] || issue_first_states[9]) 
          && (~ready_states[10] || comp_table[10][3] || issue_first_states[10]) 
          && (~ready_states[11] || comp_table[11][3] || issue_first_states[11]) 
          && (~ready_states[12] || comp_table[12][3] || issue_first_states[12]) 
          && (~ready_states[13] || comp_table[13][3] || issue_first_states[13]) 
          && (~ready_states[14] || comp_table[14][3] || issue_first_states[14]) 
          && (~ready_states[15] || comp_table[15][3] || issue_first_states[15]) 
   ;
   assign comp_table[3][0]       = (ages[3]<ages[0]); 
   assign comp_table[3][1]       = (ages[3]<ages[1]); 
   assign comp_table[3][2]       = (ages[3]<ages[2]); 
   assign comp_table[3][3]       = (ages[3]<ages[3]); 
   assign comp_table[3][4]       = (ages[3]<ages[4]); 
   assign comp_table[3][5]       = (ages[3]<ages[5]); 
   assign comp_table[3][6]       = (ages[3]<ages[6]); 
   assign comp_table[3][7]       = (ages[3]<ages[7]); 
   assign comp_table[3][8]       = (ages[3]<ages[8]); 
   assign comp_table[3][9]       = (ages[3]<ages[9]); 
   assign comp_table[3][10]       = (ages[3]<ages[10]); 
   assign comp_table[3][11]       = (ages[3]<ages[11]); 
   assign comp_table[3][12]       = (ages[3]<ages[12]); 
   assign comp_table[3][13]       = (ages[3]<ages[13]); 
   assign comp_table[3][14]       = (ages[3]<ages[14]); 
   assign comp_table[3][15]       = (ages[3]<ages[15]); 
   assign ready_states[4]     = (statuses[4]==`RS_READY);
   assign issue_first_states[4]  = ready_states[4]
          && (~ready_states[0] || comp_table[0][4]) 
          && (~ready_states[1] || comp_table[1][4]) 
          && (~ready_states[2] || comp_table[2][4]) 
          && (~ready_states[3] || comp_table[3][4]) 
          && (~ready_states[5] || comp_table[5][4]) 
          && (~ready_states[6] || comp_table[6][4]) 
          && (~ready_states[7] || comp_table[7][4]) 
          && (~ready_states[8] || comp_table[8][4]) 
          && (~ready_states[9] || comp_table[9][4]) 
          && (~ready_states[10] || comp_table[10][4]) 
          && (~ready_states[11] || comp_table[11][4]) 
          && (~ready_states[12] || comp_table[12][4]) 
          && (~ready_states[13] || comp_table[13][4]) 
          && (~ready_states[14] || comp_table[14][4]) 
          && (~ready_states[15] || comp_table[15][4]) 
   ;
   assign issue_second_states[4] = ready_states[4] && ~issue_first_states[4] 
          && (~ready_states[0] || comp_table[0][4] || issue_first_states[0]) 
          && (~ready_states[1] || comp_table[1][4] || issue_first_states[1]) 
          && (~ready_states[2] || comp_table[2][4] || issue_first_states[2]) 
          && (~ready_states[3] || comp_table[3][4] || issue_first_states[3]) 
          && (~ready_states[5] || comp_table[5][4] || issue_first_states[5]) 
          && (~ready_states[6] || comp_table[6][4] || issue_first_states[6]) 
          && (~ready_states[7] || comp_table[7][4] || issue_first_states[7]) 
          && (~ready_states[8] || comp_table[8][4] || issue_first_states[8]) 
          && (~ready_states[9] || comp_table[9][4] || issue_first_states[9]) 
          && (~ready_states[10] || comp_table[10][4] || issue_first_states[10]) 
          && (~ready_states[11] || comp_table[11][4] || issue_first_states[11]) 
          && (~ready_states[12] || comp_table[12][4] || issue_first_states[12]) 
          && (~ready_states[13] || comp_table[13][4] || issue_first_states[13]) 
          && (~ready_states[14] || comp_table[14][4] || issue_first_states[14]) 
          && (~ready_states[15] || comp_table[15][4] || issue_first_states[15]) 
   ;
   assign comp_table[4][0]       = (ages[4]<ages[0]); 
   assign comp_table[4][1]       = (ages[4]<ages[1]); 
   assign comp_table[4][2]       = (ages[4]<ages[2]); 
   assign comp_table[4][3]       = (ages[4]<ages[3]); 
   assign comp_table[4][4]       = (ages[4]<ages[4]); 
   assign comp_table[4][5]       = (ages[4]<ages[5]); 
   assign comp_table[4][6]       = (ages[4]<ages[6]); 
   assign comp_table[4][7]       = (ages[4]<ages[7]); 
   assign comp_table[4][8]       = (ages[4]<ages[8]); 
   assign comp_table[4][9]       = (ages[4]<ages[9]); 
   assign comp_table[4][10]       = (ages[4]<ages[10]); 
   assign comp_table[4][11]       = (ages[4]<ages[11]); 
   assign comp_table[4][12]       = (ages[4]<ages[12]); 
   assign comp_table[4][13]       = (ages[4]<ages[13]); 
   assign comp_table[4][14]       = (ages[4]<ages[14]); 
   assign comp_table[4][15]       = (ages[4]<ages[15]); 
   assign ready_states[5]     = (statuses[5]==`RS_READY);
   assign issue_first_states[5]  = ready_states[5]
          && (~ready_states[0] || comp_table[0][5]) 
          && (~ready_states[1] || comp_table[1][5]) 
          && (~ready_states[2] || comp_table[2][5]) 
          && (~ready_states[3] || comp_table[3][5]) 
          && (~ready_states[4] || comp_table[4][5]) 
          && (~ready_states[6] || comp_table[6][5]) 
          && (~ready_states[7] || comp_table[7][5]) 
          && (~ready_states[8] || comp_table[8][5]) 
          && (~ready_states[9] || comp_table[9][5]) 
          && (~ready_states[10] || comp_table[10][5]) 
          && (~ready_states[11] || comp_table[11][5]) 
          && (~ready_states[12] || comp_table[12][5]) 
          && (~ready_states[13] || comp_table[13][5]) 
          && (~ready_states[14] || comp_table[14][5]) 
          && (~ready_states[15] || comp_table[15][5]) 
   ;
   assign issue_second_states[5] = ready_states[5] && ~issue_first_states[5] 
          && (~ready_states[0] || comp_table[0][5] || issue_first_states[0]) 
          && (~ready_states[1] || comp_table[1][5] || issue_first_states[1]) 
          && (~ready_states[2] || comp_table[2][5] || issue_first_states[2]) 
          && (~ready_states[3] || comp_table[3][5] || issue_first_states[3]) 
          && (~ready_states[4] || comp_table[4][5] || issue_first_states[4]) 
          && (~ready_states[6] || comp_table[6][5] || issue_first_states[6]) 
          && (~ready_states[7] || comp_table[7][5] || issue_first_states[7]) 
          && (~ready_states[8] || comp_table[8][5] || issue_first_states[8]) 
          && (~ready_states[9] || comp_table[9][5] || issue_first_states[9]) 
          && (~ready_states[10] || comp_table[10][5] || issue_first_states[10]) 
          && (~ready_states[11] || comp_table[11][5] || issue_first_states[11]) 
          && (~ready_states[12] || comp_table[12][5] || issue_first_states[12]) 
          && (~ready_states[13] || comp_table[13][5] || issue_first_states[13]) 
          && (~ready_states[14] || comp_table[14][5] || issue_first_states[14]) 
          && (~ready_states[15] || comp_table[15][5] || issue_first_states[15]) 
   ;
   assign comp_table[5][0]       = (ages[5]<ages[0]); 
   assign comp_table[5][1]       = (ages[5]<ages[1]); 
   assign comp_table[5][2]       = (ages[5]<ages[2]); 
   assign comp_table[5][3]       = (ages[5]<ages[3]); 
   assign comp_table[5][4]       = (ages[5]<ages[4]); 
   assign comp_table[5][5]       = (ages[5]<ages[5]); 
   assign comp_table[5][6]       = (ages[5]<ages[6]); 
   assign comp_table[5][7]       = (ages[5]<ages[7]); 
   assign comp_table[5][8]       = (ages[5]<ages[8]); 
   assign comp_table[5][9]       = (ages[5]<ages[9]); 
   assign comp_table[5][10]       = (ages[5]<ages[10]); 
   assign comp_table[5][11]       = (ages[5]<ages[11]); 
   assign comp_table[5][12]       = (ages[5]<ages[12]); 
   assign comp_table[5][13]       = (ages[5]<ages[13]); 
   assign comp_table[5][14]       = (ages[5]<ages[14]); 
   assign comp_table[5][15]       = (ages[5]<ages[15]); 
   assign ready_states[6]     = (statuses[6]==`RS_READY);
   assign issue_first_states[6]  = ready_states[6]
          && (~ready_states[0] || comp_table[0][6]) 
          && (~ready_states[1] || comp_table[1][6]) 
          && (~ready_states[2] || comp_table[2][6]) 
          && (~ready_states[3] || comp_table[3][6]) 
          && (~ready_states[4] || comp_table[4][6]) 
          && (~ready_states[5] || comp_table[5][6]) 
          && (~ready_states[7] || comp_table[7][6]) 
          && (~ready_states[8] || comp_table[8][6]) 
          && (~ready_states[9] || comp_table[9][6]) 
          && (~ready_states[10] || comp_table[10][6]) 
          && (~ready_states[11] || comp_table[11][6]) 
          && (~ready_states[12] || comp_table[12][6]) 
          && (~ready_states[13] || comp_table[13][6]) 
          && (~ready_states[14] || comp_table[14][6]) 
          && (~ready_states[15] || comp_table[15][6]) 
   ;
   assign issue_second_states[6] = ready_states[6] && ~issue_first_states[6] 
          && (~ready_states[0] || comp_table[0][6] || issue_first_states[0]) 
          && (~ready_states[1] || comp_table[1][6] || issue_first_states[1]) 
          && (~ready_states[2] || comp_table[2][6] || issue_first_states[2]) 
          && (~ready_states[3] || comp_table[3][6] || issue_first_states[3]) 
          && (~ready_states[4] || comp_table[4][6] || issue_first_states[4]) 
          && (~ready_states[5] || comp_table[5][6] || issue_first_states[5]) 
          && (~ready_states[7] || comp_table[7][6] || issue_first_states[7]) 
          && (~ready_states[8] || comp_table[8][6] || issue_first_states[8]) 
          && (~ready_states[9] || comp_table[9][6] || issue_first_states[9]) 
          && (~ready_states[10] || comp_table[10][6] || issue_first_states[10]) 
          && (~ready_states[11] || comp_table[11][6] || issue_first_states[11]) 
          && (~ready_states[12] || comp_table[12][6] || issue_first_states[12]) 
          && (~ready_states[13] || comp_table[13][6] || issue_first_states[13]) 
          && (~ready_states[14] || comp_table[14][6] || issue_first_states[14]) 
          && (~ready_states[15] || comp_table[15][6] || issue_first_states[15]) 
   ;
   assign comp_table[6][0]       = (ages[6]<ages[0]); 
   assign comp_table[6][1]       = (ages[6]<ages[1]); 
   assign comp_table[6][2]       = (ages[6]<ages[2]); 
   assign comp_table[6][3]       = (ages[6]<ages[3]); 
   assign comp_table[6][4]       = (ages[6]<ages[4]); 
   assign comp_table[6][5]       = (ages[6]<ages[5]); 
   assign comp_table[6][6]       = (ages[6]<ages[6]); 
   assign comp_table[6][7]       = (ages[6]<ages[7]); 
   assign comp_table[6][8]       = (ages[6]<ages[8]); 
   assign comp_table[6][9]       = (ages[6]<ages[9]); 
   assign comp_table[6][10]       = (ages[6]<ages[10]); 
   assign comp_table[6][11]       = (ages[6]<ages[11]); 
   assign comp_table[6][12]       = (ages[6]<ages[12]); 
   assign comp_table[6][13]       = (ages[6]<ages[13]); 
   assign comp_table[6][14]       = (ages[6]<ages[14]); 
   assign comp_table[6][15]       = (ages[6]<ages[15]); 
   assign ready_states[7]     = (statuses[7]==`RS_READY);
   assign issue_first_states[7]  = ready_states[7]
          && (~ready_states[0] || comp_table[0][7]) 
          && (~ready_states[1] || comp_table[1][7]) 
          && (~ready_states[2] || comp_table[2][7]) 
          && (~ready_states[3] || comp_table[3][7]) 
          && (~ready_states[4] || comp_table[4][7]) 
          && (~ready_states[5] || comp_table[5][7]) 
          && (~ready_states[6] || comp_table[6][7]) 
          && (~ready_states[8] || comp_table[8][7]) 
          && (~ready_states[9] || comp_table[9][7]) 
          && (~ready_states[10] || comp_table[10][7]) 
          && (~ready_states[11] || comp_table[11][7]) 
          && (~ready_states[12] || comp_table[12][7]) 
          && (~ready_states[13] || comp_table[13][7]) 
          && (~ready_states[14] || comp_table[14][7]) 
          && (~ready_states[15] || comp_table[15][7]) 
   ;
   assign issue_second_states[7] = ready_states[7] && ~issue_first_states[7] 
          && (~ready_states[0] || comp_table[0][7] || issue_first_states[0]) 
          && (~ready_states[1] || comp_table[1][7] || issue_first_states[1]) 
          && (~ready_states[2] || comp_table[2][7] || issue_first_states[2]) 
          && (~ready_states[3] || comp_table[3][7] || issue_first_states[3]) 
          && (~ready_states[4] || comp_table[4][7] || issue_first_states[4]) 
          && (~ready_states[5] || comp_table[5][7] || issue_first_states[5]) 
          && (~ready_states[6] || comp_table[6][7] || issue_first_states[6]) 
          && (~ready_states[8] || comp_table[8][7] || issue_first_states[8]) 
          && (~ready_states[9] || comp_table[9][7] || issue_first_states[9]) 
          && (~ready_states[10] || comp_table[10][7] || issue_first_states[10]) 
          && (~ready_states[11] || comp_table[11][7] || issue_first_states[11]) 
          && (~ready_states[12] || comp_table[12][7] || issue_first_states[12]) 
          && (~ready_states[13] || comp_table[13][7] || issue_first_states[13]) 
          && (~ready_states[14] || comp_table[14][7] || issue_first_states[14]) 
          && (~ready_states[15] || comp_table[15][7] || issue_first_states[15]) 
   ;
   assign comp_table[7][0]       = (ages[7]<ages[0]); 
   assign comp_table[7][1]       = (ages[7]<ages[1]); 
   assign comp_table[7][2]       = (ages[7]<ages[2]); 
   assign comp_table[7][3]       = (ages[7]<ages[3]); 
   assign comp_table[7][4]       = (ages[7]<ages[4]); 
   assign comp_table[7][5]       = (ages[7]<ages[5]); 
   assign comp_table[7][6]       = (ages[7]<ages[6]); 
   assign comp_table[7][7]       = (ages[7]<ages[7]); 
   assign comp_table[7][8]       = (ages[7]<ages[8]); 
   assign comp_table[7][9]       = (ages[7]<ages[9]); 
   assign comp_table[7][10]       = (ages[7]<ages[10]); 
   assign comp_table[7][11]       = (ages[7]<ages[11]); 
   assign comp_table[7][12]       = (ages[7]<ages[12]); 
   assign comp_table[7][13]       = (ages[7]<ages[13]); 
   assign comp_table[7][14]       = (ages[7]<ages[14]); 
   assign comp_table[7][15]       = (ages[7]<ages[15]); 
   assign ready_states[8]     = (statuses[8]==`RS_READY);
   assign issue_first_states[8]  = ready_states[8]
          && (~ready_states[0] || comp_table[0][8]) 
          && (~ready_states[1] || comp_table[1][8]) 
          && (~ready_states[2] || comp_table[2][8]) 
          && (~ready_states[3] || comp_table[3][8]) 
          && (~ready_states[4] || comp_table[4][8]) 
          && (~ready_states[5] || comp_table[5][8]) 
          && (~ready_states[6] || comp_table[6][8]) 
          && (~ready_states[7] || comp_table[7][8]) 
          && (~ready_states[9] || comp_table[9][8]) 
          && (~ready_states[10] || comp_table[10][8]) 
          && (~ready_states[11] || comp_table[11][8]) 
          && (~ready_states[12] || comp_table[12][8]) 
          && (~ready_states[13] || comp_table[13][8]) 
          && (~ready_states[14] || comp_table[14][8]) 
          && (~ready_states[15] || comp_table[15][8]) 
   ;
   assign issue_second_states[8] = ready_states[8] && ~issue_first_states[8] 
          && (~ready_states[0] || comp_table[0][8] || issue_first_states[0]) 
          && (~ready_states[1] || comp_table[1][8] || issue_first_states[1]) 
          && (~ready_states[2] || comp_table[2][8] || issue_first_states[2]) 
          && (~ready_states[3] || comp_table[3][8] || issue_first_states[3]) 
          && (~ready_states[4] || comp_table[4][8] || issue_first_states[4]) 
          && (~ready_states[5] || comp_table[5][8] || issue_first_states[5]) 
          && (~ready_states[6] || comp_table[6][8] || issue_first_states[6]) 
          && (~ready_states[7] || comp_table[7][8] || issue_first_states[7]) 
          && (~ready_states[9] || comp_table[9][8] || issue_first_states[9]) 
          && (~ready_states[10] || comp_table[10][8] || issue_first_states[10]) 
          && (~ready_states[11] || comp_table[11][8] || issue_first_states[11]) 
          && (~ready_states[12] || comp_table[12][8] || issue_first_states[12]) 
          && (~ready_states[13] || comp_table[13][8] || issue_first_states[13]) 
          && (~ready_states[14] || comp_table[14][8] || issue_first_states[14]) 
          && (~ready_states[15] || comp_table[15][8] || issue_first_states[15]) 
   ;
   assign comp_table[8][0]       = (ages[8]<ages[0]); 
   assign comp_table[8][1]       = (ages[8]<ages[1]); 
   assign comp_table[8][2]       = (ages[8]<ages[2]); 
   assign comp_table[8][3]       = (ages[8]<ages[3]); 
   assign comp_table[8][4]       = (ages[8]<ages[4]); 
   assign comp_table[8][5]       = (ages[8]<ages[5]); 
   assign comp_table[8][6]       = (ages[8]<ages[6]); 
   assign comp_table[8][7]       = (ages[8]<ages[7]); 
   assign comp_table[8][8]       = (ages[8]<ages[8]); 
   assign comp_table[8][9]       = (ages[8]<ages[9]); 
   assign comp_table[8][10]       = (ages[8]<ages[10]); 
   assign comp_table[8][11]       = (ages[8]<ages[11]); 
   assign comp_table[8][12]       = (ages[8]<ages[12]); 
   assign comp_table[8][13]       = (ages[8]<ages[13]); 
   assign comp_table[8][14]       = (ages[8]<ages[14]); 
   assign comp_table[8][15]       = (ages[8]<ages[15]); 
   assign ready_states[9]     = (statuses[9]==`RS_READY);
   assign issue_first_states[9]  = ready_states[9]
          && (~ready_states[0] || comp_table[0][9]) 
          && (~ready_states[1] || comp_table[1][9]) 
          && (~ready_states[2] || comp_table[2][9]) 
          && (~ready_states[3] || comp_table[3][9]) 
          && (~ready_states[4] || comp_table[4][9]) 
          && (~ready_states[5] || comp_table[5][9]) 
          && (~ready_states[6] || comp_table[6][9]) 
          && (~ready_states[7] || comp_table[7][9]) 
          && (~ready_states[8] || comp_table[8][9]) 
          && (~ready_states[10] || comp_table[10][9]) 
          && (~ready_states[11] || comp_table[11][9]) 
          && (~ready_states[12] || comp_table[12][9]) 
          && (~ready_states[13] || comp_table[13][9]) 
          && (~ready_states[14] || comp_table[14][9]) 
          && (~ready_states[15] || comp_table[15][9]) 
   ;
   assign issue_second_states[9] = ready_states[9] && ~issue_first_states[9] 
          && (~ready_states[0] || comp_table[0][9] || issue_first_states[0]) 
          && (~ready_states[1] || comp_table[1][9] || issue_first_states[1]) 
          && (~ready_states[2] || comp_table[2][9] || issue_first_states[2]) 
          && (~ready_states[3] || comp_table[3][9] || issue_first_states[3]) 
          && (~ready_states[4] || comp_table[4][9] || issue_first_states[4]) 
          && (~ready_states[5] || comp_table[5][9] || issue_first_states[5]) 
          && (~ready_states[6] || comp_table[6][9] || issue_first_states[6]) 
          && (~ready_states[7] || comp_table[7][9] || issue_first_states[7]) 
          && (~ready_states[8] || comp_table[8][9] || issue_first_states[8]) 
          && (~ready_states[10] || comp_table[10][9] || issue_first_states[10]) 
          && (~ready_states[11] || comp_table[11][9] || issue_first_states[11]) 
          && (~ready_states[12] || comp_table[12][9] || issue_first_states[12]) 
          && (~ready_states[13] || comp_table[13][9] || issue_first_states[13]) 
          && (~ready_states[14] || comp_table[14][9] || issue_first_states[14]) 
          && (~ready_states[15] || comp_table[15][9] || issue_first_states[15]) 
   ;
   assign comp_table[9][0]       = (ages[9]<ages[0]); 
   assign comp_table[9][1]       = (ages[9]<ages[1]); 
   assign comp_table[9][2]       = (ages[9]<ages[2]); 
   assign comp_table[9][3]       = (ages[9]<ages[3]); 
   assign comp_table[9][4]       = (ages[9]<ages[4]); 
   assign comp_table[9][5]       = (ages[9]<ages[5]); 
   assign comp_table[9][6]       = (ages[9]<ages[6]); 
   assign comp_table[9][7]       = (ages[9]<ages[7]); 
   assign comp_table[9][8]       = (ages[9]<ages[8]); 
   assign comp_table[9][9]       = (ages[9]<ages[9]); 
   assign comp_table[9][10]       = (ages[9]<ages[10]); 
   assign comp_table[9][11]       = (ages[9]<ages[11]); 
   assign comp_table[9][12]       = (ages[9]<ages[12]); 
   assign comp_table[9][13]       = (ages[9]<ages[13]); 
   assign comp_table[9][14]       = (ages[9]<ages[14]); 
   assign comp_table[9][15]       = (ages[9]<ages[15]); 
   assign ready_states[10]     = (statuses[10]==`RS_READY);
   assign issue_first_states[10]  = ready_states[10]
          && (~ready_states[0] || comp_table[0][10]) 
          && (~ready_states[1] || comp_table[1][10]) 
          && (~ready_states[2] || comp_table[2][10]) 
          && (~ready_states[3] || comp_table[3][10]) 
          && (~ready_states[4] || comp_table[4][10]) 
          && (~ready_states[5] || comp_table[5][10]) 
          && (~ready_states[6] || comp_table[6][10]) 
          && (~ready_states[7] || comp_table[7][10]) 
          && (~ready_states[8] || comp_table[8][10]) 
          && (~ready_states[9] || comp_table[9][10]) 
          && (~ready_states[11] || comp_table[11][10]) 
          && (~ready_states[12] || comp_table[12][10]) 
          && (~ready_states[13] || comp_table[13][10]) 
          && (~ready_states[14] || comp_table[14][10]) 
          && (~ready_states[15] || comp_table[15][10]) 
   ;
   assign issue_second_states[10] = ready_states[10] && ~issue_first_states[10] 
          && (~ready_states[0] || comp_table[0][10] || issue_first_states[0]) 
          && (~ready_states[1] || comp_table[1][10] || issue_first_states[1]) 
          && (~ready_states[2] || comp_table[2][10] || issue_first_states[2]) 
          && (~ready_states[3] || comp_table[3][10] || issue_first_states[3]) 
          && (~ready_states[4] || comp_table[4][10] || issue_first_states[4]) 
          && (~ready_states[5] || comp_table[5][10] || issue_first_states[5]) 
          && (~ready_states[6] || comp_table[6][10] || issue_first_states[6]) 
          && (~ready_states[7] || comp_table[7][10] || issue_first_states[7]) 
          && (~ready_states[8] || comp_table[8][10] || issue_first_states[8]) 
          && (~ready_states[9] || comp_table[9][10] || issue_first_states[9]) 
          && (~ready_states[11] || comp_table[11][10] || issue_first_states[11]) 
          && (~ready_states[12] || comp_table[12][10] || issue_first_states[12]) 
          && (~ready_states[13] || comp_table[13][10] || issue_first_states[13]) 
          && (~ready_states[14] || comp_table[14][10] || issue_first_states[14]) 
          && (~ready_states[15] || comp_table[15][10] || issue_first_states[15]) 
   ;
   assign comp_table[10][0]       = (ages[10]<ages[0]); 
   assign comp_table[10][1]       = (ages[10]<ages[1]); 
   assign comp_table[10][2]       = (ages[10]<ages[2]); 
   assign comp_table[10][3]       = (ages[10]<ages[3]); 
   assign comp_table[10][4]       = (ages[10]<ages[4]); 
   assign comp_table[10][5]       = (ages[10]<ages[5]); 
   assign comp_table[10][6]       = (ages[10]<ages[6]); 
   assign comp_table[10][7]       = (ages[10]<ages[7]); 
   assign comp_table[10][8]       = (ages[10]<ages[8]); 
   assign comp_table[10][9]       = (ages[10]<ages[9]); 
   assign comp_table[10][10]       = (ages[10]<ages[10]); 
   assign comp_table[10][11]       = (ages[10]<ages[11]); 
   assign comp_table[10][12]       = (ages[10]<ages[12]); 
   assign comp_table[10][13]       = (ages[10]<ages[13]); 
   assign comp_table[10][14]       = (ages[10]<ages[14]); 
   assign comp_table[10][15]       = (ages[10]<ages[15]); 
   assign ready_states[11]     = (statuses[11]==`RS_READY);
   assign issue_first_states[11]  = ready_states[11]
          && (~ready_states[0] || comp_table[0][11]) 
          && (~ready_states[1] || comp_table[1][11]) 
          && (~ready_states[2] || comp_table[2][11]) 
          && (~ready_states[3] || comp_table[3][11]) 
          && (~ready_states[4] || comp_table[4][11]) 
          && (~ready_states[5] || comp_table[5][11]) 
          && (~ready_states[6] || comp_table[6][11]) 
          && (~ready_states[7] || comp_table[7][11]) 
          && (~ready_states[8] || comp_table[8][11]) 
          && (~ready_states[9] || comp_table[9][11]) 
          && (~ready_states[10] || comp_table[10][11]) 
          && (~ready_states[12] || comp_table[12][11]) 
          && (~ready_states[13] || comp_table[13][11]) 
          && (~ready_states[14] || comp_table[14][11]) 
          && (~ready_states[15] || comp_table[15][11]) 
   ;
   assign issue_second_states[11] = ready_states[11] && ~issue_first_states[11] 
          && (~ready_states[0] || comp_table[0][11] || issue_first_states[0]) 
          && (~ready_states[1] || comp_table[1][11] || issue_first_states[1]) 
          && (~ready_states[2] || comp_table[2][11] || issue_first_states[2]) 
          && (~ready_states[3] || comp_table[3][11] || issue_first_states[3]) 
          && (~ready_states[4] || comp_table[4][11] || issue_first_states[4]) 
          && (~ready_states[5] || comp_table[5][11] || issue_first_states[5]) 
          && (~ready_states[6] || comp_table[6][11] || issue_first_states[6]) 
          && (~ready_states[7] || comp_table[7][11] || issue_first_states[7]) 
          && (~ready_states[8] || comp_table[8][11] || issue_first_states[8]) 
          && (~ready_states[9] || comp_table[9][11] || issue_first_states[9]) 
          && (~ready_states[10] || comp_table[10][11] || issue_first_states[10]) 
          && (~ready_states[12] || comp_table[12][11] || issue_first_states[12]) 
          && (~ready_states[13] || comp_table[13][11] || issue_first_states[13]) 
          && (~ready_states[14] || comp_table[14][11] || issue_first_states[14]) 
          && (~ready_states[15] || comp_table[15][11] || issue_first_states[15]) 
   ;
   assign comp_table[11][0]       = (ages[11]<ages[0]); 
   assign comp_table[11][1]       = (ages[11]<ages[1]); 
   assign comp_table[11][2]       = (ages[11]<ages[2]); 
   assign comp_table[11][3]       = (ages[11]<ages[3]); 
   assign comp_table[11][4]       = (ages[11]<ages[4]); 
   assign comp_table[11][5]       = (ages[11]<ages[5]); 
   assign comp_table[11][6]       = (ages[11]<ages[6]); 
   assign comp_table[11][7]       = (ages[11]<ages[7]); 
   assign comp_table[11][8]       = (ages[11]<ages[8]); 
   assign comp_table[11][9]       = (ages[11]<ages[9]); 
   assign comp_table[11][10]       = (ages[11]<ages[10]); 
   assign comp_table[11][11]       = (ages[11]<ages[11]); 
   assign comp_table[11][12]       = (ages[11]<ages[12]); 
   assign comp_table[11][13]       = (ages[11]<ages[13]); 
   assign comp_table[11][14]       = (ages[11]<ages[14]); 
   assign comp_table[11][15]       = (ages[11]<ages[15]); 
   assign ready_states[12]     = (statuses[12]==`RS_READY);
   assign issue_first_states[12]  = ready_states[12]
          && (~ready_states[0] || comp_table[0][12]) 
          && (~ready_states[1] || comp_table[1][12]) 
          && (~ready_states[2] || comp_table[2][12]) 
          && (~ready_states[3] || comp_table[3][12]) 
          && (~ready_states[4] || comp_table[4][12]) 
          && (~ready_states[5] || comp_table[5][12]) 
          && (~ready_states[6] || comp_table[6][12]) 
          && (~ready_states[7] || comp_table[7][12]) 
          && (~ready_states[8] || comp_table[8][12]) 
          && (~ready_states[9] || comp_table[9][12]) 
          && (~ready_states[10] || comp_table[10][12]) 
          && (~ready_states[11] || comp_table[11][12]) 
          && (~ready_states[13] || comp_table[13][12]) 
          && (~ready_states[14] || comp_table[14][12]) 
          && (~ready_states[15] || comp_table[15][12]) 
   ;
   assign issue_second_states[12] = ready_states[12] && ~issue_first_states[12] 
          && (~ready_states[0] || comp_table[0][12] || issue_first_states[0]) 
          && (~ready_states[1] || comp_table[1][12] || issue_first_states[1]) 
          && (~ready_states[2] || comp_table[2][12] || issue_first_states[2]) 
          && (~ready_states[3] || comp_table[3][12] || issue_first_states[3]) 
          && (~ready_states[4] || comp_table[4][12] || issue_first_states[4]) 
          && (~ready_states[5] || comp_table[5][12] || issue_first_states[5]) 
          && (~ready_states[6] || comp_table[6][12] || issue_first_states[6]) 
          && (~ready_states[7] || comp_table[7][12] || issue_first_states[7]) 
          && (~ready_states[8] || comp_table[8][12] || issue_first_states[8]) 
          && (~ready_states[9] || comp_table[9][12] || issue_first_states[9]) 
          && (~ready_states[10] || comp_table[10][12] || issue_first_states[10]) 
          && (~ready_states[11] || comp_table[11][12] || issue_first_states[11]) 
          && (~ready_states[13] || comp_table[13][12] || issue_first_states[13]) 
          && (~ready_states[14] || comp_table[14][12] || issue_first_states[14]) 
          && (~ready_states[15] || comp_table[15][12] || issue_first_states[15]) 
   ;
   assign comp_table[12][0]       = (ages[12]<ages[0]); 
   assign comp_table[12][1]       = (ages[12]<ages[1]); 
   assign comp_table[12][2]       = (ages[12]<ages[2]); 
   assign comp_table[12][3]       = (ages[12]<ages[3]); 
   assign comp_table[12][4]       = (ages[12]<ages[4]); 
   assign comp_table[12][5]       = (ages[12]<ages[5]); 
   assign comp_table[12][6]       = (ages[12]<ages[6]); 
   assign comp_table[12][7]       = (ages[12]<ages[7]); 
   assign comp_table[12][8]       = (ages[12]<ages[8]); 
   assign comp_table[12][9]       = (ages[12]<ages[9]); 
   assign comp_table[12][10]       = (ages[12]<ages[10]); 
   assign comp_table[12][11]       = (ages[12]<ages[11]); 
   assign comp_table[12][12]       = (ages[12]<ages[12]); 
   assign comp_table[12][13]       = (ages[12]<ages[13]); 
   assign comp_table[12][14]       = (ages[12]<ages[14]); 
   assign comp_table[12][15]       = (ages[12]<ages[15]); 
   assign ready_states[13]     = (statuses[13]==`RS_READY);
   assign issue_first_states[13]  = ready_states[13]
          && (~ready_states[0] || comp_table[0][13]) 
          && (~ready_states[1] || comp_table[1][13]) 
          && (~ready_states[2] || comp_table[2][13]) 
          && (~ready_states[3] || comp_table[3][13]) 
          && (~ready_states[4] || comp_table[4][13]) 
          && (~ready_states[5] || comp_table[5][13]) 
          && (~ready_states[6] || comp_table[6][13]) 
          && (~ready_states[7] || comp_table[7][13]) 
          && (~ready_states[8] || comp_table[8][13]) 
          && (~ready_states[9] || comp_table[9][13]) 
          && (~ready_states[10] || comp_table[10][13]) 
          && (~ready_states[11] || comp_table[11][13]) 
          && (~ready_states[12] || comp_table[12][13]) 
          && (~ready_states[14] || comp_table[14][13]) 
          && (~ready_states[15] || comp_table[15][13]) 
   ;
   assign issue_second_states[13] = ready_states[13] && ~issue_first_states[13] 
          && (~ready_states[0] || comp_table[0][13] || issue_first_states[0]) 
          && (~ready_states[1] || comp_table[1][13] || issue_first_states[1]) 
          && (~ready_states[2] || comp_table[2][13] || issue_first_states[2]) 
          && (~ready_states[3] || comp_table[3][13] || issue_first_states[3]) 
          && (~ready_states[4] || comp_table[4][13] || issue_first_states[4]) 
          && (~ready_states[5] || comp_table[5][13] || issue_first_states[5]) 
          && (~ready_states[6] || comp_table[6][13] || issue_first_states[6]) 
          && (~ready_states[7] || comp_table[7][13] || issue_first_states[7]) 
          && (~ready_states[8] || comp_table[8][13] || issue_first_states[8]) 
          && (~ready_states[9] || comp_table[9][13] || issue_first_states[9]) 
          && (~ready_states[10] || comp_table[10][13] || issue_first_states[10]) 
          && (~ready_states[11] || comp_table[11][13] || issue_first_states[11]) 
          && (~ready_states[12] || comp_table[12][13] || issue_first_states[12]) 
          && (~ready_states[14] || comp_table[14][13] || issue_first_states[14]) 
          && (~ready_states[15] || comp_table[15][13] || issue_first_states[15]) 
   ;
   assign comp_table[13][0]       = (ages[13]<ages[0]); 
   assign comp_table[13][1]       = (ages[13]<ages[1]); 
   assign comp_table[13][2]       = (ages[13]<ages[2]); 
   assign comp_table[13][3]       = (ages[13]<ages[3]); 
   assign comp_table[13][4]       = (ages[13]<ages[4]); 
   assign comp_table[13][5]       = (ages[13]<ages[5]); 
   assign comp_table[13][6]       = (ages[13]<ages[6]); 
   assign comp_table[13][7]       = (ages[13]<ages[7]); 
   assign comp_table[13][8]       = (ages[13]<ages[8]); 
   assign comp_table[13][9]       = (ages[13]<ages[9]); 
   assign comp_table[13][10]       = (ages[13]<ages[10]); 
   assign comp_table[13][11]       = (ages[13]<ages[11]); 
   assign comp_table[13][12]       = (ages[13]<ages[12]); 
   assign comp_table[13][13]       = (ages[13]<ages[13]); 
   assign comp_table[13][14]       = (ages[13]<ages[14]); 
   assign comp_table[13][15]       = (ages[13]<ages[15]); 
   assign ready_states[14]     = (statuses[14]==`RS_READY);
   assign issue_first_states[14]  = ready_states[14]
          && (~ready_states[0] || comp_table[0][14]) 
          && (~ready_states[1] || comp_table[1][14]) 
          && (~ready_states[2] || comp_table[2][14]) 
          && (~ready_states[3] || comp_table[3][14]) 
          && (~ready_states[4] || comp_table[4][14]) 
          && (~ready_states[5] || comp_table[5][14]) 
          && (~ready_states[6] || comp_table[6][14]) 
          && (~ready_states[7] || comp_table[7][14]) 
          && (~ready_states[8] || comp_table[8][14]) 
          && (~ready_states[9] || comp_table[9][14]) 
          && (~ready_states[10] || comp_table[10][14]) 
          && (~ready_states[11] || comp_table[11][14]) 
          && (~ready_states[12] || comp_table[12][14]) 
          && (~ready_states[13] || comp_table[13][14]) 
          && (~ready_states[15] || comp_table[15][14]) 
   ;
   assign issue_second_states[14] = ready_states[14] && ~issue_first_states[14] 
          && (~ready_states[0] || comp_table[0][14] || issue_first_states[0]) 
          && (~ready_states[1] || comp_table[1][14] || issue_first_states[1]) 
          && (~ready_states[2] || comp_table[2][14] || issue_first_states[2]) 
          && (~ready_states[3] || comp_table[3][14] || issue_first_states[3]) 
          && (~ready_states[4] || comp_table[4][14] || issue_first_states[4]) 
          && (~ready_states[5] || comp_table[5][14] || issue_first_states[5]) 
          && (~ready_states[6] || comp_table[6][14] || issue_first_states[6]) 
          && (~ready_states[7] || comp_table[7][14] || issue_first_states[7]) 
          && (~ready_states[8] || comp_table[8][14] || issue_first_states[8]) 
          && (~ready_states[9] || comp_table[9][14] || issue_first_states[9]) 
          && (~ready_states[10] || comp_table[10][14] || issue_first_states[10]) 
          && (~ready_states[11] || comp_table[11][14] || issue_first_states[11]) 
          && (~ready_states[12] || comp_table[12][14] || issue_first_states[12]) 
          && (~ready_states[13] || comp_table[13][14] || issue_first_states[13]) 
          && (~ready_states[15] || comp_table[15][14] || issue_first_states[15]) 
   ;
   assign comp_table[14][0]       = (ages[14]<ages[0]); 
   assign comp_table[14][1]       = (ages[14]<ages[1]); 
   assign comp_table[14][2]       = (ages[14]<ages[2]); 
   assign comp_table[14][3]       = (ages[14]<ages[3]); 
   assign comp_table[14][4]       = (ages[14]<ages[4]); 
   assign comp_table[14][5]       = (ages[14]<ages[5]); 
   assign comp_table[14][6]       = (ages[14]<ages[6]); 
   assign comp_table[14][7]       = (ages[14]<ages[7]); 
   assign comp_table[14][8]       = (ages[14]<ages[8]); 
   assign comp_table[14][9]       = (ages[14]<ages[9]); 
   assign comp_table[14][10]       = (ages[14]<ages[10]); 
   assign comp_table[14][11]       = (ages[14]<ages[11]); 
   assign comp_table[14][12]       = (ages[14]<ages[12]); 
   assign comp_table[14][13]       = (ages[14]<ages[13]); 
   assign comp_table[14][14]       = (ages[14]<ages[14]); 
   assign comp_table[14][15]       = (ages[14]<ages[15]); 
   assign ready_states[15]     = (statuses[15]==`RS_READY);
   assign issue_first_states[15]  = ready_states[15]
          && (~ready_states[0] || comp_table[0][15]) 
          && (~ready_states[1] || comp_table[1][15]) 
          && (~ready_states[2] || comp_table[2][15]) 
          && (~ready_states[3] || comp_table[3][15]) 
          && (~ready_states[4] || comp_table[4][15]) 
          && (~ready_states[5] || comp_table[5][15]) 
          && (~ready_states[6] || comp_table[6][15]) 
          && (~ready_states[7] || comp_table[7][15]) 
          && (~ready_states[8] || comp_table[8][15]) 
          && (~ready_states[9] || comp_table[9][15]) 
          && (~ready_states[10] || comp_table[10][15]) 
          && (~ready_states[11] || comp_table[11][15]) 
          && (~ready_states[12] || comp_table[12][15]) 
          && (~ready_states[13] || comp_table[13][15]) 
          && (~ready_states[14] || comp_table[14][15]) 
   ;
   assign issue_second_states[15] = ready_states[15] && ~issue_first_states[15] 
          && (~ready_states[0] || comp_table[0][15] || issue_first_states[0]) 
          && (~ready_states[1] || comp_table[1][15] || issue_first_states[1]) 
          && (~ready_states[2] || comp_table[2][15] || issue_first_states[2]) 
          && (~ready_states[3] || comp_table[3][15] || issue_first_states[3]) 
          && (~ready_states[4] || comp_table[4][15] || issue_first_states[4]) 
          && (~ready_states[5] || comp_table[5][15] || issue_first_states[5]) 
          && (~ready_states[6] || comp_table[6][15] || issue_first_states[6]) 
          && (~ready_states[7] || comp_table[7][15] || issue_first_states[7]) 
          && (~ready_states[8] || comp_table[8][15] || issue_first_states[8]) 
          && (~ready_states[9] || comp_table[9][15] || issue_first_states[9]) 
          && (~ready_states[10] || comp_table[10][15] || issue_first_states[10]) 
          && (~ready_states[11] || comp_table[11][15] || issue_first_states[11]) 
          && (~ready_states[12] || comp_table[12][15] || issue_first_states[12]) 
          && (~ready_states[13] || comp_table[13][15] || issue_first_states[13]) 
          && (~ready_states[14] || comp_table[14][15] || issue_first_states[14]) 
   ;
   assign comp_table[15][0]       = (ages[15]<ages[0]); 
   assign comp_table[15][1]       = (ages[15]<ages[1]); 
   assign comp_table[15][2]       = (ages[15]<ages[2]); 
   assign comp_table[15][3]       = (ages[15]<ages[3]); 
   assign comp_table[15][4]       = (ages[15]<ages[4]); 
   assign comp_table[15][5]       = (ages[15]<ages[5]); 
   assign comp_table[15][6]       = (ages[15]<ages[6]); 
   assign comp_table[15][7]       = (ages[15]<ages[7]); 
   assign comp_table[15][8]       = (ages[15]<ages[8]); 
   assign comp_table[15][9]       = (ages[15]<ages[9]); 
   assign comp_table[15][10]       = (ages[15]<ages[10]); 
   assign comp_table[15][11]       = (ages[15]<ages[11]); 
   assign comp_table[15][12]       = (ages[15]<ages[12]); 
   assign comp_table[15][13]       = (ages[15]<ages[13]); 
   assign comp_table[15][14]       = (ages[15]<ages[14]); 
   assign comp_table[15][15]       = (ages[15]<ages[15]); 
