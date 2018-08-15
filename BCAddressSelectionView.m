//
//  BCAddressSelectionView.m
//  Blockchain
//
//  Created by Ben Reeves on 17/03/2012.
//  Copyright (c) 2012 Blockchain Luxembourg S.A. All rights reserved.
//

#import "BCAddressSelectionView.h"
#import "Wallet.h"
#import "RootService.h"
#import "ReceiveTableCell.h"
#import "SendViewController.h"
#import "Contact.h"

@implementation BCAddressSelectionView

@synthesize contacts;

@synthesize addressBookAddresses;
@synthesize addressBookAddressLabels;

@synthesize legacyAddresses;
@synthesize legacyAddressLabels;

@synthesize accounts;
@synthesize accountLabels;

@synthesize wallet;
@synthesize delegate;

SelectMode selectMode;

int contactsSectionNumber;
int addressBookSectionNumber;
int accountsSectionNumber;
int legacyAddressesSectionNumber;

- (id)initWithWallet:(Wallet *)_wallet selectMode:(SelectMode)_selectMode
{
    if ([super initWithFrame:CGRectZero]) {
        [[NSBundle mainBundle] loadNibNamed:@"BCAddressSelectionView" owner:self options:nil];
        
        selectMode = _selectMode;
        
        self.wallet = _wallet;
        // The From Address View shows accounts and legacy addresses with their balance. Entries with 0 balance are not selectable.
        // The To Address View shows address book entries, account and legacy addresses without a balance.
        
        contacts = [NSMutableArray new];
        
        addressBookAddresses = [NSMutableArray array];
        addressBookAddressLabels = [NSMutableArray array];
        
        accounts = [NSMutableArray array];
        accountLabels = [NSMutableArray array];
        
        legacyAddresses = [NSMutableArray array];
        legacyAddressLabels = [NSMutableArray array];
        
        // Select from address
        if ([self showFromAddresses]) {
            // First show the HD accounts with positive balance
            for (int i = 0; i < app.wallet.getActiveAccountsCount; i++) {
                if ([app.wallet getBalanceForAccount:[app.wallet getIndexOfActiveAccount:i]] > 0) {
                    [accounts addObject:[NSNumber numberWithInt:i]];
                    [accountLabels addObject:[_wallet getLabelForAccount:[app.wallet getIndexOfActiveAccount:i]]];
                }
            }
            
            // Then show the HD accounts with a zero balance
            for (int i = 0; i < app.wallet.getActiveAccountsCount; i++) {
                if (!([app.wallet getBalanceForAccount:[app.wallet getIndexOfActiveAccount:i]] > 0)) {
                    [accounts addObject:[NSNumber numberWithInt:i]];
                    [accountLabels addObject:[_wallet getLabelForAccount:[app.wallet getIndexOfActiveAccount:i]]];
                }
            }
            
            // Then show user's active legacy addresses with a positive balance
            if (![self accountsOnly]) {
                for (NSString * addr in _wallet.activeLegacyAddresses) {
                    if ([_wallet getLegacyAddressBalance:addr] > 0) {
                        [legacyAddresses addObject:addr];
                        [legacyAddressLabels addObject:[_wallet labelForLegacyAddress:addr]];
                    }
                }
            
            // Then show the active legacy addresses with a zero balance
                for (NSString * addr in _wallet.activeLegacyAddresses) {
                    if (!([_wallet getLegacyAddressBalance:addr] > 0)) {
                        [legacyAddresses addObject:addr];
                        [legacyAddressLabels addObject:[_wallet labelForLegacyAddress:addr]];
                    }
                }
            }
            
            addressBookSectionNumber = -1;
            contactsSectionNumber = contacts.count > 0 ? 0 : -1;
            accountsSectionNumber = contactsSectionNumber + 1;
            legacyAddressesSectionNumber = (legacyAddresses.count > 0) ? accountsSectionNumber + 1 : -1;
        }
        // Select to address
        else {
            
            // Show contacts
            if (selectMode != SelectModeReceiveFromContact) {
                for (Contact *contact in [_wallet.contacts allValues]) {
                    [contacts addObject:contact];
                }
            }
            
            if (selectMode != SelectModeContact) {
                // Show the address book
                for (NSString * addr in [_wallet.addressBook allKeys]) {
                    [addressBookAddresses addObject:addr];
                    [addressBookAddressLabels addObject:[app.sendViewController labelForLegacyAddress:addr]];
                }
                
                // Then show the HD accounts
                for (int i = 0; i < app.wallet.getActiveAccountsCount; i++) {
                    [accounts addObject:[NSNumber numberWithInt:i]];
                    [accountLabels addObject:[_wallet getLabelForAccount:[app.wallet getIndexOfActiveAccount:i]]];
                }
                
                // Finally show all the user's active legacy addresses
                if (![self accountsOnly]) {
                    for (NSString * addr in _wallet.activeLegacyAddresses) {
                        [legacyAddresses addObject:addr];
                        [legacyAddressLabels addObject:[_wallet labelForLegacyAddress:addr]];
                    }
                }
            }
            
            contactsSectionNumber = contacts.count > 0 ? 0 : -1;
            accountsSectionNumber = contactsSectionNumber + 1;
            legacyAddressesSectionNumber = (legacyAddresses.count > 0) ? accountsSectionNumber + 1 : -1;
            if (addressBookAddresses.count > 0) {
                addressBookSectionNumber = (legacyAddressesSectionNumber > 0) ? legacyAddressesSectionNumber + 1 : accountsSectionNumber + 1;
            } else {
                addressBookSectionNumber = -1;
            }
        }
        
        [self addSubview:mainView];
        
        mainView.frame = CGRectMake(0, 0, app.window.frame.size.width, app.window.frame.size.height);
        
        [tableView layoutIfNeeded];
        float tableHeight = [tableView contentSize].height;
        float tableSpace = mainView.frame.size.height - DEFAULT_HEADER_HEIGHT;
        
        CGRect frame = tableView.frame;
        frame.size.height = tableSpace;
        tableView.frame = frame;
        
        // Disable scrolling if table content fits on screen
        if (tableHeight < tableSpace) {
            tableView.scrollEnabled = NO;
        }
        else {
            tableView.scrollEnabled = YES;
        }
        
        tableView.backgroundColor = COLOR_TABLE_VIEW_BACKGROUND_LIGHT_GRAY;
        
        if (selectMode == SelectModeContact && contacts.count == 0) {
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, mainView.frame.size.width - 50, 40)];
            label.textColor = COLOR_TEXT_DARK_GRAY;
            label.textAlignment = NSTextAlignmentCenter;
            label.font = [UIFont fontWithName:FONT_MONTSERRAT_REGULAR size:14];
            label.text = BC_STRING_NO_CONTACTS_YET_TITLE;
            [self addSubview:label];
            label.center = CGPointMake(mainView.center.x, mainView.center.y - DEFAULT_HEADER_HEIGHT);
        }
    }
    return self;
}

