//
//  ViewController.m
//  VoiceWithLogin_Demo
//
//  Created by ljm on 2017/10/12.
//  Copyright © 2017年 com.ynyx. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()<UITextFieldDelegate,IFlySpeechSynthesizerDelegate,IFlyRecognizerViewDelegate,IFlyPcmRecorderDelegate,UITextViewDelegate>
{
    BOOL isTableNumberF;
    BOOL isProposerNameF;
    BOOL isTelephoneNumbaerF;
    BOOL isDestionationF;
    BOOL isTimeF;
    BOOL isContentView;
}

@property (weak, nonatomic) IBOutlet UITextField *tableNumberF;
@property (weak, nonatomic) IBOutlet UITextField *proposerNameF;
@property (weak, nonatomic) IBOutlet UITextField *telephoneNumberF;
@property (weak, nonatomic) IBOutlet UITextField *destionationF;
@property (weak, nonatomic) IBOutlet UITextField *timeF;
@property (weak, nonatomic) IBOutlet UITextView *contentView;

/** 语音合成 **/
@property (nonatomic, strong) IFlySpeechSynthesizer *iFlySpeechSynthesizer;
/** 语音识别 **/
@property (nonatomic, strong) IFlyRecognizerView *iFlyRecognizerView;
/** 录音器，用于音频流识别的数据传入 **/
@property (nonatomic,strong) IFlyPcmRecorder *pcmRecorder;

@end

@implementation ViewController

#pragma mark -- hidden status
- (BOOL) prefersStatusBarHidden
{
    return YES;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        isTableNumberF = NO;
        isProposerNameF = NO;
        isTelephoneNumbaerF = NO;
        isDestionationF = NO;
        isTimeF = NO;
        isContentView = NO;
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    [self setupWithSpeak];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupUI];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];

    [_iFlyRecognizerView cancel]; //取消识别
    [_iFlyRecognizerView setDelegate:nil];
    [_iFlyRecognizerView setParameter:@"" forKey:[IFlySpeechConstant PARAMS]];
}

#pragma mark -- setkupUI
- (void) setupUI
{

    _tableNumberF.tag = 100;
    _proposerNameF.tag = 101;
    _telephoneNumberF.tag = 102;
    _destionationF.tag = 103;
    _timeF.tag = 104;

    _tableNumberF.delegate = self;
    _proposerNameF.delegate = self;
    _telephoneNumberF.delegate = self;
    _destionationF.delegate = self;
    _timeF.delegate = self;

    _contentView.delegate = self;

    _tableNumberF.layer.cornerRadius          =     3;
    _proposerNameF.layer.cornerRadius        =     _tableNumberF.layer.cornerRadius;
    _telephoneNumberF.layer.cornerRadius    =    _tableNumberF.layer.cornerRadius;
    _destionationF.layer.cornerRadius            =    _tableNumberF.layer.cornerRadius;
    _timeF.layer.cornerRadius                       =    _tableNumberF.layer.cornerRadius;

    _tableNumberF.layer.borderWidth         =    1;
    _proposerNameF.layer.borderWidth        =    _tableNumberF.layer.borderWidth;
    _telephoneNumberF.layer.borderWidth     =   _tableNumberF.layer.borderWidth;
    _destionationF.layer.borderWidth             =   _tableNumberF.layer.borderWidth;
    _timeF.layer.borderWidth                        =    _tableNumberF.layer.borderWidth;

    _tableNumberF.layer.borderColor         =    [UIColor blackColor].CGColor;
    _proposerNameF.layer.borderColor        =    _tableNumberF.layer.borderColor;
    _telephoneNumberF.layer.borderColor     =   _tableNumberF.layer.borderColor;
    _destionationF.layer.borderColor             =   _tableNumberF.layer.borderColor;
    _timeF.layer.borderColor                        =   _tableNumberF.layer.borderColor;

    _contentView.layer.borderWidth = 1;
    _contentView.text = nil;
    _contentView.layer.borderColor = [UIColor lightGrayColor].CGColor;

//    UIImageView *imgview = [[UIImageView alloc] initWithFrame:[UIScreen mainScreen].bounds];
//    imgview.image = [UIImage imageNamed:@"UserCar"];
//    [self.view addSubview:imgview];
    UIView *headView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kselfWidth, 64)];
    headView.backgroundColor = RGBColor(124, 129, 227, 1.f);
    [self.view addSubview:headView];
    
    UIButton *backBtn = [[UIButton alloc] initWithFrame:CGRectMake(20, 15, 30, 25)];
    backBtn.backgroundColor = [UIColor clearColor];
    [backBtn setImage:[UIImage imageNamed:@"back"] forState:UIControlStateNormal];
//    [backBtn setTitle:@"back" forState:UIControlStateNormal];
//    [backBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [backBtn addTarget:self action:@selector(backLastVC) forControlEvents:UIControlEventTouchUpInside];
    [headView addSubview:backBtn];

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


