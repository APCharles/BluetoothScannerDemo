//
//  ViewController.m
//  BluetoothScannerDemo
//
//  Created by 安鹏 on 16/6/6.
//  Copyright © 2016年 安鹏. All rights reserved.
//

#import "ViewController.h"
#import <CoreBluetooth/CoreBluetooth.h>
@interface ViewController ()<CBCentralManagerDelegate,CBPeripheralDelegate>

/** 本地Central设备由CBCentralManager对象表示 用于管理发现与连接Peripheral设备 */
@property (strong, nonatomic)CBCentralManager *centralManager;

@property (nonatomic,strong) CBPeripheral *selectedPeripheral;

@property(strong,nonatomic)CBPeripheral *peripheral;

/** 蓝牙列表 */
@property(strong,nonatomic)NSMutableArray *bluetoothArray;

/** 定时器 */
@property (nonatomic,strong) NSTimer *scanTimer;


@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    
    UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
    [btn setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor blueColor] forState:UIControlStateSelected];
    [btn setTitle:@"搜索" forState:UIControlStateNormal];
    [btn setTitle:@"停止" forState:UIControlStateSelected];
    
    
    [btn addTarget:self action:@selector(searchBluetooth:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithCustomView:btn];
    
    self.navigationItem.rightBarButtonItem = item;
    
    
    if (!_centralManager) {
        dispatch_queue_t queue = dispatch_get_main_queue();
        _centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:queue options:@{CBCentralManagerOptionShowPowerAlertKey:@YES}];
            //[_centralManager setDelegate:self];
    }
  

    
   
}


    //点击搜索按钮
- (void)searchBluetooth:(UIButton *)sender{

    sender.selected = !sender.selected;
    if (sender.selected) {
        if (!_scanTimer) {
            _scanTimer = [NSTimer timerWithTimeInterval:4 target:self selector:@selector(scanForPeripherals) userInfo:nil repeats:YES];
            [[NSRunLoop mainRunLoop] addTimer:_scanTimer forMode:NSDefaultRunLoopMode];
        }
        if (_scanTimer && !_scanTimer.valid) {
            [_scanTimer fire];
        }
        
    }else{
        
        if (_scanTimer && _scanTimer.valid) {
            [_scanTimer invalidate];
            _scanTimer = nil;
        }
        [_centralManager stopScan];
    }
    

}
/**
 *  扫描设备
 */
- (void)scanForPeripherals
{
    if (_centralManager.state == CBCentralManagerStateUnsupported) {//设备不支持蓝牙
        
    }else {//设备支持蓝牙连接
        if (_centralManager.state == CBCentralManagerStatePoweredOn) {//蓝牙开启状态
                                                                      //[_centralManager stopScan];
            [_centralManager scanForPeripheralsWithServices:nil options:@{CBCentralManagerScanOptionAllowDuplicatesKey:[NSNumber numberWithBool:NO]}];
        }
    }
}

#pragma mark - uitableviewDatasource

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *ID = @"Video";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    if (!cell) {
        
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:ID];
    }
    
    CBPeripheral *per = self.bluetoothArray[indexPath.row];
    if ([per.name isEqualToString:@""] || per.name == nil) {
        
        cell.textLabel.text = @"未识别蓝牙";
        return cell;
    }
    cell.textLabel.text = per.name;
    return cell;
    
    
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return 66;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return self.bluetoothArray.count;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (_centralManager.state == CBCentralManagerStateUnsupported) {//设备不支持蓝牙
        
    }else {//设备支持蓝牙连接
        if (_centralManager.state == CBCentralManagerStatePoweredOn) {//蓝牙开启状态
                                                                      //连接设备
         
            CBPeripheral *per = [_bluetoothArray objectAtIndex:indexPath.row];
         
            
            
        [_centralManager connectPeripheral:per options:@{CBConnectPeripheralOptionNotifyOnConnectionKey:@YES,CBConnectPeripheralOptionNotifyOnNotificationKey:@YES,CBConnectPeripheralOptionNotifyOnDisconnectionKey:@YES}];
        }
    }
    
    
}

