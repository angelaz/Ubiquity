//
//  NewMessageViewController.m
//  Ubiquity
//
//  Created by Winnie Wu on 7/24/13.
//  Copyright (c) 2013 Team Ubi. All rights reserved.
//

#import "NewMessageViewController.h"
#import "AppDelegate.h"

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
    
    int const SCREEN_WIDTH = [UIScreen mainScreen].applicationFrame.size.width;
    int const SCREEN_HEIGHT = [UIScreen mainScreen].applicationFrame.size.height;
    
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
    sendButton.frame = CGRectMake(SCREEN_WIDTH - 60, SCREEN_HEIGHT - 20, 50, 30);
    [sendButton addTarget:self action:@selector(sendMessage:) forControlEvents:UIControlEventTouchUpInside];
    [sendButton setTitle: @"Send" forState:UIControlStateNormal];
    [self.view addSubview:sendButton];
    
    UIPickerView *repeatTimesPicker = [[UIPickerView alloc] initWithFrame: CGRectMake(10, SCREEN_HEIGHT - 80, SCREEN_WIDTH - 100, 30.0)];
    repeatTimesPicker.delegate = self;
    repeatTimesPicker.dataSource = self;
    repeatTimesPicker.showsSelectionIndicator = YES;
    [self.view addSubview:repeatTimesPicker];
    
    
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

/* Start Picker Methods */
- (void)pickerView:(UIPickerView *)pickerView didSelectRow: (NSInteger)row inComponent:(NSInteger)component {
    // Handle the selection
}

// tell the picker how many rows are available for a given component
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    NSUInteger numRows = 10;
    
    return numRows;
}

// tell the picker how many components it will have
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

// tell the picker the title for a given component
- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    NSString *title;
    title = [NSString stringWithFormat:@"%d",row];
    
    return title;
}

// tell the picker the width of each row for a given component
- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component {
    int sectionWidth = 300;
    
    return sectionWidth;
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
