//
//  LJMLoginViewController.m
//  VoiceWithLogin_Demo
//
//  Created by ljm on 2017/10/12.
//  Copyright © 2017年 com.ynyx. All rights reserved.
//

#import "LJMLoginViewController.h"


@interface LJMLoginViewController ()<IFlyRecognizerViewDelegate,UITextFieldDelegate,IFlyPcmRecorderDelegate>
{
    UITextField *accountF;
    UITextField *passwordF;
    UIButton    *loginBtn;

    BOOL        isAccount;
    BOOL        isPassword;
}

/** 语音识别 **/
@property (nonatomic, strong) IFlyRecognizerView *iFlyRecognizerView;
@property (nonatomic,strong) IFlyPcmRecorder *pcmRecorder;//录音器，用于音频流识别的数据传入

@end

@implementation LJMLoginViewController

- (instancetype)init
{
    if (self = [super init]) {
        isAccount = NO;
        isPassword = NO;
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    [self setupWithRecognizer];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self setupUI];

}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];

    [_iFlyRecognizerView cancel]; //取消识别
    [_iFlyRecognizerView setDelegate:nil];
    [_iFlyRecognizerView setParameter:@"" forKey:[IFlySpeechConstant PARAMS]];
}

#pragma mark -- setupUI
- (void) setupUI
{
    /** account **/
    UILabel *accountLab = [[UILabel alloc] initWithFrame:CGRectMake(30, 150, 100, 50)];
    accountLab.text = @"account:";
    accountLab.textAlignment = NSTextAlignmentLeft;
    [self.view addSubview:accountLab];
    
    accountF = [[UITextField alloc] initWithFrame:CGRectMake(
                                                             CGRectGetMaxX(accountLab.frame) + 10,
                                                             CGRectGetMinY(accountLab.frame),
                                                             kselfWidth - CGRectGetMaxX(accountLab.frame) - 30,
                                                             accountLab.frame.size.height)];
    accountF.placeholder = @"Please speack your account!";
    accountF.textAlignment = NSTextAlignmentLeft;
    accountF.delegate = self;
    [self.view addSubview:accountF];
    
    
    /** password **/
    UILabel *passwordLab = [[UILabel alloc] initWithFrame:CGRectMake(30, 230, 100, 50)];
    passwordLab.text = @"password:";
    passwordLab.textAlignment = NSTextAlignmentLeft;
    [self.view addSubview:passwordLab];
    
    passwordF = [[UITextField alloc] initWithFrame:CGRectMake(
                                                              accountF.frame.origin.x,
                                                              passwordLab.frame.origin.y,
                                                              accountF.frame.size.width,
                                                              accountLab.frame.size.height)];
    passwordF.placeholder = @"Please tell your password";
    passwordF.delegate = self;
    passwordF.textAlignment = NSTextAlignmentLeft;
    passwordF.secureTextEntry = YES;
    [self.view addSubview:passwordF];
    
    /** login button **/
    loginBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, kselfWidth - 100, 60)];
    loginBtn.center = CGPointMake(self.view.center.x, self.view.center.y + 100);
    loginBtn.backgroundColor = RGBColor(97, 161, 255, 1.f);
    [loginBtn setTitle:@"login" forState:UIControlStateNormal];
    [loginBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [loginBtn addTarget:self action:@selector(loginClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:loginBtn];
    
}

#pragma mark -- 语音识别
- (void) setupWithRecognizer
{
    //单例模式，UI的实例
    if (_iFlyRecognizerView == nil) {
        //UI显示剧中
        _iFlyRecognizerView= [[IFlyRecognizerView alloc] initWithCenter:self.view.center];

        [_iFlyRecognizerView setParameter:@"" forKey:[IFlySpeechConstant PARAMS]];

        //设置听写模式
        [_iFlyRecognizerView setParameter:@"iat" forKey:[IFlySpeechConstant IFLY_DOMAIN]];

    }
    _iFlyRecognizerView.delegate = self;

    if (_iFlyRecognizerView != nil) {
        IATConfig *instance = [IATConfig sharedInstance];
        //设置最长录音时间
        [_iFlyRecognizerView setParameter:instance.speechTimeout forKey:[IFlySpeechConstant SPEECH_TIMEOUT]];
        //设置后端点
        [_iFlyRecognizerView setParameter:instance.vadEos forKey:[IFlySpeechConstant VAD_EOS]];
        //设置前端点
        [_iFlyRecognizerView setParameter:instance.vadBos forKey:[IFlySpeechConstant VAD_BOS]];
        //网络等待时间
        [_iFlyRecognizerView setParameter:@"20000" forKey:[IFlySpeechConstant NET_TIMEOUT]];

        //设置采样率，推荐使用16K
        [_iFlyRecognizerView setParameter:instance.sampleRate forKey:[IFlySpeechConstant SAMPLE_RATE]];
        if ([instance.language isEqualToString:[IATConfig chinese]]) {
            //设置语言
            [_iFlyRecognizerView setParameter:instance.language forKey:[IFlySpeechConstant LANGUAGE]];
            //设置方言
            [_iFlyRecognizerView setParameter:instance.accent forKey:[IFlySpeechConstant ACCENT]];
        }else if ([instance.language isEqualToString:[IATConfig english]]) {
            //设置语言
            [_iFlyRecognizerView setParameter:instance.language forKey:[IFlySpeechConstant LANGUAGE]];
        }
        //设置是否返回标点符号
        [_iFlyRecognizerView setParameter:instance.dot forKey:[IFlySpeechConstant ASR_PTT]];
        //不带标点
//        [_iFlyRecognizerView setParameter:instance.dot forKey:[IFlySpeechConstant ASR_PTT_NODOT]];

    }
}

#pragma mark -- loginClicked
- (void) loginClicked :(id) sender
{
    UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:@"tip" message:@"are you sure login ?" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *sureAction = [UIAlertAction actionWithTitle:@"ok" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
    
        if (accountF.text == nil || [accountF.text isEqualToString:@""]) {
            
        }else if (passwordF.text == nil || [passwordF.text isEqualToString:@""])
        {
            
        }else
        {
            ViewController *vc = [[ViewController alloc] init];
            [self presentViewController:vc animated:YES completion:nil];

        }
    }];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {

    }];

    [alertVC addAction:sureAction];
    [alertVC addAction:cancelAction];

    [self presentViewController:alertVC animated:YES completion:nil];

}

