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

#import "mCategories.h"
#import "mContacts.h"
#import "mDetails.h"
#import "functionLibrary.h"
#import "TBXML.h"
#import "NSString+colorizer.h"
#import "NSString+size.h"
#import "UIColor+HSL.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import <UIKit/UIBezierPath.h>

#define mMCContactsNotFoundLabelFontSize 14

/**
 * Custom cell class for iOS6 to resemble
 * grouped apperance when on plain appearance of tablewView
 */
@interface mCategoriesTableViewCell : UITableViewCell
@end

@implementation mCategoriesTableViewCell

- (void)setFrame:(CGRect)frame {
  frame.origin.x += 10.0f;
  frame.size.width -= 2 * 10.0f;
  [super setFrame:frame];
}

@end

@interface mCategoriesViewController()
{
  UISearchBar *searchBar;
  NSUserDefaults *UD;
}

@property (nonatomic, strong) UITableView         *tableView;

@property (nonatomic, strong) NSString            *szBackImgView;

@property (nonatomic, strong) UILabel             *noContactsFoundLabel;

@property (nonatomic, strong) NSMutableArray      *categoriesArray;
@property (nonatomic, strong) UIButton            *shareEMailButton;
@property (nonatomic, strong) UIButton            *shareSMSButton;
@property BOOL hasColorskin;

@property (nonatomic, strong) NSMutableArray      *displayArray;

@property BOOL hasSearched;

@end

@implementation mCategoriesViewController
@synthesize categories;
@synthesize array;
@synthesize showLink;
@synthesize szBackImgView = _szBackImgView;
@synthesize shareEMail;
@synthesize shareSMS;
@synthesize addContact;
@synthesize appID;

@synthesize categoriesArray = _categoriesArray,
shareEMailButton = _shareEMailButton,
shareSMSButton = _shareSMSButton;

@synthesize mMCColorOfBackground;
@synthesize mMCColorOfText;

@synthesize hasColorskin;

@synthesize displayArray;

@synthesize hasSearched;

#pragma mark -
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
  self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
  if (self)
  {
    _szBackImgView         = nil;
    _noContactsFoundLabel  = nil;
    _shareEMailButton      = nil;
    _shareSMSButton        = nil;
    self.categories        = nil;
    self.categoriesArray   = nil;
    self.mMCColorOfBackground = [UIColor colorWithRed:94.0f / 255.0f green:104.0f / 255.0f blue:112.0f / 255.0f alpha:1.0f];
    self.mMCColorOfText = [UIColor colorWithRed:255.0f/255.0f green:190.0f/255.0f blue:106.0f/255.0f alpha:1.0f];
    self.hasColorskin = NO;
    self.displayArray = nil;
    self.appID = nil;
    self.categoriesArray = nil;
  }
  return self;
}

- (void)dealloc
{
  self.noContactsFoundLabel = nil;
  self.szBackImgView    = nil;
  self.categoriesArray  = nil;
  self.shareEMailButton = nil;
  self.shareSMSButton   = nil;
  self.categories       = nil;
  
  self.mMCColorOfBackground = nil;
  self.mMCColorOfText = nil;
  
  self.displayArray = nil;
  self.appID = nil;
  self.categoriesArray = nil;
  
  [UD release];
  
  if(searchBar){
    [searchBar release];
    searchBar = nil;
  }
  
  self.tableView = nil;
  
  [super dealloc];
}


