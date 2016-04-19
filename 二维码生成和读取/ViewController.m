//
//  ViewController.m
//  二维码生成和读取
//
//  Created by lanmao on 16/4/6.
//  Copyright © 2016年 小霸道. All rights reserved.
//

#import "ViewController.h"
#import <AVFoundation/AVFoundation.h>

@interface ViewController ()<AVCaptureMetadataOutputObjectsDelegate,UIAlertViewDelegate>
{
    AVCaptureSession *session;
}
//

@property (nonatomic,strong)UITextField *tfCode;
@property (nonatomic,strong)UIButton *btnGenerate;
@property (nonatomic,strong)UIImageView *imageView;
//AVCaptureInput
//@property (nonatomic,strong)UIView *scanRectView;
//@property (nonatomic,strong)AVCaptureDevice *device;
//@property (nonatomic,strong)AVCaptureDeviceInput *input;
//@property (nonatomic,strong)AVCaptureMetadataOutput *output;
//@property (nonatomic,strong)AVCaptureSession *session;
//@property (nonatomic,strong)AVCaptureVideoPreviewLayer *preview;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self creatUI];
//    [self creatUII];
    
    
}

- (void)creatUII
{
    CGSize windowSize = [UIScreen mainScreen].bounds.size;
    CGSize scanSize = CGSizeMake(windowSize.width * 3/4, windowSize.width * 3/4);
    CGRect scanRect = CGRectMake((windowSize.width - scanSize.width)/2, (windowSize.height - scanSize.height)/2, scanSize.width, scanSize.height);
    scanRect = CGRectMake(scanRect.origin.y / windowSize.height, scanRect.origin.x/windowSize.width, scanRect.size.height / windowSize.height, scanRect.size.width /windowSize.width);
    //获取摄像设备
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    
    if ([device hasMediaType:AVMediaTypeVideo]) {
        NSLog(@"NO");
    }else
    {
         NSLog(@"NO0");
    }
//    创建输入流
    NSError *error ;
    AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:device error:&error];
    if (!input) {
        NSLog(@"error:%@",[error localizedDescription]);
        return;
    }
//    创建输出流
    AVCaptureMetadataOutput *output = [[AVCaptureMetadataOutput alloc] init];
//    设置代理 在主线程里刷新
    [output setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
//    初始化链接对象
    session = [[AVCaptureSession alloc] init];
//    高质量采集率
    [session setSessionPreset:AVCaptureSessionPresetHigh];
    
    if ([session canAddInput:input]) {
            [session addInput:input];
NSLog(@"NO1");
    }
    if ([session canAddOutput:output]) {
            [session addOutput:output];
NSLog(@"NO2");
    }
    
    output.metadataObjectTypes = @[AVMetadataObjectTypeQRCode,AVMetadataObjectTypeEAN13Code, AVMetadataObjectTypeEAN8Code, AVMetadataObjectTypeCode128Code];
    output.rectOfInterest = scanRect;
   AVCaptureVideoPreviewLayer *preview = [AVCaptureVideoPreviewLayer layerWithSession:session];
    preview.videoGravity = AVLayerVideoGravityResizeAspectFill;
    preview.frame = self.view.layer.bounds;
    [self.view.layer insertSublayer:preview atIndex:0];
    
//    self.scanRectView = [UIView new];
//    [self.view addSubview:self.scanRectView];
//    self.scanRectView.frame = CGRectMake(0, 0, scanSize.width, scanSize.height);
//    self.scanRectView.center = CGPointMake(CGRectGetMinX([UIScreen mainScreen].bounds), CGRectGetMinY([UIScreen mainScreen].bounds));
//    self.scanRectView.layer.borderColor = [UIColor redColor].CGColor;
//    self.scanRectView.layer.borderWidth = 1;
    [session startRunning];
}

- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection
{
    if (metadataObjects.count == 0) {
        return;
    }
    if (metadataObjects.count > 0) {
        [session stopRunning];
        AVMetadataMachineReadableCodeObject *metadataObject = metadataObjects.lastObject;
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:metadataObject.stringValue message:@"" delegate:self cancelButtonTitle:@"ok" otherButtonTitles:nil];
        [alert show];
    }
}
- (void)alertView:(UIAlertView *)alertView willDismissWithButtonIndex:(NSInteger)buttonIndex
{
    [session stopRunning];
}
- (void)creatUI
{
    CGSize windowSize = [UIScreen mainScreen].bounds.size;
    self.tfCode = [[UITextField alloc] initWithFrame:CGRectMake(10, 64, windowSize.width - 100, 40)];
    self.tfCode.borderStyle = UITextBorderStyleRoundedRect;
    [self.view addSubview:self.tfCode];
    
    self.btnGenerate = [[UIButton alloc] initWithFrame:CGRectMake(windowSize.width - 100, 64, 90, 40)];
    [self.btnGenerate addTarget:self action:@selector(actionGenerate) forControlEvents:UIControlEventTouchUpInside];
    self.btnGenerate.backgroundColor = [UIColor lightGrayColor];
    [self.btnGenerate setTitle:@"生成" forState:UIControlStateNormal];
    [self.btnGenerate setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.view addSubview:self.btnGenerate];
    
    self.imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 200, 200)];
    self.imageView.center = CGPointMake(windowSize.width/2, windowSize.height/2);
    [self.view addSubview:self.imageView];
    
    self.tfCode.text = @"http://www.baidu.com";
}
- (void)actionGenerate
{
    NSString *text = self.tfCode.text;
    NSData *stringData = [text dataUsingEncoding:NSUTF8StringEncoding];
//    生成
    CIFilter *qrFilter = [CIFilter filterWithName:@"CIQRCodeGenerator"];
    [qrFilter setDefaults];
    
    [qrFilter setValue:stringData forKey:@"inputMessage"];
    [qrFilter setValue:@"M" forKey:@"inputCorrectionLevel"];
//    UIColor *onColor = [UIColor blackColor];
//    UIColor *offColor = [UIColor whiteColor];
//    上色
//    CIFilter *colorFilter = [CIFilter filterWithName:@"CIFalseColor" keysAndValues:@"inputImage",qrFilter.outputImage,@"inputColor0",[UIColor colorWithCGColor:onColor.CGColor],@"inputColor1",[UIColor colorWithCGColor:offColor.CGColor], nil];
    CIImage *qrImage = qrFilter.outputImage;
    
//    绘制
    CGSize size = CGSizeMake(200, 200);
    CGImageRef cgImage = [[CIContext contextWithOptions:nil] createCGImage:qrImage fromRect:qrImage.extent];
    UIGraphicsBeginImageContext(size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetInterpolationQuality(context, kCGInterpolationNone);
    CGContextScaleCTM(context, 1.0, -1.0);
    CGContextDrawImage(context, CGContextGetClipBoundingBox(context), cgImage);
    UIImage *codeImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    CGImageRelease(cgImage);
    self.imageView.image = codeImage;
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
