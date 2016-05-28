//
//  LDPMResetTradePasswordInputViewController.m
//  PreciousMetals
//
//  Created by wangchao on 6/26/15.
//  Copyright (c) 2015 NetEase. All rights reserved.
//

#import "LDPMResetPWInputViewController.h"
#import "LDPMResetPWPWInfoCell.h"
#import "LDPMResetPWPWSetCell.h"
#import "NPMTradeSession.h"
#import "LDPMResetPWNSCell.h"
#import "NSString+ValidityCheck.h"
#import "ResetPasswordParam.h"
#import "NPMOpenAccountService.h"
#import "NPMServiceResponse.h"
#import "NPMTradeLoginViewController.h"
#import "NPMTradeMainViewController.h"
#import "LDPMTradePwdManager.h"

//#1 need to import "LDPMKeyboardToolbar.h"
#import "LDPMKeyboardToolbar.h"
#import "LDPMResetPWTintLabelCell.h"
#import "LDPMAlterPasswordViewController.h"

//#2 need to confirm to LDPMKeyboardToolbarDelegate protocal
@interface LDPMResetPWInputViewController ()<LDPMKeyboardToolbarDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) UITextField *setTextField;
@property (weak, nonatomic) UITextField *confirmTextField;
@property (weak, nonatomic) UIButton *nextButton;
@property (assign, nonatomic) BOOL isDeleting;
@property (copy, nonatomic) NSString *typeStr;
@property (copy, nonatomic) NSString *jumpUrl;
@property (copy, nonatomic) NSString *infoStr;
@property (copy, nonatomic) NSString *descStr;
@property (copy, nonatomic) NSString *placeHoderStr;
@property (assign, nonatomic) NSInteger passwordLenth;
@property (assign, nonatomic) NSInteger keyboardType;
//#3 the following need to copy
@property (strong, nonatomic) LDPMKeyboardToolbar *toolbar;
@property (strong, nonatomic) NSArray *textFieldsIndexPaths;
@property (weak, nonatomic) UITextField *activeTextField;
@property (strong, nonatomic) NSMutableDictionary *textFieldDictionary;

@property (strong, nonatomic, readonly) PartnerAccount *account;
@end

@implementation LDPMResetPWInputViewController

typedef void (^resetPasswordBlock)(NPMServiceResponse *);
#pragma  mark - lifeCycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //patnerId检查
    NSAssert(self.partnerId.length > 0, @"%@ partnerId不能为空", NSStringFromClass(self.class));
    if (self.partnerId.length <= 0) {
        self.partnerId = [[NPMTradeSession sharedInstance] defaultOpenedPartnerId];
    }
    
    self.tableView.delegate = (id<UITableViewDelegate>)self;
    self.tableView.dataSource = (id<UITableViewDataSource>)self;
    self.enableBackGroundTapToResignFirstResponder = YES;
    
    if (self.isFromTrade) {
        self.typeStr = @"交易";
        self.jumpUrl = [@"ntesfa://tab?tab=trade" stringByAppendingString:[NSString stringWithFormat:@"&partnerId=%@", self.account.partnerId]];
        self.infoStr = @"请设置交易密码";
        self.descStr = @"（用于交易登录）";
        self.placeHoderStr = [self.partnerId isEqualToString:NPMPartnerIDGuangGuiZhongXin] ? @"须为数字+英文字母组合，8-10位" : @"须为数字+英文字母组合，6-10位";
        self.passwordLenth = 10;
        self.keyboardType = UIKeyboardTypeDefault;
        self.title = @"重置交易密码";
    } else {
        self.typeStr = @"资金";
        self.jumpUrl = @"ntesfa://tab?tab=trade&partnerId=njs&tradeTab=TRANSFER";
        self.infoStr = @"请设置资金密码";
        self.descStr = @"（用于转账）";
        if (NSFoundationVersionNumber < NSFoundationVersionNumber_iOS_7_0) {
            self.placeHoderStr = @"请输入6位数字(非123456、555等)";
        } else {
            self.placeHoderStr = @"请输入6位数字(非123456、555等方式)";
        }
        self.passwordLenth = 6;
        self.keyboardType = UIKeyboardTypeNumberPad;
        self.title = @"重置资金密码";
    }
    
    //#4 the following need to copy
    self.toolbar = [[LDPMKeyboardToolbar alloc]init];
    self.toolbar.kbDelegate = self;
    self.textFieldsIndexPaths = [self createInputIndexPaths];
    self.textFieldDictionary = [NSMutableDictionary dictionary];
    
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    self.toolbar.active = YES;
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    self.toolbar.active = NO;
}

