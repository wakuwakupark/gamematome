//
//  NewsViewController.m
//  GameMatome
//
//  Created by Hiroyuki Yahagi on 2014/06/07.
//  Copyright (c) 2014年 Hiroyuki Yahagi. All rights reserved.
//

#import "NewsViewController.h"
#import "BrouserViewController.h"
#import "ForUseCoreData.h"
#import "Game.h"
#import "Site.h"
#import "News.h"
#import "Memo.h"
#import "Affs.h"
#import "GADBannerView.h"
#import "GetGameList.h"
#import "GetSiteList.h"
#import "GetUpdate.h"
#import "Parser.h"
#import "ChkController.h"
#import "GetAffURL.h"

#define MODE 1 // 0:local 1:web
#define MAX_NEWS_SIXE 300
#define FIRST_8CROPS 5
#define DIST_8CROPS 10
#define FIRST_FING 3
#define DIST_FING 6

@interface NewsViewController ()

@end

@implementation NewsViewController

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization

    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
    _tableView.dataSource = self;
    _tableView.delegate = self;
    
    _backgroundView.hidden = YES;
    _textView.hidden = YES;
    _editDoneButton.hidden = YES;
    _activityIndicator.hidden = YES;
    
    //ゲームデータを収集
    switch (MODE) {
        case 0:
            [self getSitesData];
            break;
        case 1:
            [self setGameListWithDataBase];
            break;
    }
    
    //
    chkController = [[ChkController alloc]initWithDelegate:self];
    [chkController requestDataList];
    
    //RSSから読み取り
    [self rssDataRead];
    
    newsArray = [ForUseCoreData getAllNewsOrderByDate];
    affArray = [[ForUseCoreData getEntityDataEntityNameWithEntityName:@"Affs"] mutableCopy];
    
    _refreshControl = [[UIRefreshControl alloc] init];
    [_refreshControl addTarget:self action:@selector(refresh) forControlEvents:UIControlEventValueChanged];
    [_tableView addSubview:_refreshControl];
    
    [self registerForKeyboardNotifications];

    NSUserDefaults* ud = [NSUserDefaults standardUserDefaults];
    if([ud objectForKey:@"on"] == NULL){
        
        [ud setObject:@"1" forKey:@"on"];
        
        UIAlertView *alert =
        [[UIAlertView alloc]
         initWithTitle:@"お願い"
         message:@"AppStore に\nレビューを書きませんか？"
         delegate:self
         cancelButtonTitle:@"キャンセル"
         otherButtonTitles:@"レビュー", nil
         ];
        
        
        [alert show];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    
    [[ForUseCoreData getManagedObjectContext] save:NULL];
}

- (void)viewDidAppear:(BOOL)animated
{
    [self setshowingArrayWithAdds];
    [_tableView reloadData];
}



- (void)getSitesData
{
    //データを取得
    gamesArray = [ForUseCoreData getEntityDataEntityNameWithEntityName:@"Game"];
    
    
    //サイズ0ならplistから設定
    if(gamesArray.count != 0){
        NSLog(@"gamesArray Already Set");
        return;
    }
    
    
    
    //データベースをリフレッシュ
    [ForUseCoreData deleteAllObjects];
    
    NSString* path = [[NSBundle mainBundle] pathForResource:@"SitesData" ofType:@"plist"];
    
    NSDictionary *allDictionary = [NSDictionary dictionaryWithContentsOfFile:path];
    

    
    for (int i=0; i<[allDictionary count]; i++) {
        NSString* key = [[allDictionary allKeys] objectAtIndex:i];
        NSDictionary* dic = [allDictionary objectForKey:key];
        
        Game* newGame  = [NSEntityDescription insertNewObjectForEntityForName:@"Game" inManagedObjectContext:[ForUseCoreData getManagedObjectContext]];
        
        [newGame setName:key];
        [newGame setUnuse:false];
        
        //サイト情報の取得
        NSDictionary* sitesDic = [dic objectForKey:@"sites"];
        if([sitesDic count]!=0){
            
            //データを取得
            for (int j=0; j<[sitesDic count]; j++) {
                
                NSString* dataKey = [[sitesDic allKeys]objectAtIndex:j];
                NSString* urlString = [sitesDic objectForKey:dataKey];
                
                Site* newSite  = [NSEntityDescription insertNewObjectForEntityForName:@"Site" inManagedObjectContext:[ForUseCoreData getManagedObjectContext]];
                
                [newSite setGame:newGame];
                [newSite setName:dataKey];
                [newSite setPageURL:urlString];
                
                //rssデータが存在するかチェック
                NSString* rssString = [[dic objectForKey:@"rss"] objectForKey:dataKey];
                if(rssString != NULL)
                    [newSite setRssURL:rssString];
                else
                    [newSite setRssURL:NULL];
                
                [newSite setType:dataKey];
                
            }
            
        }
        
    }
    
    //保存
    [[ForUseCoreData getManagedObjectContext] save:NULL];
    
    gamesArray = [ForUseCoreData getEntityDataEntityNameWithEntityName:@"Game"];
    
}

