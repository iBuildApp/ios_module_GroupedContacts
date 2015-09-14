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

#import "mDetails.h"
#import "mMultiContacts.h"
#import "functionLibrary.h"
#import "NSString+colorizer.h"
#import "UIColor+HSL.h"
#import <SDWebImage/UIImageView+WebCache.h>

@interface mDetails()

@property(nonatomic, assign) BOOL tabBarIsHidden;
@property (nonatomic, strong) UITableView         *tableView;

@end

@implementation mDetails

@synthesize details;
@synthesize showLink;
@synthesize szBackImgView = _szBackImgView;
@synthesize contactAvatar;
@synthesize shareEMail;
@synthesize shareSMS;
@synthesize addContact;
@synthesize inet;
@synthesize showTabBar, tabBarIsHidden;

@synthesize mMCColorOfBackground;
@synthesize mMCColorOfText;

@synthesize hasColorskin;

#pragma mark -
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
  self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
  if (self)
  {
    _szBackImgView              = nil;
    self.contactAvatar          = nil;
    self.showTabBar             = YES;  // show TabBar by default
    self.tabBarIsHidden         = NO;
    
    self.mMCColorOfBackground   = nil;
    self.mMCColorOfText         = nil;
    self.hasColorskin           = NO;
  }
  return self;
}

- (void)dealloc
{
  self.szBackImgView = nil;
  self.contactAvatar = nil;
  
  self.mMCColorOfBackground = nil;
  self.mMCColorOfText = nil;
  
  self.tableView = nil;
  
  [super dealloc];
}

#pragma mark - View Lifecycle

- (void)viewWillAppear:(BOOL)animated
{
  if ( addContact || shareEMail || shareSMS )
  {
    UIBarButtonItem *actionButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction
                                                                                  target:self
                                                                                  action:@selector(showActionSelector)];
    self.navigationItem.rightBarButtonItem = actionButton;
    
    [actionButton release];
  }
  
  [super viewWillAppear:animated];
    // before hiding / displaying tabBar we must remember its previous state
  self.tabBarIsHidden = [[self.tabBarController tabBar] isHidden];
  [[self.tabBarController tabBar] setHidden:!self.showTabBar];
  
#ifdef __IPHONE_7_0
  
  if ([self.tableView respondsToSelector:@selector(setSeparatorInset:)])
    [self.tableView setSeparatorInset:UIEdgeInsetsZero];
  
  if ([self.tableView respondsToSelector:@selector(setLayoutMargins:)])
    [self.tableView setLayoutMargins:UIEdgeInsetsZero];
  
#endif
  
  self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
  
  UIImageView *backImgView = nil;

  backImgView = [[[UIImageView alloc] init] autorelease];
  backImgView.backgroundColor = self.mMCColorOfBackground;
  
  [backImgView setFrame:[self.tableView bounds]];
  self.tableView.backgroundView = backImgView;
  
  self.view.backgroundColor = self.mMCColorOfBackground;
  
  if ( self.contactAvatar )
  {
    UIView *avatarView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 320.0f, 120.0f)];
    avatarView.backgroundColor = [UIColor clearColor];
    self.tableView.tableHeaderView = avatarView;

      // Create container for a picture, because it is impossible to set a shadow for picture.
      // So we make shadow for container :)
    
    CGFloat cornerRadius = 5.0;
    UIView *container = [[[UIView alloc] initWithFrame:CGRectMake(110.0f, 10.0f, 100.0f, 100.0f)] autorelease];
    container.layer.shadowOffset = CGSizeMake(3, 3);
    container.layer.shadowOpacity = 0.5;
    container.layer.shadowRadius = cornerRadius;
    container.layer.shadowColor = [UIColor blackColor].CGColor;
    container.layer.shadowPath = [[UIBezierPath bezierPathWithRoundedRect:container.bounds cornerRadius:cornerRadius] CGPath];
    
    UIImageView *avatar = [[[UIImageView alloc] initWithFrame:container.bounds] autorelease];
    
    NSString *szAvatarURL = self.contactAvatar;
    szAvatarURL = [szAvatarURL stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    szAvatarURL = [szAvatarURL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    [avatar setImageWithURL:[NSURL URLWithString:szAvatarURL]
           placeholderImage:[UIImage imageNamed:resourceFromBundle(@"mContacts_contact")]];
    
    avatar.layer.cornerRadius = 10.0f;
    avatar.layer.masksToBounds = YES;
    avatar.layer.borderColor = [UIColor lightGrayColor].CGColor;
    avatar.layer.borderWidth = 1.0f;
    
    avatar.contentMode = UIViewContentModeScaleAspectFill;
    
    [avatarView addSubview:container];
    [container addSubview:avatar];
    [self.tableView addSubview:avatarView];
    [avatarView release];
	}
}

