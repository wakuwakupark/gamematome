//
//  NewsViewController.h
//  GameMatome
//
//  Created by Hiroyuki Yahagi on 2014/06/07.
//  Copyright (c) 2014年 Hiroyuki Yahagi. All rights reserved.
//

#import <UIKit/UIKit.h>
@import GoogleMobileAds;
#import "ChkControllerDelegate.h"


//@class Item;
@class Site;
@class News;
@class Memo;
@class GADBannerView;
@class ChkController;

@interface NewsViewController : UIViewController <UITableViewDataSource,UITableViewDelegate,NSXMLParserDelegate,ChkControllerDelegate,UIAlertViewDelegate>
{
    NSArray* gamesArray;        //ゲームエンティティが格納される配列

    NSArray* newsArray;      //ニュース配列
    NSMutableArray* showingArray; //表示中の記事配列
    
    //引っ張って更新
    UIRefreshControl *_refreshControl;
    
    Memo* editingMemo;
    
    int mode; //0 test  1 
    
    GADBannerView* bannerView;
    ChkController* chkController;
    NSMutableArray* addArray;
    
    NSArray* affArray;
    NSString* initialTextOfEditingMemo;
    
    //データ削除時のインデックス
    NSIndexPath* deletedIndex;
}

@property (weak, nonatomic) IBOutlet UITableView *tableView;


@property (weak, nonatomic) IBOutlet UIView *backgroundView;
@property (weak, nonatomic) IBOutlet UITextView *textView;
@property (weak, nonatomic) IBOutlet UIButton *editDoneButton;

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

- (IBAction)refreshButtonPressed:(id)sender;
- (IBAction)editDoneButtonPressed:(id)sender;
- (IBAction)reviewButtonPressed:(id)sender;


@end


