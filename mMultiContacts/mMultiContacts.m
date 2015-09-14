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

#import "mMultiContacts.h"
#import "functionLibrary.h"
#import "TBXML.h"
#import "NSString+colorizer.h"
#import "UIColor+HSL.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import <UIKit/UIBezierPath.h>


@interface mMultiContactsViewController()
@property (nonatomic, strong) NSString            *szBackImgView;

@property (nonatomic, strong) NSMutableArray      *lDetails;
@property (nonatomic, strong) NSMutableDictionary *contact;

@property (nonatomic, strong) NSSet               *categories;
@property (nonatomic, retain) NSString            *appID;

@property BOOL hasColorskin;
@end

@implementation mMultiContactsViewController
@synthesize array;
@synthesize showLink;
@synthesize szBackImgView = _szBackImgView;
@synthesize shareEMail;
@synthesize shareSMS;
@synthesize addContact;
@synthesize appID;

@synthesize categories;

@synthesize lDetails = _lDetails,
contact = _contact;

@synthesize mMCColorOfBackground;
@synthesize mMCColorOfText;

@synthesize hasColorskin;

#pragma mark -
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
  self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
  if (self)
  {
    _szBackImgView    = nil;
    _lDetails         = nil;
    _contact          = nil;
    self.array        = nil;
    
    self.categories   = nil;
    self.appID        = nil;
    
    self.mMCColorOfBackground = [UIColor colorWithRed:94.0f / 255.0f green:104.0f / 255.0f blue:112.0f / 255.0f alpha:1.0f];
    self.mMCColorOfText = [UIColor colorWithRed:255.0f/255.0f green:190.0f/255.0f blue:106.0f/255.0f alpha:1.0f];
    self.hasColorskin = NO;
  }
  return self;
}

- (void)dealloc
{
  self.szBackImgView    = nil;
  self.lDetails         = nil;
  self.contact          = nil;
  
  self.array            = nil;
  
  self.categories       = nil;
  
  self.mMCColorOfBackground = nil;
  self.mMCColorOfText = nil;
  
  [super dealloc];
}


#pragma mark - Parsing and setting params

/**
 *  Special parser for processing original xml file
 *
 *  @param xmlElement_ XML node
 *  @param params_     Dictionary with module parameters
 */
+ (void)parseXML:(NSValue *)xmlElement_
     withParams:(NSMutableDictionary *)params_
{
  TBXMLElement element;
  [xmlElement_ getValue:&element];

  typedef struct tagTTagsForDictionary
  {
    const NSString *tagName;
    const NSString *keyName;
  }TTagsForDictionary;
  
  const TTagsForDictionary parsedTags[] = { { @"title"      , @"title"       },
    { @"description", @"description" },
    { @"type"       , @"type"        } };
  
  NSMutableArray *contentArray = [NSMutableArray array];
  
  NSMutableDictionary *colorSkin = [NSMutableDictionary dictionary];
  
  TBXMLElement *data = &element;
  TBXMLElement *dataChild = data->firstChild;
  while (dataChild)
  {
    
    if ([[TBXML elementName:dataChild] isEqualToString:@"colorskin"])
    {
      
      if ([TBXML childElementNamed:@"color1" parentElement:dataChild])
        [colorSkin setValue:[TBXML textForElement:[TBXML childElementNamed:@"color1" parentElement:dataChild]] forKey:@"color1"];

      if ([TBXML childElementNamed:@"color3" parentElement:dataChild])
        [colorSkin setValue:[TBXML textForElement:[TBXML childElementNamed:@"color3" parentElement:dataChild]] forKey:@"color3"];
    }
    
    dataChild = dataChild->nextSibling;
  };
  
  TBXMLElement *personElement = [TBXML childElementNamed:@"person" parentElement:&element];
  if ( !personElement )
    personElement = [TBXML childElementNamed:@"contact" parentElement:&element];
  
  while( personElement )
  {
    NSMutableArray *conList = [NSMutableArray array];
    TBXMLElement *conElement = [TBXML childElementNamed:@"con" parentElement:personElement];
    while ( conElement )
    {
      NSMutableDictionary *conDictionary = [[NSMutableDictionary alloc] init];
      TBXMLElement *tagElement = conElement->firstChild;
      while( tagElement )
      {
        NSString *szTag = [[TBXML elementName:tagElement] lowercaseString];
        for ( int i = 0; i < sizeof(parsedTags) / sizeof(parsedTags[0]); ++i )
        {
          if ( [szTag isEqual:parsedTags[i].tagName] )
          {
            NSString *tagContent = [TBXML textForElement:tagElement];
            if ( [tagContent length] )
              [conDictionary setObject:tagContent forKey:parsedTags[i].keyName];
            break;
          }
        }
        tagElement = tagElement->nextSibling;
      }
      if ( [conDictionary count] )
        [conList addObject:conDictionary];
      [conDictionary release];
      
      conElement = [TBXML nextSiblingNamed:@"con" searchFromElement:conElement];
    }
    if ( [conList count] )
      [contentArray addObject:[NSDictionary dictionaryWithObject:conList forKey:@"con"]];
    
    personElement = [TBXML nextSiblingNamed:[TBXML elementName:personElement] searchFromElement:personElement];
  }
  
  [params_ setObject:[NSArray arrayWithObject:[NSDictionary dictionaryWithObject:contentArray forKey:@"persons"]] forKey:@"data"];
  if (colorSkin.count)
  {
    [params_ setObject:colorSkin forKey:@"colorskin"];
  }
  
  NSMutableArray *catTMP = [NSMutableArray new];
  
  for (NSDictionary *con in [[[params_ objectForKey:@"data"] objectAtIndex:0] objectForKey:@"persons"])
  {
    for (NSDictionary *tag in [con objectForKey:@"con"])
    {
      if ([tag objectForKey:@"type"] && [[tag objectForKey:@"type"] isEqualToString:@"6"])
      {
        if ([tag objectForKey:@"title"] && [[tag objectForKey:@"title"] isEqualToString:@"category"])
        {
          if ([tag objectForKey:@"description"])
          {
            [catTMP addObject:[tag objectForKey:@"description"]];
          }
        }
      }
    }
  }
  
  NSOrderedSet *categories = [NSOrderedSet orderedSetWithArray:[[catTMP copy] autorelease]];
  
  [catTMP release];
  
  [params_ setObject:categories forKey:@"categories"];
}

