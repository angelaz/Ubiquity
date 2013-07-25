//
//  NewMessageViewController.m
//  Ubiquity
//
//  Created by Winnie Wu on 7/24/13.
//  Copyright (c) 2013 Team Ubi. All rights reserved.
//

#import "NewMessageViewController.h"

@interface NewMessageViewController ()
@property (nonatomic, strong) UITextField *toRecipientTextField;
@property (nonatomic, strong) UILabel *toLabel;
@property (nonatomic, strong) UITextField *messageTextField;
@property (nonatomic, strong) UIButton *sendButton;
@end

@implementation NewMessageViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    self.toLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 30, 50, 30)];
    self.toLabel.text = @"To:";
    [self.view addSubview:self.toLabel];
    
    self.toRecipientTextField = [[UITextField alloc] initWithFrame:CGRectMake(40.0, 30.0, 270.0, 30.0)];
    self.toRecipientTextField.delegate = self;
    self.toRecipientTextField.borderStyle = UITextBorderStyleRoundedRect;
    [self.view addSubview:self.toRecipientTextField];
    
    self.messageTextField = [[UITextField alloc] initWithFrame:CGRectMake(10.0, 70.0, 300.0, 150.0)];
    self.messageTextField.delegate = self;
    self.messageTextField.borderStyle = UITextBorderStyleRoundedRect;
    [self.view addSubview:self.messageTextField];

    
    UIButton *sendButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    sendButton.frame = CGRectMake([UIScreen mainScreen].applicationFrame.size.width - 60, [UIScreen mainScreen].applicationFrame.size.height - 20, 50, 30);
    [sendButton addTarget:self action:@selector(sendMessage:) forControlEvents:UIControlEventTouchUpInside];
    [sendButton setTitle: @"Send" forState:UIControlStateNormal];
    [self.view addSubview:sendButton];
    
}

- (void) sendMessage: (id) sender
{
    NSLog(@"Message sent!");
    
    [self dismissViewControllerAnimated:NO completion:nil];
}

- (BOOL) textFieldShouldReturn: (UITextField *)textField {
    [textField resignFirstResponder];
    return  NO;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
