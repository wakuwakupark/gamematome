//
//  SettingViewController.m
//  GameMatome
//
//  Created by Hiroyuki Yahagi on 2014/06/07.
//  Copyright (c) 2014年 Hiroyuki Yahagi. All rights reserved.
//

#import "SettingViewController.h"
#import "ForUseCoreData.h"
#import "Game.h"
#import "DetailSettingViewController.h"

@interface SettingViewController ()

@end

@implementation SettingViewController

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
    // Do any additional setup after loading the view.
    gamesArray = [ForUseCoreData getEntityDataEntityNameWithEntityName:@"Game"];

    
    _tableView.delegate = self;
    _tableView.dataSource = self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [_tableView reloadData];
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

#pragma tableView 

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    
    Game* game = [gamesArray objectAtIndex:indexPath.row];
    
    cell.textLabel.text = [game name];
    
    //各ボタンにイベントを設定
    for(UIView* view in cell.contentView.subviews){
        
        switch (view.tag) {
            case 1:
            {
                UIButton* button = (UIButton *)view;
                [button addTarget:self action:@selector(onClickUnuseButton:event:) forControlEvents:UIControlEventTouchUpInside];
                
                if([[game unuse]integerValue] == 1){
                    button.selected = false;
                }else{
                    button.selected = true;
                }
            }
                break;
        }
    }
    
    return cell;
}



// ボタンタップ時に実行される処理
- (void)onClickUnuseButton:(UIButton *)button event:(UIEvent *)event
{
    // タップされたボタンから、対応するセルを取得する
    NSIndexPath *indexPath = [self indexPathForControlEvent:event];
    UITableViewCell *cell = (UITableViewCell *)[self.tableView cellForRowAtIndexPath:indexPath];
    
    //お気に入り追加
    Game *selected = [gamesArray objectAtIndex:indexPath.row];
    
    //各ボタンにイベントを設定
    for(UIView* view in cell.contentView.subviews){
        switch (view.tag) {
            case 1:
            {
                if([[selected unuse]integerValue] == 1){
                    [selected changeUnuseState:0];
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


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [gamesArray count];
}



- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    DetailSettingViewController* dvc = [segue destinationViewController];
    
    Game* selected = [gamesArray objectAtIndex:[[_tableView indexPathForSelectedRow] row]];
    
    [dvc setSelectedGame:selected];
}


@end
