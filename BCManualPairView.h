//
//  ManualPairView.h
//  Blockchain
//
//  Created by Mark Pfluger on 9/25/14.
//  Copyright (c) 2014 Blockchain Luxembourg S.A. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BCModalContentView.h"

@interface BCManualPairView : BCModalContentView <UITextFieldDelegate> {
    IBOutlet UITextField *walletIdentifierTextField;
    IBOutlet UITextField *passwordTextField;
    UITextField *verifyTwoFactorTextField;
}

- (IBAction)continueClicked:(id)sender;
- (void)hideKeyboard;
- (void)clearPasswordTextField;
- (void)clearTextFields;
- (void)verifyTwoFactorSMS;
- (void)verifyTwoFactorGoogle;
- (void)verifyTwoFactorYubiKey;

@end
