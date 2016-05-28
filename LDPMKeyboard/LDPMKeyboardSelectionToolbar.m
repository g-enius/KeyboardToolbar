//
//  LDPMKeyboardSelectionToolBar.m
//  PreciousMetals
//
//  Created by gaoyu on 15/8/4.
//  Copyright (c) 2015年 NetEase. All rights reserved.
//

#import "LDPMKeyboardSelectionToolbar.h"

static CGFloat const kDefaultSpacerWidth = 2.0f;

@interface LDPMKeyboardSelectionToolbar ()
@end

@implementation LDPMKeyboardSelectionToolbar

- (instancetype)init
{
    if (self = [super init]) {
        [self sizeToFit];
    }
    return self;
}

-(void)layoutSubviews
{
    UIBarButtonItem *headSpacer = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    [headSpacer setWidth:-10.0f];
    UIBarButtonItem *nilButton = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    UIView *baseView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0.7*self.size.width + 6 * kDefaultSpacerWidth, self.size.height)];
    baseView.backgroundColor = [UIColor clearColor];
    
    NSInteger selectionCount = 0;
    NSMutableArray *items = [[NSMutableArray alloc] init];
    
    selectionCount = [self.keyboardDelegate selectionCountOfToolbar:self];
    CGSize buttonSize = CGSizeMake(0.7*self.size.width/selectionCount, 20);
    
    for (int i = 0 ; i < selectionCount; i ++) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.frame = CGRectMake(i*(buttonSize.width + 2*kDefaultSpacerWidth), 12, buttonSize.width, buttonSize.height);
        [button setTitleColor:[NPMColor blackTextColor] forState:UIControlStateNormal];
        button.titleLabel.font = [UIFont systemFontOfSize:13];
        [button setTitle:[self.keyboardDelegate keyboardSelectionToolbar:self buttonNameAtIndex:i] forState:UIControlStateNormal];
        button.tag = i;
        button.backgroundColor = [UIColor clearColor];
        [button addTarget:self action:@selector(selectionButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        [baseView addSubview:button];
        if (i < selectionCount - 1) {
            UIView *sepline = [[UIView alloc] initWithFrame:CGRectMake((i+1)*(buttonSize.width + 2*kDefaultSpacerWidth) - kDefaultSpacerWidth, 12, 1, 20)];
            sepline.backgroundColor = [NPMColor seplineColor];
            [baseView addSubview:sepline];
        }
    }
    
    UIButton *doneButton = [UIButton buttonWithType:UIButtonTypeCustom];
    doneButton.frame = CGRectMake(0, 0, 40, 40);
    [doneButton setTitle:@"完成" forState:UIControlStateNormal];
    [doneButton setTitleColor:self.tintColor forState:UIControlStateNormal];
    [doneButton addTarget:self action:@selector(doneAction:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *doneItem = [[UIBarButtonItem alloc] initWithCustomView:doneButton];
    
    UIBarButtonItem *mainActionItem = [[UIBarButtonItem alloc] initWithCustomView:baseView];
    [items addObject:headSpacer];
    [items addObject:mainActionItem];
    [items addObject:nilButton];
    [items addObject:doneItem];
    self.items = items;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Button Methods
- (void)doneAction:(UIButton *)sender
{
    if (self.keyboardDelegate && [self.keyboardDelegate respondsToSelector:@selector(keyboardSelectionToolbar:doneButtonDidSelect:)]) {
        [self.keyboardDelegate keyboardSelectionToolbar:self doneButtonDidSelect:sender];
    }
}

- (void)selectionButtonPressed:(UIButton *)sender {
    [self.keyboardDelegate keyboardSelectionToolbar:self selectionButtonDidSelectAtIndex:sender.tag];
}

@end
