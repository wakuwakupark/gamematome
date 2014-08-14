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

    NSXMLParser *_parser;

    NSArray* newsArray;      //表示用ニュース配列
    NSArray* favoriteArray; //お気に入りニュース用
    int rssSiteNumber;
    
    //引っ張って更新
    UIRefreshControl *_refreshControl;
    
    //parser
    NSString *_elementName; //読み取り中のDOM要素名
    int version;            //読み取り中のRSSのバージョン
    int checkingMode;   //読み取りモード

    
    Site* readingSite;      //RSS読み取り中のサイト
    News* checkingNews;     //データ設定中のニュース
    
    //パース用データバッファ
    NSString* titleBuffer;
    NSString* contentURLBuffer;
    NSDate* dateBuffer;
    NSData* imgBuffer;
    
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


