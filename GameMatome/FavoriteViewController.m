//
//  FavoriteViewController.m
//  GameMatome
//
//  Created by Hiroyuki Yahagi on 2014/06/07.
//  Copyright (c) 2014年 Hiroyuki Yahagi. All rights reserved.
//

#import "FavoriteViewController.h"
#import "BrouserViewController.h"
#import "ForUseCoreData.h"
#import "Game.h"
#import "Site.h"
#import "News.h"
#import "Memo.h"
#import "GADBannerView.h"
#import "ColorParser.h"

@interface FavoriteViewController ()

@end

@implementation FavoriteViewController

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
    
    
    //広告の設定
    bannerView = [[GADBannerView alloc]initWithAdSize:kGADAdSizeBanner];
    bannerView.adUnitID = @"ca-app-pub-9624460734614700/2538576676";
    bannerView.rootViewController = self;
    [self.view addSubview:bannerView];
    [bannerView loadRequest:[GADRequest request]];
    [bannerView setFrame:CGRectMake(0, 470, 320, 50)];
    
    
    _tableView.dataSource = self;
    _tableView.delegate = self;
    
    _backgroundView.hidden = YES;
    _textView.hidden = YES;
    _editDoneButton.hidden = YES;
    
    
//    _refreshControl = [[UIRefreshControl alloc] init];
//    [_refreshControl addTarget:self action:@selector(refresh) forControlEvents:UIControlEventValueChanged];
//    [_tableView addSubview:_refreshControl];
    
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
    //データベースから取得
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

    favoriteArray = [ForUseCoreData getFavoriteNewsOrderByDate];
    
    [_tableView reloadData];
    
}

- (void)endRefresh
{
    [_refreshControl endRefreshing];
}


- (void)rssDataRead
{
    //RSSの読み取り
    //DOMツリー化
    rssSiteNumber = 0;
    
    
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
            
            readingSite = site;
            [self rssDataReadOfSite:[site rssURL]];
            
            [site setLastUpdated:[NSDate date]];
        }
    }
    
    [[ForUseCoreData getManagedObjectContext] save:NULL];
}

- (void)rssDataReadOfSite:(NSString*) feed
{
    NSURL *url = [NSURL URLWithString:feed];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    NSURLResponse *response = nil;
    NSError *error = nil;
    NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    version = -1;
    _parser = [[NSXMLParser alloc] initWithData:data];
    _parser.delegate = self;
    
    titleBuffer = NULL;
    contentURLBuffer = NULL;
    dateBuffer = NULL;
    imgBuffer = NULL;
    
    [_parser parse];
    
    
}



#pragma mark XMLParserDelegate
- (void)parser:(NSXMLParser *)parser
didStartElement:(NSString *)elementName
  namespaceURI:(NSString *)namespaceURI
 qualifiedName:(NSString *)qName
    attributes:(NSDictionary *)attributeDict
{
    _elementName = elementName;
    
    if ([_elementName isEqualToString:@"rdf:RDF"]) {
        //rss 1.0
        version = 1;
    }else if ([_elementName isEqualToString:@"rss"]){
        //rss 2.0
        version = 2;
    }
    
    if(version == -1)
        return;
    
    switch (version) {
        case 1:
            //サイトデータ作成mode
            if ([_elementName isEqualToString:@"channel"]){
                checkingMode = 1;
                //nowItem = NULL;
                checkingNews = NULL;
            }
            
            //itemデータ作成mode
            else if ([_elementName isEqualToString:@"item"]){
                
                
                checkingMode = 2;
                
            }
            
            break;
        case 2:
            if ([_elementName isEqualToString:@"channel"]){
                checkingMode = 1;
                checkingNews = NULL;
                
            }else if ([_elementName isEqualToString:@"item"]){
                
                checkingMode = 2;
                
            }
            
            break;
        default:
            checkingMode = 0;
            break;
    }
    
}

