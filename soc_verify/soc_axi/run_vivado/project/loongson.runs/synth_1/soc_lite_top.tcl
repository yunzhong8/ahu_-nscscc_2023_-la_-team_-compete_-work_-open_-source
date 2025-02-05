# 
# Synthesis run script generated by Vivado
# 

set TIME_start [clock seconds] 
proc create_report { reportName command } {
  set status "."
  append status $reportName ".fail"
  if { [file exists $status] } {
    eval file delete [glob $status]
  }
  send_msg_id runtcl-4 info "Executing : $command"
  set retval [eval catch { $command } msg]
  if { $retval != 0 } {
    set fp [open $status w]
    close $fp
    send_msg_id runtcl-5 warning "$msg"
  }
}
create_project -in_memory -part xc7a200tfbg676-2

set_param project.singleFileAddWarning.threshold 0
set_param project.compositeFile.enableAutoGeneration 0
set_param synth.vivado.isSynthRun true
set_msg_config -source 4 -id {IP_Flow 19-2162} -severity warning -new_severity info
set_property webtalk.parent_dir /home/sun/Vivado2019/nscscc/func-submit/soc_verify/soc_axi/run_vivado/project/loongson.cache/wt [current_project]
set_property parent.project_path /home/sun/Vivado2019/nscscc/func-submit/soc_verify/soc_axi/run_vivado/project/loongson.xpr [current_project]
set_property XPM_LIBRARIES {XPM_CDC XPM_MEMORY} [current_project]
set_property default_lib xil_defaultlib [current_project]
set_property target_language Verilog [current_project]
set_property ip_output_repo /home/sun/Vivado2019/nscscc/func-submit/soc_verify/soc_axi/run_vivado/project/loongson.cache/ip [current_project]
set_property ip_cache_permissions {read write} [current_project]
add_files /home/sun/Vivado2019/nscscc/func-submit/func/obj/inst_ram.coe
read_verilog {
  /home/sun/Vivado2019/nscscc/func-submit/soc_verify/soc_axi/run_vivado/project/loongson.srcs/sources_1/imports/mycpu/DefineError.h
  /home/sun/Vivado2019/nscscc/func-submit/soc_verify/soc_axi/run_vivado/project/loongson.srcs/sources_1/imports/mycpu/DefineConfg.h
  /home/sun/Vivado2019/nscscc/func-submit/soc_verify/soc_axi/run_vivado/project/loongson.srcs/sources_1/imports/mycpu/DefineSignLocation.h
  /home/sun/Vivado2019/nscscc/func-submit/soc_verify/soc_axi/run_vivado/project/loongson.srcs/sources_1/imports/mycpu/DefineTestConfg.h
  /home/sun/Vivado2019/nscscc/func-submit/soc_verify/soc_axi/run_vivado/project/loongson.srcs/sources_1/imports/mycpu/DefineLoogLenWidth.h
  /home/sun/Vivado2019/nscscc/func-submit/soc_verify/soc_axi/run_vivado/project/loongson.srcs/sources_1/imports/mycpu/DefineModuleBus.h
  /home/sun/Vivado2019/nscscc/func-submit/soc_verify/soc_axi/run_vivado/project/loongson.srcs/sources_1/imports/mycpu/DefineCache.h
  /home/sun/Vivado2019/nscscc/func-submit/soc_verify/soc_axi/run_vivado/project/loongson.srcs/sources_1/imports/mycpu/DefineExcepSign.h
  /home/sun/Vivado2019/nscscc/func-submit/soc_verify/soc_axi/run_vivado/project/loongson.srcs/sources_1/imports/mycpu/DefineCsrAddr.h
  /home/sun/Vivado2019/nscscc/func-submit/soc_verify/soc_axi/run_vivado/project/loongson.srcs/sources_1/imports/mycpu/DefineMemSign.h
  /home/sun/Vivado2019/nscscc/func-submit/soc_verify/soc_axi/run_vivado/project/loongson.srcs/sources_1/imports/mycpu/DefineAluOp.h
  /home/sun/Vivado2019/nscscc/func-submit/soc_verify/soc_axi/run_vivado/project/loongson.srcs/sources_1/imports/mycpu/DefineInstSign.h
  /home/sun/Vivado2019/nscscc/func-submit/soc_verify/soc_axi/run_vivado/project/loongson.srcs/sources_1/imports/mycpu/DefineIdSign.h
  /home/sun/Vivado2019/nscscc/func-submit/soc_verify/soc_axi/run_vivado/project/loongson.srcs/sources_1/imports/mycpu/DefineExSign.h
  /home/sun/Vivado2019/nscscc/func-submit/soc_verify/soc_axi/run_vivado/project/loongson.srcs/sources_1/imports/mycpu/DefineWbSign.h
  /home/sun/Vivado2019/nscscc/func-submit/soc_verify/soc_axi/run_vivado/project/loongson.srcs/sources_1/imports/mycpu/DefineBJSign.h
}
set_property file_type "Verilog Header" [get_files /home/sun/Vivado2019/nscscc/func-submit/soc_verify/soc_axi/run_vivado/project/loongson.srcs/sources_1/imports/mycpu/DefineError.h]
set_property file_type "Verilog Header" [get_files /home/sun/Vivado2019/nscscc/func-submit/soc_verify/soc_axi/run_vivado/project/loongson.srcs/sources_1/imports/mycpu/DefineConfg.h]
set_property file_type "Verilog Header" [get_files /home/sun/Vivado2019/nscscc/func-submit/soc_verify/soc_axi/run_vivado/project/loongson.srcs/sources_1/imports/mycpu/DefineSignLocation.h]
set_property file_type "Verilog Header" [get_files /home/sun/Vivado2019/nscscc/func-submit/soc_verify/soc_axi/run_vivado/project/loongson.srcs/sources_1/imports/mycpu/DefineTestConfg.h]
set_property file_type "Verilog Header" [get_files /home/sun/Vivado2019/nscscc/func-submit/soc_verify/soc_axi/run_vivado/project/loongson.srcs/sources_1/imports/mycpu/DefineLoogLenWidth.h]
set_property file_type "Verilog Header" [get_files /home/sun/Vivado2019/nscscc/func-submit/soc_verify/soc_axi/run_vivado/project/loongson.srcs/sources_1/imports/mycpu/DefineModuleBus.h]
set_property file_type "Verilog Header" [get_files /home/sun/Vivado2019/nscscc/func-submit/soc_verify/soc_axi/run_vivado/project/loongson.srcs/sources_1/imports/mycpu/DefineCache.h]
set_property file_type "Verilog Header" [get_files /home/sun/Vivado2019/nscscc/func-submit/soc_verify/soc_axi/run_vivado/project/loongson.srcs/sources_1/imports/mycpu/DefineExcepSign.h]
set_property file_type "Verilog Header" [get_files /home/sun/Vivado2019/nscscc/func-submit/soc_verify/soc_axi/run_vivado/project/loongson.srcs/sources_1/imports/mycpu/DefineCsrAddr.h]
set_property file_type "Verilog Header" [get_files /home/sun/Vivado2019/nscscc/func-submit/soc_verify/soc_axi/run_vivado/project/loongson.srcs/sources_1/imports/mycpu/DefineMemSign.h]
set_property file_type "Verilog Header" [get_files /home/sun/Vivado2019/nscscc/func-submit/soc_verify/soc_axi/run_vivado/project/loongson.srcs/sources_1/imports/mycpu/DefineAluOp.h]
set_property file_type "Verilog Header" [get_files /home/sun/Vivado2019/nscscc/func-submit/soc_verify/soc_axi/run_vivado/project/loongson.srcs/sources_1/imports/mycpu/DefineInstSign.h]
set_property file_type "Verilog Header" [get_files /home/sun/Vivado2019/nscscc/func-submit/soc_verify/soc_axi/run_vivado/project/loongson.srcs/sources_1/imports/mycpu/DefineIdSign.h]
set_property file_type "Verilog Header" [get_files /home/sun/Vivado2019/nscscc/func-submit/soc_verify/soc_axi/run_vivado/project/loongson.srcs/sources_1/imports/mycpu/DefineExSign.h]
set_property file_type "Verilog Header" [get_files /home/sun/Vivado2019/nscscc/func-submit/soc_verify/soc_axi/run_vivado/project/loongson.srcs/sources_1/imports/mycpu/DefineWbSign.h]
set_property file_type "Verilog Header" [get_files /home/sun/Vivado2019/nscscc/func-submit/soc_verify/soc_axi/run_vivado/project/loongson.srcs/sources_1/imports/mycpu/DefineBJSign.h]
read_verilog -library xil_defaultlib {
  /home/sun/Vivado2019/nscscc/func-submit/soc_verify/soc_axi/run_vivado/project/loongson.srcs/sources_1/imports/mycpu/define.v
  /home/sun/Vivado2019/nscscc/func-submit/soc_verify/soc_axi/run_vivado/project/loongson.srcs/sources_1/imports/mycpu/Arith_Logic_Unit.v
  /home/sun/Vivado2019/nscscc/func-submit/soc_verify/soc_axi/run_vivado/project/loongson.srcs/sources_1/imports/mycpu/Branch_Unit.v
  /home/sun/Vivado2019/nscscc/func-submit/soc_verify/soc_axi/run_vivado/project/loongson.srcs/sources_1/imports/mycpu/CacheRdataQueue.v
  /home/sun/Vivado2019/nscscc/func-submit/soc_verify/soc_axi/run_vivado/project/loongson.srcs/sources_1/imports/mycpu/Cdo.v
  /home/sun/Vivado2019/nscscc/func-submit/soc_verify/soc_axi/run_vivado/project/loongson.srcs/sources_1/imports/mycpu/CdoCb.v
  /home/sun/Vivado2019/nscscc/func-submit/soc_verify/soc_axi/run_vivado/project/loongson.srcs/sources_1/imports/mycpu/CdoSq.v
  /home/sun/Vivado2019/nscscc/func-submit/soc_verify/soc_axi/run_vivado/project/loongson.srcs/sources_1/imports/mycpu/CountReg.v
  /home/sun/Vivado2019/nscscc/func-submit/soc_verify/soc_axi/run_vivado/project/loongson.srcs/sources_1/imports/mycpu/Csr.v
  /home/sun/Vivado2019/nscscc/func-submit/soc_verify/soc_axi/run_vivado/project/loongson.srcs/sources_1/imports/mycpu/Data_Relevant.v
  /home/sun/Vivado2019/nscscc/func-submit/soc_verify/soc_axi/run_vivado/project/loongson.srcs/sources_1/imports/mycpu/Div.v
  /home/sun/Vivado2019/nscscc/func-submit/soc_verify/soc_axi/run_vivado/project/loongson.srcs/sources_1/imports/mycpu/EX.v
  /home/sun/Vivado2019/nscscc/func-submit/soc_verify/soc_axi/run_vivado/project/loongson.srcs/sources_1/imports/mycpu/EX_MEM.v
  /home/sun/Vivado2019/nscscc/func-submit/soc_verify/soc_axi/run_vivado/project/loongson.srcs/sources_1/imports/mycpu/Error.v
  /home/sun/Vivado2019/nscscc/func-submit/soc_verify/soc_axi/run_vivado/project/loongson.srcs/sources_1/imports/mycpu/ExStage.v
  /home/sun/Vivado2019/nscscc/func-submit/soc_verify/soc_axi/run_vivado/project/loongson.srcs/sources_1/imports/mycpu/ID.v
  /home/sun/Vivado2019/nscscc/func-submit/soc_verify/soc_axi/run_vivado/project/loongson.srcs/sources_1/imports/mycpu/ID_EX.v
  /home/sun/Vivado2019/nscscc/func-submit/soc_verify/soc_axi/run_vivado/project/loongson.srcs/sources_1/imports/mycpu/IF.v
  /home/sun/Vivado2019/nscscc/func-submit/soc_verify/soc_axi/run_vivado/project/loongson.srcs/sources_1/imports/mycpu/IF_ID.v
  /home/sun/Vivado2019/nscscc/func-submit/soc_verify/soc_axi/run_vivado/project/loongson.srcs/sources_1/imports/mycpu/IdCb.v
  /home/sun/Vivado2019/nscscc/func-submit/soc_verify/soc_axi/run_vivado/project/loongson.srcs/sources_1/imports/mycpu/IdSq.v
  /home/sun/Vivado2019/nscscc/func-submit/soc_verify/soc_axi/run_vivado/project/loongson.srcs/sources_1/imports/mycpu/IdStage.v
  /home/sun/Vivado2019/nscscc/func-submit/soc_verify/soc_axi/run_vivado/project/loongson.srcs/sources_1/imports/mycpu/IfStage.v
  /home/sun/Vivado2019/nscscc/func-submit/soc_verify/soc_axi/run_vivado/project/loongson.srcs/sources_1/imports/mycpu/IfTCb.v
  /home/sun/Vivado2019/nscscc/func-submit/soc_verify/soc_axi/run_vivado/project/loongson.srcs/sources_1/imports/mycpu/IfTSq.v
  /home/sun/Vivado2019/nscscc/func-submit/soc_verify/soc_axi/run_vivado/project/loongson.srcs/sources_1/imports/mycpu/IfTStage.v
  /home/sun/Vivado2019/nscscc/func-submit/soc_verify/soc_axi/run_vivado/project/loongson.srcs/sources_1/imports/mycpu/IndetifyInstType.v
  /home/sun/Vivado2019/nscscc/func-submit/soc_verify/soc_axi/run_vivado/project/loongson.srcs/sources_1/imports/mycpu/Lanuch.v
  /home/sun/Vivado2019/nscscc/func-submit/soc_verify/soc_axi/run_vivado/project/loongson.srcs/sources_1/imports/mycpu/Loog.v
  /home/sun/Vivado2019/nscscc/func-submit/soc_verify/soc_axi/run_vivado/project/loongson.srcs/sources_1/imports/mycpu/MEM.v
  /home/sun/Vivado2019/nscscc/func-submit/soc_verify/soc_axi/run_vivado/project/loongson.srcs/sources_1/imports/mycpu/MEM_WB.v
  /home/sun/Vivado2019/nscscc/func-submit/soc_verify/soc_axi/run_vivado/project/loongson.srcs/sources_1/imports/mycpu/MMCb.v
  /home/sun/Vivado2019/nscscc/func-submit/soc_verify/soc_axi/run_vivado/project/loongson.srcs/sources_1/imports/mycpu/MMSq.v
  /home/sun/Vivado2019/nscscc/func-submit/soc_verify/soc_axi/run_vivado/project/loongson.srcs/sources_1/imports/mycpu/MMStage.v
  /home/sun/Vivado2019/nscscc/func-submit/soc_verify/soc_axi/run_vivado/project/loongson.srcs/sources_1/imports/mycpu/MemStage.v
  /home/sun/Vivado2019/nscscc/func-submit/soc_verify/soc_axi/run_vivado/project/loongson.srcs/sources_1/imports/mycpu/Mmu.v
  /home/sun/Vivado2019/nscscc/func-submit/soc_verify/soc_axi/run_vivado/project/loongson.srcs/sources_1/imports/mycpu/OpDecoder.v
  /home/sun/Vivado2019/nscscc/func-submit/soc_verify/soc_axi/run_vivado/project/loongson.srcs/sources_1/imports/mycpu/PreIF.v
  /home/sun/Vivado2019/nscscc/func-submit/soc_verify/soc_axi/run_vivado/project/loongson.srcs/sources_1/imports/mycpu/Predactor.v
  /home/sun/Vivado2019/nscscc/func-submit/soc_verify/soc_axi/run_vivado/project/loongson.srcs/sources_1/imports/mycpu/Predactor_Btb.v
  /home/sun/Vivado2019/nscscc/func-submit/soc_verify/soc_axi/run_vivado/project/loongson.srcs/sources_1/imports/mycpu/Predactor_PUC.v
  /home/sun/Vivado2019/nscscc/func-submit/soc_verify/soc_axi/run_vivado/project/loongson.srcs/sources_1/imports/mycpu/Predactor_Pht.v
  /home/sun/Vivado2019/nscscc/func-submit/soc_verify/soc_axi/run_vivado/project/loongson.srcs/sources_1/imports/mycpu/PreifReg.v
  /home/sun/Vivado2019/nscscc/func-submit/soc_verify/soc_axi/run_vivado/project/loongson.srcs/sources_1/imports/mycpu/Preif_IF.v
  /home/sun/Vivado2019/nscscc/func-submit/soc_verify/soc_axi/run_vivado/project/loongson.srcs/sources_1/imports/mycpu/Queue.v
  /home/sun/Vivado2019/nscscc/func-submit/soc_verify/soc_axi/run_vivado/project/loongson.srcs/sources_1/imports/mycpu/Reg_File.v
  /home/sun/Vivado2019/nscscc/func-submit/soc_verify/soc_axi/run_vivado/project/loongson.srcs/sources_1/imports/mycpu/Reg_File_Box.v
  /home/sun/Vivado2019/nscscc/func-submit/soc_verify/soc_axi/run_vivado/project/loongson.srcs/sources_1/imports/mycpu/SignProduce.v
  /home/sun/Vivado2019/nscscc/func-submit/soc_verify/soc_axi/run_vivado/project/loongson.srcs/sources_1/imports/mycpu/TlbGroup.v
  /home/sun/Vivado2019/nscscc/func-submit/soc_verify/soc_axi/run_vivado/project/loongson.srcs/sources_1/imports/mycpu/WB.v
  /home/sun/Vivado2019/nscscc/func-submit/soc_verify/soc_axi/run_vivado/project/loongson.srcs/sources_1/imports/mycpu/WbStage.v
  /home/sun/Vivado2019/nscscc/func-submit/soc_verify/soc_axi/rtl/axi_wrap/axi_wrap.v
  /home/sun/Vivado2019/nscscc/func-submit/soc_verify/soc_axi/rtl/ram_wrap/axi_wrap_ram.v
  /home/sun/Vivado2019/nscscc/func-submit/soc_verify/soc_axi/run_vivado/project/loongson.srcs/sources_1/imports/mycpu/cache_table.v
  /home/sun/Vivado2019/nscscc/func-submit/soc_verify/soc_axi/run_vivado/project/loongson.srcs/sources_1/imports/mycpu/cache_way.v
  /home/sun/Vivado2019/nscscc/func-submit/soc_verify/soc_axi/rtl/CONFREG/confreg.v
  /home/sun/Vivado2019/nscscc/func-submit/soc_verify/soc_axi/run_vivado/project/loongson.srcs/sources_1/imports/mycpu/mycpu_cache_top.v
  /home/sun/Vivado2019/nscscc/func-submit/soc_verify/soc_axi/run_vivado/project/loongson.srcs/sources_1/imports/mycpu/mycpu_top.v
  /home/sun/Vivado2019/nscscc/func-submit/soc_verify/soc_axi/run_vivado/project/loongson.srcs/sources_1/imports/mycpu/simple_sram_aix_bridge.v
  /home/sun/Vivado2019/nscscc/func-submit/soc_verify/soc_axi/run_vivado/project/loongson.srcs/sources_1/imports/mycpu/temp_cache.v
  /home/sun/Vivado2019/nscscc/func-submit/soc_verify/soc_axi/run_vivado/project/loongson.srcs/sources_1/imports/mycpu/tlb.v
  /home/sun/Vivado2019/nscscc/func-submit/soc_verify/soc_axi/run_vivado/project/loongson.srcs/sources_1/imports/mycpu/tools.v
  /home/sun/Vivado2019/nscscc/func-submit/soc_verify/soc_axi/run_vivado/project/loongson.srcs/sources_1/imports/mycpu/wallace_mul.v
  /home/sun/Vivado2019/nscscc/func-submit/soc_verify/soc_axi/rtl/soc_lite_top.v
}
read_ip -quiet /home/sun/Vivado2019/nscscc/func-submit/soc_verify/soc_axi/rtl/xilinx_ip/clk_pll/clk_pll.xci
set_property used_in_implementation false [get_files -all /home/sun/Vivado2019/nscscc/func-submit/soc_verify/soc_axi/rtl/xilinx_ip/clk_pll/clk_pll_board.xdc]
set_property used_in_implementation false [get_files -all /home/sun/Vivado2019/nscscc/func-submit/soc_verify/soc_axi/rtl/xilinx_ip/clk_pll/clk_pll.xdc]
set_property used_in_implementation false [get_files -all /home/sun/Vivado2019/nscscc/func-submit/soc_verify/soc_axi/rtl/xilinx_ip/clk_pll/clk_pll_ooc.xdc]

