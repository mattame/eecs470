# Begin_DVE_Session_Save_Info
# DVE restart session
# Saved on Mon Apr 22 01:54:44 2013
# Designs open: 1
#   Sim: /afs/umich.edu/user/s/c/scottmel/EECS470/FinalProject/eecs470/vsimp_new/dve_simv
# Toplevel windows open: 2
# 	TopLevel.1
# 	TopLevel.2
#   Source.1: testbench.memory
#   Memory.1: testbench.memory.unified_memory[8191:0]
#   Wave.1: 268 signals
#   Group count = 1
#   Group Group1 signal count = 268
# End_DVE_Session_Save_Info

# DVE version: E-2011.03_Full64
# DVE build date: Feb 23 2011 21:10:05


#<Session mode="Restart" path=".restartSimSession.tcl" type="Debug">

gui_set_loading_session_type Restart
gui_continuetime_set
gui_clear_window -type Wave
gui_clear_window -type List

# Application preferences
gui_set_pref_value -key app_default_font -value {Helvetica,10,-1,5,50,0,0,0,0,0}
gui_src_preferences -tabstop 8 -maxbits 24 -windownumber 1
#<WindowLayout>

# DVE Topleve session: 


# Create and position top-level windows :TopLevel.1

set TopLevel.1 TopLevel.1

# Docked window settings
set HSPane.1 HSPane.1
set Hier.1 Hier.1
set DLPane.1 DLPane.1
set Data.1 Data.1
set Console.1 Console.1
gui_sync_global -id ${TopLevel.1} -option true

# MDI window settings
set Source.1 Source.1
gui_update_layout -id ${Source.1} {{show_state maximized} {dock_state undocked} {dock_on_new_line false}}
set Memory.1 Memory.1
gui_update_layout -id ${Memory.1} {{show_state maximized} {dock_state undocked} {dock_on_new_line false}}

# End MDI window settings


# Create and position top-level windows :TopLevel.2

set TopLevel.2 TopLevel.2

# Docked window settings
gui_sync_global -id ${TopLevel.2} -option true

# MDI window settings
set Wave.1 Wave.1
gui_update_layout -id ${Wave.1} {{show_state maximized} {dock_state undocked} {dock_on_new_line false} {child_wave_left 536} {child_wave_right 1308} {child_wave_colname 266} {child_wave_colvalue 266} {child_wave_col1 0} {child_wave_col2 1}}

# End MDI window settings


#</WindowLayout>

