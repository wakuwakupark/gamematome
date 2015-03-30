//
//  FavoriteViewController.m
//  GameMatome
//
//  Created by Hiroyuki Yahagi on 2014/06/07.
//  Copyright (c) 2014年 Hiroyuki Yahagi. All rights reserved.
//

#import "MemoViewController.h"
#import "BrouserViewController.h"
#import "ForUseCoreData.h"
#import "Game.h"
#import "Site.h"
#import "News.h"
#import "Memo.h"
#import "ColorParser.h"

@interface MemoViewController ()

@end

@implementation MemoViewController

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
    int height = [[UIScreen mainScreen] bounds].size.height;
    [bannerView setFrame:CGRectMake(0, height-100, 320, 50)];
    
    
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
    [self setNewsHavingMemo];
    [_tableView reloadData];
}

- (void)refresh
{
    [_refreshControl endRefreshing];
    [self setNewsHavingMemo];
    [_tableView reloadData];
    
}

- (void)endRefresh
{
    [_refreshControl endRefreshing];
}


#pragma mark UITableView Delegate

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    News* selected = [newsArray objectAtIndex:[[_tableView indexPathForSelectedRow]row]];
    
    BrouserViewController* bvc = [segue destinationViewController];
    bvc.firstURL = selected.contentURL;
    bvc.showingNews = selected;
    bvc.showingSite = NULL;
    selected.didRead = @(1);
    
    if (((News *)selected).contentHTML != NULL) {
        bvc.firstHTML =((News *)selected).contentHTML;
    }else{
        bvc.firstHTML = NULL;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self performSegueWithIdentifier:@"goBrouser" sender:self];
}

#pragma mark UITableView DataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    return [newsArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    
    News* item = [newsArray objectAtIndex:indexPath.row];
    
    
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
                //
                UIImageView* imV = (UIImageView *)view;
                imV.image = [UIImage imageNamed:@"noImage.jpg"];
                NSString* imageURL=@"";
                if(item.image != NULL){
                    imageURL = item.image;
                }else if (item.site.image != NULL){
                    imageURL = item.site.image;
                }else if (item.site.game.image != NULL){
                    imageURL = item.site.game.image;
                }
                
                if(item.imageData != NULL){
                    imV.image = [UIImage imageWithData:item.imageData];
                }else if(![imageURL isEqual: @""]){
                    //
                    
                    dispatch_queue_t q_global = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
                    dispatch_queue_t q_main = dispatch_get_main_queue();
                    dispatch_async(q_global, ^{
                        
                        NSData* data = [NSData dataWithContentsOfURL:[NSURL URLWithString:imageURL]];
                        item.imageData = data;
                        
                        dispatch_async(q_main, ^{
                            imV.image = [UIImage imageWithData:data];
                            
                        });
                        
                    });
                    
                }
            }
                break;
            case 6:
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
            case 4:
            {
                UILabel* textView = (UILabel*) view;
                //textView.text = item.site.name;
                textView.text = [NSString stringWithFormat:@"%@", item.memo.contents];
                
                
                
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
                NSDate *date = [[item memo] updateDate];
                NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
                [formatter setDateFormat:@"yyyy/MM/dd HH:mm"];
                textView.text = [NSString stringWithFormat:@"メモ更新日時: %@",[formatter stringFromDate:date]];
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
    News *selected = [newsArray objectAtIndex:indexPath.row];
    
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
    
    News *selected = [newsArray objectAtIndex:indexPath.row];
    
    
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
    [self refresh];
}

- (IBAction)editDoneButtonPressed:(id)sender {
    
    [_textView resignFirstResponder];
    
    editingMemo.contents = _textView.text;
    
    //データが変更されていれば更新日時を書き換え
    if (![initialTextOfEditingMemo isEqualToString:[_textView text]]) {
        
//        NSDateFormatter *outputFormatter = [[NSDateFormatter alloc] init];
//        [outputFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
//        NSLog([outputFormatter stringFromDate:[NSDate date]]);
//        NSLog([outputFormatter stringFromDate:[NSDate dateWithTimeIntervalSinceNow:
//                                               [[NSTimeZone systemTimeZone] secondsFromGMT]]]);

        
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

- (void) setNewsHavingMemo
{
    //長さ1以上のメモを取得
    NSArray* memoArray = [ForUseCoreData getAllMemoOrderByDate];
    
    newsArray = [NSMutableArray array];
    
    for (Memo* memo in memoArray) {
        
        if([memo.news.site.unuse  isEqual: @(0)])
            [newsArray addObject:memo.news];
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
