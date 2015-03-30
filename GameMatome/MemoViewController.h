//
//  FavoriteViewController.h
//  GameMatome
//
//  Created by Hiroyuki Yahagi on 2014/06/07.
//  Copyright (c) 2014年 Hiroyuki Yahagi. All rights reserved.
//

#import <UIKit/UIKit.h>

@import GoogleMobileAds;


//@class Item;
@class Site;
@class News;
@class Memo;
@class GADBannerView;

@interface MemoViewController : UIViewController<UITableViewDataSource,UITableViewDelegate>
{
    NSArray* gamesArray;        //ゲームエンティティが格納される配列

    
    NSMutableArray* newsArray;      //表示用ニュース配列
    
    //引っ張って更新
    UIRefreshControl *_refreshControl;
    
    Memo* editingMemo;
    NSString* initialTextOfEditingMemo;
    
    GADBannerView* bannerView;
}

@property (weak, nonatomic) IBOutlet UITableView *tableView;


@property (weak, nonatomic) IBOutlet UIView *backgroundView;
@property (weak, nonatomic) IBOutlet UITextView *textView;
@property (weak, nonatomic) IBOutlet UIButton *editDoneButton;


- (IBAction)editDoneButtonPressed:(id)sender;



@end


/*
 
 起動
 設定でチェック済のゲームにかんするRSSからデータを引っ張る
 セルにタッチでブラウザviewに以降
 お気に入り登録
 未読は文字を太く
 
 */