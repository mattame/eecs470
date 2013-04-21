# Begin_DVE_Session_Save_Info
# DVE view(Wave.1 ) session
# Saved on Sun Apr 21 15:36:19 2013
# Toplevel windows open: 2
# 	TopLevel.1
# 	TopLevel.2
#   Wave.1: 32 signals
# End_DVE_Session_Save_Info

# DVE version: E-2011.03_Full64
# DVE build date: Feb 23 2011 21:10:05


#<Session mode="View" path="/afs/umich.edu/user/s/c/scottmel/EECS470/FinalProject/eecs470/vsimp_new/session.inter.vpd.tcl" type="Debug">

#<Database>

#</Database>

# DVE View/pane content session: 

# Begin_DVE_Session_Save_Info (Wave.1)
# DVE wave signals session
# Saved on Sun Apr 21 15:36:19 2013
# 32 signals
# End_DVE_Session_Save_Info

# DVE version: E-2011.03_Full64
# DVE build date: Feb 23 2011 21:10:05


#Add ncecessay scopes

gui_set_time_units 1s
set Group1 Group1
if {[gui_sg_is_group -name Group1]} {
    set Group1 [gui_sg_generate_new_name]
}

gui_sg_addsignal -group "$Group1" { {Sim:testbench.pipeline_0.LSQ_0.clock} {Sim:testbench.pipeline_0.LSQ_0.reset} {Sim:testbench.pipeline_0.LSQ_0.miss_reset} }
set Group2 Group2
if {[gui_sg_is_group -name Group2]} {
    set Group2 [gui_sg_generate_new_name]
}

gui_sg_addsignal -group "$Group2" { {Sim:testbench.pipeline_0.LSQ_0.proc2Dmem_command} {Sim:testbench.pipeline_0.LSQ_0.proc2Dmem_addr} {Sim:testbench.pipeline_0.LSQ_0.proc2Dmem_data} }
set Group3 Group3
if {[gui_sg_is_group -name Group3]} {
    set Group3 [gui_sg_generate_new_name]
}

gui_sg_addsignal -group "$Group3" { {Sim:testbench.pipeline_0.LSQ_0.Dmem2proc_data} {Sim:testbench.pipeline_0.LSQ_0.Dmem2proc_tag} {Sim:testbench.pipeline_0.LSQ_0.Dmem2proc_response} }
set Group4 Group4
if {[gui_sg_is_group -name Group4]} {
    set Group4 [gui_sg_generate_new_name]
}

gui_sg_addsignal -group "$Group4" { {Sim:testbench.pipeline_0.LSQ_0.ROB_tag_1} {Sim:testbench.pipeline_0.LSQ_0.rd_mem_in_1} {Sim:testbench.pipeline_0.LSQ_0.wr_mem_in_1} {Sim:testbench.pipeline_0.LSQ_0.valid_in_1} }
set Group5 Group5
if {[gui_sg_is_group -name Group5]} {
    set Group5 [gui_sg_generate_new_name]
}

gui_sg_addsignal -group "$Group5" { {Sim:testbench.pipeline_0.LSQ_0.EX_tag_1} {Sim:testbench.pipeline_0.LSQ_0.value_in_1} {Sim:testbench.pipeline_0.LSQ_0.address_in_1} {Sim:testbench.pipeline_0.LSQ_0.EX_valid_1} }
set Group6 Group6
if {[gui_sg_is_group -name Group6]} {
    set Group6 [gui_sg_generate_new_name]
}

gui_sg_addsignal -group "$Group6" { {Sim:testbench.pipeline_0.LSQ_0.ROB_tag_2} {Sim:testbench.pipeline_0.LSQ_0.rd_mem_in_2} {Sim:testbench.pipeline_0.LSQ_0.wr_mem_in_2} {Sim:testbench.pipeline_0.LSQ_0.valid_in_2} }
set Group7 Group7
if {[gui_sg_is_group -name Group7]} {
    set Group7 [gui_sg_generate_new_name]
}

