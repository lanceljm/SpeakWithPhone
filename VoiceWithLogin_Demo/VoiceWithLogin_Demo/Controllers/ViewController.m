//
//  ViewController.m
//  VoiceWithLogin_Demo
//
//  Created by ljm on 2017/10/12.
//  Copyright © 2017年 com.ynyx. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

#pragma mark -- hidden status
- (BOOL) prefersStatusBarHidden
{
    return YES;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [self setupUI];
}

#pragma mark -- setkupUI
- (void) setupUI
{
    UIImageView *imgview = [[UIImageView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    imgview.image = [UIImage imageNamed:@"UserCar"];
    [self.view addSubview:imgview];
    
    
    UIButton *backBtn = [[UIButton alloc] initWithFrame:CGRectMake(40, 10, 40, 25)];
    backBtn.backgroundColor = [UIColor clearColor];
    [backBtn setTitle:@"back" forState:UIControlStateNormal];
    [backBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [backBtn addTarget:self action:@selector(backLastVC) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:backBtn];

}

#pragma mark -- back action
- (void) backLastVC
{
    [self dismissViewControllerAnimated:YES completion:nil];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
