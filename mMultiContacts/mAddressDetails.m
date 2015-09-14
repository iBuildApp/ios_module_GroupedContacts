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

#import "mAddressDetails.h"
#import "mDetails.h"
#import "functionLibrary.h"
#import "NSString+colorizer.h"
#import "UIColor+HSL.h"
#import "NSString+size.h"

@interface mAddressDetails()

/**
 *  Defines TabBar behavior
 */
@property (nonatomic, assign) BOOL tabBarIsHidden;

@property (nonatomic, strong) UITableView         *tableView;

@end

@implementation mAddressDetails

@synthesize
  addressDetails = _addressDetails,
  szBackImgView = _szBackImgView,
  tabBarIsHidden,
  mMCColorOfBackground,
  mMCColorOfText,
  hasColorskin;

#pragma mark -
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
  self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
  if (self)
  {
    _szBackImgView  = nil;
    _addressDetails = nil;
    self.tabBarIsHidden = NO;
    
    self.mMCColorOfBackground = nil;
    self.mMCColorOfText = nil;
    self.hasColorskin = NO;
  }
  return self;
}

- (void)dealloc
{
  self.szBackImgView  = nil;
  self.addressDetails = nil;
  
  self.mMCColorOfBackground = nil;
  self.mMCColorOfText = nil;
  
  self.tableView = nil;
  
  [super dealloc];
}

#pragma mark - View lifecycle

-(void)viewWillAppear:(BOOL)animated
{
  [super viewWillAppear:animated];
    // before hiding / displaying tabBar we must remember its previous state
  self.tabBarIsHidden = [[self.tabBarController tabBar] isHidden];
  if ( !self.tabBarIsHidden )
    [[self.tabBarController tabBar] setHidden:YES];
}

-(void)viewWillDisappear:(BOOL)animated
{
  [super viewWillDisappear:animated];
    // restore tabBar state
  [[self.tabBarController tabBar] setHidden:self.tabBarIsHidden];
}



- (void)viewDidLoad
{
  [self.navigationItem setHidesBackButton:NO animated:NO];
  [self.navigationController setNavigationBarHidden:NO animated:NO];
  self.navigationItem.title = NSBundleLocalizedString(@"mMC_detailsTitle", @"Address");
  self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
  
  
  CGRect frame = CGRectMake(10, 0, self.view.frame.size.width - 20, self.view.frame.size.height);
  
  self.tableView = [[[UITableView alloc] initWithFrame:frame style:UITableViewStyleGrouped] autorelease];
  
  self.tableView.delegate = self;
  self.tableView.dataSource = self;
  
  self.tableView.backgroundColor = [UIColor clearColor];
  self.tableView.autoresizesSubviews = NO;
  self.tableView.autoresizingMask    = UIViewAutoresizingFlexibleHeight;
  
  self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
  
  self.tableView.tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, 20.f)];
  
  [self.view addSubview:self.tableView];

  
  UIImageView *backImgView = nil;

  backImgView = [[[UIImageView alloc] init] autorelease];
  backImgView.backgroundColor = self.mMCColorOfBackground;
  
  [backImgView setFrame:[self.tableView bounds]];
  self.tableView.backgroundView = backImgView;
  
  self.view.backgroundColor = self.mMCColorOfBackground;
  
  [super viewDidLoad];
}


#pragma mark - UITableView delegate & datasource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
  return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
  return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
  NSString *szText = [functionLibrary stringByReplaceEntitiesInString:[self.addressDetails stringByReplacingOccurrencesOfString:@"\n" withString:@" "]];
  
  CGSize expectedLabelSize = [szText sizeForFont:[UIFont systemFontOfSize:18.0f]
                                       limitSize:CGSizeMake( tableView.frame.size.width - 44.f, 9999.f )
                                 nslineBreakMode:NSLineBreakByWordWrapping];
  
  return expectedLabelSize.height + 55;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
  UIImage *cellBGImage = nil;
  
  cellBGImage = [UIImage imageNamed:([self.mMCColorOfBackground isLight] ? resourceFromBundle(@"mContacts_TableRowSingleLight.png") :
                                                                           resourceFromBundle(@"mContacts_TableRowSingle.png"))];
  
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
  
  cell.selectionStyle = UITableViewCellSelectionStyleNone;
  cell.textLabel.font = [UIFont systemFontOfSize:18.0f];
  cell.textLabel.numberOfLines = 0;
  cell.textLabel.lineBreakMode = NSLineBreakByWordWrapping;
  cell.textLabel.text = self.addressDetails;
  return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
  [tableView deselectRowAtIndexPath:indexPath animated:YES];
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