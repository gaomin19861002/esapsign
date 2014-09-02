//
//  UlanSignViewController.m
//  esapsign
//
//  Created by Gaomin on 14-7-29.
//  Copyright (c) 2014年 Caland. All rights reserved.
//

#import "UlanSignViewController.h"

#import "ULAN.h"
//#import "GTMBase64.h"

//==============================================================================
#pragma mark - 宏定义

#define cancelBtFrame_iPad          CGRectMake(234, 284, 124, 50);
#define cancelBtFrame_Single_iPad   CGRectMake(105, 284, 216, 50);

//==============================================================================
#pragma mark - 私有变量/方法

@interface UlanSignViewController () <ULANDelegate,UITextFieldDelegate>

@property (strong, nonatomic) NSData      *dataToSigan;

//签名结果
@property (strong, nonatomic) NSString * singatureBase64;
//签名类型
//签名类型
@property (strong, nonatomic) NSString * signType;
//签名类型
@property (strong, nonatomic) NSString * hashAlgorithm;
@property (nonatomic) BOOL  isExternalHash;

@property (strong, nonatomic) UIView*  parentView;

- (void)removeSelfViewMainThread;

- (IBAction)tapDone:(id)sender;
- (IBAction)tapCancel:(id)sender;

@end

//==============================================================================
#pragma mark - 类实现

@implementation UlanSignViewController

//==============================================================================
#pragma mark - 初始化

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