- (void)viewWillDisappear:(BOOL)animated
{
  [super viewWillDisappear:animated];
    // restore tabBar state
  [[self.tabBarController tabBar] setHidden:self.tabBarIsHidden];
}


- (void)viewDidLoad
{
  [self.navigationItem setHidesBackButton:NO animated:NO];
  [self.navigationController setNavigationBarHidden:NO animated:NO];
  
  self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
  
  CGRect frame = CGRectMake(10, 0, self.view.frame.size.width - 20, self.view.frame.size.height);
  
  self.tableView = [[[UITableView alloc] initWithFrame:frame style:UITableViewStyleGrouped] autorelease];
  
  self.tableView.delegate = self;
  self.tableView.dataSource = self;
  
  self.tableView.backgroundColor = [UIColor clearColor];
  self.tableView.autoresizesSubviews = NO;
  self.tableView.autoresizingMask    = UIViewAutoresizingFlexibleHeight;
  
  self.tableView.tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, 20.f)];
  
  [self.view addSubview:self.tableView];
  
  [super viewDidLoad];
}


#pragma mark -
- (void)showActionSelector
{
	UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                           delegate:self
                                                  cancelButtonTitle:nil
                                             destructiveButtonTitle:nil
                                                  otherButtonTitles:nil];
  
  if (addContact)
    [actionSheet addButtonWithTitle:NSBundleLocalizedString(@"mMC_addContactButton", @"Add Contact to Address Book")];
  
	if (shareEMail)
    [actionSheet addButtonWithTitle:NSBundleLocalizedString(@"mMC_addShareEmailButton", @"Share Contact via Email")];
  
	if (shareSMS)
    [actionSheet addButtonWithTitle:NSBundleLocalizedString(@"mMC_addShareSMSButton", @"Share Contact via SMS")];
	
  if (actionSheet.numberOfButtons > 0)
  {
    actionSheet.destructiveButtonIndex = [actionSheet addButtonWithTitle:NSBundleLocalizedString(@"mMC_addShareCancelButton", @"Cancel")];
    [actionSheet showInView:(self.tabBarController ? self.tabBarController.view : self.navigationController.view )];
  }
  
  [actionSheet release];
}


- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
  NSString *buttonTitle=[actionSheet buttonTitleAtIndex:buttonIndex];
  NSString *messageText = [[NSString stringWithFormat:@"%@: ", NSBundleLocalizedString(@"mMC_messageNameString", @"Name")] stringByAppendingString:(((NSString *)[details objectForKey:@"name"]).length) ? [details objectForKey:@"name"] : @"-"];
  
  if (((NSString *)[details objectForKey:@"phone"]).length)
    messageText = [messageText stringByAppendingString: [[NSString stringWithFormat:@"\n<br />%@: ", NSBundleLocalizedString(@"mMC_messagePhoneString", @"Phone")]  stringByAppendingString:[details objectForKey:@"phone"]]];
  
  if (((NSString *)[details objectForKey:@"email"]).length)
    messageText = [messageText stringByAppendingString: [[NSString stringWithFormat:@"\n<br />%@: ", NSBundleLocalizedString(@"mMC_messageEmailString", @"Email")] stringByAppendingString:[details objectForKey:@"email"]]];
  
  if (((NSString *)[details objectForKey:@"homepage"]).length)
    messageText = [messageText stringByAppendingString: [[NSString stringWithFormat:@"\n<br />%@: ", NSBundleLocalizedString(@"mMC_messageHomepageString", @"Homepage")]  stringByAppendingString:[details objectForKey:@"homepage"]]];
  
  if (((NSString *)[details objectForKey:@"address"]).length)
    messageText = [messageText stringByAppendingString: [[NSString stringWithFormat:@"\n<br />%@: ", NSBundleLocalizedString(@"mMC_messageAddressString", @"Address")] stringByAppendingString:[details objectForKey:@"address"]]];
  
  
	if ([buttonTitle isEqualToString:NSBundleLocalizedString(@"mMC_addContactButton", @"Add Contact to Address Book")])
  {
      // perform adding to contacts after delay: actionSheet should have time to disappear: task #4781
    
    SEL addContactSelector = NSSelectorFromString(@"addContact:withPhone:");
    
    NSString *contactName = (((NSString *)[details objectForKey:@"name"]).length) ? ([details objectForKey:@"name"]) : @"-";
    NSString *phone = [details objectForKey:@"phone"];
    
    NSInvocation *inv = [NSInvocation invocationWithMethodSignature:[self methodSignatureForSelector:addContactSelector]];
    [inv setSelector:addContactSelector];
    [inv setTarget:self];
    
    //arguments 0 and 1 are self and _cmd respectively, automatically set by NSInvocation
    [inv setArgument:&contactName atIndex:2];
    [inv setArgument:&phone atIndex:3];

    [inv performSelector:@selector(invoke) withObject:nil afterDelay:1];
    
    return;
  }
  
	if ([buttonTitle isEqualToString:NSBundleLocalizedString(@"mMC_addShareEmailButton", @"Share Contact via Email")])
    [functionLibrary callMailComposerWithRecipients:nil
                                         andSubject:NSBundleLocalizedString(@"mMC_messageSubject", @"Contact info")
                                            andBody:messageText
                                             asHTML:YES
                                     withAttachment:nil
                                           mimeType:@""
                                           fileName:@""
                                     fromController:self
                                           showLink:showLink];
  
	if ([buttonTitle isEqualToString:NSBundleLocalizedString(@"mMC_addShareSMSButton", @"Share Contact via SMS")])
    [functionLibrary callSMSComposerWithRecipients:nil
                                           andBody:messageText
                                    fromController:self];
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
  if (buttonIndex == 1)
  {
    if ( [alertView.message length] )
    {
      [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[[NSString stringWithFormat: @"tel:%@",alertView.message] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
    }
    else
    {
      UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSBundleLocalizedString(@"mMC_emptyPhoneNumberCallTitle", @"Error!")
                                                      message:NSBundleLocalizedString(@"mMC_emptyPhoneNumberCallMessage", @"Empty phone number!")
                                                     delegate:nil
                                            cancelButtonTitle:NSBundleLocalizedString(@"mMC_emptyPhoneNumberCallOkButtonTitle", @"OK")
                                            otherButtonTitles:nil];
      [alert show];
      [alert release];
    }
    
  }
  else if (buttonIndex == 2)
  {
    if ( [alertView.message length] )
    {
      NSString *contactName = (((NSString *)[details objectForKey:@"name"]).length) ?([details objectForKey:@"name"]) : @"-";
      
      [self addContact:contactName
             withPhone:alertView.message];

    }
    else
    {
      UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSBundleLocalizedString(@"mMC_emptyPhoneNumberAddTitle", @"Error!")
                                                      message:NSBundleLocalizedString(@"mMC_emptyPhoneNumberAddMessage", @"Can not add contact without phone number!")
                                                     delegate:nil
                                            cancelButtonTitle:NSBundleLocalizedString(@"mMC_emptyPhoneNumberAddOkButtonTitle", @"OK")
                                            otherButtonTitles:nil];
      [alert show];
      [alert release];
    }
  }
}


- (void)addContact:(NSString *)contactName withPhone:(NSString *)phone
{
  if (!contactName || !phone)
  {
    NSLog(@"addContact: incorrect data");
    return;
  }
  
  [functionLibrary addContact:contactName
                    withPhone:phone];
}