#pragma  mark -- CBCentralManagerDelegate
- (void)centralManagerDidUpdateState:(CBCentralManager *)central
{
    
    NSString * state = nil;
    switch ([central state])
    {
        case CBCentralManagerStateUnsupported:
        state = @"The platform/hardware doesn't support Bluetooth Low Energy.";
        break;
        case CBCentralManagerStateUnauthorized:
        state = @"The app is not authorized to use Bluetooth Low Energy.";
        break;
        case CBCentralManagerStatePoweredOff:
        state = @"Bluetooth is currently powered off.";
        break;
        case CBCentralManagerStatePoweredOn:
        state = @"work";
        
        break;
        case CBCentralManagerStateUnknown:
        default:
        ;
    }
    
}

- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary<NSString *,id> *)advertisementData RSSI:(NSNumber *)RSSI{
    
    NSLog(@"Discover name : %@", peripheral.name);
    
    BOOL isExist = NO;
    
    if (_bluetoothArray.count == 0) {
        [_bluetoothArray addObject:peripheral];
        NSIndexPath *path = [NSIndexPath indexPathForRow:0 inSection:0];
        [self.tableView insertRowsAtIndexPaths:@[path] withRowAnimation:UITableViewRowAnimationFade];
    }else{
        
        for (int i = 0;i < _bluetoothArray.count;i++) {
            
            CBPeripheral *per = [_bluetoothArray objectAtIndex:i];
            if ([peripheral.identifier.UUIDString isEqualToString:per.identifier.UUIDString]) {
                isExist = YES;
                [_bluetoothArray replaceObjectAtIndex:i withObject:per];
                [self.tableView  reloadData];
            }
        }
        if (!isExist) {
            [_bluetoothArray addObject:peripheral];
            NSIndexPath *path = [NSIndexPath indexPathForRow:(_bluetoothArray.count - 1) inSection:0];
            [self.tableView  insertRowsAtIndexPaths:@[path] withRowAnimation:UITableViewRowAnimationFade];
        }
        
    }

    

}

- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral
{
    NSLog(@"Peripheral Connected");
    
    UIAlertController *vc = [UIAlertController alertControllerWithTitle:@"蓝牙" message:@"提示信息" preferredStyle:UIAlertControllerStyleAlert];
    
    
    UIAlertAction *action = [UIAlertAction actionWithTitle:@"连接成功" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        [self dismissViewControllerAnimated:vc completion:nil];
    }];
    
    [vc addAction:action];
    [self presentViewController:vc animated:YES completion:nil];
    [peripheral setDelegate:self];
    [peripheral discoverServices:nil];
}


#pragma mark -- CBPeripheralDelegate
- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:error
{
    if (error==nil)
        {
        NSLog(@"Write edata failed!");
        return;
        }
    NSLog(@"Write edata success!");
}
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error
{
    if (error==nil)
        {
        for (CBService *service in peripheral.services) {
            
            [peripheral discoverCharacteristics:nil forService:service];
        }
        
            //在这个方法中我们要查找到我们需要的服务  然后调用discoverCharacteristics方法查找我们需要的特性
            //该discoverCharacteristics方法调用完后会调用代理CBPeripheralDelegate的
            //- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error
        
        }
}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error{
    if (error==nil) {
            //在这个方法中我们要找到我们所需的服务的特性 然后调用setNotifyValue方法告知我们要监测这个服务特性的状态变化
        for (CBCharacteristic *characteristic in service.characteristics) {
            
            [peripheral setNotifyValue:YES forCharacteristic:characteristic];
        }
        
            //当setNotifyValue方法调用后调用代理CBPeripheralDelegate的- (void)peripheral:(CBPeripheral *)peripheral didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    NSLog(@"enter didUpdateNotificationStateForCharacteristic!");
    if (error==nil)
        {
            //调用下面的方法后 会调用到代理的- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
        [peripheral readValueForCharacteristic:characteristic];
        }
}


- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    NSLog(@"enter didUpdateValueForCharacteristic!");
    NSData *data = characteristic.value;
    NSLog(@"read data=%@!",data);
    
}


    //扫描蓝牙设备的列表
- (NSMutableArray *)bluetoothArray{
    
    if (!_bluetoothArray) {
        
        _bluetoothArray = [[NSMutableArray alloc] init];
    }
    
    return _bluetoothArray;
}

@end
