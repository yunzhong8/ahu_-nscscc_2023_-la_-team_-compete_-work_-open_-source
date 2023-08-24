`ifndef DEFINETESTCONFG
`define DEFINETESTCONFG
/*本文件是用于控制CPU的测试的配置文件
1.ila测试端口是否打开
2.是否打印轨迹
*/
/***************************************ILA测试**************************************/
//`define OPEN_ILA               //未被注销表示：是否打开总体的ila （打开这个下面才有效）
//`define OPEN_ILA_CPU_WHOLE     //未被注销表示：是打开CPU内的ila完整的ial
//`define OPEN_ILA_CPU_SIMPLY    //未被注销表示：打开简单的CPUILA

//`define OEPN_ILA_ICACHEILA     //未被注销表示：打开icache的ila
//`define OEPN_ILA_ICACHEILA_WHOLE

//`define OEPN_ILA_DCACHEILA     //未被注销表示：打开dcache的ila
//`define OEPN_ILA_DCACHEILA_WHOLE

//`define OPEN_ILA_Bridge        //未被注销表示：打开转接桥的的ila
//`define OPEN_ILA_Bridge_WHOLE


/***************************************仿真测试配置文件**************************************/
    //1表示关闭对比测试，0表示开启对比测试（关键）
    `define close_trace_compare  0 //(default:1,表示关闭对比测试)
    //1表示用zzq设置的正确轨迹进行对比测试,0表示源代码的测试集
    `define use_zzq_test  0 //（default:0表示使用官方的正确轨迹进行比对）
        
     //是否生成轨迹逻辑代码（关键）
//        `define OPEN_DIFF //(default默认注销了，表示不将diff模块加入cpu中不记录trace)

   
 //（关键）
//    `define DOUBLE_LAUNCH_TRACE//本行没有被注销，则表示记录路径使用双发射的路径，所以如果双发使能则不注销本行，如果单发射则注销本行
     //以下行只允许一行是未被注销的
     //`define TEST_allbench
     //`define TEST_bitcount//pass
     //`define TEST_bubble_sort //pass
     //`define TEST_coremark//pass
     //`define TEST_crc32//pass
     //`define TEST_dhrystone //pass
     //`define TEST_quick_sort//pass 0mi
     //`define TEST_select_sort //已经通过
     //`define TEST_sha //pass
    `define TEST_stream_copy //已经通过（default:默认不注销表示测试streamcopy测试集）
//     `define TEST_stringsearch //pass
     //`define TEST_func
//     `define TEST_zzq
    
/********************设置是否使用trace对比测试当前CPU********************/   
   
    //trace比对正确轨迹的路径，
            //官方