-(void) viewWillAppear:(BOOL)animated
{
    [self initLayout];
    [super viewWillAppear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

//==============================================================================
#pragma mark - <ULANDelegate>

-(void) didConnected:(CFISTError*)err
{
    if (err)
    {
        NSLog(@"didConnected:%@",[err toString]);
        return;
    }
    
    //取消键效果
    [UIView beginAnimations:@"animationCancel" context:nil];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
	[UIView setAnimationDuration:0.5f];
    
    //取消键效果
    CATransition *animationPin = [CATransition animation];
    animationPin.duration = 1.0f;
    animationPin.type = kCATransitionReveal;
    
    //完成键效果
    CATransition *animationCommit = [CATransition animation];
    animationCommit.duration = 0.5f;
    animationCommit.type = kCATransitionMoveIn;
    animationCommit.subtype = kCATransitionFromRight;
    CGRect cancelBtFrame = cancelBtFrame_iPad;
    
    self.pinField.hidden = NO;
    self.pinHint.hidden = NO;
    self.doneButton.hidden = NO;
    self.cancelButton.frame = cancelBtFrame ;
    [UIView commitAnimations];
    
    [self.pinField.layer addAnimation:animationPin forKey:@"animationPin"];
    [self.doneButton.layer addAnimation:animationCommit forKey:@"animationCommit"];
    
    [self setLable:1 isHighLight:YES text:nil];
    [self.pinField becomeFirstResponder];
    //自动测试
    //    [self performSelector:@selector(onPinCommit:) withObject:nil afterDelay:1];
    //    [self.ble fetchCert:CERT_TYPE_RSA1024];
}

///called when ble disConnected,
-(void) didDisConnected:(CFISTError*)err
{
    if (self.singatureBase64.length <= 0)
    {
        self.pinHint.text=@"已断开连接!";
        self.pinHint.hidden=NO;
    }
    
    if (err)
    {
        NSLog(@"didDisConnected:%@",[err toString]);
        return;
    }
}

-(void) didSigned:(CFISTError*)err result:(NSString *)signature
{
    if (!err)
    {
        [self setLable:3 isHighLight:YES text:@"数字签名成功..."];
        self.singatureBase64 = signature;
        NSString* result = [NSString stringWithFormat:@"签名结果：%@", self.singatureBase64];
        [self setLable:4 isHighLight:NO text:result];
        //        [self performSelectorOnMainThread:@selector(setSignatureMainThread:) withObject:signature waitUntilDone:YES];
        [self performSelectorInBackground:@selector(removeSelfView:) withObject:[NSNumber numberWithFloat:1.5]];
        NSLog(@"签名结果：%@",self.singatureBase64);
        [self.ble disConnect];
        [self.delegate afterDone:err type:1 result:signature];
    }
    else
    {
        NSMutableString *errString = [NSMutableString string];
        if (err.errorCode == CFIST_ERROR_INVALID_PIN)
        {
            [errString appendFormat:@"PIN码错误！\n剩余可重试：%i", err.pinCanRetries];
            [self didConnected:nil];
            [self setLable:4 isHighLight:YES text:errString ];
            
        }
        else
        {
            errString=[NSMutableString stringWithFormat:@"数字签名失败:%@",[err toString] ];
            [self setLable:4 isHighLight:YES text:errString ];
            [self.ble disConnect];
//            [self.delegate afterDone:err type:1 result:signature];
        }
        
        NSLog(@"%@",errString);
    }
}

//==============================================================================
#pragma mark - <UITextFieldDelgate>

-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    NSTimeInterval animationDuration = 0.30f;
    [UIView beginAnimations:@"ResizeForKeyboard" context:nil];
    [UIView setAnimationDuration:animationDuration];
    int y = -140;

    self.view.frame = CGRectMake(self.view.frame.origin.x, y, self.view.frame.size.width, self.view.frame.size.height);
    [UIView commitAnimations];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

//输入框编辑完成以后，将视图恢复到原始状态
-(void)textFieldDidEndEditing:(UITextField *)textField
{
    NSTimeInterval animationDuration = 0.30f;
    [UIView beginAnimations:@"ResizeForKeyboard" context:nil];
    [UIView setAnimationDuration:animationDuration];
    self.view.frame =CGRectMake(self.view.frame.origin.x, 0, self.view.frame.size.width, self.view.frame.size.height);
    [UIView commitAnimations];
}

//==============================================================================
#pragma mark - 点击事件

- (IBAction)tapDone:(id)sender
{
    if (self.pinField.text.length == 0 || self.pinField.text == nil || [self.pinField.text isEqualToString:@""])
    {
        self.pinHint.text= @"Pin码不可为空!";
        return;
    }
    
    [self.ble sign:self.dataToSigan
               pin:self.pinField.text
          signType:self.signType
     hashAlgorithm:self.hashAlgorithm
          certType:self.certType
    isExternalHash:self.isExternalHash];
    
    [self setLable:2 isHighLight:YES text:nil];
    [self removePin];
}

- (IBAction)tapCancel:(id)sender
{
    if (self.ble)
    {
        [self.ble disConnect];
    }
    
    if (self.delegate)
    {
        [self.delegate afterDone:nil type:0 result:nil];
    }
    
    [self performSelectorInBackground:@selector(removeSelfView:) withObject:[NSNumber numberWithFloat:0]];
}

//==============================================================================
#pragma mark - 签名方法

-(void)sign:(NSData *)dataToSign parentView:(UIView *)parent
  delegate:(id<SignViewUlanDelegate>)delegate
   signType:(NSString *)signType
   certType:(NSString *)certType
       hash:(NSString *)hash
      keyID:(NSString *)keyID
isExternalHash:(BOOL)isExternalHash
{
    self.keyID = keyID;
    self.dataToSigan = dataToSign;
    self.delegate = delegate;
    self.parentView = parent;
    self.signType = signType;
    self.certType = certType;
    self.hashAlgorithm = hash;
    self.isExternalHash = isExternalHash;
    
    // Bounce to 1% of the normal size
	[UIView beginAnimations:nil context:UIGraphicsGetCurrentContext()];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
	[UIView setAnimationDuration:0.0f];
	self.view.transform = CGAffineTransformMakeScale(0.1f, 0.1f);
	[UIView commitAnimations];
	
	// Return back to 100%
	[UIView beginAnimations:nil context:UIGraphicsGetCurrentContext()];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
	[UIView setAnimationDuration:0.3f];
	self.view.transform = CGAffineTransformMakeScale(1.0f, 1.0f);
	[UIView commitAnimations];
	[parent addSubview:self.view];
    self.view.frame= CGRectMake(0, 0, parent.frame.size.width, parent.frame.size.height);
    self.view.center=parent.center;
}

-(void) removeSelfView:(NSNumber *)duration
{
    sleep(duration.floatValue);
    [self performSelectorOnMainThread:@selector(removeSelfViewMainThread) withObject:nil waitUntilDone:YES];
    
}

//==============================================================================
#pragma mark - 私有方法

- (void)initLayout
{
    self.pinField.text = nil;
    [self.pinField setHidden:YES];
    [self.doneButton setHidden:YES];
    [self.pinHint setHidden:YES];
    self.pinHint.text = nil;
    
    for (UILabel *label in self.labels)
    {
        [label setHidden:YES];
    }
    
    CGRect cancelBtFrame = cancelBtFrame_Single_iPad;

    self.cancelButton.frame = cancelBtFrame ;
    
    [self setLable:0 isHighLight:YES text:nil];
//    self.ble = [ULAN sharedBluetoothKey:self];
    if (![self.ble isConnected])
    {
        [self.ble connectKey:self.keyID];
    }
    else
    {
        [self didConnected:0];
    }
}

- (void)removeSelfViewMainThread
{
    [self.parentView setAlpha:1.0];
    [self.view removeFromSuperview];
}

-(void)removePin
{
    //    //取消键效果
    [UIView beginAnimations:@"animationCancelRemove" context:nil];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
    [UIView setAnimationDuration:0.35f];
    
    CATransition *animationPin = [CATransition animation];
    animationPin.removedOnCompletion=YES;
    animationPin.duration = 0.35f;
    animationPin.type = kCATransitionFade;
    //完成键效果
    CATransition *animationCommit = [CATransition animation];
    animationCommit.delegate=self;
    animationCommit.duration = 0.5f;
    animationCommit.type = kCATransitionMoveIn;
    animationCommit.subtype = kCATransitionFromLeft;
    
    [self.pinField setHidden:YES];
    [self.pinHint setHidden:YES];
    [self.doneButton setHidden:YES];
    
    CGRect cancelBtFrame = cancelBtFrame_Single_iPad;

    self.cancelButton.frame = cancelBtFrame ;
    
    [UIView commitAnimations];
    
    [self.pinField.layer addAnimation:animationPin forKey:@"animationPinRemove"];
    [self.pinHint.layer addAnimation:animationPin forKey:@"animationPinHintRemove"];
    [self.doneButton.layer addAnimation:animationCommit forKey:@"animationCommitRemove"];
    
    [self.pinField resignFirstResponder];
}

//设置制定的lable高亮，同时其余变暗
-(void)setLable:(int)index isHighLight:(BOOL)isHighLight text:(NSString*)text
{
    if (index>=self.labels.count)
    {
        return;
    }
    
    UILabel *theLabel = [self.labels objectAtIndex:index];
    theLabel.hidden = NO;
    
    if (!isHighLight)
    {
        theLabel.textColor = [UIColor grayColor];
    }
    else
    {
        theLabel.textColor = [UIColor whiteColor];
        for (int i = 0; i < self.labels.count; i++)
        {
            UILabel *label = [self.labels objectAtIndex:i];
            if (i < index)
            {
                label.textColor = [UIColor grayColor];
            }
            else if (i > index)
            {
                [label setHidden:YES];
            }
        }
    }
    
    if (text)
    {
        theLabel.text=text;
    }
}

@end

//==============================================================================