#pragma mark View lifecycle
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
  
  UD = [NSUserDefaults standardUserDefaults];
  
  if ([UD objectForKey:@"savedSearchString"] && [[UD objectForKey:@"savedSearchString"] length])
    [UD removeObjectForKey:@"savedSearchString"];
  
  [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated
{
  self.displayArray    = [NSMutableArray array];
  self.categoriesArray = [NSMutableArray array];
  
  for (NSString *category in self.categories)
  {
    [self.categoriesArray addObject:category];
  }
  
  [super viewWillAppear:animated];
  
  if ( UIInterfaceOrientationIsLandscape( [[UIApplication sharedApplication] statusBarOrientation] ) )
  {
    [[UIDevice currentDevice] performSelector:NSSelectorFromString(@"setOrientation:")
                                   withObject:(id)UIInterfaceOrientationPortrait];
  }
  
  
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
  
  UIView *searchBarContainer = [self setupSearchBarContainer];
  
  self.tableView.tableHeaderView = searchBarContainer;
  
  UIImageView *backImgView = nil;

  backImgView = [[[UIImageView alloc] init] autorelease];
  backImgView.backgroundColor = self.mMCColorOfBackground;
  
  self.view.backgroundColor = self.mMCColorOfBackground;
  
  [backImgView setFrame:[self.tableView bounds]];
  self.tableView.backgroundView = backImgView;
  
  if (!([UD objectForKey:@"savedSearchString"] && [[UD objectForKey:@"savedSearchString"] length]))
  {
    self.displayArray = self.categoriesArray;
    hasSearched = NO;
  }
  
  UIEdgeInsets newContentInset = self.tableView.contentInset;
  newContentInset.bottom = 30.0f;
  
  if(SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")){
    //eliminate 1pt gap of bgColor between searchBarContainer and navBar
    newContentInset.top = -1.0f;
  }
  
  self.tableView.contentInset = newContentInset;
}

-(void)viewWillDisappear:(BOOL)animated
{
  [super viewWillDisappear:animated];
  
  [self.noContactsFoundLabel removeFromSuperview];
  self.noContactsFoundLabel = nil;
}

-(UIView *)setupSearchBarContainer
{
  searchBar = [[[UISearchBar alloc] init] autorelease];
  
  // hardcode for task_id=3771
  if ([self.appID isEqualToString:@"638839"])
    searchBar.placeholder = @"Search by Location";
  else
    searchBar.placeholder = NSBundleLocalizedString(@"mMC_searchBarplaceholder", @"Search by contact info");
  
  searchBar.delegate = self;
  CGRect searchBarFrame = CGRectMake(0.0f, 0.0f, 300.0f, 40.0f);

  if(SYSTEM_VERSION_LESS_THAN(@"7.0")){
    searchBarFrame.origin.y = 10.0f;
  }
  
  searchBar.frame = searchBarFrame;
  
  searchBar.backgroundColor = [UIColor clearColor];
  searchBar.translucent = YES;
  
  searchBar.backgroundColor     = [UIColor clearColor];
  searchBar.autoresizesSubviews = YES;
  searchBar.autoresizingMask    = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
  
  searchBar.text                = [[UD objectForKey:@"savedSearchString"] length]? [UD objectForKey:@"savedSearchString"] : @"";
  [self search:searchBar.text];
  
  /// remove background image
  for ( id img in searchBar.subviews )
  {
    if ([img isKindOfClass:NSClassFromString(@"UISearchBarBackground")])
    {
      [img removeFromSuperview];
      break;
    }
  }
  
#ifdef __IPHONE_7_0
  if ( [searchBar respondsToSelector:@selector(setBarTintColor:)] )
    [searchBar setBarTintColor:[UIColor clearColor]];
#endif
  
  UIView *container = [[[UIView alloc] init] autorelease];
  container.backgroundColor = [UIColor clearColor];
  CGRect containerFrame = searchBar.frame;
  
  if(SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")){
    containerFrame.size.height += 10.0f;
  } else {
    containerFrame.size.height += 20.0f;
  }
  
  container.frame = containerFrame;
  
  [container addSubview:searchBar];
  
  return container;
}

#pragma mark - Searching

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
  [UD setObject:searchText forKey:@"savedSearchString"];
  [self search:searchText];
}

