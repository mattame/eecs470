
NUM_RSES = 4

# make assignments #
for i in range(NUM_RSES):
   print "   assign ready_states["+str(i)+"]     = (statuses["+str(i)+"]==`RS_READY);"

   # assign issue first states #
   print "   assign issue_first_states["+str(i)+"]  = ready_states["+str(i)+"]"
   for j in range(NUM_RSES):
      if (j!=i):
         print "          && (~ready_states["+str(j)+"] || comp_table["+str(j)+"]["+str(i)+"]) "
   print "   ;"

   # assign issue second states #
   print "   assign issue_second_states["+str(i)+"] = ready_states["+str(i)+"] && ~issue_first_states["+str(i)+"] "
   for j in range(NUM_RSES):
      if (j!=i):
         print "          && (~ready_states["+str(j)+"] || comp_table["+str(j)+"]["+str(i)+"] || issue_first_states["+str(j)+"]) "
   print "   ;"

   # assign comp table #
   for j in range(NUM_RSES):
      print "   assign comp_table["+str(i)+"]["+str(j)+"]       = (ages["+str(i)+"]<ages["+str(j)+"]); "


#
# GOTTEN FROM THIS:
#
#   generate
#      for (i=0; i<`NUM_RSES; i=i+1)
#      begin : ASSIGNSTATESOUTERLOOP
#
#         assign ready_states[i]        = (statuses[i]==`RS_READY);
#         assign issue_first_states[i]  = ready_states[i];              // note: issue_first_states and issue_second_states are wands, hence the effect here
#         assign issue_second_states[i] = ready_states[i];
#         assign issue_second_states[i] = ~issue_first_states[i];
#
#         for (j=0; j<`NUM_RSES; j=j+1)
#         begin : ASSIGNSTATESINNERLOOP
#            assign issue_first_states[i]  = (j==i) ? 1'b1 : (~ready_states[j] || comp_table[j][i]);   // exclusion cases for rs entry j
#            assign issue_second_states[i] = (j==i) ? 1'b1 : (~ready_states[j] || comp_table[j][i] || issue_first_states[j]);   // exclusion cases for rs entry j
#            assign comp_table[i][j]       = (ages[i]<ages[j]);   // is rs entry i newer than rs entry j?  
#         end
#
#      end
#   endgenerate
#





