`ifndef DEFINECONFG
`define DEFINECONFG
`include "DefineTestConfg.h"
/*本文件是用于控制CPU的微架构�?
可以调控的点
1. 单双
2.发射队列长度
3. 是否关闭icache
4. 是否关闭dcache
5. tlb项数（最大是32：）
6. 是否打开PMI中断
*/
/***************************************CPU微架构配置文�?**************************************/
//1表示开启双发射，0表示使用单发射
`define DOUBLE_LAUNCH 0 //(default:0,表示使用单发射模式)

//1表示打开内部检测错误，0表示不使用内部错误状态检测(default:1,表示打开ERROR)
`define ERROR_OPEN 0

//1表示不使用dcache0表示使用使用dache(default:0,表示使用icache)
`define CLOSE_DCACHE 0

//1表示不使用dcache,0表示使用使用dache(default:1，表示不使用dcache)
`define CLOSE_ICACHE 0


//转接桥配置
`define USE_SIMPLE_BRIDGE //表示转接桥可以busrt�?(默认使用能burst写的)
//    `define BRIDGE_WA_WD_SERIAL//表示使用只能串行，先发地�?，在发数据的转接�?


//发射队列大小,发射队列的长度必须是2的n次方
`define LAUNCH_QUEUE_LEN 16 //修改则必须修�? LAUNCH_QUEUE_POINTER_LEN(default:16,表示发射队列�?16)
`define LAUNCH_QUEUE_POINTER_LEN 4 //log2(LAUNCH_QUEUE_LEN) log2(16)
`define LAUNCH_QUEUE_ALLOWIN_CRITICAL_VALUE `LAUNCH_QUEUE_LEN-2   

`define LAUNCH_QUEUE_WIDTEH `LAUNCH_QUEUE_LEN-1 :0


`define LAUNCH_QUEUE_POINTER_WIDTEH `LAUNCH_QUEUE_POINTER_LEN-1 :0 

`define LAUNCH_QUEUE_LEN_LEN  `LAUNCH_QUEUE_POINTER_LEN + 1 
`define LAUNCH_QUEUE_LEN_WIDTH `LAUNCH_QUEUE_LEN_LEN-1:0


//设在tlb项数�?(默认4�?16�?)
`define TlbIndexLen 5 //发生修改要，修改值为>=15修改csr中的tlbidx_reg的空字段，tlb项目�?=2^(TlbIndexLen)
//是否打开PMI中断�?
//`define OPEN_PMI_INTERRUPT //注销表示不打�?，没有注�?表示打开
      
    
`endif 