- (void)refresh
{
    [_refreshControl endRefreshing];
    
    switch (MODE) {
        case 1:
            [self setGameListWithDataBase];
            break;
        default:
            break;
    }
    
    [self rssDataRead];
    
    newsArray = [ForUseCoreData getAllNewsOrderByDate];
    affArray = [[ForUseCoreData getEntityDataEntityNameWithEntityName:@"Affs"] mutableCopy];
    [self setshowingArrayWithAdds];
    
    
    [_tableView reloadData];
    
    [_activityIndicator stopAnimating];
    
    _backgroundView.hidden = YES;
    _activityIndicator.hidden = YES;
    
}

- (void)endRefresh
{
    [_refreshControl endRefreshing];
}


- (void)rssDataRead
{
    //RSSの読み取り
    //DOMツリー化

    for(Game* game in gamesArray){
        
        //不使用ならば次へ
        if([[game unuse]isEqualToNumber:@(1)])
            continue;
            
        for (Site* site in [game sites]) {
            
            //不使用ならば次へ
            if([[site unuse]isEqualToNumber:@(1)])
                continue;
            
            //rssが設定されていなければNULL
            if([site rssURL] == NULL)
                continue;
            
            //rssの最終更新日時を確認
            
            //readingSite = site;
            //[self rssDataReadOfSite:[site rssURL]];
            
            Parser* parser = [[Parser alloc]init];
            [parser doParseWithSite:site];
            
            [site setLastUpdated: [NSDate date]];
        }
    }
    
    //最大サイズを超えていたら削除
    if([newsArray count]> MAX_NEWS_SIXE){
        for (int i=MAX_NEWS_SIXE; i<[newsArray count]; i++) {
            [[ForUseCoreData getManagedObjectContext]deleteObject:[newsArray objectAtIndex:i]];
        }
    }
    
    [[ForUseCoreData getManagedObjectContext] save:NULL];

}



#pragma mark UITableView Delegate

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    //対象インデックスのオブジェクトがnewsかbannarで分類
    NSObject* selected = [showingArray objectAtIndex:[[_tableView indexPathForSelectedRow]row]];
    
    if([selected isKindOfClass:[News class]]){
        
        BrouserViewController* bvc = [segue destinationViewController];
        bvc.firstURL = ((News *)selected).contentURL;
        bvc.showingNews = (News *)selected;
        bvc.showingSite = NULL;
        ((News *)selected).didRead = @(1);
        
    }else if ([selected isKindOfClass:[ChkRecordData class]]){
        
        BrouserViewController* bvc = [segue destinationViewController];
        bvc.firstURL = ((ChkRecordData *)selected).linkUrl;
        bvc.showingNews = NULL;
        bvc.showingSite = NULL;

    }else{
        BrouserViewController* bvc = [segue destinationViewController];
        bvc.firstURL = ((Affs *)selected).url;
        bvc.showingNews = NULL;
        bvc.showingSite = NULL;
        bvc.naviItem.title = ((Affs*)selected).title;
    }
    
}

