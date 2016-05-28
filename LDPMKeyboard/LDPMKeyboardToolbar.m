//
//  LDPMToolbar.m
//  testKeyboard
//
//  Created by wangchao on 7/17/15.
//  Copyright (c) 2015 wangchao. All rights reserved.
//

#import "LDPMKeyboardToolbar.h"

NSInteger const tagConstant = 9000;

@interface LDPMKeyboardToolbar ()
@property (strong, nonatomic) UIBarButtonItem *prev;
@property (strong, nonatomic) UIBarButtonItem *next;
@end

@implementation LDPMKeyboardToolbar

- (instancetype)init
{
    self = [super init];

    if (self) {
        [self sizeToFit];
        [self initToolbarButtonItems];

        self.active = YES;
    }

    return self;
}

- (void)initToolbarButtonItems {
    UIImage *imageLeftArrow = [UIImage imageNamed:@"LDPMKeyboardToolbar.bundle/ArrowLeft"];
    UIImage *imageRightArrow = [UIImage imageNamed:@"LDPMKeyboardToolbar.bundle/ArrowRight"];
    
    self.prev = [[UIBarButtonItem alloc] initWithImage:imageLeftArrow style:UIBarButtonItemStylePlain target:self action:@selector(preAction)];
    self.next = [[UIBarButtonItem alloc] initWithImage:imageRightArrow style:UIBarButtonItemStylePlain target:self action:@selector(nextAction)];
    
    UIButton *doneButton = [UIButton buttonWithType:UIButtonTypeCustom];
    doneButton.frame = CGRectMake(0, 0, 40, 40);
    [doneButton setTitle:@"完成" forState:UIControlStateNormal];
    [doneButton setTitleColor:self.tintColor forState:UIControlStateNormal];
    [doneButton addTarget:self action:@selector(doneAction) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *doneItem = [[UIBarButtonItem alloc] initWithCustomView:doneButton];
    
    //  Create a fake button to maintain flexibleSpace between doneButton and nilButton. (Actually it moves done button to right side.
    UIBarButtonItem *nilButton = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    
    UIBarButtonItem *fixed = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    [fixed setWidth:23];
    
    NSMutableArray *items = [[NSMutableArray alloc] init];
    
    [items addObject:self.prev];
    [items addObject:fixed];
    [items addObject:self.next];
    [items addObject:nilButton];
    [items addObject:doneItem];
    self.items = items;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark -

-(void)setActive:(BOOL)active
{
    _active = active;
    if (_active) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextFieldTextDidBeginEditingNotification object:nil];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextViewTextDidBeginEditingNotification object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textInputViewDidBeginEditing:) name:UITextFieldTextDidBeginEditingNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textInputViewDidBeginEditing:) name:UITextViewTextDidBeginEditingNotification object:nil];
    } else{
        [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextFieldTextDidBeginEditingNotification object:nil];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextViewTextDidBeginEditingNotification object:nil];
    }
}

#pragma mark - outlets display methods
- (void)setChangeInputButtonsDisplay:(BOOL)type {
    if (!type) {
        NSMutableArray *newItems = [self.items mutableCopy];
        [newItems removeObject:self.prev];
        [newItems removeObject:self.next];
        self.items = newItems;
    } else {
        [self initToolbarButtonItems];
    }
}

#pragma mark -
- (void)textInputViewDidBeginEditing:(NSNotification *)notification
{
    id<UITextInput> textInputView = notification.object;

    if (self.kbDelegate && [self.kbDelegate respondsToSelector:@selector(kbToobar:isNextButtonEnableForTextInputView:)]) {
        self.next.enabled = [self.kbDelegate kbToobar:self isNextButtonEnableForTextInputView:textInputView];
    } else {
        self.next.enabled = NO;
    }

    if (self.kbDelegate && [self.kbDelegate respondsToSelector:@selector(kbToobar:isPreButtonEnableForTextInputView:)]) {
        self.prev.enabled = [self.kbDelegate kbToobar:self isPreButtonEnableForTextInputView:textInputView];
    } else {
        self.prev.enabled = NO;
    }
}

- (void)preAction
{
    if (self.kbDelegate && [self.kbDelegate respondsToSelector:@selector(preButtonDidPressed:)]) {
        [self.kbDelegate preButtonDidPressed:self];
    }
}

- (void)nextAction
{
    if (self.kbDelegate && [self.kbDelegate respondsToSelector:@selector(nextButtonDidPressed:)]) {
        [self.kbDelegate nextButtonDidPressed:self];
    }
}

- (void)doneAction
{
    if (self.kbDelegate && [self.kbDelegate respondsToSelector:@selector(doneButtonDidPressed:)]) {
        [self.kbDelegate doneButtonDidPressed:self];
    }
}

@end