read_ip -quiet /home/sun/Vivado2019/nscscc/func-submit/soc_verify/soc_axi/run_vivado/project/loongson.srcs/sources_1/ip/pht_ram/pht_ram.xci
set_property used_in_implementation false [get_files -all /home/sun/Vivado2019/nscscc/func-submit/soc_verify/soc_axi/run_vivado/project/loongson.srcs/sources_1/ip/pht_ram/pht_ram_ooc.xdc]

read_ip -quiet /home/sun/Vivado2019/nscscc/func-submit/soc_verify/soc_axi/run_vivado/project/loongson.srcs/sources_1/ip/tagv_ram/tagv_ram.xci
set_property used_in_implementation false [get_files -all /home/sun/Vivado2019/nscscc/func-submit/soc_verify/soc_axi/run_vivado/project/loongson.srcs/sources_1/ip/tagv_ram/tagv_ram_ooc.xdc]

read_ip -quiet /home/sun/Vivado2019/nscscc/func-submit/soc_verify/soc_axi/run_vivado/project/loongson.srcs/sources_1/ip/data_bank/data_bank.xci
set_property used_in_implementation false [get_files -all /home/sun/Vivado2019/nscscc/func-submit/soc_verify/soc_axi/run_vivado/project/loongson.srcs/sources_1/ip/data_bank/data_bank_ooc.xdc]