- (void) search:(NSString *) matchString
{
  NSString *upString = [matchString uppercaseString];
  
  NSMutableSet *searched = [[NSMutableSet alloc] init];
  for (NSDictionary *con in self.array)
  {
    for (NSDictionary *entity in [con objectForKey:@"con"])
    {
      if (  ([[entity objectForKey:@"title"] isEqualToString:@"name"]
            || [[entity objectForKey:@"title"] isEqualToString:@"phone"]
            || [[entity objectForKey:@"title"] isEqualToString:@"address"])
         && [[entity objectForKey:@"description"] length])
      {
        NSString *line = [entity objectForKey:@"description"];
        
        NSRange range = [[line uppercaseString] rangeOfString:upString];
        if (range.location != NSNotFound)
        {
          [searched addObject:[NSNumber numberWithInteger:[self.array indexOfObject:con]]];
        }
      }
    }
  }
  
  NSMutableArray *searchedItems = [NSMutableArray new];
  
  for (NSNumber *index in searched)
  {
    int i = index.intValue;
    
    NSArray *tmp = [[self.array objectAtIndex:i] objectForKey:@"con"];
    
    for (int k = 0; k < tmp.count; k++)
    {
      if ([[[tmp objectAtIndex:k] objectForKey:@"title"] isEqualToString:@"name"] && [[[tmp objectAtIndex:k] objectForKey:@"description"] length] )
      {
        [searchedItems addObject:[[tmp objectAtIndex:k] objectForKey:@"description"] ];
      }
    }
  }
  
  [searchedItems sortUsingComparator:^(id string1, id string2) {
    return [((NSString *)string1) compare:((NSString *)string2) options:NSNumericSearch];
  }];
  
  self.displayArray = searchedItems;
  hasSearched = YES;
  
  if ([matchString length] == 0)
  {
    self.displayArray = self.categoriesArray;
    hasSearched = NO;
  }
  
  [searched release];
  [searchedItems release];
  
  [self.tableView reloadData];
  
  [self showNoContactsFoundLabelIfNeeded];
}

-(void)showNoContactsFoundLabelIfNeeded
{
  if(!self.displayArray.count){
    if(self.noContactsFoundLabel.hidden){
      
      [self.view bringSubviewToFront:self.noContactsFoundLabel];
      self.noContactsFoundLabel.hidden = NO;
      
      self.tableView.scrollEnabled = NO;
    }
  } else {
    if(!self.noContactsFoundLabel.hidden){
      self.noContactsFoundLabel.hidden = YES;
      self.tableView.scrollEnabled = YES;
    }
  }
}

-(UILabel *)noContactsFoundLabel
{
  if(!_noContactsFoundLabel){
    
    NSString *noContactsFoundText = NSBundleLocalizedString(@"mMC_noResultsFound", @"No results found");
    
    CGSize noContactsFoundTextSize = [noContactsFoundText sizeForFont:[UIFont systemFontOfSize:mMCContactsNotFoundLabelFontSize]
                                                            limitSize:self.view.frame.size
                                                      nslineBreakMode:NSLineBreakByWordWrapping];

    CGRect noContactsFoundLabelFrame = (CGRect){
      0.0f,
      0.0f,//CGRectGetMaxY(searchBar.frame) + offsetY,
      self.view.frame.size.width,
      noContactsFoundTextSize.height
    };
    
    _noContactsFoundLabel = [[UILabel alloc] initWithFrame:noContactsFoundLabelFrame];
    
    _noContactsFoundLabel.text = noContactsFoundText;
    
    _noContactsFoundLabel.textAlignment = NSTextAlignmentCenter;
    _noContactsFoundLabel.lineBreakMode = NSLineBreakByWordWrapping;
    _noContactsFoundLabel.numberOfLines = 0;
    _noContactsFoundLabel.textColor = self.mMCColorOfText;
    _noContactsFoundLabel.backgroundColor = [UIColor clearColor];
    
    [self.view addSubview:_noContactsFoundLabel];
    
    _noContactsFoundLabel.hidden = YES;
  }

  CGFloat accessoryViewOriginY = [self.view convertPoint:searchBar.inputAccessoryView.frame.origin
                                                fromView:searchBar.inputAccessoryView].y;
  
  CGRect actualizedLabelFrame = _noContactsFoundLabel.frame;
  CGFloat freeSpaceHeight = accessoryViewOriginY - CGRectGetMaxY(searchBar.frame);
  CGFloat offsetY = (freeSpaceHeight - actualizedLabelFrame.size.height - searchBar.frame.origin.y) / 2;
  
  actualizedLabelFrame.origin.y = CGRectGetMaxY(searchBar.frame) + offsetY;
  
  _noContactsFoundLabel.frame = actualizedLabelFrame;
  
  return _noContactsFoundLabel;
}

