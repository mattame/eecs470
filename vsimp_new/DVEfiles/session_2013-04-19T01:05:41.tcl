# Begin_DVE_Session_Save_Info
# DVE full session
# Saved on Fri Apr 19 01:05:41 2013
# Designs open: 1
#   Sim: /afs/umich.edu/user/m/a/mattnick/eecs470/P4/eecs470/vsimp_new/dve_simv
# Toplevel windows open: 1
# 	TopLevel.2
#   Wave.1: 16 signals
#   Group count = 2
#   Group Group1 signal count = 16
#   Group Group2 signal count = 4
# End_DVE_Session_Save_Info

# DVE version: E-2011.03_Full64
# DVE build date: Feb 23 2011 21:10:05


#<Session mode="Full" path="/afs/umich.edu/user/m/a/mattnick/eecs470/P4/eecs470/vsimp_new/DVEfiles/session.tcl" type="Debug">

gui_set_loading_session_type Post
gui_continuetime_set

# Close design
if { [gui_sim_state -check active] } {
    gui_sim_terminate
}
gui_close_db -all
gui_expr_clear_all

# Close all windows
gui_close_window -type Console
gui_close_window -type Wave
gui_close_window -type Source
gui_close_window -type Schematic
gui_close_window -type Data
gui_close_window -type DriverLoad
gui_close_window -type List
gui_close_window -type Memory
gui_close_window -type HSPane
gui_close_window -type DLPane
gui_close_window -type Assertion
gui_close_window -type CovHier
gui_close_window -type CoverageTable
gui_close_window -type CoverageMap
gui_close_window -type CovDensity
gui_close_window -type CovDetail
gui_close_window -type Local
gui_close_window -type Stack
gui_close_window -type Watch
gui_close_window -type Grading
gui_close_window -type Group
gui_close_window -type Transaction



# Application preferences
gui_set_pref_value -key app_default_font -value {Helvetica,10,-1,5,50,0,0,0,0,0}
gui_src_preferences -tabstop 8 -maxbits 24 -windownumber 1
#<WindowLayout>

# DVE Topleve session: 


# Create and position top-level windows :TopLevel.2

if {![gui_exist_window -window TopLevel.2]} {
    set TopLevel.2 [ gui_create_window -type TopLevel \
       -icon $::env(DVE)/auxx/gui/images/toolbars/dvewin.xpm] 
} else { 
    set TopLevel.2 TopLevel.2
}
gui_show_window -window ${TopLevel.2} -show_state normal -rect {{409 234} {1875 1170}}

# ToolBar settings
gui_set_toolbar_attributes -toolbar {TimeOperations} -dock_state top
gui_set_toolbar_attributes -toolbar {TimeOperations} -offset 0
gui_show_toolbar -toolbar {TimeOperations}
gui_set_toolbar_attributes -toolbar {&File} -dock_state top
gui_set_toolbar_attributes -toolbar {&File} -offset 0
gui_show_toolbar -toolbar {&File}
gui_set_toolbar_attributes -toolbar {&Edit} -dock_state top
gui_set_toolbar_attributes -toolbar {&Edit} -offset 0
gui_show_toolbar -toolbar {&Edit}
gui_set_toolbar_attributes -toolbar {Simulator} -dock_state top
gui_set_toolbar_attributes -toolbar {Simulator} -offset 0
gui_show_toolbar -toolbar {Simulator}
gui_set_toolbar_attributes -toolbar {Interactive Rewind} -dock_state top
gui_set_toolbar_attributes -toolbar {Interactive Rewind} -offset 0
gui_show_toolbar -toolbar {Interactive Rewind}
gui_set_toolbar_attributes -toolbar {Signal} -dock_state top
gui_set_toolbar_attributes -toolbar {Signal} -offset 0
gui_show_toolbar -toolbar {Signal}
gui_set_toolbar_attributes -toolbar {&Scope} -dock_state top
gui_set_toolbar_attributes -toolbar {&Scope} -offset 0
gui_show_toolbar -toolbar {&Scope}
gui_set_toolbar_attributes -toolbar {&Trace} -dock_state top
gui_set_toolbar_attributes -toolbar {&Trace} -offset 0
gui_show_toolbar -toolbar {&Trace}
gui_set_toolbar_attributes -toolbar {BackTrace} -dock_state top
gui_set_toolbar_attributes -toolbar {BackTrace} -offset 0
gui_show_toolbar -toolbar {BackTrace}
gui_set_toolbar_attributes -toolbar {&Window} -dock_state top
gui_set_toolbar_attributes -toolbar {&Window} -offset 0
gui_show_toolbar -toolbar {&Window}
gui_set_toolbar_attributes -toolbar {Zoom} -dock_state top
gui_set_toolbar_attributes -toolbar {Zoom} -offset 0
gui_show_toolbar -toolbar {Zoom}
gui_set_toolbar_attributes -toolbar {Zoom And Pan History} -dock_state top
gui_set_toolbar_attributes -toolbar {Zoom And Pan History} -offset 0
gui_show_toolbar -toolbar {Zoom And Pan History}
gui_set_toolbar_attributes -toolbar {Grid} -dock_state top
gui_set_toolbar_attributes -toolbar {Grid} -offset 0
gui_show_toolbar -toolbar {Grid}