#<Database>

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
gui_sg_addsignal -group ${Group1} { testbench.pipeline_0.lsq_proc2Dmem_command_out testbench.pipeline_0.lsq_proc2Dmem_addr_out testbench.pipeline_0.lsq_proc2Dmem_data_out testbench.pipeline_0.lsq_Dmem2proc_data testbench.pipeline_0.lsq_Dmem2proc_tag testbench.pipeline_0.lsq_Dmem2proc_response {testbench.memory.unified_memory[4096]} {testbench.memory.unified_memory[4095]} {testbench.memory.unified_memory[4094]} {testbench.memory.unified_memory[4093]} {testbench.memory.unified_memory[4092]} {testbench.memory.unified_memory[4091]} {testbench.memory.unified_memory[4090]} {testbench.memory.unified_memory[4089]} {testbench.memory.unified_memory[4088]} {testbench.memory.unified_memory[4087]} {testbench.memory.unified_memory[4086]} {testbench.memory.unified_memory[4085]} {testbench.memory.unified_memory[4084]} {testbench.memory.unified_memory[4083]} {testbench.memory.unified_memory[4082]} {testbench.memory.unified_memory[4081]} {testbench.memory.unified_memory[4080]} {testbench.memory.unified_memory[4079]} {testbench.memory.unified_memory[4078]} {testbench.memory.unified_memory[4077]} {testbench.memory.unified_memory[4076]} {testbench.memory.unified_memory[4075]} {testbench.memory.unified_memory[4074]} {testbench.memory.unified_memory[4073]} {testbench.memory.unified_memory[4072]} {testbench.memory.unified_memory[4071]} {testbench.memory.unified_memory[4070]} {testbench.memory.unified_memory[4069]} {testbench.memory.unified_memory[4068]} {testbench.memory.unified_memory[4067]} {testbench.memory.unified_memory[4066]} {testbench.memory.unified_memory[4065]} {testbench.memory.unified_memory[4064]} {testbench.memory.unified_memory[4063]} {testbench.memory.unified_memory[4062]} {testbench.memory.unified_memory[4061]} {testbench.memory.unified_memory[4060]} {testbench.memory.unified_memory[4059]} {testbench.memory.unified_memory[4058]} {testbench.memory.unified_memory[4057]} {testbench.memory.unified_memory[4056]} {testbench.memory.unified_memory[4055]} {testbench.memory.unified_memory[4054]} {testbench.memory.unified_memory[4053]} {testbench.memory.unified_memory[4052]} {testbench.memory.unified_memory[4051]} {testbench.memory.unified_memory[4050]} {testbench.memory.unified_memory[4049]} {testbench.memory.unified_memory[4048]} {testbench.memory.unified_memory[4047]} {testbench.memory.unified_memory[4046]} {testbench.memory.unified_memory[4045]} {testbench.memory.unified_memory[4044]} {testbench.memory.unified_memory[4043]} {testbench.memory.unified_memory[4042]} {testbench.memory.unified_memory[4041]} {testbench.memory.unified_memory[4040]} {testbench.memory.unified_memory[4039]} {testbench.memory.unified_memory[4038]} {testbench.memory.unified_memory[4037]} {testbench.memory.unified_memory[4036]} {testbench.memory.unified_memory[4035]} {testbench.memory.unified_memory[4034]} {testbench.memory.unified_memory[4033]} {testbench.memory.unified_memory[4032]} {testbench.memory.unified_memory[4031]} {testbench.memory.unified_memory[4030]} {testbench.memory.unified_memory[4029]} {testbench.memory.unified_memory[4028]} {testbench.memory.unified_memory[4027]} {testbench.memory.unified_memory[4026]} {testbench.memory.unified_memory[4025]} {testbench.memory.unified_memory[4024]} {testbench.memory.unified_memory[4023]} {testbench.memory.unified_memory[4022]} {testbench.memory.unified_memory[4021]} {testbench.memory.unified_memory[4020]} {testbench.memory.unified_memory[4019]} {testbench.memory.unified_memory[4018]} {testbench.memory.unified_memory[4017]} {testbench.memory.unified_memory[4016]} {testbench.memory.unified_memory[4015]} {testbench.memory.unified_memory[4014]} {testbench.memory.unified_memory[4013]} {testbench.memory.unified_memory[4012]} {testbench.memory.unified_memory[4011]} {testbench.memory.unified_memory[4010]} {testbench.memory.unified_memory[4009]} {testbench.memory.unified_memory[4008]} {testbench.memory.unified_memory[4007]} {testbench.memory.unified_memory[4006]} {testbench.memory.unified_memory[4005]} {testbench.memory.unified_memory[4004]} {testbench.memory.unified_memory[4003]} {testbench.memory.unified_memory[4002]} }
gui_sg_addsignal -group ${Group1} { {testbench.memory.unified_memory[4001]} {testbench.memory.unified_memory[4000]} {testbench.memory.unified_memory[3999]} {testbench.memory.unified_memory[3998]} {testbench.memory.unified_memory[3997]} {testbench.memory.unified_memory[3996]} {testbench.memory.unified_memory[3995]} {testbench.memory.unified_memory[3994]} {testbench.memory.unified_memory[3993]} {testbench.memory.unified_memory[3992]} {testbench.memory.unified_memory[3991]} {testbench.memory.unified_memory[3990]} {testbench.memory.unified_memory[3989]} {testbench.memory.unified_memory[3988]} {testbench.memory.unified_memory[3987]} {testbench.memory.unified_memory[3986]} {testbench.memory.unified_memory[3985]} {testbench.memory.unified_memory[3984]} {testbench.memory.unified_memory[3983]} {testbench.memory.unified_memory[3982]} {testbench.memory.unified_memory[3981]} {testbench.memory.unified_memory[3980]} {testbench.memory.unified_memory[3979]} {testbench.memory.unified_memory[3978]} {testbench.memory.unified_memory[3977]} {testbench.memory.unified_memory[3976]} {testbench.memory.unified_memory[3975]} {testbench.memory.unified_memory[3974]} {testbench.memory.unified_memory[3973]} {testbench.memory.unified_memory[3972]} {testbench.memory.unified_memory[3971]} {testbench.memory.unified_memory[3970]} {testbench.memory.unified_memory[3969]} {testbench.memory.unified_memory[3968]} {testbench.memory.unified_memory[3967]} {testbench.memory.unified_memory[3966]} {testbench.memory.unified_memory[3965]} {testbench.memory.unified_memory[3964]} {testbench.memory.unified_memory[3963]} {testbench.memory.unified_memory[3962]} {testbench.memory.unified_memory[3961]} {testbench.memory.unified_memory[3960]} {testbench.memory.unified_memory[3959]} {testbench.memory.unified_memory[3958]} {testbench.memory.unified_memory[3957]} {testbench.memory.unified_memory[3956]} {testbench.memory.unified_memory[3955]} {testbench.memory.unified_memory[3954]} {testbench.memory.unified_memory[3953]} {testbench.memory.unified_memory[3952]} {testbench.memory.unified_memory[3951]} {testbench.memory.unified_memory[3950]} {testbench.memory.unified_memory[3949]} {testbench.memory.unified_memory[3948]} {testbench.memory.unified_memory[3947]} {testbench.memory.unified_memory[3946]} {testbench.memory.unified_memory[3945]} {testbench.memory.unified_memory[3944]} {testbench.memory.unified_memory[3943]} {testbench.memory.unified_memory[3942]} {testbench.memory.unified_memory[3941]} {testbench.memory.unified_memory[3940]} {testbench.memory.unified_memory[3939]} {testbench.memory.unified_memory[3938]} {testbench.memory.unified_memory[3937]} {testbench.memory.unified_memory[3936]} {testbench.memory.unified_memory[3935]} {testbench.memory.unified_memory[3934]} {testbench.memory.unified_memory[3933]} {testbench.memory.unified_memory[3932]} {testbench.memory.unified_memory[3931]} {testbench.memory.unified_memory[3930]} {testbench.memory.unified_memory[3929]} {testbench.memory.unified_memory[3928]} {testbench.memory.unified_memory[3927]} {testbench.memory.unified_memory[3926]} {testbench.memory.unified_memory[3925]} {testbench.memory.unified_memory[3924]} {testbench.memory.unified_memory[3923]} {testbench.memory.unified_memory[3922]} {testbench.memory.unified_memory[3921]} {testbench.memory.unified_memory[3920]} {testbench.memory.unified_memory[3919]} {testbench.memory.unified_memory[3918]} {testbench.memory.unified_memory[3917]} {testbench.memory.unified_memory[3916]} {testbench.memory.unified_memory[3915]} {testbench.memory.unified_memory[3914]} {testbench.memory.unified_memory[3913]} {testbench.memory.unified_memory[3912]} {testbench.memory.unified_memory[3911]} {testbench.memory.unified_memory[3910]} {testbench.memory.unified_memory[3909]} {testbench.memory.unified_memory[3908]} {testbench.memory.unified_memory[3907]} {testbench.memory.unified_memory[3906]} {testbench.memory.unified_memory[3905]} {testbench.memory.unified_memory[3904]} {testbench.memory.unified_memory[3903]} {testbench.memory.unified_memory[3902]} {testbench.memory.unified_memory[3901]} }
gui_sg_addsignal -group ${Group1} { {testbench.memory.unified_memory[3900]} {testbench.memory.unified_memory[3899]} {testbench.memory.unified_memory[3898]} {testbench.memory.unified_memory[3897]} {testbench.memory.unified_memory[3896]} {testbench.memory.unified_memory[3895]} {testbench.memory.unified_memory[3894]} {testbench.memory.unified_memory[3893]} {testbench.memory.unified_memory[3892]} {testbench.memory.unified_memory[3891]} {testbench.memory.unified_memory[3890]} {testbench.memory.unified_memory[3889]} {testbench.memory.unified_memory[3888]} {testbench.memory.unified_memory[3887]} {testbench.memory.unified_memory[3886]} {testbench.memory.unified_memory[3885]} {testbench.memory.unified_memory[3884]} {testbench.memory.unified_memory[3883]} {testbench.memory.unified_memory[3882]} {testbench.memory.unified_memory[3881]} {testbench.memory.unified_memory[3880]} {testbench.memory.unified_memory[3879]} {testbench.memory.unified_memory[3878]} {testbench.memory.unified_memory[3877]} {testbench.memory.unified_memory[3876]} {testbench.memory.unified_memory[3875]} {testbench.memory.unified_memory[3874]} {testbench.memory.unified_memory[3873]} {testbench.memory.unified_memory[3872]} {testbench.memory.unified_memory[3871]} {testbench.memory.unified_memory[3870]} {testbench.memory.unified_memory[3869]} {testbench.memory.unified_memory[3868]} {testbench.memory.unified_memory[3867]} {testbench.memory.unified_memory[3866]} {testbench.memory.unified_memory[3865]} {testbench.memory.unified_memory[3864]} {testbench.memory.unified_memory[3863]} {testbench.memory.unified_memory[3862]} {testbench.memory.unified_memory[3861]} {testbench.memory.unified_memory[3860]} {testbench.memory.unified_memory[3859]} {testbench.memory.unified_memory[3858]} {testbench.memory.unified_memory[3857]} {testbench.memory.unified_memory[3856]} {testbench.memory.unified_memory[3855]} {testbench.memory.unified_memory[3854]} {testbench.memory.unified_memory[3853]} {testbench.memory.unified_memory[3852]} {testbench.memory.unified_memory[3851]} {testbench.memory.unified_memory[3850]} {testbench.memory.unified_memory[3849]} {testbench.memory.unified_memory[3848]} {testbench.memory.unified_memory[3847]} {testbench.memory.unified_memory[3846]} {testbench.memory.unified_memory[3845]} {testbench.memory.unified_memory[3844]} {testbench.memory.unified_memory[3843]} {testbench.memory.unified_memory[3842]} {testbench.memory.unified_memory[3841]} {testbench.memory.unified_memory[3840]} {testbench.memory.unified_memory[3839]} {testbench.memory.unified_memory[3838]} {testbench.memory.unified_memory[3837]} {testbench.memory.unified_memory[3836]} {testbench.memory.unified_memory[3835]} }

