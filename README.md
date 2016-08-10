# FStep
升级项目中的afnetworking到3.x。以及数据库采用ytk的kvs


1:先前项目中添加的库AFNetworking需要升级到3.x版本。其中tcnetworking做好了封装。拖入到项目中使用。
满足多任务请求。其中注意的就是要在appdelegate中添加通知，观察网络变化。3G/2E -->并发数调整为2;
4G/WIFI调整为5.
2:项目中的背景图片是个实例，以iphone5为基础适配。在skitch中建立5/5s artboard，导出@2x图片用于需要
2x机型，3x用于6p等。其他一只布局在constant里面有参考数。需要乘系数。
3：sql对象化封装，直接使用ytk的kvc即可。业务和数据处理分开。使用代理传值。块处理网络请求
