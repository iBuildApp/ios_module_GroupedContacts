/****************************************************************************
 *                                                                           *
 *  Copyright (C) 2014-2015 iBuildApp, Inc. ( http://ibuildapp.com )         *
 *                                                                           *
 *  This file is part of iBuildApp.                                          *
 *                                                                           *
 *  This Source Code Form is subject to the terms of the iBuildApp License.  *
 *  You can obtain one at http://ibuildapp.com/license/                      *
 *                                                                           *
 ****************************************************************************/

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "mCategories.h"
#import "mContacts.h"
#import "mDetails.h"

/**
 *  Main module class for widget Contacts. Module entry point. Represents modules Contacts, Multicontacts, Grouped contacts
 */
@interface mMultiContactsViewController : UIViewController

/**
 *  Array of contacts info
 */
@property (nonatomic, copy  ) NSArray  *array;

/**
 *  Add link to ibuildapp.com to sharing messages
 */
@property (nonatomic, assign) BOOL showLink;

/**
 *  Allow sharing via Email
 */
@property (nonatomic, assign) BOOL shareEMail;

/**
 *  Allow sharing via SMS
 */
@property (nonatomic, assign) BOOL shareSMS;

/**
 *  Allow adding contacts to AddressBook
 */
@property (nonatomic, assign) BOOL addContact;

/**
 *  Contact avatar URL
 */
@property (nonatomic, retain) NSString *contactAvatar;

/**
 *  Background color
 */
@property (nonatomic, retain) UIColor *mMCColorOfBackground;

/**
 *  Text color
 */
@property (nonatomic, retain) UIColor *mMCColorOfText;


/**
 *  ViewController for categories
 */
@property (nonatomic, strong) mCategoriesViewController *categoriesViewController;

/**
 *  ViewController for contacts
 */
@property (nonatomic, strong) mContactsViewController *contactsViewController;

/**
 *  ViewController for details
 */
@property (nonatomic, strong) mDetails *detailsViewController;

@end