# Global: Highlighting

# Post database loading setting...

# Restore C1 time
gui_set_time -C1_only 1447



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


# Hier 'Hier.1'
gui_show_window -window ${Hier.1}
gui_list_set_filter -id ${Hier.1} -list { {Package 1} {All 1} {Process 1} {UnnamedProcess 1} {Function 1} {Block 1} {OVA Unit 1} {LeafScCell 1} {LeafVlgCell 1} {Interface 1} {LeafVhdCell 1} {$unit 1} {NamedBlock 1} {Task 1} {VlgPackage 1} {ClassDef 1} }
gui_list_set_filter -id ${Hier.1} -text {*}
gui_change_design -id ${Hier.1} -design Sim
catch {gui_list_expand -id ${Hier.1} testbench}
catch {gui_list_select -id ${Hier.1} {testbench.memory}}
gui_view_scroll -id ${Hier.1} -vertical -set 0
gui_view_scroll -id ${Hier.1} -horizontal -set 0

# Data 'Data.1'
gui_list_set_filter -id ${Data.1} -list { {Buffer 1} {Input 1} {Others 1} {Linkage 1} {Output 1} {Parameter 1} {All 1} {Aggregate 1} {Event 1} {Assertion 1} {Constant 1} {Interface 1} {Signal 1} {$unit 1} {Inout 1} {Variable 1} }
gui_list_set_filter -id ${Data.1} -reset
gui_list_show_data -id ${Data.1} {testbench.memory}
gui_list_expand -id ${Data.1} testbench.memory.unified_memory
gui_show_window -window ${Data.1}
catch { gui_list_select -id ${Data.1} {{testbench.memory.unified_memory[4096]} {testbench.memory.unified_memory[4095]} {testbench.memory.unified_memory[4094]} {testbench.memory.unified_memory[4093]} {testbench.memory.unified_memory[4092]} {testbench.memory.unified_memory[4091]} {testbench.memory.unified_memory[4090]} {testbench.memory.unified_memory[4089]} {testbench.memory.unified_memory[4088]} {testbench.memory.unified_memory[4087]} {testbench.memory.unified_memory[4086]} {testbench.memory.unified_memory[4085]} {testbench.memory.unified_memory[4084]} {testbench.memory.unified_memory[4083]} {testbench.memory.unified_memory[4082]} {testbench.memory.unified_memory[4081]} {testbench.memory.unified_memory[4080]} {testbench.memory.unified_memory[4079]} {testbench.memory.unified_memory[4078]} {testbench.memory.unified_memory[4077]} {testbench.memory.unified_memory[4076]} {testbench.memory.unified_memory[4075]} {testbench.memory.unified_memory[4074]} {testbench.memory.unified_memory[4073]} {testbench.memory.unified_memory[4072]} {testbench.memory.unified_memory[4071]} {testbench.memory.unified_memory[4070]} {testbench.memory.unified_memory[4069]} {testbench.memory.unified_memory[4068]} {testbench.memory.unified_memory[4067]} {testbench.memory.unified_memory[4066]} {testbench.memory.unified_memory[4065]} {testbench.memory.unified_memory[4064]} {testbench.memory.unified_memory[4063]} {testbench.memory.unified_memory[4062]} {testbench.memory.unified_memory[4061]} {testbench.memory.unified_memory[4060]} {testbench.memory.unified_memory[4059]} {testbench.memory.unified_memory[4058]} {testbench.memory.unified_memory[4057]} {testbench.memory.unified_memory[4056]} {testbench.memory.unified_memory[4055]} {testbench.memory.unified_memory[4054]} {testbench.memory.unified_memory[4053]} {testbench.memory.unified_memory[4052]} {testbench.memory.unified_memory[4051]} {testbench.memory.unified_memory[4050]} {testbench.memory.unified_memory[4049]} {testbench.memory.unified_memory[4048]} {testbench.memory.unified_memory[4047]} {testbench.memory.unified_memory[4046]} {testbench.memory.unified_memory[4045]} {testbench.memory.unified_memory[4044]} {testbench.memory.unified_memory[4043]} {testbench.memory.unified_memory[4042]} {testbench.memory.unified_memory[4041]} {testbench.memory.unified_memory[4040]} {testbench.memory.unified_memory[4039]} {testbench.memory.unified_memory[4038]} {testbench.memory.unified_memory[4037]} {testbench.memory.unified_memory[4036]} {testbench.memory.unified_memory[4035]} {testbench.memory.unified_memory[4034]} {testbench.memory.unified_memory[4033]} {testbench.memory.unified_memory[4032]} {testbench.memory.unified_memory[4031]} {testbench.memory.unified_memory[4030]} {testbench.memory.unified_memory[4029]} {testbench.memory.unified_memory[4028]} {testbench.memory.unified_memory[4027]} {testbench.memory.unified_memory[4026]} {testbench.memory.unified_memory[4025]} {testbench.memory.unified_memory[4024]} {testbench.memory.unified_memory[4023]} {testbench.memory.unified_memory[4022]} {testbench.memory.unified_memory[4021]} {testbench.memory.unified_memory[4020]} {testbench.memory.unified_memory[4019]} {testbench.memory.unified_memory[4018]} {testbench.memory.unified_memory[4017]} {testbench.memory.unified_memory[4016]} {testbench.memory.unified_memory[4015]} {testbench.memory.unified_memory[4014]} {testbench.memory.unified_memory[4013]} {testbench.memory.unified_memory[4012]} {testbench.memory.unified_memory[4011]} {testbench.memory.unified_memory[4010]} {testbench.memory.unified_memory[4009]} {testbench.memory.unified_memory[4008]} {testbench.memory.unified_memory[4007]} {testbench.memory.unified_memory[4006]} {testbench.memory.unified_memory[4005]} {testbench.memory.unified_memory[4004]} {testbench.memory.unified_memory[4003]} {testbench.memory.unified_memory[4002]} {testbench.memory.unified_memory[4001]} {testbench.memory.unified_memory[4000]} {testbench.memory.unified_memory[3999]} {testbench.memory.unified_memory[3998]} {testbench.memory.unified_memory[3997]} {testbench.memory.unified_memory[3996]} {testbench.memory.unified_memory[3995]} {testbench.memory.unified_memory[3994]} {testbench.memory.unified_memory[3993]} {testbench.memory.unified_memory[3992]} {testbench.memory.unified_memory[3991]} {testbench.memory.unified_memory[3990]} {testbench.memory.unified_memory[3989]} {testbench.memory.unified_memory[3988]} {testbench.memory.unified_memory[3987]} {testbench.memory.unified_memory[3986]} {testbench.memory.unified_memory[3985]} {testbench.memory.unified_memory[3984]} {testbench.memory.unified_memory[3983]} {testbench.memory.unified_memory[3982]} {testbench.memory.unified_memory[3981]} {testbench.memory.unified_memory[3980]} {testbench.memory.unified_memory[3979]} {testbench.memory.unified_memory[3978]} {testbench.memory.unified_memory[3977]} {testbench.memory.unified_memory[3976]} {testbench.memory.unified_memory[3975]} {testbench.memory.unified_memory[3974]} {testbench.memory.unified_memory[3973]} {testbench.memory.unified_memory[3972]} {testbench.memory.unified_memory[3971]} {testbench.memory.unified_memory[3970]} {testbench.memory.unified_memory[3969]} {testbench.memory.unified_memory[3968]} {testbench.memory.unified_memory[3967]} {testbench.memory.unified_memory[3966]} {testbench.memory.unified_memory[3965]} {testbench.memory.unified_memory[3964]} {testbench.memory.unified_memory[3963]} {testbench.memory.unified_memory[3962]} {testbench.memory.unified_memory[3961]} {testbench.memory.unified_memory[3960]} {testbench.memory.unified_memory[3959]} {testbench.memory.unified_memory[3958]} {testbench.memory.unified_memory[3957]} {testbench.memory.unified_memory[3956]} {testbench.memory.unified_memory[3955]} {testbench.memory.unified_memory[3954]} {testbench.memory.unified_memory[3953]} {testbench.memory.unified_memory[3952]} {testbench.memory.unified_memory[3951]} {testbench.memory.unified_memory[3950]} {testbench.memory.unified_memory[3949]} {testbench.memory.unified_memory[3948]} {testbench.memory.unified_memory[3947]} {testbench.memory.unified_memory[3946]} {testbench.memory.unified_memory[3945]} {testbench.memory.unified_memory[3944]} {testbench.memory.unified_memory[3943]} {testbench.memory.unified_memory[3942]} {testbench.memory.unified_memory[3941]} {testbench.memory.unified_memory[3940]} {testbench.memory.unified_memory[3939]} {testbench.memory.unified_memory[3938]} {testbench.memory.unified_memory[3937]} {testbench.memory.unified_memory[3936]} {testbench.memory.unified_memory[3935]} {testbench.memory.unified_memory[3934]} {testbench.memory.unified_memory[3933]} {testbench.memory.unified_memory[3932]} {testbench.memory.unified_memory[3931]} {testbench.memory.unified_memory[3930]} {testbench.memory.unified_memory[3929]} {testbench.memory.unified_memory[3928]} {testbench.memory.unified_memory[3927]} {testbench.memory.unified_memory[3926]} {testbench.memory.unified_memory[3925]} {testbench.memory.unified_memory[3924]} {testbench.memory.unified_memory[3923]} {testbench.memory.unified_memory[3922]} {testbench.memory.unified_memory[3921]} {testbench.memory.unified_memory[3920]} {testbench.memory.unified_memory[3919]} {testbench.memory.unified_memory[3918]} {testbench.memory.unified_memory[3917]} {testbench.memory.unified_memory[3916]} {testbench.memory.unified_memory[3915]} {testbench.memory.unified_memory[3914]} {testbench.memory.unified_memory[3913]} {testbench.memory.unified_memory[3912]} {testbench.memory.unified_memory[3911]} {testbench.memory.unified_memory[3910]} {testbench.memory.unified_memory[3909]} {testbench.memory.unified_memory[3908]} {testbench.memory.unified_memory[3907]} {testbench.memory.unified_memory[3906]} {testbench.memory.unified_memory[3905]} {testbench.memory.unified_memory[3904]} {testbench.memory.unified_memory[3903]} {testbench.memory.unified_memory[3902]} {testbench.memory.unified_memory[3901]} {testbench.memory.unified_memory[3900]} {testbench.memory.unified_memory[3899]} {testbench.memory.unified_memory[3898]} {testbench.memory.unified_memory[3897]} {testbench.memory.unified_memory[3896]} {testbench.memory.unified_memory[3895]} {testbench.memory.unified_memory[3894]} {testbench.memory.unified_memory[3893]} {testbench.memory.unified_memory[3892]} {testbench.memory.unified_memory[3891]} {testbench.memory.unified_memory[3890]} {testbench.memory.unified_memory[3889]} {testbench.memory.unified_memory[3888]} {testbench.memory.unified_memory[3887]} {testbench.memory.unified_memory[3886]} {testbench.memory.unified_memory[3885]} {testbench.memory.unified_memory[3884]} {testbench.memory.unified_memory[3883]} {testbench.memory.unified_memory[3882]} {testbench.memory.unified_memory[3881]} {testbench.memory.unified_memory[3880]} {testbench.memory.unified_memory[3879]} {testbench.memory.unified_memory[3878]} {testbench.memory.unified_memory[3877]} {testbench.memory.unified_memory[3876]} {testbench.memory.unified_memory[3875]} {testbench.memory.unified_memory[3874]} {testbench.memory.unified_memory[3873]} {testbench.memory.unified_memory[3872]} {testbench.memory.unified_memory[3871]} {testbench.memory.unified_memory[3870]} {testbench.memory.unified_memory[3869]} {testbench.memory.unified_memory[3868]} {testbench.memory.unified_memory[3867]} {testbench.memory.unified_memory[3866]} {testbench.memory.unified_memory[3865]} {testbench.memory.unified_memory[3864]} {testbench.memory.unified_memory[3863]} {testbench.memory.unified_memory[3862]} {testbench.memory.unified_memory[3861]} {testbench.memory.unified_memory[3860]} {testbench.memory.unified_memory[3859]} {testbench.memory.unified_memory[3858]} {testbench.memory.unified_memory[3857]} {testbench.memory.unified_memory[3856]} {testbench.memory.unified_memory[3855]} {testbench.memory.unified_memory[3854]} {testbench.memory.unified_memory[3853]} {testbench.memory.unified_memory[3852]} {testbench.memory.unified_memory[3851]} {testbench.memory.unified_memory[3850]} {testbench.memory.unified_memory[3849]} {testbench.memory.unified_memory[3848]} {testbench.memory.unified_memory[3847]} {testbench.memory.unified_memory[3846]} {testbench.memory.unified_memory[3845]} {testbench.memory.unified_memory[3844]} {testbench.memory.unified_memory[3843]} {testbench.memory.unified_memory[3842]} {testbench.memory.unified_memory[3841]} {testbench.memory.unified_memory[3840]} {testbench.memory.unified_memory[3839]} {testbench.memory.unified_memory[3838]} {testbench.memory.unified_memory[3837]} {testbench.memory.unified_memory[3836]} {testbench.memory.unified_memory[3835]} {testbench.memory.unified_memory[4096]} {testbench.memory.unified_memory[4095]} {testbench.memory.unified_memory[4094]} {testbench.memory.unified_memory[4093]} {testbench.memory.unified_memory[4092]} {testbench.memory.unified_memory[4091]} {testbench.memory.unified_memory[4090]} {testbench.memory.unified_memory[4089]} {testbench.memory.unified_memory[4088]} {testbench.memory.unified_memory[4087]} {testbench.memory.unified_memory[4086]} {testbench.memory.unified_memory[4085]} {testbench.memory.unified_memory[4084]} {testbench.memory.unified_memory[4083]} {testbench.memory.unified_memory[4082]} {testbench.memory.unified_memory[4081]} {testbench.memory.unified_memory[4080]} {testbench.memory.unified_memory[4079]} {testbench.memory.unified_memory[4078]} {testbench.memory.unified_memory[4077]} {testbench.memory.unified_memory[4076]} {testbench.memory.unified_memory[4075]} {testbench.memory.unified_memory[4074]} {testbench.memory.unified_memory[4073]} {testbench.memory.unified_memory[4072]} {testbench.memory.unified_memory[4071]} {testbench.memory.unified_memory[4070]} {testbench.memory.unified_memory[4069]} {testbench.memory.unified_memory[4068]} {testbench.memory.unified_memory[4067]} {testbench.memory.unified_memory[4066]} {testbench.memory.unified_memory[4065]} {testbench.memory.unified_memory[4064]} {testbench.memory.unified_memory[4063]} {testbench.memory.unified_memory[4062]} {testbench.memory.unified_memory[4061]} {testbench.memory.unified_memory[4060]} {testbench.memory.unified_memory[4059]} {testbench.memory.unified_memory[4058]} {testbench.memory.unified_memory[4057]} {testbench.memory.unified_memory[4056]} {testbench.memory.unified_memory[4055]} {testbench.memory.unified_memory[4054]} {testbench.memory.unified_memory[4053]} {testbench.memory.unified_memory[4052]} {testbench.memory.unified_memory[4051]} {testbench.memory.unified_memory[4050]} {testbench.memory.unified_memory[4049]} {testbench.memory.unified_memory[4048]} {testbench.memory.unified_memory[4047]} {testbench.memory.unified_memory[4046]} {testbench.memory.unified_memory[4045]} {testbench.memory.unified_memory[4044]} {testbench.memory.unified_memory[4043]} {testbench.memory.unified_memory[4042]} {testbench.memory.unified_memory[4041]} {testbench.memory.unified_memory[4040]} {testbench.memory.unified_memory[4039]} {testbench.memory.unified_memory[4038]} {testbench.memory.unified_memory[4037]} {testbench.memory.unified_memory[4036]} {testbench.memory.unified_memory[4035]} {testbench.memory.unified_memory[4034]} {testbench.memory.unified_memory[4033]} {testbench.memory.unified_memory[4032]} {testbench.memory.unified_memory[4031]} {testbench.memory.unified_memory[4030]} {testbench.memory.unified_memory[4029]} {testbench.memory.unified_memory[4028]} {testbench.memory.unified_memory[4027]} {testbench.memory.unified_memory[4026]} {testbench.memory.unified_memory[4025]} {testbench.memory.unified_memory[4024]} {testbench.memory.unified_memory[4023]} {testbench.memory.unified_memory[4022]} {testbench.memory.unified_memory[4021]} {testbench.memory.unified_memory[4020]} {testbench.memory.unified_memory[4019]} {testbench.memory.unified_memory[4018]} {testbench.memory.unified_memory[4017]} {testbench.memory.unified_memory[4016]} {testbench.memory.unified_memory[4015]} {testbench.memory.unified_memory[4014]} {testbench.memory.unified_memory[4013]} {testbench.memory.unified_memory[4012]} {testbench.memory.unified_memory[4011]} {testbench.memory.unified_memory[4010]} {testbench.memory.unified_memory[4009]} {testbench.memory.unified_memory[4008]} {testbench.memory.unified_memory[4007]} {testbench.memory.unified_memory[4006]} {testbench.memory.unified_memory[4005]} {testbench.memory.unified_memory[4004]} {testbench.memory.unified_memory[4003]} {testbench.memory.unified_memory[4002]} {testbench.memory.unified_memory[4001]} {testbench.memory.unified_memory[4000]} {testbench.memory.unified_memory[3999]} {testbench.memory.unified_memory[3998]} {testbench.memory.unified_memory[3997]} {testbench.memory.unified_memory[3996]} {testbench.memory.unified_memory[3995]} {testbench.memory.unified_memory[3994]} {testbench.memory.unified_memory[3993]} {testbench.memory.unified_memory[3992]} {testbench.memory.unified_memory[3991]} {testbench.memory.unified_memory[3990]} {testbench.memory.unified_memory[3989]} {testbench.memory.unified_memory[3988]} {testbench.memory.unified_memory[3987]} {testbench.memory.unified_memory[3986]} {testbench.memory.unified_memory[3985]} {testbench.memory.unified_memory[3984]} {testbench.memory.unified_memory[3983]} {testbench.memory.unified_memory[3982]} {testbench.memory.unified_memory[3981]} {testbench.memory.unified_memory[3980]} {testbench.memory.unified_memory[3979]} {testbench.memory.unified_memory[3978]} {testbench.memory.unified_memory[3977]} {testbench.memory.unified_memory[3976]} {testbench.memory.unified_memory[3975]} {testbench.memory.unified_memory[3974]} {testbench.memory.unified_memory[3973]} {testbench.memory.unified_memory[3972]} {testbench.memory.unified_memory[3971]} {testbench.memory.unified_memory[3970]} {testbench.memory.unified_memory[3969]} {testbench.memory.unified_memory[3968]} {testbench.memory.unified_memory[3967]} {testbench.memory.unified_memory[3966]} {testbench.memory.unified_memory[3965]} {testbench.memory.unified_memory[3964]} {testbench.memory.unified_memory[3963]} {testbench.memory.unified_memory[3962]} {testbench.memory.unified_memory[3961]} {testbench.memory.unified_memory[3960]} {testbench.memory.unified_memory[3959]} {testbench.memory.unified_memory[3958]} {testbench.memory.unified_memory[3957]} {testbench.memory.unified_memory[3956]} {testbench.memory.unified_memory[3955]} {testbench.memory.unified_memory[3954]} {testbench.memory.unified_memory[3953]} {testbench.memory.unified_memory[3952]} {testbench.memory.unified_memory[3951]} {testbench.memory.unified_memory[3950]} {testbench.memory.unified_memory[3949]} {testbench.memory.unified_memory[3948]} {testbench.memory.unified_memory[3947]} {testbench.memory.unified_memory[3946]} {testbench.memory.unified_memory[3945]} {testbench.memory.unified_memory[3944]} {testbench.memory.unified_memory[3943]} {testbench.memory.unified_memory[3942]} {testbench.memory.unified_memory[3941]} {testbench.memory.unified_memory[3940]} {testbench.memory.unified_memory[3939]} {testbench.memory.unified_memory[3938]} {testbench.memory.unified_memory[3937]} {testbench.memory.unified_memory[3936]} {testbench.memory.unified_memory[3935]} {testbench.memory.unified_memory[3934]} {testbench.memory.unified_memory[3933]} {testbench.memory.unified_memory[3932]} {testbench.memory.unified_memory[3931]} {testbench.memory.unified_memory[3930]} {testbench.memory.unified_memory[3929]} {testbench.memory.unified_memory[3928]} {testbench.memory.unified_memory[3927]} {testbench.memory.unified_memory[3926]} {testbench.memory.unified_memory[3925]} {testbench.memory.unified_memory[3924]} {testbench.memory.unified_memory[3923]} {testbench.memory.unified_memory[3922]} {testbench.memory.unified_memory[3921]} {testbench.memory.unified_memory[3920]} {testbench.memory.unified_memory[3919]} {testbench.memory.unified_memory[3918]} {testbench.memory.unified_memory[3917]} {testbench.memory.unified_memory[3916]} {testbench.memory.unified_memory[3915]} {testbench.memory.unified_memory[3914]} {testbench.memory.unified_memory[3913]} {testbench.memory.unified_memory[3912]} {testbench.memory.unified_memory[3911]} {testbench.memory.unified_memory[3910]} {testbench.memory.unified_memory[3909]} {testbench.memory.unified_memory[3908]} {testbench.memory.unified_memory[3907]} {testbench.memory.unified_memory[3906]} {testbench.memory.unified_memory[3905]} {testbench.memory.unified_memory[3904]} {testbench.memory.unified_memory[3903]} {testbench.memory.unified_memory[3902]} {testbench.memory.unified_memory[3901]} {testbench.memory.unified_memory[3900]} {testbench.memory.unified_memory[3899]} {testbench.memory.unified_memory[3898]} {testbench.memory.unified_memory[3897]} {testbench.memory.unified_memory[3896]} {testbench.memory.unified_memory[3895]} {testbench.memory.unified_memory[3894]} {testbench.memory.unified_memory[3893]} {testbench.memory.unified_memory[3892]} {testbench.memory.unified_memory[3891]} {testbench.memory.unified_memory[3890]} {testbench.memory.unified_memory[3889]} {testbench.memory.unified_memory[3888]} {testbench.memory.unified_memory[3887]} {testbench.memory.unified_memory[3886]} {testbench.memory.unified_memory[3885]} {testbench.memory.unified_memory[3884]} {testbench.memory.unified_memory[3883]} {testbench.memory.unified_memory[3882]} {testbench.memory.unified_memory[3881]} {testbench.memory.unified_memory[3880]} {testbench.memory.unified_memory[3879]} {testbench.memory.unified_memory[3878]} {testbench.memory.unified_memory[3877]} {testbench.memory.unified_memory[3876]} {testbench.memory.unified_memory[3875]} {testbench.memory.unified_memory[3874]} {testbench.memory.unified_memory[3873]} {testbench.memory.unified_memory[3872]} {testbench.memory.unified_memory[3871]} {testbench.memory.unified_memory[3870]} {testbench.memory.unified_memory[3869]} {testbench.memory.unified_memory[3868]} {testbench.memory.unified_memory[3867]} {testbench.memory.unified_memory[3866]} {testbench.memory.unified_memory[3865]} {testbench.memory.unified_memory[3864]} {testbench.memory.unified_memory[3863]} {testbench.memory.unified_memory[3862]} {testbench.memory.unified_memory[3861]} {testbench.memory.unified_memory[3860]} {testbench.memory.unified_memory[3859]} {testbench.memory.unified_memory[3858]} {testbench.memory.unified_memory[3857]} {testbench.memory.unified_memory[3856]} {testbench.memory.unified_memory[3855]} {testbench.memory.unified_memory[3854]} {testbench.memory.unified_memory[3853]} {testbench.memory.unified_memory[3852]} {testbench.memory.unified_memory[3851]} {testbench.memory.unified_memory[3850]} {testbench.memory.unified_memory[3849]} {testbench.memory.unified_memory[3848]} {testbench.memory.unified_memory[3847]} {testbench.memory.unified_memory[3846]} {testbench.memory.unified_memory[3845]} {testbench.memory.unified_memory[3844]} {testbench.memory.unified_memory[3843]} {testbench.memory.unified_memory[3842]} {testbench.memory.unified_memory[3841]} {testbench.memory.unified_memory[3840]} {testbench.memory.unified_memory[3839]} {testbench.memory.unified_memory[3838]} {testbench.memory.unified_memory[3837]} {testbench.memory.unified_memory[3836]} {testbench.memory.unified_memory[3835]} }}
gui_view_scroll -id ${Data.1} -vertical -set 78025
gui_view_scroll -id ${Data.1} -horizontal -set 0
gui_view_scroll -id ${Hier.1} -vertical -set 0
gui_view_scroll -id ${Hier.1} -horizontal -set 0

