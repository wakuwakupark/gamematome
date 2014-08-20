//
//  NewsViewController.h
//  GameMatome
//
//  Created by Hiroyuki Yahagi on 2014/06/07.
//  Copyright (c) 2014年 Hiroyuki Yahagi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ChkControllerDelegate.h"


//@class Item;
@class Site;
@class News;
@class Memo;
@class GADBannerView;
@class ChkController;

@interface NewsViewController : UIViewController <UITableViewDataSource,UITableViewDelegate,NSXMLParserDelegate,ChkControllerDelegate>
{
    NSArray* gamesArray;        //ゲームエンティティが格納される配列

    NSArray* newsArray;      //表示用ニュース配列
    NSArray* favoriteArray; //お気に入りニュース用
    
    //引っ張って更新
    UIRefreshControl *_refreshControl;
    
    Memo* editingMemo;
    
    int mode; //0 all  1 favorite
    
    
    GADBannerView* bannerView;
    ChkController* chkController;
    NSMutableArray* addArray;
    
    NSString* initialTextOfEditingMemo;
}

@property (weak, nonatomic) IBOutlet UITableView *tableView;


@property (weak, nonatomic) IBOutlet UIView *backgroundView;
@property (weak, nonatomic) IBOutlet UITextView *textView;
@property (weak, nonatomic) IBOutlet UIButton *editDoneButton;

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

- (IBAction)refreshButtonPressed:(id)sender;
- (IBAction)editDoneButtonPressed:(id)sender;


@end