#pragma mark UITableView DataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{

    return [showingArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    
    
    //News* item = [self getSelectedNewsWithMode:indexPath.row];
    NSObject* selected = [showingArray objectAtIndex:indexPath.row];
    
    if([selected isKindOfClass:[News class]]){
        News* item = (News* )selected;
        
        if([item.didRead intValue] == 1){
            cell.backgroundColor = [UIColor lightGrayColor];
        }else{
            cell.backgroundColor = [UIColor whiteColor];
        }
        
        //各ボタンにイベントを設定
        for(UIView* view in cell.contentView.subviews){
            
            switch (view.tag) {
                case 1:
                {
                    UIButton* button = (UIButton *)view;
                    [button addTarget:self action:@selector(onClickFavoriteButton:event:) forControlEvents:UIControlEventTouchUpInside];
                    button.hidden = NO;
                    
                    if([item.favorite intValue] == 1){
                        button.selected = true;
                    }else{
                        button.selected = false;
                    }
                }
                    break;
                case 2:
                {
                    UIButton* button = (UIButton *)view;
                    button.hidden = NO;
                    //メモボタン
                    [button addTarget:self action:@selector(onClickMemoButton:event:) forControlEvents:UIControlEventTouchUpInside];
                }
                    break;
                case 3:
                {
                }
                    break;
                case 4:
                {
                    UILabel* textView = (UILabel*) view;
                    textView.text = item.title;
                    
                }
                    break;
                case 5:
                {
                    UILabel* textView = (UILabel*) view;
                    textView.text = item.site.name;
                }
                    break;
                case 6:
                {
                    UILabel* textView = (UILabel*) view;
                    NSDate *date = [item date];
                    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
                    [formatter setDateFormat:@"yyyy/MM/dd HH:mm"];
                    textView.text = [formatter stringFromDate:date];
                }
                    break;
                default:
                    break;
            }
            
        }

        
    }else if ([selected isKindOfClass:[ChkRecordData class]]){
        
        ChkRecordData* item = (ChkRecordData*)selected;
        
        cell.backgroundColor = [UIColor whiteColor];

        //各ボタンにイベントを設定
        for(UIView* view in cell.contentView.subviews){
            
            switch (view.tag) {
                case 1:
                {
                    UIButton* button = (UIButton *)view;
                    button.hidden = YES;
                }
                    break;
                case 2:
                {
                    UIButton* button = (UIButton *)view;
                    //メモボタン
                    button.hidden = YES;
                }
                    break;
                case 3:
                {
                }
                    break;
                case 4:
                {
                    UILabel* textView = (UILabel*) view;
                    textView.text = [NSString stringWithFormat:@"【PR】 %@", item.description];
                }
                    break;
                case 5:
                {
                    UILabel* textView = (UILabel*) view;
                    textView.text = item.title;
                }
                    break;
                case 6:
                {
                    UILabel* textView = (UILabel*) view;
                    textView.text = @"";
                }
                    break;
                default:
                    break;
            }
            
        }
        
    }else if([selected isKindOfClass:[Affs class]]){
        
        Affs* item = (Affs*)selected;
        
        cell.backgroundColor = [UIColor whiteColor];
        
        //各ボタンにイベントを設定
        for(UIView* view in cell.contentView.subviews){
            
            switch (view.tag) {
                case 1:
                {
                    UIButton* button = (UIButton *)view;
                    button.hidden = NO;
                }
                    break;
                case 2:
                {
                    UIButton* button = (UIButton *)view;
                    //メモボタン
                    button.hidden = NO;
                }
                    break;
                case 3:
                {
                }
                    break;
                case 4:
                {
                    UILabel* textView = (UILabel*) view;
                    textView.text = item.title;
                }
                    break;
                case 5:
                {
                    UILabel* textView = (UILabel*) view;
                    textView.text = item.siteName;
                }
                    break;
                case 6:
                {
                    UILabel* textView = (UILabel*) view;
                    textView.text = @"";
                }
                    break;
                default:
                    break;
            }
            
        }
        
    }
    
    return cell;
    
}

// ボタンタップ時に実行される処理
- (void)onClickFavoriteButton:(UIButton *)button event:(UIEvent *)event
{
    // タップされたボタンから、対応するセルを取得する
    NSIndexPath *indexPath = [self indexPathForControlEvent:event];
    UITableViewCell *cell = (UITableViewCell *)[self.tableView cellForRowAtIndexPath:indexPath];
    
    //お気に入り追加
    News *selected = [showingArray objectAtIndex :indexPath.row];
    
    //各ボタンにイベントを設定
    for(UIView* view in cell.contentView.subviews){
        if(view.class == [UIButton class]){
            UIButton* button = (UIButton *)view;
            
            if(button.tag == 1){
                
                if([selected.favorite intValue] == 0){
                    [selected setFavorite:[NSNumber numberWithInt:1]];
                    button.selected = true;
                }else{
                    [selected setFavorite:[NSNumber numberWithInt:0]];
                    button.selected = false;
                }
            }
        }
    }
    
    
}

