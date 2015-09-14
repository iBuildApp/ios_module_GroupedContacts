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

#import <UIKit/UIKit.h>
#import "mMap.h"
#import "mWebVC.h"
#import "mAddressDetails.h"

/**
 *  ViewController for detail page of contact
 */
@interface mDetails : UIViewController <UITableViewDataSource,
                                            UITableViewDelegate,
                                            UIActionSheetDelegate,
                                            MFMessageComposeViewControllerDelegate,
                                            MFMailComposeViewControllerDelegate>
{
  NSMutableArray *lDetails;
}

/**
 *  Dictionary with contact details
 */
@property (nonatomic, retain) NSMutableDictionary *details;

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
 *  Show or hide tabBar on view appear and disappear
 */
@property (nonatomic, assign) BOOL showTabBar;

/**
 *  Back imageView image URL
 */
@property (nonatomic, strong) NSString *szBackImgView;

/**
 *  Contact avatar URL
 */
@property (nonatomic, strong) NSString *contactAvatar;

/**
 *  Presence or absence of network
 */
@property BOOL inet;

/**
 *  Background color
 */
@property (nonatomic, retain) UIColor *mMCColorOfBackground;

/**
 *  Text color
 */
@property (nonatomic, retain) UIColor *mMCColorOfText;

/**
 *  Is there colorskin or not
 */
@property BOOL hasColorskin;

@end