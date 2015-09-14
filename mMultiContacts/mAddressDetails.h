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

/**
 *  ViewController for address details page (module mMultiContacts)
 */
@interface mAddressDetails : UIViewController <UITableViewDataSource,
                                                UITableViewDelegate>

/**
 *  Address details
 */
@property (nonatomic, copy  ) NSString *addressDetails;

/**
 *  Background image URL
 */
@property (nonatomic, strong) NSString *szBackImgView;

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