// ボタンタップ時に実行される処理
- (void)onClickMemoButton:(UIButton *)button event:(UIEvent *)event
{
    // タップされたボタンから、対応するセルを取得する
    NSIndexPath *indexPath = [self indexPathForControlEvent:event];

    News *selected = [showingArray objectAtIndex :indexPath.row];
    
    
    editingMemo = [selected memo];
    if(editingMemo == NULL){
        editingMemo = [NSEntityDescription insertNewObjectForEntityForName:@"Memo" inManagedObjectContext:[ForUseCoreData getManagedObjectContext]];
        editingMemo.news = selected;
        selected.memo = editingMemo;
    }
    
    _textView.text = editingMemo.contents;
    initialTextOfEditingMemo = editingMemo.contents;
    
    [self fadeinMemoView];
    
}

// UIControlEventからタッチ位置のindexPathを取得する
- (NSIndexPath *)indexPathForControlEvent:(UIEvent *)event {
    UITouch *touch = [[event allTouches] anyObject];
    CGPoint p = [touch locationInView:self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:p];
    return indexPath;
}


- (IBAction)refreshButtonPressed:(id)sender
{
    _backgroundView.hidden = NO;
    _activityIndicator.hidden = NO;
    
    [_activityIndicator startAnimating];
    

    NSIndexPath* indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    [_tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:NO];
  
    [self performSelector:@selector(refresh) withObject:nil afterDelay:0.1];
}

- (IBAction)editDoneButtonPressed:(id)sender {
    
    [_textView resignFirstResponder];
    
    editingMemo.contents = _textView.text;
    
    //データが変更されていれば更新日時を書き換え
    if (![initialTextOfEditingMemo isEqualToString:[_textView text]]) {
        editingMemo.updateDate =  [NSDate date];
    }
    
    [[ForUseCoreData getManagedObjectContext] save:NULL];

    [self fadeOutMemoView];
}

- (IBAction)reviewButtonPressed:(id)sender {
    
    NSUserDefaults* ud = [NSUserDefaults standardUserDefaults];
    NSString* url = [ud objectForKey:@"myituneURL"];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
}

- (void) fadeinMemoView
{
    //Viewを透明にする
    [_backgroundView setAlpha:0.0];
    
    // アニメーション
    [UIView beginAnimations:nil context:NULL];
    // 秒数設定
    [UIView setAnimationDuration:0.2];
    [_backgroundView setAlpha:1];
    
    
    _backgroundView.hidden = NO;
    _textView.hidden = NO;
    _editDoneButton.hidden = NO;
    
    // アニメーション終了
    [UIView commitAnimations];

}

- (void) fadeOutMemoView
{
    
    // アニメーション
    [UIView beginAnimations:nil context:NULL];
    // 秒数設定
    [UIView setAnimationDuration:0.2];
    [_backgroundView setAlpha:0];
    
    // アニメーション終了
    [UIView commitAnimations];
    
}