- (BOOL)showFromAddresses
{
    return selectMode == SelectModeReceiveTo || selectMode == SelectModeSendFrom || selectMode == SelectModeTransferTo || selectMode == SelectModeFilter;
}

- (BOOL)accountsOnly
{
    return selectMode == SelectModeTransferTo || selectMode == SelectModeReceiveFromContact;
}

- (BOOL)allSelectable
{
    return selectMode == SelectModeReceiveTo || selectMode == SelectModeSendTo || selectMode == SelectModeTransferTo || selectMode == SelectModeFilter || selectMode == SelectModeReceiveFromContact;
}

- (void)tableView:(UITableView *)_tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    BOOL shouldCloseModal = YES;
    
    if ([self showFromAddresses]) {
        if (indexPath.section == accountsSectionNumber) {
            if (selectMode == SelectModeFilter) {
                if (indexPath.row == 0) {
                    [delegate didSelectFromAccount:FILTER_INDEX_ALL];
                } else if (accounts.count == indexPath.row - 1) {
                    [delegate didSelectFromAccount:FILTER_INDEX_IMPORTED_ADDRESSES];
                } else {
                    [delegate didSelectFromAccount:[app.wallet getIndexOfActiveAccount:[[accounts objectAtIndex:indexPath.row - 1] intValue]]];

                }
            } else {
                [delegate didSelectFromAccount:[app.wallet getIndexOfActiveAccount:[[accounts objectAtIndex:indexPath.row] intValue]]];
            }
        }
        else if (indexPath.section == legacyAddressesSectionNumber) {
            
            NSString *legacyAddress = [legacyAddresses objectAtIndex:[indexPath row]];
            
            if ([self allSelectable] &&
                [app.wallet isWatchOnlyLegacyAddress:legacyAddress] &&
                ![[NSUserDefaults standardUserDefaults] boolForKey:USER_DEFAULTS_KEY_HIDE_WATCH_ONLY_RECEIVE_WARNING]) {
                if ([delegate respondsToSelector:@selector(didSelectWatchOnlyAddress:)]) {
                    [delegate didSelectWatchOnlyAddress:legacyAddress];
                    [_tableView deselectRowAtIndexPath:indexPath animated:YES];
                    shouldCloseModal = NO;
                } else {
                    [delegate didSelectFromAddress:legacyAddress];
                }
            } else {
                [delegate didSelectFromAddress:legacyAddress];
            }
        }
    }
    else {
        if (indexPath.section == addressBookSectionNumber) {
            [delegate didSelectToAddress:[addressBookAddresses objectAtIndex:[indexPath row]]];
        }
        else if (indexPath.section == accountsSectionNumber) {
            [delegate didSelectToAccount:[app.wallet getIndexOfActiveAccount:(int)indexPath.row]];
        }
        else if (indexPath.section == legacyAddressesSectionNumber) {
            [delegate didSelectToAddress:[legacyAddresses objectAtIndex:[indexPath row]]];
        }
        else if (indexPath.section == contactsSectionNumber) {
            [delegate didSelectContact:[contacts objectAtIndex:[indexPath row]]];
            [tableView deselectRowAtIndexPath:indexPath animated:YES];
        }
    }
    
    if (shouldCloseModal && !app.topViewControllerDelegate) {
        [app closeModalWithTransition:kCATransitionFromLeft];
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if ([self showFromAddresses]) {
        return  (accounts.count > 0 ? 1 : 0) + (legacyAddresses.count > 0 && selectMode != SelectModeFilter ? 1 : 0);
    }
    
    return (addressBookAddresses.count > 0 ? 1 : 0) + (accounts.count > 0 ? 1 : 0) + (legacyAddresses.count > 0 ? 1 : 0) + (contacts.count > 0 ? 1 : 0);
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, mainView.frame.size.width, 45)];
    view.backgroundColor = COLOR_TABLE_VIEW_BACKGROUND_LIGHT_GRAY;
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(20, 12, mainView.frame.size.width, 30)];
    label.textColor = COLOR_BLOCKCHAIN_BLUE;
    label.font = [UIFont fontWithName:FONT_MONTSERRAT_REGULAR size:FONT_SIZE_SMALL_MEDIUM];
    
    [view addSubview:label];
    
    NSString *labelString;
    
    if ([self showFromAddresses]) {
        if (section == accountsSectionNumber) {
            labelString = selectMode == SelectModeFilter ? @"" : BC_STRING_WALLETS;
        }
        else if (section == legacyAddressesSectionNumber) {
            labelString = BC_STRING_IMPORTED_ADDRESSES;
        }
        else if (section == contactsSectionNumber) {
            labelString = BC_STRING_CONTACTS;
        }
    }
    else {
        if (section == addressBookSectionNumber) {
            labelString = BC_STRING_ADDRESS_BOOK;
        }
        else if (section == accountsSectionNumber) {
            labelString = BC_STRING_WALLETS;
        }
        else if (section == legacyAddressesSectionNumber) {
            labelString = BC_STRING_IMPORTED_ADDRESSES;
        }
        else if (section == contactsSectionNumber) {
            labelString = BC_STRING_CONTACTS;
        }
    }
    
    label.text = labelString;
    
    return view;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if ([self showFromAddresses]) {
        if (section == accountsSectionNumber) {
            if (selectMode == SelectModeFilter) {
                if (legacyAddresses.count > 0) {
                    return accounts.count + 2;
                } else {
                    return accounts.count + 1;
                }
            } else {
                return accounts.count;
            }
        }
        else if (section == legacyAddressesSectionNumber) {
            return legacyAddresses.count;
        }
        else if (section == contactsSectionNumber) {
            return contacts.count;
        }
    }
    else {
        if (section == addressBookSectionNumber) {
            return addressBookAddresses.count;
        }
        else if (section == accountsSectionNumber) {
            return accounts.count;
        }
        else if (section == legacyAddressesSectionNumber) {
            return legacyAddresses.count;
        }
        else if (section == contactsSectionNumber) {
            return contacts.count;
        }
    }
    
    assert(false); // Should never get here
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 45.0f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == accountsSectionNumber || indexPath.section == contactsSectionNumber) {
        return ROW_HEIGHT_ACCOUNT;
    }
    
    return ROW_HEIGHT;
}