#pragma mark -- back action
- (void) backLastVC
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)textViewDidBeginEditing:(UITextView *)textView
{

    [textView resignFirstResponder];

    [_iFlySpeechSynthesizer startSpeaking:@"请输入补充内容"];
    isTableNumberF               = NO;
    isProposerNameF             = NO;
    isTelephoneNumbaerF      = NO;
    isDestionationF                = NO;
    isTimeF                           = NO;
    isContentView                 = YES;

    [NSThread sleepForTimeInterval:2.5f];

    if(_iFlyRecognizerView == nil)
    {
        [self setupWithRecognizer ];
    }

    //设置音频来源为麦克风
    [_iFlyRecognizerView setParameter:IFLY_AUDIO_SOURCE_MIC forKey:@"audio_source"];
    //设置听写结果格式为json
    [_iFlyRecognizerView setParameter:@"plain" forKey:[IFlySpeechConstant RESULT_TYPE]];

    //保存录音文件，保存在sdk工作路径中，如未设置工作路径，则默认保存在library/cache下
    //        [_iFlyRecognizerView setParameter:@"asr.pcm" forKey:[IFlySpeechConstant ASR_AUDIO_PATH]];
    [_iFlyRecognizerView start];

}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    [textField resignFirstResponder];

    switch (textField.tag) {
        case 100:
        {
            [_iFlySpeechSynthesizer startSpeaking:@"请输入申请表编号"];
            isTableNumberF               = YES;
            isProposerNameF             = NO;
            isTelephoneNumbaerF      = NO;
            isDestionationF                = NO;
            isTimeF                           = NO;
            isContentView                 = NO;
        }
            break;
        case 101:
        {
            [_iFlySpeechSynthesizer startSpeaking:@"请输入申请人姓名"];
            isTableNumberF               = NO;
            isProposerNameF             = YES;
            isTelephoneNumbaerF      = NO;
            isDestionationF                = NO;
            isTimeF                           = NO;
            isContentView                 = NO;
        }
            break;
        case 102:
        {
            [_iFlySpeechSynthesizer startSpeaking:@"请输入申请人联系电话"];
            isTableNumberF               = NO;
            isProposerNameF             = NO;
            isTelephoneNumbaerF      = YES;
            isDestionationF                = NO;
            isTimeF                           = NO;
            isContentView                 = NO;
        }
            break;
        case 103:
        {
            [_iFlySpeechSynthesizer startSpeaking:@"请输入目的地"];
            isTableNumberF               = NO;
            isProposerNameF             = NO;
            isTelephoneNumbaerF      = NO;
            isDestionationF                = YES;
            isTimeF                           = NO;
            isContentView                 = NO;
        }
            break;
        case 104:
        {
            [_iFlySpeechSynthesizer startSpeaking:@"请输入时间"];
            isTableNumberF               = NO;
            isProposerNameF             = NO;
            isTelephoneNumbaerF      = NO;
            isDestionationF                = NO;
            isTimeF                           = YES;
            isContentView                 = NO;
        }
            break;
        default:
            break;
    }

    [NSThread sleepForTimeInterval:5.5f];

    if(_iFlyRecognizerView == nil)
    {
        [self setupWithRecognizer ];
    }

    //设置音频来源为麦克风
    [_iFlyRecognizerView setParameter:IFLY_AUDIO_SOURCE_MIC forKey:@"audio_source"];
    //设置听写结果格式为json
    [_iFlyRecognizerView setParameter:@"plain" forKey:[IFlySpeechConstant RESULT_TYPE]];

    //保存录音文件，保存在sdk工作路径中，如未设置工作路径，则默认保存在library/cache下
    //        [_iFlyRecognizerView setParameter:@"asr.pcm" forKey:[IFlySpeechConstant ASR_AUDIO_PATH]];
    [_iFlyRecognizerView start];

}

#pragma mark -- 语音识别返回结果
- (void)onResult:(NSArray *)resultArray isLast:(BOOL)isLast
{
    NSMutableString *result = [[NSMutableString alloc] init];
    NSDictionary *dic = [resultArray objectAtIndex:0];

    for (NSString *key in dic) {
        [result appendFormat:@"%@",key];
    }

    if (isTableNumberF) {
        _tableNumberF.text = [NSString stringWithFormat:@"%@%@",_tableNumberF.text,result];
    }else if (isProposerNameF)
    {
        _proposerNameF.text = [NSString stringWithFormat:@"%@%@",_proposerNameF.text,result];
    }else if (isTelephoneNumbaerF)
    {
        _telephoneNumberF.text = [NSString stringWithFormat:@"%@%@",_telephoneNumberF.text,result];
    }else if (isDestionationF)
    {
        _destionationF.text = [NSString stringWithFormat:@"%@%@",_destionationF.text,result];
    }else if (isTimeF)
    {
        _timeF.text = [NSString stringWithFormat:@"%@%@",_timeF.text,result];
    }else
    {
        _contentView.text = [NSString stringWithFormat:@"%@%@",_contentView.text,result];

    }

}

@end