- (void) setGameListWithDataBase
{
    NSUserDefaults* ud = [NSUserDefaults standardUserDefaults];
    GetUpdate* gu = [[GetUpdate alloc]init];
    if([ud objectForKey:@"lastUpdate"] != NULL){
        NSDate* date = [ud objectForKey:@"lastUpdate"];
        if([date compare:[gu returnUpdate]] != NSOrderedAscending){
            gamesArray = [ForUseCoreData getEntityDataEntityNameWithEntityName:@"Game"];
            return;
        }
    }
    
    [ud setObject:[gu returnUpdate] forKey:@"lastUpdate"];
    
    GetGameList* gg = [[GetGameList alloc]init];
    GetSiteList* gs = [[GetSiteList alloc]init];
    
    NSMutableArray* gamesBuffer = [[ForUseCoreData getEntityDataEntityNameWithEntityName:@"Game"] mutableCopy];
    
    NSDictionary* dbGames = [gg returnGameArray];
    NSDictionary* dbSites = [gs returnSiteArray];
    
    for (NSDictionary* dic in [dbGames allValues]) {
        BOOL flag = false;
        for(Game* g in gamesBuffer){
            if([g.gameId intValue] == [[dic objectForKey:@"id"]intValue]){
                flag = true;
                break;
            }
        }
        
        if (!flag) {
            Game* newGame = [NSEntityDescription insertNewObjectForEntityForName:@"Game" inManagedObjectContext:[ForUseCoreData getManagedObjectContext]];
            [newGame setName:[dic objectForKey:@"name"]];
            [newGame setGameId:[NSNumber numberWithInt:[[dic objectForKey:@"id"]intValue]]];
            [newGame setUnuse:@(0)];
            [gamesBuffer addObject:newGame];
        }
    }
    
    NSMutableArray* siteBuffer = [[ForUseCoreData getEntityDataEntityNameWithEntityName:@"Site"] mutableCopy];
    
    for (NSDictionary* dic in [dbSites allValues]) {
        BOOL flag = false;
        NSString* gameId = [dic objectForKey:@"game_id"];
        NSString* siteId = [dic objectForKey:@"site_id"];
        
        for (Site* s in siteBuffer) {

            if([s.siteId intValue] == [siteId intValue]){
                flag = true;
                break;
            }
        }
        
        if(!flag){
            Site* site = [NSEntityDescription insertNewObjectForEntityForName:@"Site" inManagedObjectContext:[ForUseCoreData getManagedObjectContext]];
            [site setName:[dic objectForKey:@"name"]];
            [site setPageURL:[dic objectForKey:@"contentsURL"]];
            [site setRssURL:[dic objectForKey:@"rssURL"]];
            [site setSiteId:[NSNumber numberWithInt:[siteId intValue]]];
            
            for (Game* g in gamesBuffer) {
                if ([g.gameId intValue] == [gameId intValue]) {
                    [site setGame:g];
                    break;
                }
            }
        }
    }
    
    
    [[ForUseCoreData getManagedObjectContext]save:NULL];
    
    gamesArray = [ForUseCoreData getEntityDataEntityNameWithEntityName:@"Game"];
    
    affArray = [NSArray array];
    if([[ud objectForKey:@"test"] isEqualToString:@"0"]){
        GetAffURL* ga = [[GetAffURL alloc]init];
        affArray = [ga getAffs];
    }
    
    return;
}


#pragma mark keyboardAction

- (void)registerForKeyboardNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWasShown:)
                                                 name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillBeHidden:)
                                                 name:UIKeyboardWillHideNotification object:nil];
}

- (void)keyboardWasShown:(NSNotification*)aNotification
{
    [_editDoneButton setFrame:CGRectMake(254.0, 100, 46.0, 30.0)];
    [_textView setFrame:CGRectMake(20,140, 280, 200)];
}


- (void)keyboardWillBeHidden:(NSNotification*)aNotification
{
    [_editDoneButton setFrame:CGRectMake(254.0, 144.0, 46.0, 30.0)];
    [_textView setFrame:CGRectMake(20,182, 280, 267)];
}

- (void) setshowingArrayWithAdds
{
    showingArray = [newsArray mutableCopy];
    
    NSUserDefaults* ud = [NSUserDefaults standardUserDefaults];
    if([[ud objectForKey:@"test"] isEqualToString:@"1"]){
        return;
    }

    [self setShowingArrayWithAddArray:affArray First:FIRST_FING Distance:DIST_FING];
    [self setShowingArrayWithAddArray:addArray First:FIRST_8CROPS Distance:DIST_8CROPS];
}

- (void) setShowingArrayWithAddArray:(NSArray*)adds First:(int)first Distance:(int)distance
{
    int i=0;
    
    NSMutableArray* buffer = [NSMutableArray array];
    
    for(NSObject *news in showingArray){
        
        if([buffer count]<first){
            [buffer addObject:news];
            
        }else{
            
            if([buffer count] == first + i*distance){
                
                if([adds count] > i){
                    [buffer addObject:[adds objectAtIndex:i]];
                    i++;
                }
                
                [buffer addObject:news];
                
            }else{
                [buffer addObject:news];
            }
        }
    }
    
    showingArray = buffer;
}


#pragma mark ChkControllerDelegate

- (void) chkControllerDataListWithSuccess:(NSDictionary*)data
{
    
    addArray = [chkController dataList];
    [self setshowingArrayWithAdds];
    [_tableView reloadData];
}

- (void) chkControllerDataListWithError:(NSError *)error
{
    
}

- (void)chkControllerDataListWithNotFound:(NSDictionary *)data
{
    
}

#pragma mark UIAlertView

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
        //レビューへ飛ばす
        [self reviewButtonPressed:nil];
    }
}

@end