read_ip -quiet /home/sun/Vivado2019/nscscc/func-submit/soc_verify/soc_axi/rtl/xilinx_ip/axi_crossbar_1x2/axi_crossbar_1x2.xci
set_property used_in_implementation false [get_files -all /home/sun/Vivado2019/nscscc/func-submit/soc_verify/soc_axi/rtl/xilinx_ip/axi_crossbar_1x2/axi_crossbar_1x2_ooc.xdc]

read_ip -quiet /home/sun/Vivado2019/nscscc/func-submit/soc_verify/soc_axi/run_vivado/project/loongson.srcs/sources_1/ip/btb_ram/btb_ram.xci
set_property used_in_implementation false [get_files -all /home/sun/Vivado2019/nscscc/func-submit/soc_verify/soc_axi/run_vivado/project/loongson.srcs/sources_1/ip/btb_ram/btb_ram_ooc.xdc]

read_ip -quiet /home/sun/Vivado2019/nscscc/func-submit/soc_verify/soc_axi/rtl/xilinx_ip/axi_ram/axi_ram.xci
set_property used_in_implementation false [get_files -all /home/sun/Vivado2019/nscscc/func-submit/soc_verify/soc_axi/rtl/xilinx_ip/axi_ram/axi_ram_ooc.xdc]