- (void)parser:(NSXMLParser *)parser
foundCharacters:(NSString *)string
{
    if(version == -1)
        return;
    
    if([string hasPrefix:@"\n"])
        return;
    
    switch (version) {
        case 1:
            switch (checkingMode) {
                case 0:
                    break;
                case 1:
                    if ([_elementName isEqualToString:@"title"]){
                        
                        //RSSデータからサイトのタイトルを取得
                        //if([[readingSite name]isEqualToString:@"NoName"])
                        [readingSite setName:string];
                        
                    }
                    break;
                case 2:
                    if ([_elementName isEqualToString:@"title"]){
                        //nowItem.title = [NSString stringWithString:string];
                        
                        //ニュースのタイトルを取得
                        titleBuffer = string;
                        
                        
                    }else if ([_elementName isEqualToString:@"link"]){
                        
                        //コンテンツのURLを取得
                        contentURLBuffer = string;
                        
                    }else if([_elementName isEqualToString:@"dc:date"]){
                        
                        //更新時間を取得
                        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
                        [dateFormatter setDateFormat:@"yyyy'-'MM'-'dd'T'HH':'mm':'ssZZZZ"];
                        dateBuffer = [dateFormatter dateFromString:string];
                        
                        
                    }else if([_elementName isEqualToString:@"content:encoded"]|| [_elementName isEqualToString:@"description"]){
                        
                        //a href=" ~ " までを取り出す
                        NSArray *names = [string componentsSeparatedByString:@"a href=\""];
                        if ([names count] >= 2) {
                            NSArray* arr = [[names objectAtIndex:1] componentsSeparatedByString:@"\""];
                            NSString* imgURL = [arr objectAtIndex:0];
                            
                            NSData *rowImgData = [NSData dataWithContentsOfURL:[NSURL URLWithString:imgURL]];
                            
                            
                            //画像をトリミング
                            UIImage* img = [self trimImage:[UIImage imageWithData:rowImgData] size:CGSizeMake(60,60)];
                            
                            imgBuffer = [[NSData alloc] initWithData:UIImagePNGRepresentation( img )];
                            
                        }
                    }
                    
                    break;
                default:
                    break;
            }
            
            break;
        case 2:
            switch (checkingMode) {
                case 0:
                    break;
                case 1:
                    if ([_elementName isEqualToString:@"title"]){
                        //サイトのタイトルを入力
                        //if([[readingSite name]isEqualToString:@"NoName"])
                        [readingSite setName:string];
                    }
                    break;
                case 2:
                    if ([_elementName isEqualToString:@"title"]){
                        
                        
                        //ニュースのタイトルを設定
                        titleBuffer = string;
                        
                    }else if ([_elementName isEqualToString:@"link"]){
                        
                        //コンテンツのURLを設定
                        contentURLBuffer = string;
                        
                    }else if([_elementName isEqualToString:@"dc:date"]||[_elementName isEqualToString:@"pubDate"]){
                        
                        //更新日付を設定
                        
                        //RSS2.0型変換
                        //Thu, 5 Jun 2014 16:41:56 +0900
                        
                        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
                        [dateFormatter setDateFormat:@"EEE, dd MMM yyyy HH:mm:ss ZZZZ"];
                        dateBuffer = [dateFormatter dateFromString:string];
                        
                        
                        
                    }else if([_elementName isEqualToString:@"content:encoded"]|| [_elementName isEqualToString:@"description"]){
                        
                        //a href=" ~ " までを取り出す
                        NSArray *names = [string componentsSeparatedByString:@"a href=\""];
                        if ([names count] >= 2) {
                            NSArray* arr = [[names objectAtIndex:1] componentsSeparatedByString:@"\""];
                            NSString* imgURL = [arr objectAtIndex:0];
                            
                            NSData *rowImgData = [NSData dataWithContentsOfURL:[NSURL URLWithString:imgURL]];
                            
                            
                            //画像をトリミング
                            UIImage* img = [self trimImage:[UIImage imageWithData:rowImgData] size:CGSizeMake(60,60)];
                            
                            imgBuffer = [[NSData alloc] initWithData:UIImagePNGRepresentation( img )];
                            
                        }
                    }
                    
                    break;
                default:
                    break;
            }
            
            break;
    }
}