#pragma mark - UITableView delegate & datasource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
  return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
  return [[details objectForKey:@"x_array"] count];
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
  UIImage *cellBGImage = nil;
  
  if ([[details objectForKey:@"x_array"] count] == 1)
  {
    cellBGImage = [UIImage imageNamed:([self.mMCColorOfBackground isLight] ? resourceFromBundle(@"mContacts_TableRowSingleLight.png") : resourceFromBundle(@"mContacts_TableRowSingle.png"))];
  }
  else
  {
      // first cell
    if (indexPath.row == 0)
    {
      cellBGImage = [UIImage imageNamed:([self.mMCColorOfBackground isLight] ? resourceFromBundle(@"mContacts_TableRowFirstLight.png") : resourceFromBundle(@"mContacts_TableRowFirst.png"))];
      
    } // last cell
    else if (indexPath.row == [tableView numberOfRowsInSection:indexPath.section] - 1) {
      cellBGImage = [UIImage imageNamed:([self.mMCColorOfBackground isLight] ? resourceFromBundle(@"mContacts_TableRowLastLight.png") : resourceFromBundle(@"mContacts_TableRowLast.png"))];
      
    } // middle cells
    else
    {
      cellBGImage = [UIImage imageNamed:([self.mMCColorOfBackground isLight] ? resourceFromBundle(@"mContacts_TableRowMiddleLight.png") : resourceFromBundle(@"mContacts_TableRowMiddle.png"))];
    }
  }
  
  float w = cellBGImage.size.width / 2, h = cellBGImage.size.height / 2;
  UIImage *stretchedImage = [cellBGImage stretchableImageWithLeftCapWidth:w topCapHeight:h];
  
  UIImageView *cellTranslucentView = [[[UIImageView alloc] initWithFrame:CGRectMake(0, 0, cell.contentView.bounds.size.width - 20.0f, cell.contentView.bounds.size.height)] autorelease];
  cellTranslucentView.image = stretchedImage;
  
  [cell setBackgroundView:cellTranslucentView];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
  static NSString *Cell_ID = @"Cell";
  
  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:Cell_ID];
  if (cell == nil)
  {
    cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:Cell_ID] autorelease];
    
    cell.backgroundColor = [UIColor clearColor];
    cell.textLabel.backgroundColor = [UIColor clearColor];
    cell.detailTextLabel.backgroundColor = [UIColor clearColor];
    cell.textLabel.textColor = self.mMCColorOfText;
    
  }
  
  if (indexPath.row == 0)
  {
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.imageView.image = [UIImage imageNamed:resourceFromBundle(@"mContacts_contact.png")];
    cell.textLabel.font = [UIFont systemFontOfSize:18.0f];
    
    cell.indentationLevel = 1;
    cell.indentationWidth = 5.0f;
  }
  else
  {
    cell.imageView.image = [UIImage imageNamed:[resourceFromBundle(@"mContacts_") stringByAppendingString:[[[[details objectForKey:@"x_array"] objectAtIndex:indexPath.row] objectForKey:@"title"] stringByAppendingString:@".png"]]];

    cell.accessoryView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:([self.mMCColorOfBackground isLight] ? resourceFromBundle(@"mContacts_ArrowLight.png") : resourceFromBundle(@"mContacts_Arrow.png"))]] autorelease];
    cell.textLabel.font = [UIFont systemFontOfSize:16.0f];
  }
  
  cell.textLabel.text = [[[details objectForKey:@"x_array"] objectAtIndex:indexPath.row] objectForKey:@"description"];
  cell.textLabel.font = [UIFont systemFontOfSize:18.0f];
  
  cell.indentationLevel = 1;
  cell.indentationWidth = 5.0f;
  
  return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
  UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
  
  if (indexPath.row == 0)
  {
    [cell setSelected:NO];
  }
  else
  {
    if ([[[[details objectForKey:@"x_array"] objectAtIndex:indexPath.row] objectForKey:@"title"] isEqualToString:@"phone"])
    {
      UIAlertView *callRequest = [[UIAlertView alloc] initWithTitle:@""
                                                            message:[[[details objectForKey:@"x_array"] objectAtIndex:indexPath.row] objectForKey:@"description"]
                                                           delegate:self
                                                  cancelButtonTitle:NSBundleLocalizedString(@"mMC_selectActionCancel", @"Cancel")
                                                  otherButtonTitles:NSBundleLocalizedString(@"mMC_selectActionCall", @"Call"), NSBundleLocalizedString(@"mMC_selectActionAdd", @"Add to Contacts"), nil];
      [callRequest show];
      [callRequest release];
      [tableView deselectRowAtIndexPath:indexPath animated:YES];
    }
    
    if ([[[[details objectForKey:@"x_array"] objectAtIndex:indexPath.row] objectForKey:@"title"] isEqualToString:@"email"])
    {
      NSArray *recipients = [[NSArray alloc] initWithObjects:[[[[details objectForKey:@"x_array"] objectAtIndex:indexPath.row] objectForKey:@"description"] stringByReplacingOccurrencesOfString:@"mailto:" withString:@""], nil];
      
      [functionLibrary callMailComposerWithRecipients:recipients
                                           andSubject:@""
                                              andBody:@""
                                               asHTML:YES
                                       withAttachment:nil
                                             mimeType:@""
                                             fileName:@""
                                       fromController:self
                                             showLink:showLink];
      [recipients release];
      
    }
    if ([[[[details objectForKey:@"x_array"] objectAtIndex:indexPath.row] objectForKey:@"title"] isEqualToString:@"homepage"])
    {
      mWebVCViewController *homePageVC = [[[mWebVCViewController alloc] initWithNibName:nil bundle:nil] autorelease];
      homePageVC.URL        = [[[details objectForKey:@"x_array"] objectAtIndex:indexPath.row] objectForKey:@"description"];
      homePageVC.title      = NSBundleLocalizedString(@"mMC_homePageTitle", @"Homepage");
      homePageVC.showTabBar = NO;
      homePageVC.scalable   = YES;
      [self.navigationController pushViewController:homePageVC animated:YES];
    }
    
    if ([[[[details objectForKey:@"x_array"] objectAtIndex:indexPath.row] objectForKey:@"title"] isEqualToString:@"address"])
    {
      NSDictionary *addressResponse = [functionLibrary coordinatesForAddress:[[[[details objectForKey:@"x_array"] objectAtIndex:indexPath.row]
                                                                               objectForKey:@"description"] stringByReplacingOccurrencesOfString:@" " withString:@"+"]];
      
      if ([[addressResponse objectForKey:@"status"] isEqual:@"OK"])
      {
        NSMutableArray *mapPoints = [NSMutableArray array];
        NSMutableDictionary *pin = [NSMutableDictionary dictionary];
        
        ([details objectForKey:@"name"]) ? ([pin setObject:[details objectForKey:@"name"] forKey:@"title"]) : ([pin setObject:@"-" forKey:@"title"]);
        
        if ([details objectForKey:@"phone"])
          [pin setObject:[[[details objectForKey:@"phone"] stringByAppendingString:@"<br />"] stringByAppendingString:[details objectForKey:@"address"]] forKey:@"subtitle"];
        
        if ([addressResponse objectForKey:@"latitude"])
          [pin setObject:[addressResponse objectForKey:@"latitude"]  forKey:@"latitude"];
        
        if ([addressResponse objectForKey:@"longitude"])
          [pin setObject:[addressResponse objectForKey:@"longitude"] forKey:@"longitude"];
        
        if ([details objectForKey:@"homepage"])
          [pin setObject:[details objectForKey:@"homepage"] forKey:@"description"];
        
        [mapPoints addObject:pin];
        
        mMapViewController *mapVC = [[[mMapViewController alloc] init] autorelease];
        mapVC.mapPoints = mapPoints;
        mapVC.title = NSBundleLocalizedString(@"mMC_addressPageTitle", @"Address");
        [self.navigationController pushViewController:mapVC animated:YES];
      }
      else
      {
        mAddressDetails *mAD = [[[mAddressDetails alloc] init] autorelease];
        mAD.addressDetails = [[[details objectForKey:@"x_array"] objectAtIndex:indexPath.row] objectForKey:@"description"];
        mAD.szBackImgView = self.szBackImgView;
        mAD.mMCColorOfBackground = self.mMCColorOfBackground;
        mAD.mMCColorOfText = self.mMCColorOfText;
        mAD.hasColorskin = self.hasColorskin;
        [self.navigationController pushViewController:mAD animated:YES];
      }
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
  }
}

#pragma mark - MFMessageComposeViewControllerDelegate

- (void)messageComposeViewController:(MFMessageComposeViewController *)controller
                 didFinishWithResult:(MessageComposeResult)result
{
  [self dismissModalViewControllerAnimated:YES];
}

#pragma mark - MFMailComposeViewControllerDelegate

- (void)mailComposeController:(MFMailComposeViewController *)controller
         didFinishWithResult:(MFMailComposeResult)result
                       error:(NSError *)error
{
  [self dismissModalViewControllerAnimated:YES];
}

#pragma mark - Interface orientation handling

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
  return UIInterfaceOrientationIsPortrait(interfaceOrientation);
}

- (BOOL)shouldAutorotate
{
  return YES;
}

- (NSUInteger)supportedInterfaceOrientations
{
  return UIInterfaceOrientationMaskPortrait | UIInterfaceOrientationMaskPortraitUpsideDown;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
  return UIInterfaceOrientationPortrait;
}


@end