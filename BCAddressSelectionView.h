/*
 * 
 * Copyright (c) 2012, Ben Reeves. All rights reserved.
 *
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public
 * License as published by the Free Software Foundation; either
 * version 2.1 of the License, or (at your option) any later version.
 *
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public
 * License along with this library; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston,
 * MA 02110-1301  USA
 */

#import <UIKit/UIKit.h>

@class Wallet, Contact;

@protocol AddressSelectionDelegate <NSObject>
- (void)didSelectFromAddress:(NSString*)address;
- (void)didSelectToAddress:(NSString*)address;
- (void)didSelectFromAccount:(int)account;
- (void)didSelectToAccount:(int)account;
- (void)didSelectContact:(Contact *)contact;
@optional
- (void)didSelectWatchOnlyAddress:(NSString*)address;
@end

@interface BCAddressSelectionView : UIView <UITableViewDelegate, UITableViewDataSource> {
    IBOutlet UIView *mainView;
    IBOutlet UITableView *tableView;
}

typedef enum {
    SelectModeFilter = 50,
    SelectModeSendFrom = 100,
    SelectModeSendTo = 200,
    SelectModeReceiveTo = 300,
    SelectModeReceiveFromContact = 350,
    SelectModeTransferTo = 400,
    SelectModeContact = 500
}SelectMode;

- (id)initWithWallet:(Wallet*)_wallet selectMode:(SelectMode)selectMode;
- (void)reloadTableView;

@property(nonatomic, strong) NSMutableArray *contacts;

@property(nonatomic, strong) NSMutableArray *addressBookAddresses;
@property(nonatomic, strong) NSMutableArray *addressBookAddressLabels;

@property(nonatomic, strong) NSMutableArray *legacyAddresses;
@property(nonatomic, strong) NSMutableArray *legacyAddressLabels;

@property(nonatomic, strong) NSMutableArray *accounts;
@property(nonatomic, strong) NSMutableArray *accountLabels;

@property(nonatomic, strong) Wallet *wallet;
@property(nonatomic, strong) Contact *previouslySelectedContact;
@property(nonatomic, strong) id<AddressSelectionDelegate> delegate;

@end
