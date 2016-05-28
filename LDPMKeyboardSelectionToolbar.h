//
//  LDPMKeyboardSelectionToolBar.h
//  PreciousMetals
//
//  Created by gaoyu on 15/8/4.
//  Copyright (c) 2015年 NetEase. All rights reserved.
//

#import <UIKit/UIKit.h>
@class LDPMKeyboardSelectionToolbar;

@protocol LDPMKeyboardSelectionToolbarDelegate <NSObject>
@required
- (void)keyboardSelectionToolbar:(LDPMKeyboardSelectionToolbar*)toolbar doneButtonDidSelect:(UIButton *)doneButton;
- (NSString *)keyboardSelectionToolbar:(LDPMKeyboardSelectionToolbar*)toolbar buttonNameAtIndex:(NSInteger)index;
- (void)keyboardSelectionToolbar:(LDPMKeyboardSelectionToolbar *)toolbar selectionButtonDidSelectAtIndex:(NSInteger)index;
- (NSInteger)selectionCountOfToolbar:(LDPMKeyboardSelectionToolbar*)toolbar;
@end

@interface LDPMKeyboardSelectionToolbar : UIToolbar
@property (nonatomic, weak) id<LDPMKeyboardSelectionToolbarDelegate> keyboardDelegate;
@end

