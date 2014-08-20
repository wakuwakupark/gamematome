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
#import "GADBannerView.h"
#import "GetGameList.h"
#import "GetSiteList.h"
#import "GetUpdate.h"
#import "Parser.h"
#import "ChkController.h"

#define MODE 0 // 0:local 1:web
#define MAX_NEWS_SIXE 300


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
    
    
    _refreshControl = [[UIRefreshControl alloc] init];
    [_refreshControl addTarget:self action:@selector(refresh) forControlEvents:UIControlEventValueChanged];
    [_tableView addSubview:_refreshControl];
    
    [self registerForKeyboardNotifications];

    
}

- (void)viewWillDisappear:(BOOL)animated
{
    
    [[ForUseCoreData getManagedObjectContext] save:NULL];
}

- (void)viewDidAppear:(BOOL)animated
{
    favoriteArray = [ForUseCoreData getFavoriteNewsOrderByDate];
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
    favoriteArray = [ForUseCoreData getFavoriteNewsOrderByDate];
    
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
    News* selected = [self getSelectedNewsWithMode:[[_tableView indexPathForSelectedRow] row]];
    
 
    BrouserViewController* bvc = [segue destinationViewController];
    bvc.firstURL = selected.contentURL;
    bvc.showingNews = selected;
    bvc.showingSite = NULL;
    selected.didRead = @(1);
}

#pragma mark UITableView DataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    switch ([self.tabBarController selectedIndex]) {
        case 0:
            return [newsArray count];
        case 1:
            return [favoriteArray count];
    }
    
    return [newsArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    
    News* item = [self getSelectedNewsWithMode:indexPath.row];
    
    
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
                    //メモボタン
                    [button addTarget:self action:@selector(onClickMemoButton:event:) forControlEvents:UIControlEventTouchUpInside];
                }
                    break;
                case 3:
                {
                    if(item.image != NULL && item.image.length >= 500){
                        UIImageView *imageView = (UIImageView*) view;
                        imageView.image = [UIImage imageWithData:item.image];
                    }else{
                        UIImageView *imageView = (UIImageView*) view;
                        imageView.image = [UIImage imageNamed:@"noimage.jpg"];
                    }
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
    
    
    
    
    return cell;
    
}

// ボタンタップ時に実行される処理
- (void)onClickFavoriteButton:(UIButton *)button event:(UIEvent *)event
{
    // タップされたボタンから、対応するセルを取得する
    NSIndexPath *indexPath = [self indexPathForControlEvent:event];
    UITableViewCell *cell = (UITableViewCell *)[self.tableView cellForRowAtIndexPath:indexPath];
    
    //お気に入り追加
    News *selected = [self getSelectedNewsWithMode:indexPath.row];
    
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

    News *selected = [self getSelectedNewsWithMode:indexPath.row];
    
    
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
    
    [self performSelector:@selector(refresh) withObject:nil afterDelay:0.1];
//    [self refresh];
    
    [self.tableView setContentOffset:CGPointZero animated:YES];
    
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


- (id) getSelectedNewsWithMode:(NSInteger)index
{

    return [newsArray objectAtIndex:index];
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



#pragma mark ChkControllerDelegate

- (void) chkControllerDataListWithSuccess:(NSDictionary*)data
{
    
    addArray = [chkController dataList];
    [_tableView reloadData];
}

- (void) chkControllerDataListWithError:(NSError *)error
{
    
}

- (void)chkControllerDataListWithNotFound:(NSDictionary *)data
{
    
}

@end