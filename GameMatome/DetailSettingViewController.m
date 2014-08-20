//
//  DetailSettingViewController.m
//  GameMatome
//
//  Created by Hiroyuki Yahagi on 2014/08/10.
//  Copyright (c) 2014年 Hiroyuki Yahagi. All rights reserved.
//

#import "DetailSettingViewController.h"
#import "Game.h"
#import "Site.h"
#import "ForUseCoreData.h"
#import "BrouserViewController.h"
#import "GADBannerView.h"

@interface DetailSettingViewController ()

@end

@implementation DetailSettingViewController

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
    [bannerView setFrame:CGRectMake(0, 518, 320, 50)];
    
    
    _tableView.delegate = self;
    _tableView.dataSource = self;
    
    _naviItem.title = _selectedGame.name;
    
    sitesArray = [NSMutableArray array];
    for(Site* s in [_selectedGame sites]){
        [sitesArray addObject:s];
    }

    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillDisappear:(BOOL)animated
{
    [[ForUseCoreData getManagedObjectContext] save:NULL];
}

- (void)viewWillAppear:(BOOL)animated
{
    [_tableView reloadData];
}


#pragma mark TableView

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    
    Site* site = [sitesArray objectAtIndex:indexPath.row];
    
    //各ボタンにイベントを設定
    for(UIView* view in cell.contentView.subviews){
        
        switch (view.tag) {
            case 1:
            {
                UIButton* button = (UIButton *)view;
                [button addTarget:self action:@selector(onClickUnuseButton:event:) forControlEvents:UIControlEventTouchUpInside];
                
                if([[site unuse]integerValue] == 1){
                    button.selected = false;
                }else{
                    button.selected = true;
                }
            }
                break;
        }
    }
    
    
    cell.textLabel.text = site.name;
    
    return cell;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [sitesArray count];
}



// ボタンタップ時に実行される処理
- (void)onClickUnuseButton:(UIButton *)button event:(UIEvent *)event
{
    // タップされたボタンから、対応するセルを取得する
    NSIndexPath *indexPath = [self indexPathForControlEvent:event];
    UITableViewCell *cell = (UITableViewCell *)[self.tableView cellForRowAtIndexPath:indexPath];
    
    //お気に入り追加
    Site *selected = [sitesArray objectAtIndex:indexPath.row];
    
    //各ボタンにイベントを設定
    for(UIView* view in cell.contentView.subviews){
        switch (view.tag) {
            case 1:
            {
                if([[selected unuse]integerValue] == 1){
                    [selected changeUnuseState:0];
                    [_selectedGame setUnuse:@(0)];
                    button.selected = true;
                    
                }else{
                    [selected changeUnuseState:1];
                    button.selected = false;
                    
                }
            }
                break;
        }
    }
    
}



// UIControlEventからタッチ位置のindexPathを取得する
- (NSIndexPath *)indexPathForControlEvent:(UIEvent *)event
{
    UITouch *touch = [[event allTouches] anyObject];
    CGPoint p = [touch locationInView:self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:p];
    return indexPath;
}



#pragma mark 画面遷移

- (IBAction)doneButtonPressed:(id)sender {
    
    [self dismissViewControllerAnimated:YES completion:NULL];
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    Site* selected = [sitesArray objectAtIndex:[[_tableView indexPathForSelectedRow] row]];
    
    BrouserViewController* bvc = [segue destinationViewController];
    bvc.firstURL = selected.pageURL;
    bvc.showingNews = NULL;
    bvc.showingSite = selected;
    
}

@end
