# BluetoothScannerDemo

这个demo展示的只是点击搜索按钮以后，程序会搜索外围蓝牙设备，并展示到列表。

苹果使用Core Bluetooth framework来与BLE(低功耗蓝牙)设备进行通信。
   蓝牙通信中有两个角色：Central和Peripheral，Peripheral是提供数据的一方，Central是使用Peripheral提供的数据
完成特定任务的一方。
Peripheral端以广告包的形式来广播一些数据。一个广告包(advertising packet)是一小束相关数据，
可能包含Peripheral提供的有用的信息，如Peripheral名或主要功能。在BLE下，广告是Peripheral设备表现的主要形式。

Central端可以扫描并监听其感兴趣的任何广播信息的Peripheral设备。

数据的广播及接收需要以一定的数据结构来表示。而服务就是这样一种数据结构。Peripheral端可能包含一个或多个服务或提供关于连接信号强度的有用信息。
一个服务是一个设备的数据的集合及数据相关的操作。
而服务本身又是由特性或所包含的服务组成的。

在一个Central端与Peripheral端成功建立连接后，Central可以发现Peripheral端提供的完整的服务及特性的集合。
一个Central也可以读写Peripheral端的服务特性的值。

当与peripheral设备交互时，我们主要是在处理它的服务及特性。
在Core Bluetooth框架中，服务是一个CBService对象，特性是一个CBCharacteristic对象。


![image](https://github.com/APCharles/BluetoothScannerDemo/blob/master/demo.gif)