# Source 'Source.1'
gui_src_value_annotate -id ${Source.1} -switch false
gui_set_env TOGGLE::VALUEANNOTATE 0
gui_open_source -id ${Source.1}  -replace -active testbench.memory /afs/umich.edu/user/s/c/scottmel/EECS470/FinalProject/eecs470/vsimp_new/testbench/mem.v
gui_src_value_annotate -id ${Source.1} -switch true
gui_set_env TOGGLE::VALUEANNOTATE 1
gui_view_scroll -id ${Source.1} -vertical -set 510
gui_src_set_reusable -id ${Source.1}

# View 'Wave.1'
gui_wv_sync -id ${Wave.1} -switch false
set groupExD [gui_get_pref_value -category Wave -key exclusiveSG]
gui_set_pref_value -category Wave -key exclusiveSG -value {false}
set origWaveHeight [gui_get_pref_value -category Wave -key waveRowHeight]
gui_list_set_height -id Wave -height 25
set origGroupCreationState [gui_list_create_group_when_add -wave]
gui_list_create_group_when_add -wave -disable
gui_wv_zoom_timerange -id ${Wave.1} 1327 1713
gui_list_add_group -id ${Wave.1} -after {New Group} {Group1}
gui_list_select -id ${Wave.1} {testbench.pipeline_0.lsq_Dmem2proc_data }
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
gui_list_set_insertion_bar  -id ${Wave.1} -group Group1  -position in

