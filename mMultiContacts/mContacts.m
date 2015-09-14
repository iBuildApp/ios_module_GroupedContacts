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

#import "mContacts.h"
#import "functionLibrary.h"
#import "TBXML.h"
#import "NSString+colorizer.h"
#import "UIColor+HSL.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import <UIKit/UIBezierPath.h>


@interface mContactsViewController()

@property (nonatomic, strong) UITableView         *tableView;

@property (nonatomic, strong) NSString            *szBackImgView;

@property (nonatomic, strong) NSMutableArray      *lDetails;
@property (nonatomic, strong) NSMutableDictionary *contact;
@property (nonatomic, strong) UIButton            *shareEMailButton;
@property (nonatomic, strong) UIButton            *shareSMSButton;
@property BOOL hasColorskin;

@end

@implementation mContactsViewController
@synthesize array;
@synthesize showLink;
@synthesize szBackImgView = _szBackImgView;
@synthesize shareEMail;
@synthesize shareSMS;
@synthesize addContact;

@synthesize lDetails = _lDetails,
contact = _contact,
shareEMailButton = _shareEMailButton,
shareSMSButton = _shareSMSButton;

@synthesize mMCColorOfBackground;
@synthesize mMCColorOfText;

@synthesize hasColorskin;

@synthesize category;

#pragma mark -
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
  self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
  if (self)
  {
    _szBackImgView    = nil;
    _lDetails         = nil;
    _contact          = nil;
    _shareEMailButton = nil;
    _shareSMSButton   = nil;
    self.array   = nil;
    self.mMCColorOfBackground = [UIColor colorWithRed:94.0f / 255.0f green:104.0f / 255.0f blue:112.0f / 255.0f alpha:1.0f];
    self.mMCColorOfText = [UIColor colorWithRed:255.0f/255.0f green:190.0f/255.0f blue:106.0f/255.0f alpha:1.0f];
    self.hasColorskin = NO;
    
    self.category = nil;
  }
  return self;
}

-(void)dealloc
{
  self.szBackImgView    = nil;
  self.lDetails         = nil;
  self.contact          = nil;
  self.shareEMailButton = nil;
  self.shareSMSButton   = nil;
  
  self.array       = nil;
  
  self.mMCColorOfBackground = nil;
  self.mMCColorOfText = nil;
  
  self.category = nil;
  
  self.tableView = nil;
  
  [super dealloc];
}


