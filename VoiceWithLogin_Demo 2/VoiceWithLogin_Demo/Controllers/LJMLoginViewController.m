//
//  LJMLoginViewController.m
//  VoiceWithLogin_Demo
//
//  Created by ljm on 2017/10/12.
//  Copyright © 2017年 com.ynyx. All rights reserved.
//

#import "LJMLoginViewController.h"

@interface LJMLoginViewController ()<IFlySpeechSynthesizerDelegate,UITextFieldDelegate>
{
    UITextField *accountF;
    UITextField *passwordF;
    UIButton    *loginBtn;
}

/** 语音合成 **/
@property (nonatomic, strong) IFlySpeechSynthesizer *iFlySpeechSynthesizer;

@end

@implementation LJMLoginViewController

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self setupWithSpeak];
    
    [_iFlySpeechSynthesizer startSpeaking:@"请输入账号和密码"];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self setupUI];
    
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
    accountF.delegate = self;
    accountF.placeholder = @"Please speack your account!";
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
    passwordF.delegate = self;
    passwordF.placeholder = @"Please tell your password";
    passwordF.secureTextEntry = YES;
    [self.view addSubview:passwordF];

    
    /** login button **/
    loginBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, kselfWidth - 100, 60)];
    loginBtn.center = self.view.center;
    loginBtn.backgroundColor = RGBColor(97, 161, 255, 1.f);
    [loginBtn setTitle:@"login" forState:UIControlStateNormal];
    [loginBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [loginBtn addTarget:self action:@selector(loginClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:loginBtn];
    
}

#pragma mark -- 语音合成
- (void) setupWithSpeak
{
    //获取语音合成单例
    _iFlySpeechSynthesizer = [IFlySpeechSynthesizer sharedInstance];
    //设置协议委托对象
    _iFlySpeechSynthesizer.delegate = self;
    //设置合成参数
    //设置在线工作方式
    [_iFlySpeechSynthesizer setParameter:[IFlySpeechConstant TYPE_CLOUD]
                                  forKey:[IFlySpeechConstant ENGINE_TYPE]];
    //设置音量，取值范围 0~100
    [_iFlySpeechSynthesizer setParameter:@"50"
                                  forKey: [IFlySpeechConstant VOLUME]];
    //发音人，默认为”xiaoyan”，可以设置的参数列表可参考“合成发音人列表”
    [_iFlySpeechSynthesizer setParameter:@" xiaoyan "
                                  forKey: [IFlySpeechConstant VOICE_NAME]];
    //保存合成文件名，如不再需要，设置为nil或者为空表示取消，默认目录位于library/cache下
    [_iFlySpeechSynthesizer setParameter:@" tts.pcm"
                                  forKey: [IFlySpeechConstant TTS_AUDIO_PATH]];
}

#pragma mark -- loginClicked
- (void) loginClicked :(id) sender
{
    //启动合成会话
//    [_iFlySpeechSynthesizer startSpeaking: @"你好，我是远信的小红坤，请确认登录!"];
    
    
//    UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:@"tip" message:@"are you sure login ?" preferredStyle:UIAlertControllerStyleAlert];
//    UIAlertAction *sureAction = [UIAlertAction actionWithTitle:@"ok" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
    
        if (accountF.text == nil  || [accountF.text isEqualToString:@""]) {
            [_iFlySpeechSynthesizer startSpeaking: @"请注意账号不能为空"];
        }else if (passwordF.text == nil || [passwordF.text isEqualToString:@""]) {
            [_iFlySpeechSynthesizer startSpeaking: @"请注意密码不能为空"];
        }else
        {
            [_iFlySpeechSynthesizer startSpeaking: @"你好，我是远信的小红坤，欢迎登录后勤服务"];
            
            ViewController *vc = [[ViewController alloc] init];
            [self presentViewController:vc animated:YES completion:nil];
        }
//
//    }];
//    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
//
//    }];
//
//    [alertVC addAction:sureAction];
//    [alertVC addAction:cancelAction];
//
//    [self presentViewController:alertVC animated:YES completion:nil];
//
}


- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    if (textField == accountF) {
        [_iFlySpeechSynthesizer startSpeaking:@"请在3秒内输入账号"];
    }else if (textField == passwordF)
    {
        [_iFlySpeechSynthesizer startSpeaking:@"请在3秒内输入密码"];
    }
}


@end