# End ToolBar settings

# Docked window settings
gui_sync_global -id ${TopLevel.2} -option true

# MDI window settings
set Wave.1 [gui_create_window -type {Wave}  -parent ${TopLevel.2}]
gui_show_window -window ${Wave.1} -show_state maximized
gui_update_layout -id ${Wave.1} {{show_state maximized} {dock_state undocked} {dock_on_new_line false} {child_wave_left 425} {child_wave_right 1036} {child_wave_colname 210} {child_wave_colvalue 211} {child_wave_col1 0} {child_wave_col2 1}}

# End MDI window settings

gui_set_env TOPLEVELS::TARGET_FRAME(Source) none
gui_set_env TOPLEVELS::TARGET_FRAME(Schematic) none
gui_set_env TOPLEVELS::TARGET_FRAME(PathSchematic) none
gui_set_env TOPLEVELS::TARGET_FRAME(Wave) none
gui_set_env TOPLEVELS::TARGET_FRAME(List) none
gui_set_env TOPLEVELS::TARGET_FRAME(Memory) none
gui_set_env TOPLEVELS::TARGET_FRAME(DriverLoad) none
gui_update_statusbar_target_frame ${TopLevel.2}

#</WindowLayout>

#<Database>

# DVE Open design session: 

if { [llength [lindex [gui_get_db -design Sim] 0]] == 0 } {
gui_set_env SIMSETUP::SIMARGS {{-ucligui +v2k +vc +memcbk}}
gui_set_env SIMSETUP::SIMEXE {/afs/umich.edu/user/m/a/mattnick/eecs470/P4/eecs470/vsimp_new/dve_simv}
gui_set_env SIMSETUP::ALLOW_POLL {0}
if { ![gui_is_db_opened -db {/afs/umich.edu/user/m/a/mattnick/eecs470/P4/eecs470/vsimp_new/dve_simv}] } {
gui_sim_run Ucli -exe dve_simv -args {-ucligui +v2k +vc +memcbk} -dir /afs/umich.edu/user/m/a/mattnick/eecs470/P4/eecs470/vsimp_new -nosource
}
}
if { ![gui_sim_state -check active] } {error "Simulator did not start correctly" error}
gui_set_precision 1s
gui_set_time_units 1s
#</Database>

# DVE Global setting session: 


# Global: Breakpoints

# Global: Bus

# Global: Expressions

# Global: Signal Time Shift

# Global: Signal Compare

# Global: Signal Groups

set Group1 Group1
gui_sg_create ${Group1}
gui_sg_addsignal -group ${Group1} { testbench.pipeline_0.reservation_station_0.statuses testbench.pipeline_0.register_file0.values testbench.pipeline_0.reservation_station_0.inst1_valid_out testbench.pipeline_0.reservation_station_0.inst1_dest_tag_out testbench.pipeline_0.reservation_station_0.inst1_IR_out testbench.pipeline_0.reservation_station_0.inst2_valid_out testbench.pipeline_0.reservation_station_0.cdb2_value_in testbench.pipeline_0.reservation_station_0.cdb2_tag_in testbench.pipeline_0.reservation_station_0.cdb1_tag_in testbench.pipeline_0.reservation_station_0.cdb1_value_in testbench.pipeline_0.reservation_station_0.inst1_rega_value_out testbench.pipeline_0.reservation_station_0.inst2_regb_value_out testbench.pipeline_0.reservation_station_0.inst1_regb_value_out testbench.pipeline_0.reservation_station_0.inst2_rega_value_out testbench.pipeline_0.reservation_station_0.inst2_dest_tag_out testbench.pipeline_0.reservation_station_0.inst2_IR_out }
gui_set_radix -radix enum -signals {Sim:testbench.pipeline_0.register_file0.values}
set Group2 Group2
gui_sg_create ${Group2}
gui_sg_addsignal -group ${Group2} { testbench.pipeline_0.reservation_station_0.cdb2_value_in testbench.pipeline_0.reservation_station_0.cdb2_tag_in testbench.pipeline_0.reservation_station_0.cdb1_tag_in testbench.pipeline_0.reservation_station_0.cdb1_value_in }

# Global: Highlighting

# Post database loading setting...

# Restore C1 time
gui_set_time -C1_only 229



# Save global setting...

# Wave/List view global setting
gui_cov_show_value -switch false

# Close all empty TopLevel windows
foreach __top [gui_ekki_get_window_ids -type TopLevel] {
    if { [llength [gui_ekki_get_window_ids -parent $__top]] == 0} {
        gui_close_window -window $__top
    }
}
gui_set_loading_session_type noSession
# DVE View/pane content session: 