- (UIToolbar *)createInputAccessoryView
{
  UIToolbar *toolbar = [[[UIToolbar alloc] init] autorelease];
  [toolbar setBarStyle:UIBarStyleBlackTranslucent];
  [toolbar sizeToFit];
  UIBarButtonItem *flexButton   = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
  UIBarButtonItem *doneButton   = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(hideKeyboard)];
  [toolbar setItems:[NSArray arrayWithObjects:flexButton, doneButton, nil]];
  [flexButton release];
  [doneButton release];
  return toolbar;
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar_
{
  [searchBar_ setInputAccessoryView:[self createInputAccessoryView]];
}


- (void)hideKeyboard
{
  if ([searchBar isFirstResponder])
  {
    [searchBar resignFirstResponder];
  }
}

#pragma mark -
#pragma mark TableView delegate & datasource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
  return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
  return self.displayArray.count;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
  UIImage *cellBGImage = nil;
  
  if ([self.tableView numberOfRowsInSection:0] == 1)
  {
    cellBGImage = [UIImage imageNamed:([self.mMCColorOfBackground isLight] ? resourceFromBundle(@"mContacts_TableRowSingleLight.png") :
                                                                             resourceFromBundle(@"mContacts_TableRowSingle.png"))];
  }
  else
  {
      // first cell
    if (indexPath.row == 0)
    {
      cellBGImage = [UIImage imageNamed:([self.mMCColorOfBackground isLight] ? resourceFromBundle(@"mContacts_TableRowFirstLight.png") :
                                                                               resourceFromBundle(@"mContacts_TableRowFirst.png"))];
        // last cell
    }
    else if (indexPath.row == [tableView numberOfRowsInSection:indexPath.section] - 1) {
      cellBGImage = [UIImage imageNamed:([self.mMCColorOfBackground isLight] ? resourceFromBundle(@"mContacts_TableRowLastLight.png") :
                                                                               resourceFromBundle(@"mContacts_TableRowLast.png"))];
        // middle cells
    }
    else
    {
      cellBGImage = [UIImage imageNamed:([self.mMCColorOfBackground isLight] ? resourceFromBundle(@"mContacts_TableRowMiddleLight.png")
                                                                             : resourceFromBundle(@"mContacts_TableRowMiddle.png"))];
    }
  }
  float w = cellBGImage.size.width / 2, h = cellBGImage.size.height / 2;
  UIImage *stretchedImage = [cellBGImage stretchableImageWithLeftCapWidth:w topCapHeight:h];
  
  UIImageView *cellTranslucentView = [[[UIImageView alloc] initWithFrame:CGRectMake(0, 0, cell.contentView.bounds.size.width - 20.0f, cell.contentView.bounds.size.height)] autorelease];
  cellTranslucentView.image = stretchedImage;
  
  [cell setBackgroundView:cellTranslucentView];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  static NSString *Cell_ID = @"Cell";
  
  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:Cell_ID];
  if (cell == nil)
  {
    
    if(SYSTEM_VERSION_LESS_THAN(@"7.0")){
      cell = [[[mCategoriesTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:Cell_ID] autorelease];
      cell.textLabel.font = [UIFont systemFontOfSize:17.0f];
    } else {
      cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:Cell_ID] autorelease];
    }
    
    cell.backgroundColor = [UIColor clearColor];
    cell.textLabel.backgroundColor = [UIColor clearColor];
    cell.detailTextLabel.backgroundColor = [UIColor clearColor];
    cell.textLabel.textColor = self.mMCColorOfText;
    //cell.selectionStyle = UITableViewCellSelectionStyleNone;
  }
  
  cell.accessoryView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:([self.mMCColorOfBackground isLight] ? resourceFromBundle(@"mContacts_ArrowLight.png") : resourceFromBundle(@"mContacts_Arrow.png"))]] autorelease];
  cell.textLabel.text = [self.displayArray objectAtIndex:indexPath.row];
  
  return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
  [tableView deselectRowAtIndexPath:indexPath animated:YES];
  
  [self hideKeyboard];
  
  if (hasSearched)
  {
    NSMutableDictionary *initDictionary = [[[NSMutableDictionary alloc] init] autorelease];
    
    NSString *avatarString = @"";
    
    for (int i = 0; i < self.array.count; i++)
    {
      NSMutableArray *cPerson = [[self.array objectAtIndex:i] objectForKey:@"con"];
      for (int j = 0; j < cPerson.count; j++)
      {
        if ([[[cPerson objectAtIndex:j] objectForKey:@"title"] isEqualToString:@"name"]
           && [[[cPerson objectAtIndex:j] objectForKey:@"description"] length] > 0
           && [[[cPerson objectAtIndex:j] objectForKey:@"description"] isEqualToString:[self.displayArray objectAtIndex:indexPath.row]])
        {
          NSMutableArray *arrayCleaned = [[NSMutableArray alloc] init];
          
          for (int k = 0; k < cPerson.count; k++)
          {
            if ( [[cPerson objectAtIndex:k] objectForKey:@"description"]
               && ([[cPerson objectAtIndex:k] objectForKey:@"title"]
                   &&![[[cPerson objectAtIndex:k] objectForKey:@"title"] isEqual:@"avatar"]
                   &&![[[cPerson objectAtIndex:k] objectForKey:@"title"] isEqual:@"category"]))
              [arrayCleaned addObject:[cPerson objectAtIndex:k]];
            
            if ( [[cPerson objectAtIndex:k] objectForKey:@"description"]
               && ([[cPerson objectAtIndex:k] objectForKey:@"title"]
                   && [[[cPerson objectAtIndex:k] objectForKey:@"title"] isEqual:@"avatar"]))
              avatarString = [[cPerson objectAtIndex:k] objectForKey:@"description"];
            
            if ( [[cPerson objectAtIndex:k] objectForKey:@"description"]
               && ([[cPerson objectAtIndex:k] objectForKey:@"title"]
                   && [[[cPerson objectAtIndex:k] objectForKey:@"title"] isEqual:@"name"]))
              [initDictionary setObject:[[[[cPerson objectAtIndex:k] objectForKey:@"description"] copy] autorelease] forKey:@"name"];
          }
          
          if ( arrayCleaned.count )
            [initDictionary setObject:[[arrayCleaned copy] autorelease] forKey:@"x_array"];
          
          [arrayCleaned removeAllObjects];
          [arrayCleaned release];
        }
      }
    }
    
    mDetails *detailsVC = [[[mDetails alloc] init] autorelease];
    detailsVC.details       = initDictionary;
    detailsVC.showLink      = showLink;
    detailsVC.shareEMail    = shareEMail;
    detailsVC.shareSMS      = shareSMS;
    detailsVC.addContact    = addContact;
    if ([avatarString length]) detailsVC.contactAvatar = avatarString;
    
    detailsVC.mMCColorOfBackground = self.mMCColorOfBackground;
    detailsVC.mMCColorOfText       = self.mMCColorOfText;
    
    [self.navigationController pushViewController:detailsVC animated:YES];
  }
  else
  {
    NSMutableArray *initArray = [[[NSMutableArray alloc] init] autorelease];
    
    for (int i = 0; i < self.array.count; i++)
    {
      for (int k = 0; k < [[[self.array objectAtIndex:i] objectForKey:@"con"] count]; k++)
      {
        if ([[[[self.array objectAtIndex:i] objectForKey:@"con"] objectAtIndex:k] objectForKey:@"type"] && [[[[[self.array objectAtIndex:i] objectForKey:@"con"] objectAtIndex:k] objectForKey:@"type"] isEqualToString:@"6"])
        {
          if ([[[[[self.array objectAtIndex:i] objectForKey:@"con"] objectAtIndex:k] objectForKey:@"description"] isEqualToString:[self.displayArray objectAtIndex:indexPath.row]])
            [initArray addObject:[[self.array objectAtIndex:i] objectForKey:@"con"]];
          continue;
        }
      }
    }
    
    mContactsViewController *contactsVC = [[[mContactsViewController alloc] init] autorelease];
    contactsVC.array         = initArray;
    contactsVC.showLink      = showLink;
    contactsVC.shareEMail    = shareEMail;
    contactsVC.shareSMS      = shareSMS;
    contactsVC.addContact    = addContact;

    contactsVC.mMCColorOfBackground = self.mMCColorOfBackground;
    contactsVC.mMCColorOfText       = self.mMCColorOfText;
    
    contactsVC.title = [self.displayArray objectAtIndex:indexPath.row];
    
    [self.navigationController pushViewController:contactsVC animated:YES];
  }
}

#pragma mark -
#pragma mark interface orientation handling

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