gui_sg_addsignal -group "$Group7" { {Sim:testbench.pipeline_0.LSQ_0.EX_tag_2} {Sim:testbench.pipeline_0.LSQ_0.value_in_2} {Sim:testbench.pipeline_0.LSQ_0.address_in_2} {Sim:testbench.pipeline_0.LSQ_0.EX_valid_2} }
set Group8 Group8
if {[gui_sg_is_group -name Group8]} {
    set Group8 [gui_sg_generate_new_name]
}

gui_sg_addsignal -group "$Group8" { {Sim:testbench.pipeline_0.LSQ_0.LSQ_IF_stall} {Sim:testbench.pipeline_0.LSQ_0.LSQ_EX_valid} {Sim:testbench.pipeline_0.LSQ_0.LSQ_empty} {Sim:testbench.pipeline_0.LSQ_0.LSQ_full} }
set Group9 Group9
if {[gui_sg_is_group -name Group9]} {
    set Group9 [gui_sg_generate_new_name]
}

gui_sg_addsignal -group "$Group9" { {Sim:testbench.pipeline_0.LSQ_0.LSQENTRIES[0].entries.stored_address} {Sim:testbench.pipeline_0.LSQ_0.LSQENTRIES[0].entries.stored_value} {Sim:testbench.pipeline_0.LSQ_0.LSQENTRIES[0].entries.stored_tag} }
if {![info exists useOldWindow]} { 
	set useOldWindow true
}
if {$useOldWindow && [string first "Wave" [gui_get_current_window -view]]==0} { 
	set Wave.1 [gui_get_current_window -view] 
} else {
	gui_open_window Wave
set Wave.1 [ gui_get_current_window -view ]
}
set groupExD [gui_get_pref_value -category Wave -key exclusiveSG]
gui_set_pref_value -category Wave -key exclusiveSG -value {false}
set origWaveHeight [gui_get_pref_value -category Wave -key waveRowHeight]
gui_list_set_height -id Wave -height 25
set origGroupCreationState [gui_list_create_group_when_add -wave]
gui_list_create_group_when_add -wave -disable
gui_marker_set_ref -id ${Wave.1}  C1
gui_wv_zoom_timerange -id ${Wave.1} 0 431
gui_list_add_group -id ${Wave.1} -after {New Group} [list $Group1]
gui_list_add_group -id ${Wave.1} -after {New Group} [list $Group2]
gui_list_add_group -id ${Wave.1} -after {New Group} [list $Group3]
gui_list_add_group -id ${Wave.1} -after {New Group} [list $Group4]
gui_list_add_group -id ${Wave.1} -after {New Group} [list $Group5]
gui_list_add_group -id ${Wave.1} -after {New Group} [list $Group6]
gui_list_add_group -id ${Wave.1} -after {New Group} [list $Group7]
gui_list_add_group -id ${Wave.1} -after {New Group} [list $Group8]
gui_list_add_group -id ${Wave.1} -after {New Group} [list $Group9]
gui_list_select -id ${Wave.1} {testbench.pipeline_0.LSQ_0.LSQ_full }
gui_seek_criteria -id ${Wave.1} {Any Edge}


gui_set_pref_value -category Wave -key exclusiveSG -value $groupExD
gui_list_set_height -id Wave -height $origWaveHeight
if {$origGroupCreationState} {
	gui_list_create_group_when_add -wave -enable
}
if { $groupExD } {
 gui_msg_report -code DVWW028
}
gui_list_set_filter -id ${Wave.1} -list { {Buffer 1} {Input 1} {Others 1} {Linkage 1} {Output 1} {Parameter 1} {All 1} {Aggregate 1} {Event 1} {Assertion 1} {Constant 1} {Interface 1} {Signal 1} {$unit 1} {Inout 1} {Variable 1} }
gui_list_set_filter -id ${Wave.1} -text {*}
gui_list_set_insertion_bar  -id ${Wave.1} -group $Group9  -position in

gui_marker_move -id ${Wave.1} {C1} 422
gui_view_scroll -id ${Wave.1} -vertical -set 141
gui_show_grid -id ${Wave.1} -enable false
#</Session>