#pragma mark - View Lifecycle
- (void)viewDidLoad
{
  CGRect frame = CGRectMake(10, 0, self.view.frame.size.width - 20, self.view.frame.size.height);
  
  self.tableView = [[[UITableView alloc] initWithFrame:frame style:UITableViewStyleGrouped] autorelease];
  
  self.tableView.delegate = self;
  self.tableView.dataSource = self;
  
  self.tableView.backgroundColor = [UIColor clearColor];
  self.tableView.autoresizesSubviews = NO;
  self.tableView.autoresizingMask    = UIViewAutoresizingFlexibleHeight;
  
  self.tableView.tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, 20.f)];
  
  [self.view addSubview:self.tableView];
  
  
  NSMutableArray *arrTemp = [NSMutableArray new];
  
  for (int i = 0; i < self.array.count; i++)
  {
    NSMutableArray *cPerson = nil;
    
    if ([[self.array objectAtIndex:i] respondsToSelector:@selector(objectAtIndex:)])
    {
      cPerson = [self.array objectAtIndex:i];
    }
    
    if ([[self.array objectAtIndex:i] respondsToSelector:@selector(objectForKey:)])
    {
      cPerson = [[self.array objectAtIndex:i] objectForKey:@"con"];
    }
    
    for(int j = 0; j < cPerson.count; j++)
    {
      if([[[cPerson objectAtIndex:j] objectForKey:@"title"] isEqualToString:@"name"] &&
         [[[cPerson objectAtIndex:j] objectForKey:@"description"] length] > 0)
        [arrTemp addObject:[cPerson copy]];
    }
  }
  
  self.array = arrTemp;
  
  [arrTemp removeAllObjects];
  [arrTemp release];
  
  self.contact  = [NSMutableDictionary dictionary];
  self.lDetails = [NSMutableArray array];
  
  for (int i = 0; i < self.array.count; i++) {
    NSMutableArray *cPerson = [self.array objectAtIndex:i];
    for(int j = 0; j < cPerson.count; j++)
    {
      if([[[cPerson objectAtIndex:j] objectForKey:@"title"] isEqualToString:@"name"] && [[[cPerson objectAtIndex:j] objectForKey:@"description"] length] > 0)
        [self.contact setObject:[[cPerson objectAtIndex:j] objectForKey:@"description"] forKey:@"name"];
      
      if([[[cPerson objectAtIndex:j] objectForKey:@"title"] isEqualToString:@"phone"] && [[[cPerson objectAtIndex:j] objectForKey:@"description"] length] > 0)
        [self.contact setObject:[[cPerson objectAtIndex:j] objectForKey:@"description"] forKey:@"phone"];
      
      if([[[cPerson objectAtIndex:j] objectForKey:@"title"] isEqualToString:@"email"] && [[[cPerson objectAtIndex:j] objectForKey:@"description"] length] > 0)
        [self.contact setObject:[[cPerson objectAtIndex:j] objectForKey:@"description"] forKey:@"email"];
      
      if([[[cPerson objectAtIndex:j] objectForKey:@"title"] isEqualToString:@"homepage"] && [[[cPerson objectAtIndex:j] objectForKey:@"description"] length] > 0)
        [self.contact setObject:[[cPerson objectAtIndex:j] objectForKey:@"description"] forKey:@"homepage"];
      
      if([[[cPerson objectAtIndex:j] objectForKey:@"title"] isEqualToString:@"address"] && [[[cPerson objectAtIndex:j] objectForKey:@"description"] length] > 0)
        [self.contact setObject:[[cPerson objectAtIndex:j] objectForKey:@"description"] forKey:@"address"];
      
      if([[[cPerson objectAtIndex:j] objectForKey:@"title"] isEqualToString:@"avatar"] && [[[cPerson objectAtIndex:j] objectForKey:@"description"] length] > 0)
        [self.contact setObject:[[cPerson objectAtIndex:j] objectForKey:@"description"] forKey:@"avatar"];
      
      NSMutableArray *arrayCleaned = [[NSMutableArray alloc] init];
      
      for(int k = 0; k < cPerson.count; k++) {
        if(  [[cPerson objectAtIndex:k] objectForKey:@"description"] &&
           ([[cPerson objectAtIndex:k] objectForKey:@"title"]       &&
            ![[[cPerson objectAtIndex:k] objectForKey:@"title"] isEqual:@"avatar"] && ![[[cPerson objectAtIndex:k] objectForKey:@"title"] isEqual:@"category"]))[arrayCleaned addObject:[cPerson objectAtIndex:k]];
      }
      
      if ( arrayCleaned.count )
        [self.contact setObject:[[arrayCleaned copy] autorelease] forKey:@"x_array"];
      
      [arrayCleaned removeAllObjects];
      [arrayCleaned release];
    }
    
    if([self.contact objectForKey:@"name"])
      [self.lDetails addObject:[[self.contact copy] autorelease]];
    
    [self.contact removeAllObjects];
  }

  [super viewDidLoad];
}


-(void)viewWillAppear:(BOOL)animated
{
  [super viewWillAppear:animated];
  
  [self.navigationItem setHidesBackButton:NO animated:NO];
  [self.navigationController setNavigationBarHidden:NO animated:NO];
  self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
  
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
}

#pragma mark -
#pragma mark TableView delegate and datasource

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
	return 0.0f;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
  return (self.lDetails.count > 0) ? 1 : 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
  return self.array.count;
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
  UIImage *cellBGImage = nil;
  
  if ([self.tableView numberOfRowsInSection:0] == 1)
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
    cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:Cell_ID] autorelease];
    
    cell.backgroundColor = [UIColor clearColor];
    cell.textLabel.backgroundColor = [UIColor clearColor];
    cell.detailTextLabel.backgroundColor = [UIColor clearColor];
    cell.textLabel.textColor = self.mMCColorOfText;
  }
  
  cell.accessoryView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:([self.mMCColorOfBackground isLight] ? resourceFromBundle(@"mContacts_ArrowLight.png") : resourceFromBundle(@"mContacts_Arrow.png"))]] autorelease];
  cell.indentationLevel = 1;
  cell.indentationWidth = 5.0f;
  cell.textLabel.text = [[self.lDetails objectAtIndex:indexPath.row] objectForKey:@"name"];
  
  return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
  [tableView deselectRowAtIndexPath:indexPath animated:YES];
  
  mDetails *detailsVC = [[[mDetails alloc] init] autorelease];
  detailsVC.details       = [self.lDetails objectAtIndex:indexPath.row];
  detailsVC.showLink      = showLink;
  detailsVC.shareEMail    = shareEMail;
  detailsVC.shareSMS      = shareSMS;
  detailsVC.addContact    = addContact;
  detailsVC.showTabBar    = NO;
  detailsVC.szBackImgView = self.szBackImgView;
  detailsVC.mMCColorOfBackground = self.mMCColorOfBackground;
  detailsVC.mMCColorOfText       = self.mMCColorOfText;
  detailsVC.hasColorskin         = self.hasColorskin;
  if([[self.lDetails objectAtIndex:indexPath.row] objectForKey:@"avatar"]) detailsVC.contactAvatar = [[self.lDetails objectAtIndex:indexPath.row] objectForKey:@"avatar"];
  
  [self.navigationController pushViewController:detailsVC animated:YES];
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