//                 `define TRACE_REF_FILE "/home/ysyx/LoogArch/work_catagory/func-submit-master/gettrace/golden_trace.txt"
//                `define TRACE_REF_FILE  "/home/ysyx/perf_test-la32r/soft/func_gettrace/golden_trace.txt"    
            //在zzq路径
                `define ZZQ_TRACE_REF_FILE "/home/ysyx/LoogArch/LoongArch_Trace_record/right_trace/ZzqTest/test_jmp.txt"
    
/********************设置记录的信息********************/
       
        
        //1表示用txt记录trance
        `define simply_trace_record_open 1
        `define whole_trace_record_open  1
        `define dcache_trace_record_open 1
        `define bridge_trace_record_open 1
        //1表示当前记录的是正确运行的轨迹，0表示当前记录的轨迹是要进行测试的
        `define record_right_trace 0 
        
        /********************设在测试文件记录路径********************/
           
            `define RECODE_DCACHE 1
            
                                  
            `ifdef DOUBLE_LAUNCH_TRACE
                `ifdef TEST_allbench//双发射的轨迹记录路径路径
                    `define Test_TRACE_WRITE_FILE              "/home/ysyx/LoogArch/LoongArch_Trace_record/double_launch_test_trace/PerfTest/allbench/allbench_simply.txt"   
                    `define Test_TRACE_WRITE_FILE_WHOLE        "/home/ysyx/LoogArch/LoongArch_Trace_record/double_launch_test_trace/PerfTest/allbench/allbench_whole.txt"
                    `define Test_TRACE_WRITE_FILE_WHOLE_CACHE  "/home/ysyx/LoogArch/LoongArch_Trace_record/double_launch_test_trace/PerfTest/allbench/allbench_whole_cache.txt"
                    `define Test_TRACE_WRITE_FILE_WHOLE_BRIDGE "/home/ysyx/LoogArch/LoongArch_Trace_record/double_launch_test_trace/PerfTest/allbench/allbench_whole_bridge.txt"
                `elsif TEST_bitcount      
                    `define Test_TRACE_WRITE_FILE              "/home/ysyx/LoogArch/LoongArch_Trace_record/double_launch_test_trace/PerfTest/bitcount/bitcount_simply.txt"
                    `define Test_TRACE_WRITE_FILE_WHOLE        "/home/ysyx/LoogArch/LoongArch_Trace_record/double_launch_test_trace/PerfTest/bitcount/bitcount_whole.txt"
                    `define Test_TRACE_WRITE_FILE_WHOLE_CACHE  "/home/ysyx/LoogArch/LoongArch_Trace_record/double_launch_test_trace/PerfTest/bitcount/bitcount_whole_cache.txt"
                    `define Test_TRACE_WRITE_FILE_WHOLE_BRIDGE "/home/ysyx/LoogArch/LoongArch_Trace_record/double_launch_test_trace/PerfTest/bitcount/bitcount_whole_bridge.txt"
                `elsif TEST_bubble_sort         
                    `define Test_TRACE_WRITE_FILE              "/home/ysyx/LoogArch/LoongArch_Trace_record/double_launch_test_trace/PerfTest/bubble_sort/bubble_sort_simply.txt"   
                    `define Test_TRACE_WRITE_FILE_WHOLE        "/home/ysyx/LoogArch/LoongArch_Trace_record/double_launch_test_trace/PerfTest/bubble_sort/bubble_sort_whole.txt" 
                    `define Test_TRACE_WRITE_FILE_WHOLE_CACHE  "/home/ysyx/LoogArch/LoongArch_Trace_record/double_launch_test_trace/PerfTest/bubble_sort/bubble_sort_whole_cache.txt" 
                    `define Test_TRACE_WRITE_FILE_WHOLE_BRIDGE "/home/ysyx/LoogArch/LoongArch_Trace_record/double_launch_test_trace/PerfTest/bubble_sort/bubble_sort_whole_bridge.txt"
                `elsif TEST_coremark 
                    `define Test_TRACE_WRITE_FILE              "/home/ysyx/LoogArch/LoongArch_Trace_record/double_launch_test_trace/PerfTest/coremark/coremark_simply.txt"  
                    `define Test_TRACE_WRITE_FILE_WHOLE        "/home/ysyx/LoogArch/LoongArch_Trace_record/double_launch_test_trace/PerfTest/coremark/coremark_whole.txt"   
                    `define Test_TRACE_WRITE_FILE_WHOLE_CACHE  "/home/ysyx/LoogArch/LoongArch_Trace_record/double_launch_test_trace/PerfTest/coremark/coremark_whole_cache.txt" 
                    `define Test_TRACE_WRITE_FILE_WHOLE_BRIDGE "/home/ysyx/LoogArch/LoongArch_Trace_record/test_trace/ZzqTest/cahce_replace_test/cahce_replace_test_whole_bridge.txt"
                `elsif TEST_crc32     
                    `define Test_TRACE_WRITE_FILE "/home/ysyx/LoogArch/LoongArch_Trace_record/double_launch_test_trace/PerfTest/crc32/crc32_simply.txt"     
                    `define Test_TRACE_WRITE_FILE_WHOLE "/home/ysyx/LoogArch/LoongArch_Trace_record/double_launch_test_trace/PerfTest/crc32/crc32_whole.txt"
                    `define Test_TRACE_WRITE_FILE_WHOLE_CACHE "/home/ysyx/LoogArch/LoongArch_Trace_record/double_launch_test_trace/PerfTest/crc32/crc32_whole_cache.txt"
                    `define Test_TRACE_WRITE_FILE_WHOLE_BRIDGE "/home/ysyx/LoogArch/LoongArch_Trace_record/test_trace/ZzqTest/cahce_replace_test/cahce_replace_test_whole_bridge.txt"
                `elsif TEST_dhrystone          
                    `define Test_TRACE_WRITE_FILE  "/home/ysyx/LoogArch/LoongArch_Trace_record/double_launch_test_trace/PerfTest/dhrystone/dhrystone_simply.txt"    
                    `define Test_TRACE_WRITE_FILE_WHOLE "/home/ysyx/LoogArch/LoongArch_Trace_record/test_tracedouble_launch_test_trace/PerfTest/dhrystone/dhrystone_whole.txt" 
                    `define Test_TRACE_WRITE_FILE_WHOLE_CACHE "/home/ysyx/LoogArch/LoongArch_Trace_record/double_launch_test_trace/PerfTest/dhrystone/dhrystone_whole_cache.txt"
                    `define Test_TRACE_WRITE_FILE_WHOLE_BRIDGE "/home/ysyx/LoogArch/LoongArch_Trace_record/test_trace/ZzqTest/cahce_replace_test/cahce_replace_test_whole_bridge.txt"
                `elsif TEST_quick_sort  
                    `define Test_TRACE_WRITE_FILE "/home/ysyx/LoogArch/LoongArch_Trace_record/double_launch_test_trace/PerfTest/quick_sort/quick_sort_simply.txt"  
                    `define Test_TRACE_WRITE_FILE_WHOLE "/home/ysyx/LoogArch/LoongArch_Trace_record/double_launch_test_trace/PerfTest/quick_sort/quick_sort_whole.txt"    
                    `define Test_TRACE_WRITE_FILE_WHOLE_CACHE "/home/ysyx/LoogArch/LoongArch_Trace_record/double_launch_test_trace/PerfTest/quick_sort/quick_sort_whole_cache.txt"   
                    `define Test_TRACE_WRITE_FILE_WHOLE_BRIDGE "/home/ysyx/LoogArch/LoongArch_Trace_record/test_trace/ZzqTest/cahce_replace_test/cahce_replace_test_whole_bridge.txt" 
                `elsif  TEST_select_sort
                    `define Test_TRACE_WRITE_FILE "/home/ysyx/LoogArch/LoongArch_Trace_record/double_launch_test_trace/PerfTest/select_sort/select_sort_simply.txt"    
                    `define Test_TRACE_WRITE_FILE_WHOLE "/home/ysyx/LoogArch/LoongArch_Trace_record/double_launch_test_trace/PerfTest/select_sort/select_sort_whole.txt"
                    `define Test_TRACE_WRITE_FILE_WHOLE_CACHE "/home/ysyx/LoogArch/LoongArch_Trace_record/double_launch_test_trace/PerfTest/select_sort/select_sort_whole_cache.txt"
                    `define Test_TRACE_WRITE_FILE_WHOLE_BRIDGE "/home/ysyx/LoogArch/LoongArch_Trace_record/test_trace/ZzqTest/cahce_replace_test/cahce_replace_test_whole_bridge.txt"
                `elsif TEST_sha     
                    `define Test_TRACE_WRITE_FILE "/home/ysyx/LoogArch/LoongArch_Trace_record/double_launch_test_trace/PerfTest/sha/sha_simply.txt"        
                    `define Test_TRACE_WRITE_FILE_WHOLE "/home/ysyx/LoogArch/LoongArch_Trace_record/double_launch_test_trace/PerfTest/sha/sha_whole.txt"   
                    `define Test_TRACE_WRITE_FILE_WHOLE_CACHE "/home/ysyx/LoogArch/LoongArch_Trace_record/double_launch_test_trace/PerfTest/sha/sha_whole_cache.txt"  
                    `define Test_TRACE_WRITE_FILE_WHOLE_BRIDGE "/home/ysyx/LoogArch/LoongArch_Trace_record/test_trace/ZzqTest/cahce_replace_test/cahce_replace_test_whole_bridge.txt" 
                `elsif  TEST_stream_copy              
                    `define Test_TRACE_WRITE_FILE "/home/ysyx/LoogArch/LoongArch_Trace_record/double_launch_test_trace/PerfTest/stream_copy/stream_copy_simply.txt"   
                    `define Test_TRACE_WRITE_FILE_WHOLE "/home/ysyx/LoogArch/LoongArch_Trace_record/double_launch_test_trace/PerfTest/stream_copy/stream_copy_whole.txt" 
                    `define Test_TRACE_WRITE_FILE_WHOLE_CACHE "/home/ysyx/LoogArch/LoongArch_Trace_record/double_launch_test_trace/PerfTest/stream_copy/stream_copy_whole_cache.txt" 
                    `define Test_TRACE_WRITE_FILE_WHOLE_BRIDGE "/home/ysyx/LoogArch/LoongArch_Trace_record/test_trace/ZzqTest/cahce_replace_test/cahce_replace_test_whole_bridge.txt"
                 `elsif TEST_stringsearch  
                   `define Test_TRACE_WRITE_FILE "/home/ysyx/LoogArch/LoongArch_Trace_record/double_launch_test_trace/PerfTest/stringsearch/stringsearch_simply.txt"     
                   `define Test_TRACE_WRITE_FILE_WHOLE "/home/ysyx/LoogArch/LoongArch_Trace_record/double_launch_test_trace/PerfTest/stringsearch/stringsearch_whole.txt"              
                   `define Test_TRACE_WRITE_FILE_WHOLE_CACHE "/home/ysyx/LoogArch/LoongArch_Trace_record/double_launch_test_trace/PerfTest/stringsearch/stringsearch_whole_cache.txt"   
                   `define Test_TRACE_WRITE_FILE_WHOLE_BRIDGE "/home/ysyx/LoogArch/LoongArch_Trace_record/test_trace/ZzqTest/cahce_replace_test/cahce_replace_test_whole_bridge.txt"                                                                                              
                 `elsif TEST_func
                   `define Test_TRACE_WRITE_FILE             "/home/ysyx/LoogArch/LoongArch_Trace_record/double_launch_test_trace/FuncTest/seventy_two/seventy_two_simply.txt"     
                   `define Test_TRACE_WRITE_FILE_WHOLE       "/home/ysyx/LoogArch/LoongArch_Trace_record/double_launch_test_trace/FuncTest/seventy_two/seventy_two_whole.txt"              
                   `define Test_TRACE_WRITE_FILE_WHOLE_CACHE "/home/ysyx/LoogArch/LoongArch_Trace_record/double_launch_test_trace/FuncTest/seventy_two/seventy_two_whole_cache.txt"   
                   `define Test_TRACE_WRITE_FILE_WHOLE_BRIDGE "/home/ysyx/LoogArch/LoongArch_Trace_record/test_trace/ZzqTest/cahce_replace_test/cahce_replace_test_whole_bridge.txt"                       
                `endif
            `else
                `ifdef TEST_allbench//单发射的轨迹记录路径路径
                    `define Test_TRACE_WRITE_FILE "/home/ysyx/LoogArch/LoongArch_Trace_record/test_trace/PerfTest/allbench/allbench_simply.txt"   
                    `define Test_TRACE_WRITE_FILE_WHOLE "/home/ysyx/LoogArch/LoongArch_Trace_record/test_trace/PerfTest/allbench/allbench_whole.txt"
                    `define Test_TRACE_WRITE_FILE_WHOLE_CACHE "/home/ysyx/LoogArch/LoongArch_Trace_record/test_trace/PerfTest/allbench/allbench_whole_cache.txt"
                    `define Test_TRACE_WRITE_FILE_WHOLE_BRIDGE "/home/ysyx/LoogArch/LoongArch_Trace_record/test_trace/ZzqTest/cahce_replace_test/cahce_replace_test_whole_bridge.txt"
                `elsif TEST_bitcount      
                    `define Test_TRACE_WRITE_FILE "/home/ysyx/LoogArch/LoongArch_Trace_record/test_trace/PerfTest/bitcount/bitcount_simply.txt"
                    `define Test_TRACE_WRITE_FILE_WHOLE "/home/ysyx/LoogArch/LoongArch_Trace_record/test_trace/PerfTest/bitcount/bitcount_whole.txt"
                    `define Test_TRACE_WRITE_FILE_WHOLE_CACHE "/home/ysyx/LoogArch/LoongArch_Trace_record/test_trace/PerfTest/bitcount/bitcount_whole_cache.txt"
                    `define Test_TRACE_WRITE_FILE_WHOLE_BRIDGE "/home/ysyx/LoogArch/LoongArch_Trace_record/test_trace/ZzqTest/cahce_replace_test/cahce_replace_test_whole_bridge.txt"
                `elsif TEST_bubble_sort         
                    `define Test_TRACE_WRITE_FILE "/home/ysyx/LoogArch/LoongArch_Trace_record/test_trace/PerfTest/bubble_sort/bubble_sort_simply.txt"   
                    `define Test_TRACE_WRITE_FILE_WHOLE "/home/ysyx/LoogArch/LoongArch_Trace_record/test_trace/PerfTest/bubble_sort/bubble_sort_whole.txt" 
                    `define Test_TRACE_WRITE_FILE_WHOLE_CACHE "/home/ysyx/LoogArch/LoongArch_Trace_record/test_trace/PerfTest/bubble_sort/bubble_sort_whole_cache.txt" 
                    `define Test_TRACE_WRITE_FILE_WHOLE_BRIDGE "/home/ysyx/LoogArch/LoongArch_Trace_record/test_trace/ZzqTest/cahce_replace_test/cahce_replace_test_whole_bridge.txt"
                `elsif TEST_coremark 
                    `define Test_TRACE_WRITE_FILE "/home/ysyx/LoogArch/LoongArch_Trace_record/test_trace/PerfTest/coremark/coremark_simply.txt"  
                    `define Test_TRACE_WRITE_FILE_WHOLE "/home/ysyx/LoogArch/LoongArch_Trace_record/test_trace/PerfTest/coremark/coremark_whole.txt"   
                    `define Test_TRACE_WRITE_FILE_WHOLE_CACHE "/home/ysyx/LoogArch/LoongArch_Trace_record/test_trace/PerfTest/coremark/coremark_whole_cache.txt" 
                    `define Test_TRACE_WRITE_FILE_WHOLE_BRIDGE "/home/ysyx/LoogArch/LoongArch_Trace_record/test_trace/ZzqTest/cahce_replace_test/cahce_replace_test_whole_bridge.txt"
                `elsif TEST_crc32     
                    `define Test_TRACE_WRITE_FILE "/home/ysyx/LoogArch/LoongArch_Trace_record/test_trace/PerfTest/crc32/crc32_simply.txt"     
                    `define Test_TRACE_WRITE_FILE_WHOLE "/home/ysyx/LoogArch/LoongArch_Trace_record/test_trace/PerfTest/crc32/crc32_whole.txt"
                    `define Test_TRACE_WRITE_FILE_WHOLE_CACHE "/home/ysyx/LoogArch/LoongArch_Trace_record/test_trace/PerfTest/crc32/crc32_whole_cache.txt"
                    `define Test_TRACE_WRITE_FILE_WHOLE_BRIDGE "/home/ysyx/LoogArch/LoongArch_Trace_record/test_trace/ZzqTest/cahce_replace_test/cahce_replace_test_whole_bridge.txt"
                `elsif TEST_dhrystone          
                    `define Test_TRACE_WRITE_FILE  "/home/ysyx/LoogArch/LoongArch_Trace_record/test_trace/PerfTest/dhrystone/dhrystone_simply.txt"    
                    `define Test_TRACE_WRITE_FILE_WHOLE "/home/ysyx/LoogArch/LoongArch_Trace_record/test_trace/PerfTest/dhrystone/dhrystone_whole.txt" 
                    `define Test_TRACE_WRITE_FILE_WHOLE_CACHE "/home/ysyx/LoogArch/LoongArch_Trace_record/test_trace/PerfTest/dhrystone/dhrystone_whole_cache.txt"
                    `define Test_TRACE_WRITE_FILE_WHOLE_BRIDGE "/home/ysyx/LoogArch/LoongArch_Trace_record/test_trace/ZzqTest/cahce_replace_test/cahce_replace_test_whole_bridge.txt"
                `elsif TEST_quick_sort  
                    `define Test_TRACE_WRITE_FILE "/home/ysyx/LoogArch/LoongArch_Trace_record/test_trace/PerfTest/quick_sort/quick_sort_simply.txt"  
                    `define Test_TRACE_WRITE_FILE_WHOLE "/home/ysyx/LoogArch/LoongArch_Trace_record/test_trace/PerfTest/quick_sort/quick_sort_whole.txt"    
                    `define Test_TRACE_WRITE_FILE_WHOLE_CACHE "/home/ysyx/LoogArch/LoongArch_Trace_record/test_trace/PerfTest/quick_sort/quick_sort_whole_cache.txt"   
                    `define Test_TRACE_WRITE_FILE_WHOLE_BRIDGE "/home/ysyx/LoogArch/LoongArch_Trace_record/test_trace/ZzqTest/cahce_replace_test/cahce_replace_test_whole_bridge.txt" 
                `elsif  TEST_select_sort
                    `define Test_TRACE_WRITE_FILE "/home/ysyx/LoogArch/LoongArch_Trace_record/test_trace/PerfTest/select_sort/select_sort_simply.txt"    
                    `define Test_TRACE_WRITE_FILE_WHOLE "/home/ysyx/LoogArch/LoongArch_Trace_record/test_trace/PerfTest/select_sort/select_sort_whole.txt"
                    `define Test_TRACE_WRITE_FILE_WHOLE_CACHE "/home/ysyx/LoogArch/LoongArch_Trace_record/test_trace/PerfTest/select_sort/select_sort_whole_cache.txt"
                    `define Test_TRACE_WRITE_FILE_WHOLE_BRIDGE "/home/ysyx/LoogArch/LoongArch_Trace_record/test_trace/ZzqTest/cahce_replace_test/cahce_replace_test_whole_bridge.txt"
                `elsif TEST_sha     
                    `define Test_TRACE_WRITE_FILE "/home/ysyx/LoogArch/LoongArch_Trace_record/test_trace/PerfTest/sha/sha_simply.txt"        
                    `define Test_TRACE_WRITE_FILE_WHOLE "/home/ysyx/LoogArch/LoongArch_Trace_record/test_trace/PerfTest/sha/sha_whole.txt"   
                    `define Test_TRACE_WRITE_FILE_WHOLE_CACHE "/home/ysyx/LoogArch/LoongArch_Trace_record/test_trace/PerfTest/sha/sha_whole_cache.txt"   
                    `define Test_TRACE_WRITE_FILE_WHOLE_BRIDGE "/home/ysyx/LoogArch/LoongArch_Trace_record/test_trace/ZzqTest/cahce_replace_test/cahce_replace_test_whole_bridge.txt"
                `elsif  TEST_stream_copy              
                    `define Test_TRACE_WRITE_FILE              "/home/ysyx/LoogArch/LoongArch_Trace_record/test_trace/PerfTest/stream_copy/stream_copy_simply.txt"   
                    `define Test_TRACE_WRITE_FILE_WHOLE        "/home/ysyx/LoogArch/LoongArch_Trace_record/test_trace/PerfTest/stream_copy/stream_copy_whole.txt" 
                    `define Test_TRACE_WRITE_FILE_WHOLE_CACHE  "/home/ysyx/LoogArch/LoongArch_Trace_record/test_trace/PerfTest/stream_copy/stream_copy_whole_cache.txt" 
                    `define Test_TRACE_WRITE_FILE_WHOLE_BRIDGE "/home/ysyx/LoogArch/LoongArch_Trace_record/test_trace/PerfTest/stream_copy/stream_copy_whole_bridge.txt" 
                 `elsif TEST_stringsearch  
                   `define Test_TRACE_WRITE_FILE             "/home/ysyx/LoogArch/LoongArch_Trace_record/test_trace/PerfTest/stringsearch/stringsearch_simply.txt"     
                   `define Test_TRACE_WRITE_FILE_WHOLE       "/home/ysyx/LoogArch/LoongArch_Trace_record/test_trace/PerfTest/stringsearch/stringsearch_whole.txt"              
                   `define Test_TRACE_WRITE_FILE_WHOLE_CACHE "/home/ysyx/LoogArch/LoongArch_Trace_record/test_trace/PerfTest/stringsearch/stringsearch_whole_cache.txt"   
                   `define Test_TRACE_WRITE_FILE_WHOLE_BRIDGE "/home/ysyx/LoogArch/LoongArch_Trace_record/test_trace/ZzqTest/cahce_replace_test/cahce_replace_test_whole_bridge.txt"                                                                                              
                 `elsif TEST_func
                   `define Test_TRACE_WRITE_FILE              "/home/ysyx/LoogArch/LoongArch_Trace_record/test_trace/FuncTest/seventy_two/seventy_two_simply.txt"     
                   `define Test_TRACE_WRITE_FILE_WHOLE        "/home/ysyx/LoogArch/LoongArch_Trace_record/test_trace/FuncTest/seventy_two/seventy_two_whole.txt"              
                   `define Test_TRACE_WRITE_FILE_WHOLE_CACHE  "/home/ysyx/LoogArch/LoongArch_Trace_record/test_trace/FuncTest/seventy_two/seventy_two_whole_cache.txt"   
                   `define Test_TRACE_WRITE_FILE_WHOLE_BRIDGE "/home/ysyx/LoogArch/LoongArch_Trace_record/test_trace/FuncTest/seventy_two/seventy_two_whole_bridge.txt"        
                 `elsif TEST_zzq
                   `define Test_TRACE_WRITE_FILE              "/home/ysyx/LoogArch/LoongArch_Trace_record/test_trace/ZzqTest/cahce_replace_test/cahce_replace_test_simply.txt"     
                   `define Test_TRACE_WRITE_FILE_WHOLE        "/home/ysyx/LoogArch/LoongArch_Trace_record/test_trace/ZzqTest/cahce_replace_test/cahce_replace_test_whole.txt"              
                   `define Test_TRACE_WRITE_FILE_WHOLE_CACHE  "/home/ysyx/LoogArch/LoongArch_Trace_record/test_trace/ZzqTest/cahce_replace_test/cahce_replace_test_whole_cache.txt"      
                   `define Test_TRACE_WRITE_FILE_WHOLE_BRIDGE "/home/ysyx/LoogArch/LoongArch_Trace_record/test_trace/ZzqTest/cahce_replace_test/cahce_replace_test_whole_bridge.txt"                     
                
                 `endif
            `endif               
            
            
                //ZZQ正确轨迹路径
                    //`define RIGHT_TRACE_WRITE_FILE "/home/ysyx/LoogArch/LoongArch_Trace_record/right_trace/FuncTest/point72.txt"
                    //`define RIGHT_TRACE_WRITE_FILE  "/home/ysyx/LoogArch/LoongArch_Trace_record/right_trace/ZzqTest/test_jmp.txt"
                    `define RIGHT_TRACE_WRITE_FILE  "/home/ysyx/LoogArch/LoongArch_Trace_record/right_trace/ZzqTest/random.txt"
       
    
`endif 
