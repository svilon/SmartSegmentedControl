//
//  SVViewController.m
//  SmartSegmentedControl
//
//  Created by Eugene Shevtsov on 07/06/2017.
//  Copyright (c) 2017 Eugene Shevtsov. All rights reserved.
//

#import "SVViewController.h"
#import <SmartSegmentedControl/SmartSegmentedControl.h>

@interface SVViewController () <UITextFieldDelegate>

@property (nonatomic, weak) IBOutlet UIScrollView *mainScrollView;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *mainScrollBottomConstraint;

@property (nonatomic, weak) IBOutlet UIScrollView *controlContainerScrollView;
@property (nonatomic, weak) IBOutlet SmartSegmentedControl *configurableControl;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *configurableControlWidthConstraint;

@property (nonatomic, weak) IBOutlet UITextField *controlWidthTextField;
@property (nonatomic, weak) IBOutlet UISegmentedControl *controlModeSegmentedControl;

@property (nonatomic, weak) IBOutlet UITextField *segmentIndexTextField;
@property (nonatomic, weak) IBOutlet UIStepper *segmentIndexStepper;
@property (nonatomic, weak) IBOutlet UITextField *segmentWidthTextField;
@property (nonatomic, weak) IBOutlet UITextField *segmentTitleTextField;

@property (nonatomic, weak) IBOutlet UIButton *addButton;
@property (nonatomic, weak) IBOutlet UIButton *insertButton;
@property (nonatomic, weak) IBOutlet UIButton *removeButton;

@end

