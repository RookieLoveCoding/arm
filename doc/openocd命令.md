这是DS生成的openocd命令集合，放在这里供后面参考
# 一、调试控制命令
## 1. 运行控制
```
# 基本控制
halt                    # 暂停CPU执行
resume [address]        # 从当前地址或指定地址恢复执行
step [block]           # 单步执行（可选项：block=跳过函数调用）
step_blocked           # 单步执行，遇到函数调用则进入
reset                  # 硬件复位
reset run              # 复位并立即运行
reset halt             # 复位并暂停（常用编程前准备）
soft_reset_halt        # 软复位并暂停
wait_halt             # 等待直到CPU暂停

# 举例
halt; step; resume     # 暂停、单步、继续
```
## 2. 断点与观察点
```
# 软件断点（在RAM/Flash中）
bp [address] [length]  # 设置断点
rbp [address]          # 移除断点
rbp_all                # 移除所有断点
bp_list                # 列出所有断点

# 硬件断点（数量有限，但可在ROM上工作）
hw_breakpoint [address] [type]
hw_breakpoint_del [address]

# 观察点（监控数据访问）
wp [address] [length] [mode]  # mode: r, w, rw
wp_list
wp_del [id]

# 举例
bp 0x08001234 2        # 在0x08001234设置2字节断点
wp 0x20000000 4 w      # 监控0x20000000开始的4字节写入
```

# 二、内存访问命令
## 1. 读写内存
```
# 查看内存
mdw [address] [count]  # 显示字（32位）
mdh [address] [count]  # 显示半字（16位）
mdb [address] [count]  # 显示字节（8位）

# 修改内存
mww [address] [value]  # 写入字
mwh [address] [value]  # 写入半字
mwb [address] [value]  # 写入字节

# 批量内存操作
load_image [file] [address] [format]  # 加载文件到内存
dump_image [file] [address] [size]    # 保存内存到文件
mem2array [var] [width] [addr] [count] # 内存读到Tcl数组
array2mem [var] [width] [addr] [count] # Tcl数组写到内存

# 举例
mdw 0x20000000 16       # 显示16个字
mww 0x20000000 0xdeadbeef
load_image data.bin 0x20001000 bin
```

## 2. 寄存器操作
```
# CPU寄存器
reg                     # 显示所有寄存器
reg [name]              # 显示指定寄存器
reg [name] [value]      # 设置寄存器值

# 内核寄存器（Cortex-M特定）
cortex_m maskisr (auto|on|off)  # 中断屏蔽控制
cortex_m vector_catch (all|none|hw_err|...) # 异常捕获

# 举例
reg                     # 查看所有寄存器
reg pc 0x08000000      # 设置PC指针
reg r0 0x12345678
```

# 三、Flash编程命令
除了之前提到的program命令，还有更多精细控制：
```
# Flash操作
flash list              # 列出所有Flash设备
flash banks            # 显示Flash bank信息
flash info [num]       # 显示Flash详细信息
flash erase_sector [num] [first] [last]  # 擦除扇区
flash erase_address [address] [length]   # 按地址擦除
flash write_bank [num] [file] [offset]   # 写文件到Flash
flash write_image [file] [address] [format] [erase]  # 写镜像
flash fillb [address] [value] [count]    # 填充字节
flash fillw [address] [value] [count]    # 填充字
flash protect [num] [first] [last] (on|off)  # 写保护

# 举例
flash erase_sector 0 0 7    # 擦除bank0的0-7扇区
flash write_image firmware.bin 0x08000000 bin
flash write_bank 0 data.bin 0x1000
```

# 四、配置与信息命令
```
# 系统信息
targets                 # 显示所有目标
target [name]          # 切换/显示当前目标
adapter speed [kHz]    # 设置JTAG/SWD速度
adapter serial [serial] # 指定适配器序列号
poll [on|off]          # 开启/关闭轮询模式
echo "message"         # 输出消息
shutdown               # 关闭OpenOCD

# 举例
adapter speed 1000     # 设置1MHz速度
targets               # 查看所有目标
poll on               # 开启轮询（实时查看状态）
```