- (void)setParams:(NSMutableDictionary *)inputParams
{
  if (inputParams != nil)
  {
    showLink   = [[inputParams objectForKey:@"showLink"]   isEqual:@"1"];
    shareEMail = [[inputParams objectForKey:@"shareEMail"] isEqual:@"1"];
    shareSMS   = [[inputParams objectForKey:@"shareSMS"]   isEqual:@"1"];
    addContact = [[inputParams objectForKey:@"addContact"] isEqual:@"1"];
    self.appID = [inputParams objectForKey:@"app_id"];
    self.szBackImgView   = [inputParams objectForKey:@"backImg"];
    
    if ([inputParams objectForKey:@"colorskin"])
    {
      self.hasColorskin = YES;
      self.mMCColorOfBackground = [[[inputParams objectForKey:@"colorskin"] objectForKey:@"color1"] asColor];
      self.mMCColorOfText       = [[[inputParams objectForKey:@"colorskin"] objectForKey:@"color3"] asColor];
    }
    
    self.contact = [NSMutableDictionary dictionary];
    self.lDetails = [NSMutableArray array];
    self.navigationItem.title = ([[inputParams objectForKey:@"title"] length] > 0) ? [inputParams objectForKey:@"title"] : @"";
    
    for (NSMutableDictionary *person in [inputParams objectForKey:@"data"])
    {
      if (person.count)
        self.array = [person objectForKey:@"persons"];
    }
    
    if ([inputParams objectForKey:@"categories"])
    {
      self.categories = [inputParams objectForKey:@"categories"];
    }
    
    NSMutableArray *arrTemp = [NSMutableArray new];
    
    for (int i = 0; i < self.array.count; i++)
    {
      NSMutableArray *cPerson = [[self.array objectAtIndex:i] objectForKey:@"con"];
      for (int j = 0; j < cPerson.count; j++)
      {
        if ([[[cPerson objectAtIndex:j] objectForKey:@"title"] isEqualToString:@"name"] &&
           [[[cPerson objectAtIndex:j] objectForKey:@"description"] length] > 0)
          [arrTemp addObject:[[self.array objectAtIndex:i] copy]];
      }
    }
    
    self.array = arrTemp;
    
    [arrTemp removeAllObjects];
    [arrTemp release];
    
    for (int i = 0; i < self.array.count; i++)
    {
      NSMutableArray *cPerson = [[self.array objectAtIndex:i] objectForKey:@"con"];
      for (int j = 0; j < cPerson.count; j++)
      {
        NSString *title = [[cPerson objectAtIndex:j] objectForKey:@"title"];
        NSString *descr = [[cPerson objectAtIndex:j] objectForKey:@"description"];
        
          // will refactor this code later...
        if ([title isEqualToString:@"name"] && [descr length] > 0)
          [self.contact setObject:descr forKey:@"name"];
        
        if ([title isEqualToString:@"phone"] && [descr length] > 0)
          [self.contact setObject:descr forKey:@"phone"];
        
        if ([title isEqualToString:@"email"] && [descr length] > 0)
          [self.contact setObject:descr forKey:@"email"];
        
        if ([title isEqualToString:@"homepage"] && [descr length] > 0)
          [self.contact setObject:descr forKey:@"homepage"];
        
        if ([title isEqualToString:@"address"] && [descr length] > 0)
          [self.contact setObject:descr forKey:@"address"];
        
        if ([title isEqualToString:@"avatar"] && [descr length] > 0)
          [self.contact setObject:descr forKey:@"avatar"];
        
        NSMutableArray *arrayCleaned = [[NSMutableArray alloc] init];
        
        for (int k = 0; k < cPerson.count; k++)
        {
          if (  [[cPerson objectAtIndex:k] objectForKey:@"description"] &&
             ([[cPerson objectAtIndex:k] objectForKey:@"title"]       &&
              ![[[cPerson objectAtIndex:k] objectForKey:@"title"] isEqual:@"avatar"]))
            [arrayCleaned addObject:[cPerson objectAtIndex:k]];
        }
        
        if ( arrayCleaned.count )
          [self.contact setObject:[[arrayCleaned copy] autorelease] forKey:@"x_array"];
        
        [arrayCleaned removeAllObjects];
        [arrayCleaned release];
      }
      
      if ([self.contact objectForKey:@"name"])
        [self.lDetails addObject:[[self.contact copy] autorelease]];
      
      [self.contact removeAllObjects];
    }
  }
}