# Mark all dcp files as not used in implementation to prevent them from being
# stitched into the results of this synthesis run. Any black boxes in the
# design are intentionally left as such for best results. Dcp files will be
# stitched into the design at a later time, either when this synthesis run is
# opened, or when it is stitched into a dependent implementation run.
foreach dcp [get_files -quiet -all -filter file_type=="Design\ Checkpoint"] {
  set_property used_in_implementation false $dcp
}
read_xdc /home/sun/Vivado2019/nscscc/func-submit/soc_verify/soc_axi/run_vivado/constraints/soc_lite_top.xdc
set_property used_in_implementation false [get_files /home/sun/Vivado2019/nscscc/func-submit/soc_verify/soc_axi/run_vivado/constraints/soc_lite_top.xdc]

set_param ips.enableIPCacheLiteLoad 1
close [open __synthesis_is_running__ w]

synth_design -top soc_lite_top -part xc7a200tfbg676-2


# disable binary constraint mode for synth run checkpoints
set_param constraints.enableBinaryConstraints false
write_checkpoint -force -noxdef soc_lite_top.dcp
create_report "synth_1_synth_report_utilization_0" "report_utilization -file soc_lite_top_utilization_synth.rpt -pb soc_lite_top_utilization_synth.pb"
file delete __synthesis_is_running__
close [open __synthesis_is_complete__ w]