# 五、Tcl脚本控制命令
OpenOCD使用Tcl作为脚本语言，这些命令用于控制脚本执行：
```
# 脚本控制
script [filename]      # 执行Tcl脚本文件
tcl_echo [on|off]      # 控制Tcl命令回显
capture "command"      # 执行命令并捕获输出
bindto [ip]           # 绑定到特定IP地址
gdb_port [port]       # 设置GDB端口
tcl_port [port]       # 设置Tcl端口
telnet_port [port]    # 设置Telnet端口

# 变量和流程控制
set var value         # 设置变量
echo $var            # 输出变量
if {condition} { ... } else { ... }  # 条件判断
for {set i 0} {$i < 10} {incr i} { ... }  # 循环
proc name {args} { ... }  # 定义过程
```

# 六、高级调试命令
```
# 跟踪和性能分析
itm port [port] on|off  # 启用/禁用ITM跟踪
tpiu config (internal|external) (file|port)  # 配置TPIU
profile [start|stop|clear|...]  # 性能分析

# 多核调试
smp [on|off]          # 对称多处理支持
target smp [targets]  # 设置SMP组

# 电源管理
power_restore [on|off]  # 电源恢复控制
```

# 七、实用命令组合示例
## 1. 调试启动脚本
```
# debug.cfg
init
reset halt
# 设置断点
bp 0x08000100 2
# 修改内存
mww 0x20000000 0x12345678
# 恢复运行
resume
```

## 2. 内存诊断
```
# 检查内存区域
mdw 0x20000000 16
mdw 0x08000000 32
# 测试RAM
mww 0x20001000 0xAAAAAAAA
mww 0x20001004 0x55555555
mdw 0x20001000 2
```

## 3. Flash验证
```
# 验证Flash内容
init
reset halt
# 读取Flash内容并比较
flash read_bank 0 flash_dump.bin 0 0x40000
cmp firmware.bin flash_dump.bin
```

## 4. 寄存器调试
```
# 查看异常状态
reg
# Cortex-M特定寄存器
cortex_m vector_catch all
# 检查控制寄存器
mrc p15, 0, $r0, c1, c0, 0
echo "Control reg: $r0"
```

# 八、GDB集成相关
虽然这不是OpenOCD命令，但经常一起使用：
```
# 在OpenOCD中为GDB做准备
gdb_breakpoint_override (hard|soft|disable)
gdb_flash_program (enable|disable)
gdb_memory_map (enable|disable)
gdb_report_data_abort (enable|disable)

# 然后启动GDB
# arm-none-eabi-gdb
# (gdb) target remote :3333
# (gdb) monitor reset halt
# (gdb) load
```

# 九、实用技巧
## 1. 命令链执行
```
# 一行命令完成多个操作
-c "init; reset halt; mdw 0x20000000 4; resume"

# 从文件执行命令序列
-c "script commands.tcl"
```

## 2. 条件执行
```
# 在Tcl脚本中
if {[catch {halt}]} {
    echo "Failed to halt target"
} else {
    echo "Target halted"
}
```

## 3. 批量操作
```
# 批量写入配置
for {set i 0} {$i < 10} {incr i} {
    mww [expr 0x20000000 + $i*4] [expr 0x1000 + $i]
}
```

# 十、配置文件示例
了解命令后，可以创建自己的配置文件：
```
# my_board.cfg
source [find interface/stlink.cfg]
transport select hla_swd
source [find target/stm32f4x.cfg]

# 自定义初始化
proc my_init {} {
    reset halt
    adapter speed 4000
    echo "Board initialized"
}

# 自定义编程函数
proc program_my_app {} {
    init
    reset halt
    flash write_image erase my_app.elf
    verify_image my_app.elf
    reset run
    echo "Programming complete"
}
```