#pragma mark -- action with clicked
- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    if (textField == accountF) {
        isAccount = YES;
        isPassword = NO;
        if(_iFlyRecognizerView == nil)
        {
            [self setupWithRecognizer ];
        }
        accountF.text = @"";
        [accountF resignFirstResponder];


        //设置音频来源为麦克风
        [_iFlyRecognizerView setParameter:IFLY_AUDIO_SOURCE_MIC forKey:@"audio_source"];

        //设置听写结果格式为json
        [_iFlyRecognizerView setParameter:@"plain" forKey:[IFlySpeechConstant RESULT_TYPE]];

        //保存录音文件，保存在sdk工作路径中，如未设置工作路径，则默认保存在library/cache下
//        [_iFlyRecognizerView setParameter:@"asr.pcm" forKey:[IFlySpeechConstant ASR_AUDIO_PATH]];
        [_iFlyRecognizerView start];

    }else if (textField == passwordF)
    {
        isPassword = YES;
        isAccount = NO;
        if(_iFlyRecognizerView == nil)
        {
            [self setupWithRecognizer ];
        }
        passwordF.text = @"";
        [passwordF resignFirstResponder];

        //设置音频来源为麦克风
        [_iFlyRecognizerView setParameter:IFLY_AUDIO_SOURCE_MIC forKey:@"audio_source"];

        //设置听写结果格式为json
        [_iFlyRecognizerView setParameter:@"plain" forKey:[IFlySpeechConstant RESULT_TYPE]];

        //保存录音文件，保存在sdk工作路径中，如未设置工作路径，则默认保存在library/cache下
//        [_iFlyRecognizerView setParameter:@"asr.pcm" forKey:[IFlySpeechConstant ASR_AUDIO_PATH]];
        [_iFlyRecognizerView start];
    }
}

- (void)onResult:(NSArray *)resultArray isLast:(BOOL)isLast
{
    NSMutableString *result = [[NSMutableString alloc] init];
    NSDictionary *dic = [resultArray objectAtIndex:0];

    for (NSString *key in dic) {
        [result appendFormat:@"%@",key];
    }

    if (isAccount) {
        NSString *accountStr = [NSString stringWithFormat:@"%@%@",accountF.text,result];
        accountF.text = accountStr;
    }else
    {
        NSString *passwordStr = [NSString stringWithFormat:@"%@%@",passwordF.text,result];
        passwordF.text = passwordStr;
    }

}

@end