#pragma mark - View lifecycle

- (void)viewDidLoad
{
  self.view.autoresizesSubviews = YES;
  self.view.autoresizingMask    = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
  
  if (self.categories.count > 1)
  {
    self.categoriesViewController = [[[mCategoriesViewController alloc] init] autorelease];
    [self.categoriesViewController setValue:self forKey:@"_parentViewController"];
    self.categoriesViewController.view.frame = self.view.bounds;
    self.categoriesViewController.categories = self.categories;
    self.categoriesViewController.array      = self.array;
    
    self.categoriesViewController.addContact = self.addContact;
    self.categoriesViewController.shareEMail = self.shareEMail;
    self.categoriesViewController.shareSMS   = self.shareSMS;
    self.categoriesViewController.appID = self.appID;
    
    self.categoriesViewController.mMCColorOfBackground = self.mMCColorOfBackground;
    self.categoriesViewController.mMCColorOfText = self.mMCColorOfText;

    self.categoriesViewController.view.autoresizesSubviews = YES;
    self.categoriesViewController.view.autoresizingMask    = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    [self.view addSubview:self.categoriesViewController.view];
  }
  else
  {
    
    if (self.array.count > 1)
    {
      self.contactsViewController = [[[mContactsViewController alloc] init] autorelease];
      self.contactsViewController.array = self.array;
      
      [self.contactsViewController setValue:self forKey:@"_parentViewController"];
      self.contactsViewController.view.frame = self.view.bounds;
      
      self.contactsViewController.addContact = self.addContact;
      self.contactsViewController.shareEMail = self.shareEMail;
      self.contactsViewController.shareSMS   = self.shareSMS;
      
      self.contactsViewController.mMCColorOfBackground = self.mMCColorOfBackground;
      self.contactsViewController.mMCColorOfText = self.mMCColorOfText;
      
      self.contactsViewController.view.autoresizesSubviews = YES;
      self.contactsViewController.view.autoresizingMask    = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
      
      [self.view addSubview:self.contactsViewController.view];
    }
    else if (self.array.count == 1)
    {
      NSMutableDictionary *contact  = [NSMutableDictionary dictionary];
      NSMutableArray *lDetails = [NSMutableArray array];
      
      NSMutableArray *cPerson = [[self.array objectAtIndex:0] objectForKey:@"con"];
      
      for (int j = 0; j < cPerson.count; j++)
      {
        NSString *title = [[cPerson objectAtIndex:j] objectForKey:@"title"];
        NSString *descr = [[cPerson objectAtIndex:j] objectForKey:@"description"];
        
        if ([title isEqualToString:@"name"] && [descr length] > 0)
          [contact setObject:descr forKey:@"name"];
        
        if ([title isEqualToString:@"phone"] && [descr length] > 0)
          [contact setObject:descr forKey:@"phone"];
        
        if ([title isEqualToString:@"email"] && [descr length] > 0)
          [contact setObject:descr forKey:@"email"];
        
        if ([title isEqualToString:@"homepage"] && [descr length] > 0)
          [contact setObject:descr forKey:@"homepage"];
        
        if ([title isEqualToString:@"address"] && [descr length] > 0)
          [contact setObject:descr forKey:@"address"];
        
        if ([title isEqualToString:@"avatar"] && [descr length] > 0)
          [contact setObject:descr forKey:@"avatar"];
        
        NSMutableArray *arrayCleaned = [[NSMutableArray alloc] init];
        
        for (int k = 0; k < cPerson.count; k++)
        {
          if (  [[cPerson objectAtIndex:k] objectForKey:@"description"] &&
             ([[cPerson objectAtIndex:k] objectForKey:@"title"]       &&
              ![[[cPerson objectAtIndex:k] objectForKey:@"title"] isEqual:@"avatar"] && ![[[cPerson objectAtIndex:k] objectForKey:@"title"] isEqual:@"category"]))
            [arrayCleaned addObject:[cPerson objectAtIndex:k]];
        }
        
        if ( arrayCleaned.count )
          [contact setObject:[[arrayCleaned copy] autorelease] forKey:@"x_array"];
        
        [arrayCleaned removeAllObjects];
        [arrayCleaned release];
      }
      
      if ([contact objectForKey:@"name"])
        [lDetails addObject:[[contact copy] autorelease]];


      self.detailsViewController = [[[mDetails alloc] init] autorelease];
      if (lDetails.count)
        self.detailsViewController.details = [lDetails objectAtIndex:0];
      
      
      
      [self.detailsViewController setValue:self forKey:@"_parentViewController"];
      self.detailsViewController.view.frame = self.view.bounds;
      
      if ([[lDetails objectAtIndex:0] objectForKey:@"avatar"])
        self.detailsViewController.contactAvatar = [[lDetails objectAtIndex:0] objectForKey:@"avatar"];
      
      self.detailsViewController.addContact = self.addContact;
      self.detailsViewController.shareEMail = self.shareEMail;
      self.detailsViewController.shareSMS   = self.shareSMS;
      
      self.detailsViewController.mMCColorOfBackground = self.mMCColorOfBackground;
      self.detailsViewController.mMCColorOfText = self.mMCColorOfText;
      
      self.detailsViewController.view.autoresizesSubviews = YES;
      self.detailsViewController.view.autoresizingMask    = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
      
      [self.view addSubview:self.detailsViewController.view];
    }
    else
    {
      NSLog(@"Empty array of contacts");
      self.view.backgroundColor = self.mMCColorOfBackground;
      
      self.detailsViewController = [[[mDetails alloc] init] autorelease];
      
      [self.detailsViewController setValue:self forKey:@"_parentViewController"];
      self.detailsViewController.view.frame = self.view.bounds;
      
      [self.view addSubview:self.detailsViewController.view];
    }
  }
  [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated
{
  [[self.tabBarController tabBar] setHidden:NO];
	[super viewWillAppear:animated];
	
  [self.categoriesViewController viewWillAppear:animated];
  [self.contactsViewController viewWillAppear:animated];
  [self.detailsViewController viewWillAppear:animated];
  
  self.navigationItem.rightBarButtonItem = self.detailsViewController.navigationItem.rightBarButtonItem;
}


- (void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
	
  [self.categoriesViewController viewDidAppear:animated];
  [self.contactsViewController viewDidAppear:animated];
  [self.detailsViewController viewDidAppear:animated];
}


- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
	
  [self.categoriesViewController viewWillDisappear:animated];
  [self.contactsViewController viewWillDisappear:animated];
  [self.detailsViewController viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
	
  [self.categoriesViewController viewDidDisappear:animated];
  [self.contactsViewController viewDidDisappear:animated];
  [self.detailsViewController viewDidDisappear:animated];
}


#pragma mark - Interface orientation handlers

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