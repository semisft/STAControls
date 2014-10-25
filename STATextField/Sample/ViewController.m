//
//  ViewController.m
//  STATextField
//
//  Created by Aaron Jubbal on 10/16/14.
//  Copyright (c) 2014 Aaron Jubbal. All rights reserved.
//

#import "ViewController.h"
#import "STAATMTextField.h"
#import <ReactiveCocoa/ReactiveCocoa.h>

@interface ViewController ()

@property (nonatomic, strong) IBOutlet STAATMTextField *textField;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
//    [self.textField.rac_textSignal subscribeNext:^(id x) {
//        NSLog(@"%@", x);
//    }];
    
    _textField.placeholder = @"Hello world!";
    _textField.keyboardType = UIKeyboardTypeDecimalPad;
}


- (IBAction)hideKeyboard:(id)sender {
    [_textField resignFirstResponder];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    NSLog(@"%s", __PRETTY_FUNCTION__);
    
    [_textField resignFirstResponder];
    return YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