- (UITableViewCell *)tableView:(UITableView *)_tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    int section = (int) indexPath.section;
    int row = (int) indexPath.row;
    
    ReceiveTableCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ReceiveCell"];
    
    if (cell == nil) {
        cell = [[[NSBundle mainBundle] loadNibNamed:@"ReceiveCell" owner:nil options:nil] objectAtIndex:0];
        cell.backgroundColor = [UIColor whiteColor];
        
        NSString *label;
        if (section == addressBookSectionNumber) {
            label = [addressBookAddressLabels objectAtIndex:row];
            cell.addressLabel.text = [addressBookAddresses objectAtIndex:row];
        }
        else if (section == accountsSectionNumber) {
            
            if (selectMode == SelectModeFilter) {
                if (accounts.count == row - 1) {
                    label = BC_STRING_IMPORTED_ADDRESSES;
                } else if (row == 0) {
                    label = BC_STRING_TOTAL_BALANCE;
                } else {
                    label = accountLabels[indexPath.row - 1];
                }
            } else {
                label = accountLabels[indexPath.row];
            }
            
            cell.addressLabel.text = nil;
        }
        else if (section == legacyAddressesSectionNumber) {
            label = [legacyAddressLabels objectAtIndex:row];
            cell.addressLabel.text = [legacyAddresses objectAtIndex:row];
        }
        else if (section == contactsSectionNumber) {
            Contact *contact = [contacts objectAtIndex:row];
            cell.addressLabel.text = nil;
            cell.tintColor = COLOR_BLOCKCHAIN_LIGHT_BLUE;
            cell.accessoryType = contact == self.previouslySelectedContact ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
            if (contact.mdid) {
                label = contact.name;
                cell.userInteractionEnabled = YES;
                cell.labelLabel.alpha = 1.0;
                cell.addressLabel.alpha = 1.0;
            } else {
                label = [NSString stringWithFormat:@"%@ (%@)", contact.name, BC_STRING_PENDING];
                cell.userInteractionEnabled = NO;
                cell.labelLabel.alpha = 0.5;
                cell.addressLabel.alpha = 0.5;
            }
        }
        
        if (label)
            cell.labelLabel.text = label;
        else
            cell.labelLabel.text = BC_STRING_NO_LABEL;
        
        NSString *addr = cell.addressLabel.text;
        Boolean isWatchOnlyLegacyAddress = false;
        if (addr) {
            isWatchOnlyLegacyAddress = [app.wallet isWatchOnlyLegacyAddress:addr];
        }
        
        if ([self showFromAddresses]) {
            uint64_t balance = 0;
            if (section == addressBookSectionNumber) {
                balance = [app.wallet getLegacyAddressBalance:[addressBookAddresses objectAtIndex:row]];
            }
            else if (section == accountsSectionNumber) {
                if (selectMode == SelectModeFilter) {
                    if (accounts.count == row - 1) {
                        balance = [app.wallet getTotalBalanceForActiveLegacyAddresses];
                    } else if (row == 0) {
                        balance = [app.wallet getTotalActiveBalance];
                    } else {
                        balance = [app.wallet getBalanceForAccount:[app.wallet getIndexOfActiveAccount:[[accounts objectAtIndex:indexPath.row - 1] intValue]]];
                    }
                } else {
                    balance = [app.wallet getBalanceForAccount:[app.wallet getIndexOfActiveAccount:[[accounts objectAtIndex:indexPath.row] intValue]]];
                }
            }
            else if (section == legacyAddressesSectionNumber) {
                balance = [app.wallet getLegacyAddressBalance:[legacyAddresses objectAtIndex:row]];
            }
            cell.balanceLabel.text = [NSNumberFormatter formatMoney:balance];
            
            // Cells with empty balance can't be clicked and are dimmed
            if (balance == 0 && ![self allSelectable]) {
                cell.userInteractionEnabled = NO;
                cell.labelLabel.alpha = 0.5;
                cell.addressLabel.alpha = 0.5;
            } else {
                cell.userInteractionEnabled = YES;
                cell.labelLabel.alpha = 1.0;
                cell.addressLabel.alpha = 1.0;
            }
        }
        else {
            cell.balanceLabel.text = nil;
        }
        
        if (isWatchOnlyLegacyAddress) {
            // Show the watch only tag and resize the label and balance labels so there is enough space
            cell.labelLabel.frame = CGRectMake(20, 11, 148, 21);
            cell.balanceLabel.frame = CGRectMake(254, 11, 83, 21);
            cell.watchLabel.hidden = NO;
            
        } else {
            cell.labelLabel.frame = CGRectMake(20, 11, 185, 21);
            cell.balanceLabel.frame = CGRectMake(217, 11, 120, 21);
            cell.watchLabel.hidden = YES;
        }
        
        [cell layoutSubviews];
        
        // Disable user interaction on the balance button so the hit area is the full width of the table entry
        [cell.balanceButton setUserInteractionEnabled:NO];
        
        cell.balanceLabel.adjustsFontSizeToFitWidth = YES;
        
        // Selected cell color
        UIView *v = [[UIView alloc] initWithFrame:CGRectMake(0,0,cell.frame.size.width,cell.frame.size.height)];
        [v setBackgroundColor:COLOR_BLOCKCHAIN_BLUE];
        [cell setSelectedBackgroundView:v];
    }
    
    return cell;
}

- (void)reloadTableView
{
    [tableView reloadData];
}

@end