- (PartnerAccount *)account {
    return [[UserSession sharedSession] partnerAccountWithId:self.partnerId];
}

//#5 need to impliments all delegate methods
-(BOOL)kbToobar:(LDPMKeyboardToolbar *)kbToolbar isNextButtonEnableForTextInputView:(id<UITextInput>)textInputView
{
    self.activeTextField = (UITextField *)textInputView;
    self.activeTextField.enablesReturnKeyAutomatically = YES;

    NSInteger index = ((UIView *)textInputView).tag - tagConstant;
    if (index < self.textFieldsIndexPaths.count - 1) {
        self.activeTextField.returnKeyType = UIReturnKeyNext;
        return YES;
    } else {
        self.activeTextField.returnKeyType = UIReturnKeyDone;
        return NO;
    }
}

-(BOOL)kbToobar:(LDPMKeyboardToolbar *)kbToolbar isPreButtonEnableForTextInputView:(id<UITextInput>)textInputView
{
    return (((UIView *)textInputView).tag > tagConstant);
}

- (void)preButtonDidPressed:(LDPMKeyboardToolbar *)kbToolbar
{
    if (!self.activeTextField) {
        return;
    }
    
    NSInteger index = self.activeTextField.tag - tagConstant;
    if (index > 0) {
        NSIndexPath *preIndexPath = [self.textFieldsIndexPaths objectAtIndex:index-1];
        [self.tableView scrollToRowAtIndexPath:preIndexPath atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
        LDPMResetPWPWSetCell *preCell = (LDPMResetPWPWSetCell *)[self.tableView cellForRowAtIndexPath:preIndexPath];
        if ([preCell.passwordTextField respondsToSelector:@selector(becomeFirstResponder)]) {
            [preCell.passwordTextField becomeFirstResponder];
        }
//        if ([self.textFieldDictionary[preIndexPath] respondsToSelector:@selector(becomeFirstResponder)]) {
//            [self.textFieldDictionary[preIndexPath] becomeFirstResponder];
//        }
    }
}

- (void)nextButtonDidPressed:(LDPMKeyboardToolbar *)kbToolbar
{
    if (!self.activeTextField) {
        return;
    }
    
    NSInteger index = self.activeTextField.tag - tagConstant;
    if (index < self.textFieldsIndexPaths.count - 1) {
        NSIndexPath *nextIndexPath = [self.textFieldsIndexPaths objectAtIndex:index + 1];
        [self.tableView scrollToRowAtIndexPath:nextIndexPath atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
        LDPMResetPWPWSetCell *preCell = (LDPMResetPWPWSetCell *)[self.tableView cellForRowAtIndexPath:nextIndexPath];
        if ([preCell.passwordTextField respondsToSelector:@selector(becomeFirstResponder)]) {
            [preCell.passwordTextField becomeFirstResponder];
        }
//        if ([self.textFieldDictionary[nextIndexPath] respondsToSelector:@selector(becomeFirstResponder)]) {
//            [self.textFieldDictionary[nextIndexPath] becomeFirstResponder];
//        }
    }
}

- (void)doneButtonDidPressed:(LDPMKeyboardToolbar *)kbToolbar
{
    if (!self.activeTextField) {
        return;
    } else if ([self.activeTextField respondsToSelector:@selector(resignFirstResponder)]) {
        [self.activeTextField resignFirstResponder];
    }
}


#pragma mark - Create IndexPathsArray statically

//#6 if use tableView then need to implement this with same logic with tableView:cellForRowAtIndexPath
- (NSArray *)createInputIndexPaths
{
    NSMutableArray *indexPaths = [NSMutableArray array];
    for (int section = 0; section < [self numberOfSectionsInTableView:self.tableView]; section++) {
        for (int row = 0; row < [self tableView:self.tableView numberOfRowsInSection:section]; row++) {
            switch (section) {
                case 0:
                    continue;
                    break;
                    
                case 1:
                    switch (row) {
                        case 0:
                            [indexPaths addObject:[NSIndexPath indexPathForRow:row inSection:section]];
                            
                            break;
                            
                        case 1:
                            [indexPaths addObject:[NSIndexPath indexPathForRow:row inSection:section]];
                            break;
                    }
                    break;
                    
                case 2:
                    continue;
                    break;
            }

            
        }
    }

    return [NSArray arrayWithArray:indexPaths];
    
}

#pragma mark - UITableViewDataSource

- (UITableViewCell *)tableView:tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    id cell = nil;
    switch (indexPath.section) {
        case 0:
            cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([LDPMResetPWPWInfoCell class])];
            [cell passwordInfoLabel].text = self.infoStr;
            [cell passwordLimitInfoLabel].text = self.descStr;
            break;

        case 1:
            cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([LDPMResetPWPWSetCell class])];
            [[cell passwordTextField] addTarget:self action:@selector(textFieldEditing:) forControlEvents:UIControlEventEditingChanged];
            [cell setFirstCell:indexPath.row == 0];
            [cell setLastCell:indexPath.row == [self tableView:tableView numberOfRowsInSection:indexPath.section] - 1];
            switch (indexPath.row) {
                case 0:
                    [[cell passwordTextField] setKeyboardType:self.keyboardType];
                    [cell passwordTextField].placeholder = self.placeHoderStr;
                    self.setTextField = [cell passwordTextField];
                    NSInteger index = [self.textFieldsIndexPaths indexOfObject:indexPath];
                    if (index != NSNotFound) {
                        [[cell passwordTextField] setTag:index + tagConstant];
                        [[cell passwordTextField] setInputAccessoryView:self.toolbar];
                        [[cell passwordTextField] addTarget:self action:@selector(editingDidEndOnExit:) forControlEvents:UIControlEventEditingDidEndOnExit];
                        //self.textFieldDictionary[indexPath] = [cell passwordTextField];
                    }

                    break;

                case 1:
                    [[cell passwordTextField] setKeyboardType:self.keyboardType];
                    [cell passwordTextField].placeholder = [NSString stringWithFormat:@"请再次输入"];
                    self.confirmTextField = [cell passwordTextField];
                    index = [self.textFieldsIndexPaths indexOfObject:indexPath];
                    if (index != NSNotFound) {
                        [[cell passwordTextField] setTag:index + tagConstant];
                        [[cell passwordTextField] setInputAccessoryView:self.toolbar];
                        [[cell passwordTextField] addTarget:self action:@selector(editingDidEndOnExit:) forControlEvents:UIControlEventEditingDidEndOnExit];
                        //self.textFieldDictionary[indexPath] = [cell passwordTextField];
                    }
                    break;
            }
            break;

        case 2:
            cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([LDPMResetPWNSCell class])];
            self.nextButton = [cell nextButton];
            [[cell nextButton] addTarget:self action:@selector(gotoNextPage:) forControlEvents:UIControlEventTouchUpInside];
            [[cell sepline] setHidden:YES];
            break;
        case 3:
            cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([LDPMResetPWTintLabelCell class])];

            if ([self.account.partnerId isEqualToString: NPMPartnerIDNanJiaoSuo]) {
                [cell tintLabel].text = [NSString stringWithFormat:@"在工作日9:00-次日6:00期间可重置%@密码", self.typeStr];
            } else {
                [cell tintLabel].hidden = YES;
            }
            break;
    }
    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 4;
}

