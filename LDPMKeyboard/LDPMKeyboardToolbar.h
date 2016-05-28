//
//  LDPMToolbar.h
//  testKeyboard
//
//  Created by wangchao on 7/17/15.
//  Copyright (c) 2015 wangchao. All rights reserved.
//

#import <UIKit/UIKit.h>

extern NSInteger const tagConstant;

@protocol LDPMKeyboardToolbarDelegate;

@interface LDPMKeyboardToolbar : UIToolbar
@property (nonatomic, weak) id <LDPMKeyboardToolbarDelegate> kbDelegate;

@property (nonatomic,assign) BOOL active; //默认YES,active为YES时会监听输入通知，向Delegate发消息。

- (void)setChangeInputButtonsDisplay:(BOOL)type;

@end

@protocol LDPMKeyboardToolbarDelegate <NSObject>

@required
- (void)preButtonDidPressed:(LDPMKeyboardToolbar *)kbToolbar;
- (void)nextButtonDidPressed:(LDPMKeyboardToolbar *)kbToolbar;
- (void)doneButtonDidPressed:(LDPMKeyboardToolbar *)kbToolbar;
- (BOOL)kbToobar:(LDPMKeyboardToolbar *)kbToolbar isPreButtonEnableForTextInputView:(id<UITextInput>)textInputView;
- (BOOL)kbToobar:(LDPMKeyboardToolbar *)kbToolbar isNextButtonEnableForTextInputView:(id<UITextInput>)textInputView;
@end