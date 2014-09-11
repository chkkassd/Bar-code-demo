//
//  SSFViewController.m
//  Bar code demo
//
//  Created by 施赛峰 on 14-9-4.
//  Copyright (c) 2014年 赛峰 施. All rights reserved.
//

#import "SSFViewController.h"
#import <AVFoundation/AVFoundation.h>

@interface SSFViewController ()<AVCaptureMetadataOutputObjectsDelegate>

@property (weak, nonatomic) IBOutlet UIView *viewPreview;
@property (weak, nonatomic) IBOutlet UIButton *startButton;
@property (weak, nonatomic) IBOutlet UILabel *inforLabel;
@property (nonatomic, strong) AVCaptureSession *captureSession;
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *videoPreviewLayer;

@end

@implementation SSFViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
}

- (IBAction)startButtonPressed:(id)sender
{
    [self startScan];
}

- (void)startScan
{
    AVCaptureDevice * videoCaptureDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    
    NSError * error;
    AVCaptureDeviceInput * videoInput = [AVCaptureDeviceInput deviceInputWithDevice:videoCaptureDevice error:&error];
    if (!videoInput) {
        NSLog(@"%@",[error localizedDescription]);
        UIAlertView * alert = [[UIAlertView alloc] initWithTitle:nil message:@"你的手机没有摄像头" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
        [alert show];
        return;
    }
    
    AVCaptureMetadataOutput * videoOutput = [[AVCaptureMetadataOutput alloc] init];
    
    self.captureSession = [[AVCaptureSession alloc] init];
    [self.captureSession addInput:videoInput];
    [self.captureSession addOutput:videoOutput];
    
    dispatch_queue_t dispatchQueue;
    dispatchQueue = dispatch_queue_create("myQueue", NULL);
    [videoOutput setMetadataObjectsDelegate:self queue:dispatchQueue];
    [videoOutput setMetadataObjectTypes:[NSArray arrayWithObject:AVMetadataObjectTypeQRCode]];
    
    
    self.videoPreviewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:self.captureSession];
    [self.videoPreviewLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
    self.videoPreviewLayer.frame = self.viewPreview.layer.bounds;
    [self.viewPreview.layer addSublayer:self.videoPreviewLayer];
    
    [self.captureSession startRunning];
}

#pragma mark - avcapturemetadataOutputObjectsDelegate
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection
{
    if (metadataObjects != nil && metadataObjects.count > 0) {
        AVMetadataMachineReadableCodeObject * metadataObject = metadataObjects[0];
        if ([metadataObject.type isEqualToString:AVMetadataObjectTypeQRCode]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                self.inforLabel.text = [metadataObject stringValue];
                [self.captureSession stopRunning];
                [self.videoPreviewLayer removeFromSuperlayer];
            });
        }
    }
}

@end
