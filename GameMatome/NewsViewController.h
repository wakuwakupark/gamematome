//
//  NewsViewController.h
//  GameMatome
//
//  Created by Hiroyuki Yahagi on 2014/06/07.
//  Copyright (c) 2014年 Hiroyuki Yahagi. All rights reserved.
//

#import <UIKit/UIKit.h>


//@class Item;
@class Site;
@class News;
@class Memo;
@class GADBannerView;

@interface NewsViewController : UIViewController<UITableViewDataSource,UITableViewDelegate,NSXMLParserDelegate>
{
    NSArray* gamesArray;        //ゲームエンティティが格納される配列

    NSArray* newsArray;      //表示用ニュース配列
    NSArray* favoriteArray; //お気に入りニュース用
    
    //引っ張って更新
    UIRefreshControl *_refreshControl;
    
    Memo* editingMemo;
    
    int mode; //0 all  1 favorite
    
    
    GADBannerView* bannerView;
    
    
    NSString* initialTextOfEditingMemo;
}

@property (weak, nonatomic) IBOutlet UITableView *tableView;


@property (weak, nonatomic) IBOutlet UIView *backgroundView;
@property (weak, nonatomic) IBOutlet UITextView *textView;
@property (weak, nonatomic) IBOutlet UIButton *editDoneButton;


- (IBAction)refreshButtonPressed:(id)sender;
- (IBAction)editDoneButtonPressed:(id)sender;



@end


