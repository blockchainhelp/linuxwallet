//
//  BCEditAddressView.m
//  Blockchain
//
//  Created by Kevin Wu on 1/29/16.
//  Copyright © 2016 Blockchain Luxembourg S.A. All rights reserved.
//

#import "BCEditAddressView.h"
#import "RootService.h"
#import "Blockchain-Swift.h"

@implementation BCEditAddressView

-(id)initWithAddress:(NSString *)address
{
    UIWindow *window = app.window;
    
    self = [super initWithFrame:CGRectMake(0, DEFAULT_HEADER_HEIGHT, window.frame.size.width, window.frame.size.height - DEFAULT_HEADER_HEIGHT)];
    
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        self.address = address;
        
        UILabel *addressLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 8, 290, 21)];
        addressLabel.textColor = [UIColor darkGrayColor];
        addressLabel.font = [UIFont fontWithName:FONT_MONTSERRAT_REGULAR size:FONT_SIZE_LARGE];
        addressLabel.text = address;
        addressLabel.adjustsFontSizeToFitWidth = YES;
        [self addSubview:addressLabel];
        
        self.labelTextField = [[BCTextField alloc] init];
        self.labelTextField.borderStyle = UITextBorderStyleNone;
        self.labelTextField.autocapitalizationType = UITextAutocapitalizationTypeSentences;
        [self addSubview:self.labelTextField];
        self.labelTextField.frame = CGRectMake(15, 37, 290, 30);
        self.labelTextField.textColor = COLOR_TEXT_DARK_GRAY;
        self.labelTextField.font = [UIFont fontWithName:FONT_MONTSERRAT_REGULAR size:self.labelTextField.font.pointSize];
        self.labelTextField.returnKeyType = UIReturnKeyDone;
        self.labelTextField.delegate = self;
        
        UIButton *saveButton = [UIButton buttonWithType:UIButtonTypeCustom];
        saveButton.frame = CGRectMake(0, 0, self.frame.size.width, 46);
        saveButton.backgroundColor = COLOR_BLOCKCHAIN_LIGHT_BLUE;
        [saveButton setTitle:BC_STRING_SAVE forState:UIControlStateNormal];
        [saveButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        saveButton.titleLabel.font = [UIFont fontWithName:FONT_MONTSERRAT_REGULAR size:FONT_SIZE_LARGE];
        
        [saveButton addTarget:self action:@selector(labelSaveClicked) forControlEvents:UIControlEventTouchUpInside];
        
        self.labelTextField.inputAccessoryView = saveButton;
    }
    
    return self;
}

- (void)labelSaveClicked
{
    NSString *label = [self.labelTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    if (![app.wallet didUpgradeToHd]) {
        NSMutableCharacterSet *allowedCharSet = [[NSCharacterSet alphanumericCharacterSet] mutableCopy];
        [allowedCharSet formUnionWithCharacterSet:[NSCharacterSet whitespaceCharacterSet]];
        
        if ([label rangeOfCharacterFromSet:[allowedCharSet invertedSet]].location != NSNotFound) {
            [app standardNotify:BC_STRING_LABEL_MUST_BE_ALPHANUMERIC];
            return;
        }
    }
    
    NSString *addr = self.address;
    
    [app.wallet setLabel:label forLegacyAddress:addr];
    
    [self.labelTextField resignFirstResponder];
    
    [app closeModalWithTransition:kCATransitionFade];
    
    if (app.wallet.isSyncing) {
        [app showBusyViewWithLoadingText:BC_STRING_LOADING_SYNCING_WALLET];
    }
}

#pragma mark - Textfield Delegates

- (BOOL)textFieldShouldReturn:(UITextField*)aTextField
{
    [self labelSaveClicked];
    return YES;
}


@end