@implementation SVViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.

    _configurableControl.backgroundColor = [UIColor yellowColor];
    _controlWidthTextField.text = [NSString stringWithFormat:@"%f", _configurableControlWidthConstraint.constant];
    
    [self changeControlMode:_controlModeSegmentedControl];

    _segmentIndexStepper.minimumValue = 0;
    _segmentIndexStepper.maximumValue = _configurableControl.numberOfSegments;
    _segmentIndexStepper.value = _segmentIndexStepper.minimumValue;
    [self stepperValueChange:_segmentIndexStepper];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(willShowKeyboard:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(willHideKeyboard:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    if (_configurableControlWidthConstraint.constant < _controlContainerScrollView.frame.size.width) {
        UIEdgeInsets insets = _controlContainerScrollView.contentInset;
        insets.left = (_controlContainerScrollView.frame.size.width - _configurableControlWidthConstraint.constant) / 2.;
        _controlContainerScrollView.contentInset = insets;
    }
    else {
        UIEdgeInsets insets = _controlContainerScrollView.contentInset;
        insets.left = 0.;
        _controlContainerScrollView.contentInset = insets;

    }
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


#pragma mark - actions

- (IBAction)changeControlMode:(UISegmentedControl *)sender {
    switch (sender.selectedSegmentIndex) {
        case 0:
            _configurableControl.apportionsSegmentWidthsByContent = NO;
            _configurableControl.fixNativeProportionalSizing = NO;
            _configurableControl.smartAdjustment = NO;
            break;
            
        case 1:
            _configurableControl.apportionsSegmentWidthsByContent = YES;
            _configurableControl.fixNativeProportionalSizing = NO;
            _configurableControl.smartAdjustment = NO;
            break;
            
        case 2:
            _configurableControl.apportionsSegmentWidthsByContent = NO;
            _configurableControl.fixNativeProportionalSizing = YES;
            _configurableControl.smartAdjustment = NO;
            break;
            
        case 3:
            _configurableControl.apportionsSegmentWidthsByContent = NO;
            _configurableControl.fixNativeProportionalSizing = NO;
            _configurableControl.smartAdjustment = YES;
            break;
            
        default:
            [self showAlertWithText:@"!!! app is not ready for it yet"];
            break;
    }
}

- (IBAction)stepperValueChange:(UIStepper *)sender {
    int index = sender.value;
    _segmentIndexTextField.text = [NSString stringWithFormat:@"%i", index];
    
    if (index < _configurableControl.numberOfSegments) {
        _segmentWidthTextField.text = [NSString stringWithFormat:@"%f", [_configurableControl widthForSegmentAtIndex:index]];
        _segmentTitleTextField.text = [_configurableControl titleForSegmentAtIndex:index];
        _addButton.enabled = NO;
        _insertButton.enabled = YES;
        _removeButton.enabled = YES;
    }
    else {
        _segmentWidthTextField.text = @"0";
        _segmentTitleTextField.text = @"";
        _addButton.enabled = YES;
        _insertButton.enabled = NO;
        _removeButton.enabled = NO;
    }
}

- (IBAction)addButtonClick:(UIButton *)sender {
    int index = _segmentIndexStepper.value;
    [_configurableControl insertSegmentWithTitle:_segmentTitleTextField.text
                                         atIndex:index
                                        animated:YES];
    CGFloat width = _segmentWidthTextField.text.floatValue;
    if (width > 0) {
        [_configurableControl setWidth:width forSegmentAtIndex:index];
    }
    
    _segmentIndexStepper.maximumValue += 1;
    [self stepperValueChange:_segmentIndexStepper];
}

- (IBAction)insertButtonClick:(UIButton *)sender {
    int index = _segmentIndexStepper.value;
    [_configurableControl insertSegmentWithTitle:@""
                                         atIndex:index
                                        animated:YES];
    _segmentIndexStepper.maximumValue += 1;
    [self stepperValueChange:_segmentIndexStepper];
}

- (IBAction)removeButtonClick:(UIButton *)sender {
    int index = _segmentIndexStepper.value;
    [_configurableControl removeSegmentAtIndex:index animated:YES];
    _segmentIndexStepper.maximumValue -= 1;
    [self stepperValueChange:_segmentIndexStepper];
}


#pragma mark - textField delegate

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField {
    BOOL isValid = YES;
    
    if (textField == _controlWidthTextField) {
        CGFloat width = textField.text.floatValue;
        if (width) {
            _configurableControlWidthConstraint.constant = width;
            [UIView animateWithDuration:0.2 animations:^{
                [self updateViewConstraints];
            }];
        }
        else {
            isValid = NO;
        }
    }
    else if (textField == _segmentIndexTextField) {
        int index = textField.text.intValue;
        if (index >= 0 && index<=_configurableControl.numberOfSegments) {
            _segmentIndexStepper.value = index;
            [self stepperValueChange:_segmentIndexStepper];
        }
        else {
            isValid = NO;
        }
    }
    else if (textField == _segmentWidthTextField) {
        CGFloat width = textField.text.floatValue;
        int index = _segmentIndexStepper.value;
        if (index < _configurableControl.numberOfSegments) {
            [_configurableControl setWidth:width forSegmentAtIndex:index];
        }
    }
    else if (textField == _segmentTitleTextField) {
        int index = _segmentIndexStepper.value;
        if (index < _configurableControl.numberOfSegments) {
            [_configurableControl setTitle:textField.text forSegmentAtIndex:index];
        }
    }
    
    if (!isValid) {
        [self showAlertWithText:@"Inapropriate value. Please, edit it :)"];
    }
    
    return isValid;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return NO;
}


#pragma mark - keyboard observing

- (void)willShowKeyboard:(NSNotification *)notification {
    NSDictionary *userInfo = notification.userInfo;
    CGRect kbRect = [userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    
    _mainScrollBottomConstraint.constant = kbRect.size.height;
    [UIView animateWithDuration:[userInfo[UIKeyboardAnimationDurationUserInfoKey] floatValue] animations:^{
        [self updateViewConstraints];
    }];
}

- (void)willHideKeyboard:(NSNotification *)notification {
    NSDictionary *userInfo = notification.userInfo;
    _mainScrollBottomConstraint.constant = 0.;
    [UIView animateWithDuration:[userInfo[UIKeyboardAnimationDurationUserInfoKey] floatValue] animations:^{
        [self updateViewConstraints];
    }];
}


#pragma mark - service

- (void)showAlertWithText:(NSString *)text {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:text preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        [alert dismissViewControllerAnimated:YES completion:nil];
    }]];
    
    [self presentViewController:alert animated:YES completion:nil];
}


@end