gui_marker_move -id ${Wave.1} {C1} 1447
gui_view_scroll -id ${Wave.1} -vertical -set 0
gui_show_grid -id ${Wave.1} -enable false

# View 'Memory.1'
gui_show_memory -window ${Memory.1} -memory {testbench.memory.unified_memory[8191:0][63:0]}
gui_set_memory_properties -window ${Memory.1} -columns 1 -address_factor -1 -address_offset 8191 -start_address 8191 -end_address 0 -address_radix 10
gui_set_radix -radix {hex} -signals {{testbench.memory.unified_memory[8191:0][63:0]}}
gui_set_radix -radix {unsigned} -signals {{testbench.memory.unified_memory[8191:0][63:0]}}
gui_view_scroll -id ${Memory.1} -vertical -set 0
gui_view_scroll -id ${Memory.1} -horizontal -set 0
# Restore toplevel window zorder
# The toplevel window could be closed if it has no view/pane
if {[gui_exist_window -window ${TopLevel.1}]} {
	gui_set_active_window -window ${TopLevel.1}
	gui_set_active_window -window ${Memory.1}
	gui_set_active_window -window ${DLPane.1}
}
if {[gui_exist_window -window ${TopLevel.2}]} {
	gui_set_active_window -window ${TopLevel.2}
	gui_set_active_window -window ${Wave.1}
}
#</Session>