- (NSInteger)tableView:tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 1) {
        return 2;
    }
    
    return 1;
}

#pragma mark - UITextField UIControlEventEditingChanged
- (void)textFieldEditing:(UITextField *)textField
{
    NSString *tmp = [textField.text stringByReplacingOccurrencesOfString:@" " withString:@""];

    if (tmp.length > self.passwordLenth) {
        tmp = [tmp substringToIndex:self.passwordLenth];

        if (self.isFromTrade) {
            [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Exchange Pwd Warning Digit Place", @"请输入(6~10)位数字与字母组成的密码") message:nil delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil] show];
        } else {
            [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Fund Pwd Warning Alert", @"请设置为6位数字密码") message:nil delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil] show];
        }

    }

    textField.text = [tmp copy];
}

#pragma mark - UITableViewDelegate
- (void)tableView:tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}

- (CGFloat)tableView:tableView heightForHeaderInSection:(NSInteger)section
{
    switch (section) {
        case 0:
            return 24;

            break;

        case 2:
            return 26;

            break;

        default:
            return 0;

            break;
    }
}

- (UIView *)tableView:tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *headerView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [self tableView:tableView heightForHeaderInSection:section])];
    headerView.backgroundColor = [NPMColor mainBackgroundColor];
    return headerView;
}