- (void)parser:(NSXMLParser *)parser
 didEndElement:(NSString *)elementName
  namespaceURI:(NSString *)namespaceURI
 qualifiedName:(NSString *)qName
{
    if (version == -1) {
        return;
    }
    
    switch (version) {
        case 1:
            if ([elementName isEqualToString:@"item"]){
                checkingMode = 2;
                
                //サイトの最終更新時間と比較して新しかったらエンティティを生成してデータを代入
                
                if ([readingSite lastUpdated]== NULL || [[readingSite lastUpdated] compare:dateBuffer] == NSOrderedAscending) {
                    
                    //未来のデータは無視
                    if([dateBuffer compare:[NSDate date]] == NSOrderedDescending){
                        return;
                    }
                    
                    
                    //新しいニュースエンティティを作成
                    checkingNews = [NSEntityDescription insertNewObjectForEntityForName:@"News" inManagedObjectContext:[ForUseCoreData getManagedObjectContext]];
                    
                    [checkingNews setTitle:titleBuffer];
                    [checkingNews setContentURL:contentURLBuffer];
                    [checkingNews setImage:imgBuffer];
                    [checkingNews setDate:dateBuffer];
                    
                    //サイトに追加
                    
                    [[readingSite news] addObject:checkingNews];
                    
                    [checkingNews setSite:readingSite];
                    
                    //[readingSite setLastUpdated:[checkingNews date]];
                    titleBuffer = NULL;
                    contentURLBuffer = NULL;
                    dateBuffer = NULL;
                    imgBuffer = NULL;
                    
                }else{
                    [_parser abortParsing];
                }
            }
            break;
        case 2:
            if ([elementName isEqualToString:@"item"]){
                
                //サイトの最終更新時間と比較して新しかったらエンティティを生成してデータを代入
                
                if ([readingSite lastUpdated]== NULL || [[readingSite lastUpdated] compare:dateBuffer] == NSOrderedAscending) {
                    
                    //未来のデータは無視
                    if([dateBuffer compare:[NSDate date]] == NSOrderedDescending){
                        return;
                    }
                    
                    
                    //新しいニュースエンティティを作成
                    checkingNews = [NSEntityDescription insertNewObjectForEntityForName:@"News" inManagedObjectContext:[ForUseCoreData getManagedObjectContext]];
                    
                    [checkingNews setTitle:titleBuffer];
                    [checkingNews setContentURL:contentURLBuffer];
                    [checkingNews setImage:imgBuffer];
                    [checkingNews setDate:dateBuffer];
                    
                    //サイトに追加
                    
                    [[readingSite news] addObject:checkingNews];
                    
                    [checkingNews setSite:readingSite];
                    
                    //[readingSite setLastUpdated:[checkingNews date]];
                    titleBuffer = NULL;
                    contentURLBuffer = NULL;
                    dateBuffer = NULL;
                    imgBuffer = NULL;
                    
                }else{
                    [_parser abortParsing];
                }
                
            }
            break;
    }
    
}



- (void)parserDidEndDocument:(NSXMLParser *)parser
{
    rssSiteNumber ++;
    
    if (rssSiteNumber == 2) {
        
    }
    //NSLog(@"%@",[rssData description]);
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

        if(item.site.game.color == NULL)
            cell.backgroundColor = [UIColor colorWithRed:0.9 green:0.9 blue:0.9 alpha:1];
        else
            cell.backgroundColor = [ColorParser parseFromRGBString:item.site.game.color read:true];
    }else{
        
        if(item.site.game.color == NULL)
            cell.backgroundColor = [UIColor whiteColor];
        else
            cell.backgroundColor = [ColorParser parseFromRGBString:item.site.game.color read:false];
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
                
                if(item.memo == NULL || item.memo.contents.length <= 0){
                    button.imageView.image = [UIImage imageNamed:@"../memo.png"];
                }else{
                    button.imageView.image = [UIImage imageNamed:@"../memo_blue.png"];
                }
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
                if([item.didRead intValue] == 1){
                    textView.textColor = [UIColor grayColor];
                }else{
                    textView.textColor = [UIColor blackColor];
                }
                
            }
                break;
            case 5:
            {
                UILabel* textView = (UILabel*) view;
                textView.text = [NSString stringWithFormat:@"【%@】 %@",item.site.game.name, item.site.name];
                if([item.didRead intValue] == 1){
                    textView.textColor = [UIColor grayColor];
                }else{
                    textView.textColor = [UIColor blackColor];
                }
            }
                break;
            case 6:
            {
                UILabel* textView = (UILabel*) view;
                NSDate *date = [item date];
                NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
                [formatter setDateFormat:@"yyyy/MM/dd HH:mm"];
                textView.text = [formatter stringFromDate:date];
                if([item.didRead intValue] == 1){
                    textView.textColor = [UIColor grayColor];
                }else{
                    textView.textColor = [UIColor blackColor];
                }
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

- (UIImage *)trimImage:(UIImage *)imgOriginal size:(CGSize)size
{
    UIGraphicsBeginImageContext(size);
    // draw scaled image into thumbnail context
    [imgOriginal drawInRect:CGRectMake(0, 0, size.width, size.height)];
    
    UIImage *newThumbnail = UIGraphicsGetImageFromCurrentImageContext();
    // pop the context
    UIGraphicsEndImageContext();
    if(newThumbnail == nil)
        NSLog(@"could not scale image");
    return newThumbnail;
}


- (IBAction)refreshButtonPressed:(id)sender
{
    [self refresh];
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
    [_tableView reloadData];
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


- (News *) getSelectedNewsWithMode:(NSInteger)index
{
    switch ([self.tabBarController selectedIndex]) {
        case 0:
            return [newsArray objectAtIndex:index];
        case 1:
            return [favoriteArray objectAtIndex:index];
        default:
            return [newsArray objectAtIndex:index];
    }
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

@end
