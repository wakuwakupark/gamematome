//
//  BrouserViewController.h
//  GameMatome
//
//  Created by Hiroyuki Yahagi on 2014/06/07.
//  Copyright (c) 2014年 Hiroyuki Yahagi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Social/Social.h>
#import <Twitter/Twitter.h>

@class News;
@class Memo;
@class Site;
@class GADBannerView;

@interface BrouserViewController : UIViewController<UIActionSheetDelegate,UIWebViewDelegate>
{
    GADBannerView* bannerView;
    NSString* initialTextOfEditingMemo;
}

@property (nonatomic, retain) NSString* firstURL;

@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property (weak, nonatomic) IBOutlet UIButton *doneButton;
@property (weak, nonatomic) IBOutlet UITextView *textView;
@property (weak, nonatomic) IBOutlet UIView *backgroundView;
@property (nonatomic, retain) NSString * buffer;

@property (weak, nonatomic) IBOutlet UIBarButtonItem *backButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *proceedButton;

@property (weak, nonatomic) IBOutlet UIBarButtonItem *editButton;



@property (weak, nonatomic) IBOutlet UINavigationItem *naviItem;

@property (nonatomic, retain) News* showingNews;
@property (nonatomic, retain) Site* showingSite;
@property (nonatomic, retain) Memo* editingMemo;

- (IBAction)BackButtonPressed:(id)sender;

- (IBAction)ProceedButtonPressed:(id)sender;

- (IBAction)refreshButtonPressed:(id)sender;

- (IBAction)goBackListButtonPressed:(id)sender;

- (IBAction)noteButtonPressed:(id)sender;

- (IBAction)editDoneButtonPressed:(id)sender;

- (IBAction)actionButtonPressed:(id)sender;
@end