#pragma mark - 修改交易密码第三步-修改交易密码
- (void)gotoNextPage:(id)sender
{
    if (!self.setTextField.text.length) {
        [[[UIAlertView alloc] initWithTitle:@"新密码不能为空" message:nil delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil] show];
        return;
    }

    if ([self isPasswordValid:self.setTextField.text]) {
        if ([self.setTextField.text isEqualToString:self.confirmTextField.text]) {
            [self startMaskActivity:[NSString stringWithFormat:@"正在重置%@密码", self.typeStr]];

            [self loadCookie];

            NSString *oldPwd = [self.setTextField.text stringByReplacingOccurrencesOfString:@" " withString:@""];
            NSString *newPwd = [self.confirmTextField.text stringByReplacingOccurrencesOfString:@" " withString:@""];
            PartnerAccount *tradeAccount = [[NPMTradeSession sharedInstance] partnerAccountWithId:self.partnerId];
            
            ResetPasswordParam *param = [ResetPasswordParam paramWithLogin_id:[UserSession sharedSession].loginID
                                                                  login_token:[UserSession sharedSession].loginToken
                                                                    password1:oldPwd
                                                                    password2:newPwd];

            @weakify(self);
            resetPasswordBlock block = ^(NPMServiceResponse *response) {
                @strongify(self);
                
                [self stopMaskActivity];

                if (response.retCode == NPMRetCodeSuccess) {
                    [self showToast:[NSString stringWithFormat:@"%@密码重置成功", self.typeStr]];
                    
                    [LDPMTradePwdManager addTradePwd:newPwd
                                              ofType:self.isFromTrade ? LDPMTradePwdTypeLogin : LDPMTradePwdTypeFund
                                       withAccountId:tradeAccount.firmId
                                        andPartnerId:tradeAccount.partnerId];
                    
                    [self.nextButton setBackgroundImage:[UIImage imageNamed:@"button_round_back_disabled"] forState:UIControlStateNormal];
                    self.nextButton.enabled = NO;
                    [self performSelector:@selector(jumpToPage) withObject:nil afterDelay:3];
                } else {
                    if (response.errorMessage.length) {
                        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:response.errorMessage message:nil delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
                        [alert show];
                    }
                }
            };

            [self resetPassword:param onComplete:block];
        } else {
            [[[UIAlertView alloc]initWithTitle:nil message:[NSString stringWithFormat:@"两次输入的%@密码不匹配，请您重新输入", self.typeStr]  delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil] show];
        }
    }
}

#pragma mark - UIControlEventEditingDidEndOnExit

- (void)editingDidEndOnExit:(UITextField *)sender
{
    NSInteger index = sender.tag - tagConstant;
    if (index < self.textFieldsIndexPaths.count - 1) {
        [self nextButtonDidPressed:self.toolbar];
    } else if(index == self.textFieldsIndexPaths.count - 1) {
        [sender resignFirstResponder];
    }
}

#pragma mark - action

- (void)jumpToPage
{
    NSInteger firstIndex = self.navigationController.viewControllers.count - 1 - 3;
    
    if (firstIndex >= 0) {//push 进的第一页
        UIViewController *firstViewController = self.navigationController.viewControllers[firstIndex];
        [self.navigationController popToViewController:firstViewController animated:YES];
    } else {// present 进的第一页
        [self.navigationController dismissViewControllerAnimated:YES completion:nil];
    }

}

- (BOOL)isPasswordValid:(NSString *)password
{
    if (self.isFromTrade) {
        return [NSString isTradePasswordValid:self.setTextField.text withPartnerId:self.partnerId];
    } else {
        return [NSString isFundPasswordValid:self.setTextField.text];
    }
}

- (void)resetPassword:(ResetPasswordParam *)param onComplete:(resetPasswordBlock)block
{
    if (self.isFromTrade) {
        [[NPMOpenAccountService sharedService] resetTradingPassword:param onComplete:block];
    } else {
        [[NPMOpenAccountService sharedService] resetFundPassword:param onComplete:block];
    }
}

#pragma mark - loadCookies 最后一步调用
- (void)loadCookie
{
    NSHTTPCookie *cookie = [NSKeyedUnarchiver unarchiveObjectWithData:[[NSUserDefaults standardUserDefaults] objectForKey:@"LDPMResetPasswordCookie"]];//自定义标示符

    if (cookie) {
        [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookie:cookie];
    }
}

@end
