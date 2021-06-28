#import "ViewController.h"

#import "DzBluetoothManager.h"
#import "DzProgress.h"
#import "LPAPI.h"
#import "WHToast.h"


@interface ViewController() <UITableViewDelegate,UITableViewDataSource>

@property (strong, nonatomic) UITableView *myTableView;

@end

@implementation ViewController
{
    UIImage *_printLabelImage;
    NSMutableArray *_printLabelImageArray;
    NSArray *_labelArray;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [LPAPI enableProgress:NO];
    [LPAPI didReadPrinterStateHandler:^(int code, NSString *message) 
     {
         NSLog(@"提示编号：%d", code);
         NSLog(@"提示信息：%@", message);
     }];
    
    [DzBluetoothManager didDiscoveredPeripheralHandler:^(CBPeripheral *peripheral, NSString *realName, NSNumber *RSSI)
     {
         //NSLog(@"%@", [peripheral name]);
     }];
    [DzBluetoothManager didChangeBLEStateHandler:^(NSInteger state)
     {
         if (state == CBCentralManagerStatePoweredOn)
         {
             [DzBluetoothManager startScanPeripherals];
         }
     }];
    [DzBluetoothManager initBLE];
    _printLabelImageArray  = [NSMutableArray arrayWithCapacity:0];
    
    self.myTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 260, self.view.frame.size.width, self.view.frame.size.height) style:(UITableViewStylePlain)];
    self.myTableView.rowHeight = 100;
    self.myTableView.dataSource =self;
    self.myTableView.delegate = self;
    [self.view addSubview:self.myTableView];
}

// 搜索打印机并连接
- (IBAction)scanPrinters:(id)sender
{     
//    [LPAPI openPrinter:@"" 
//            completion:^(BOOL isSuccess) 
//     {
//         if (isSuccess)
//         {
//             NSLog(@"连接成功");
//         }
//         else
//         {
//             NSLog(@"连接失败");
//         }
//     }];
    
    [LPAPI scanPrinters:YES
             completion:^(NSArray *scanedPrinterNames) 
     {
         NSLog(@"搜索到的打印机列表：%@", scanedPrinterNames);
     }
didOpenedPrinterHandler:^(BOOL isSuccess)
     {
         if (isSuccess)
         {
             NSLog(@"连接成功");
             
             // 获取当前连接的打印机详情
             PrinterInfo *pi = [LPAPI connectingPrinterDetailInfos];
         }
         else
         {
             NSLog(@"连接失败");
         }
     }];
}

- (IBAction)createLabel:(id)sender
{
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    NSString *json = pasteboard.string;
    NSData *jsonData = [json dataUsingEncoding:NSUTF8StringEncoding];

    
    NSError *e = nil;
    _labelArray = [NSJSONSerialization JSONObjectWithData: jsonData options: NSJSONReadingMutableContainers error: &e];

    if (!_labelArray) {
      [WHToast showErrorWithMessage:@"标签导入失败" duration:2 finishHandler:^{
      }];
    } else {
        _printLabelImageArray  = [NSMutableArray arrayWithCapacity:0];
       for(NSDictionary *item in _labelArray) {
           [_printLabelImageArray addObject: [self drawPrintLabelImage:item]];
       }
        [WHToast showSuccessWithMessage:@"标签导入成功" duration:2 finishHandler:^{
        }];
    }
    
    [_myTableView reloadData];

    _printLabelImage = nil;
    
    // 设置打印机纸张类型
    //[LPAPI setPrintPageGapType:2];
    
    // 设置打印机打印浓度
    [LPAPI setPrintDarkness:15];
    
    // 设置打印机打印速度
    [LPAPI setPrintSpeed:3];
}

- (IBAction)printLabel:(id)sender
{    
    if (_printLabelImageArray.count > 0)
    {
        [self printLabels];
    }
    else
    {
        NSLog(@"请先生成标签");
    }
}

- (IBAction)closePrinter:(id)sender
{
    [LPAPI closePrinter];
}

// 连续打印多张
static int printCount;
- (void)printLabels
{
    ShowState(@"正在打印……")
    
    [WHToast showSuccessWithMessage:@"正在打印……" duration:1 finishHandler:^{
    }];
    printCount = _printLabelImageArray.count;
    
    [self printTest];
}

- (void)printTest
{    
    if (printCount > 0)
    {
        [self drawPrintLabelImage:[_labelArray objectAtIndex:_labelArray.count - printCount]];
        [LPAPI print:^(BOOL isSuccess)
         {
             printCount--;
             [self printTest];
             NSLog(@"打印成功");
         }]; 
    }
    else
    {
        ShowDismissMark(@"打印完成")
    }
}

- (UIImage *) drawPrintLabelImage:(NSDictionary *) dict{
    NSString *qrCode = [dict objectForKey:@"qr_code"];
    NSString *label1Title = [dict objectForKey:@"label1_title"];
    NSString *lable1Value = [dict objectForKey:@"label1_value"];
    NSString *label2Title = [dict objectForKey:@"label2_title"];
    NSString *label2Value = [dict objectForKey:@"label2_value"];
    NSString *label3Title = [dict objectForKey:@"label3_title"];
    NSString *label3Value = [dict objectForKey:@"label3_value"];

    
    double labelWidth  = 50;
    double labelHeight = 30;
    
    double hPadding = 1;
    double wPadding = 1;
    
    [LPAPI startDraw:labelWidth
              height:labelHeight
         orientation:0];
    
    [LPAPI drawRoundRectangleWithX: 0 y:hPadding width:labelWidth -2 *wPadding -4 height:labelHeight-2*hPadding lineWidth:0.5 radius:1 isFilled:false];
    
    
    double x = wPadding;
    double y = hPadding + 2;
    double qrCodeLen = labelHeight - 2*y;
    [LPAPI drawQRCode:qrCode x:x y:y width:qrCodeLen];
    

    x += qrCodeLen + 0.5;
    double textWidth = 18;
    double textHeight = 2.5;
    double fontSize = 2.5;
    int itemSpacing = 2;

    [LPAPI drawText:label1Title x:x y:y width:textWidth height:textHeight fontHeight:fontSize];
    y += fontSize;
    [LPAPI drawText:lable1Value x:x y:y width:textWidth height:textHeight fontHeight:fontSize];
    y += fontSize + itemSpacing;
    [LPAPI drawText:label2Title x:x y:y width:textWidth height:textHeight fontHeight:fontSize];
    y+= fontSize;
    [LPAPI drawText:label2Value x:x y:y width:textWidth height:textHeight fontHeight:fontSize];
    y+= fontSize + itemSpacing;
    [LPAPI drawText:label3Title x:x y:y width:textWidth height:textHeight fontHeight:fontSize];
    y+= fontSize;

    [LPAPI drawText:label3Value x:x y:y width:textWidth height:textHeight fontName:@"" fontHeight:fontSize fontStyle:1 charSpace:0 lineSpace:0 isAutoReturn:false];
    // 结束绘制，并生成要打印的标签
    return [LPAPI endDraw];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _printLabelImageArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    }
    cell.imageView.image = [_printLabelImageArray objectAtIndex:indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [self drawPrintLabelImage:[_labelArray objectAtIndex:indexPath.row]];
    [LPAPI print:^(BOOL isSuccess) {
        [WHToast showSuccessWithMessage:[NSString stringWithFormat:@"标签打印成功"] duration:0.5 finishHandler:^{
        }];
    }];
}

@end