# View 'Wave.1'
gui_wv_sync -id ${Wave.1} -switch false
set groupExD [gui_get_pref_value -category Wave -key exclusiveSG]
gui_set_pref_value -category Wave -key exclusiveSG -value {false}
set origWaveHeight [gui_get_pref_value -category Wave -key waveRowHeight]
gui_list_set_height -id Wave -height 25
set origGroupCreationState [gui_list_create_group_when_add -wave]
gui_list_create_group_when_add -wave -disable
gui_marker_set_ref -id ${Wave.1}  C1
gui_wv_zoom_timerange -id ${Wave.1} 167 507
gui_list_add_group -id ${Wave.1} -after {New Group} {Group1}
gui_list_expand -id ${Wave.1} testbench.pipeline_0.reservation_station_0.statuses
gui_list_expand -id ${Wave.1} testbench.pipeline_0.register_file0.values
gui_list_select -id ${Wave.1} {testbench.pipeline_0.reservation_station_0.cdb2_value_in testbench.pipeline_0.reservation_station_0.cdb2_tag_in testbench.pipeline_0.reservation_station_0.cdb1_tag_in testbench.pipeline_0.reservation_station_0.cdb1_value_in }
gui_set_radix -radix unsigned -signal {{testbench.pipeline_0.register_file0.values[31]}}
gui_set_radix -radix unsigned -signal {{testbench.pipeline_0.register_file0.values[30]}}
gui_set_radix -radix unsigned -signal {{testbench.pipeline_0.register_file0.values[29]}}
gui_set_radix -radix unsigned -signal {{testbench.pipeline_0.register_file0.values[28]}}
gui_set_radix -radix unsigned -signal {{testbench.pipeline_0.register_file0.values[27]}}
gui_set_radix -radix unsigned -signal {{testbench.pipeline_0.register_file0.values[26]}}
gui_set_radix -radix unsigned -signal {{testbench.pipeline_0.register_file0.values[25]}}
gui_set_radix -radix unsigned -signal {{testbench.pipeline_0.register_file0.values[24]}}
gui_set_radix -radix unsigned -signal {{testbench.pipeline_0.register_file0.values[23]}}
gui_set_radix -radix unsigned -signal {{testbench.pipeline_0.register_file0.values[22]}}
gui_set_radix -radix unsigned -signal {{testbench.pipeline_0.register_file0.values[21]}}
gui_set_radix -radix unsigned -signal {{testbench.pipeline_0.register_file0.values[20]}}
gui_set_radix -radix unsigned -signal {{testbench.pipeline_0.register_file0.values[19]}}
gui_set_radix -radix unsigned -signal {{testbench.pipeline_0.register_file0.values[18]}}
gui_set_radix -radix unsigned -signal {{testbench.pipeline_0.register_file0.values[17]}}
gui_set_radix -radix unsigned -signal {{testbench.pipeline_0.register_file0.values[16]}}
gui_set_radix -radix unsigned -signal {{testbench.pipeline_0.register_file0.values[15]}}
gui_set_radix -radix unsigned -signal {{testbench.pipeline_0.register_file0.values[14]}}
gui_set_radix -radix unsigned -signal {{testbench.pipeline_0.register_file0.values[13]}}
gui_set_radix -radix unsigned -signal {{testbench.pipeline_0.register_file0.values[12]}}
gui_set_radix -radix unsigned -signal {{testbench.pipeline_0.register_file0.values[11]}}
gui_set_radix -radix unsigned -signal {{testbench.pipeline_0.register_file0.values[10]}}
gui_set_radix -radix unsigned -signal {{testbench.pipeline_0.register_file0.values[9]}}
gui_set_radix -radix unsigned -signal {{testbench.pipeline_0.register_file0.values[8]}}
gui_set_radix -radix unsigned -signal {{testbench.pipeline_0.register_file0.values[7]}}
gui_set_radix -radix unsigned -signal {{testbench.pipeline_0.register_file0.values[6]}}
gui_set_radix -radix unsigned -signal {{testbench.pipeline_0.register_file0.values[5]}}
gui_set_radix -radix unsigned -signal {{testbench.pipeline_0.register_file0.values[4]}}
gui_set_radix -radix unsigned -signal {{testbench.pipeline_0.register_file0.values[3]}}
gui_set_radix -radix unsigned -signal {{testbench.pipeline_0.register_file0.values[2]}}
gui_set_radix -radix unsigned -signal {{testbench.pipeline_0.register_file0.values[1]}}
gui_set_radix -radix unsigned -signal {{testbench.pipeline_0.register_file0.values[0]}}
gui_seek_criteria -id ${Wave.1} {Any Edge}



gui_set_env TOGGLE::DEFAULT_WAVE_WINDOW ${Wave.1}
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
gui_list_set_insertion_bar  -id ${Wave.1} -group Group1  -item {testbench.pipeline_0.reservation_station_0.inst2_rega_value_out[63:0]} -position below

gui_marker_move -id ${Wave.1} {C1} 229
gui_view_scroll -id ${Wave.1} -vertical -set 922
gui_show_grid -id ${Wave.1} -enable false
# Restore toplevel window zorder
# The toplevel window could be closed if it has no view/pane
if {[gui_exist_window -window ${TopLevel.2}]} {
	gui_set_active_window -window ${TopLevel.2}
	gui_set_active_window -window ${Wave.1}
}
#</Session>

