我是从淘宝买的一个STM32的单片机，CPU是STM32F407ZGT6，这个一个ARM-V7架构的cotex-M核心的CPU，并且板子上附加了一些外设，可以帮助我学习ARM架构，RTOS，以及总线等必要的知识。下面记录一下这两天折腾的东西。
# 1.IDE的选择
商家教程里面配套的软件，比如KEIL，个人用起来不太顺手，因为工作的时候都是用公司定制版的VS CODE，所以感觉还是用VS CODE比较方便，另外使用VS CODE做嵌入式开发应该也是目前的主流趋势。由于商家没有配套的教程，所以自己折腾了一番，也算是稍有收获，这里记录一下。
## 1.1 关于平台
工作的时候做代码开发和测试都是在Linux系统上进行的，所以对于一些常用的命令或者脚本开发，在Linux上更顺手，所以这里还是决定在Linux系统上做开发，VS CODE作为一个前端界面，远程连接Linux执行机。这里有很多方法，如果资源充足，那就搞一台装了Linux系统的执行机，然后在Windows工作机上远程连接，但是我只有一台电脑，所以使用了微软提供的解决方案WSL，WSL全称Windows Subsystem for Linux，允许用户直接在Windows上运行原生的Linux环境和应用程序，无需使用传统虚拟机或双启动设置，安装和使用方式如下：
(1)win+R，输入cmd打开powershell，执行
`wsl --install`
此命令将自动启用WSL功能并安装默认的Ubuntu发行版。安装完成后需重启计算机。
(2)在VS CODE扩展商店中搜索WSL扩展并安装
(3)Ctrl+Shift+P打开命令面板，输入WSL:Connect to WSL，执行后VS CODE会重新加载，如果左下角显示"WSL:Ubuntu"就说明已经连上了
(4)打开终端，在/home/usrname/中创建自己的目录，后面开发建议在自己的目录中进行，不要用Windows系统的挂载目录(/mnt/xx)

## 1.2 关于代码托管
建议使用GitHub，目前基本上所有的代码托管平台都是基于Git，是目前的主流。如果GitHub连不上可以挂个梯子。

## 1.3 关于编译工具
现代C/CXX项目主流是使用cmake作为编译工具，因为Makefile实在过于抽象，而cmake则通过写CMakeLists.txt且有大量的函数可以直接用，能够清晰简洁地构建起整个项目，所以编译工具选择cmake
CMake的默认生成器是‌Unix Makefiles，如果运行cmake时未指定生成器，会自动生成一个Makefile，然后直接make编译项目即可。如果想要指定生成器，如Ninja，则需要通过-G参数指定，如`cmake -G Ninja ..`，然后执行`ninja`编译项目

## 1.4 关于程序烧录
使用开源工具openocd进行代码烧录
在终端中执行
`openocd -f interface/cmsis-dap.cfg -f target/stm32f4x.cfg -c "init; reset halt; program stm32_1.elf verify reset; resume"`
这里面会遇到一个问题，就是WSL识别不到USB端口，这是因为WSL本身不支持USB设备访问，所以我们需要把连接DAP的那个USB端口绑定到WSL上，这需要用到一个工具usbipd-win，步骤如下：
```
winget install --interactive --exact dorssel.usbipd-win  # power shell安装usbipd-win
usbipd list  # 列出所有的USB设备，里面有BUSID信息，后面绑定要用
usbipd bind --busid <BusID>  # 绑定连接到DAP的那个USB设备，绑定后USB状态变成Shared
usbipd attach --wsl --busid <BusID>  # 将该设备附加到WSL，此时该设备已挂载到WSL，Windows将无法再使用它
usbipd detach --busid <BusID> # 断开连接，用完后可以断开连接，USB设备回归到Windows
```