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
#import "ColorParser.h"

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
    
    //広告の設定    
    NSUserDefaults* ud = [NSUserDefaults standardUserDefaults];
    if([[ud valueForKey:@"test"] isEqualToString:@"0"]){
        //広告の設定
        bannerView = [[GADBannerView alloc]initWithAdSize:kGADAdSizeBanner];
        //bannerView = [[GADBannerView alloc]init];
        bannerView.adUnitID = @"ca-app-pub-9624460734614700/2538576676";
        bannerView.rootViewController = self;
        [self.view addSubview:bannerView];
        [bannerView loadRequest:[GADRequest request]];
        int height = [[UIScreen mainScreen] bounds].size.height;
        [bannerView setFrame:CGRectMake(0, height-100, 320, 50)];
    }

    
    gamesArray = [ForUseCoreData getEntityDataEntityNameWithEntityName:@"Game"];

    
    _tableView.delegate = self;
    _tableView.dataSource = self;
    
    UINib *nib = [UINib nibWithNibName:@"SettingTableViewCell" bundle:nil];
    [_tableView registerNib:nib forCellReuseIdentifier:@"Cell"];
    
    if([[ud valueForKey:@"test"] isEqualToString:@"1"]){
        [_tableView setFrame:CGRectMake(_tableView.frame.origin.x, _tableView.frame.origin.y, _tableView.frame.size.width, _tableView.frame.size.height+50)];
    }
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
    
    //cell.textLabel.text = [game name];
    
    if(game.color == NULL)
        cell.backgroundColor = [UIColor whiteColor];
    else
        cell.backgroundColor = [ColorParser parseFromRGBString:game.color read:false];
    
    //各ボタンにイベントを設定
    for(UIView* view in cell.contentView.subviews){
        
        switch (view.tag) {
            case 1:
            {
                UIButton* button = (UIButton *)view;
                [button addTarget:self action:@selector(onClickUnuseButton:event:) forControlEvents:UIControlEventTouchUpInside];
                
                if([[game unuse]integerValue] == 1){
                    button.selected = true;
                    button.titleLabel.textColor = [UIColor whiteColor];
                    button.backgroundColor = [UIColor lightGrayColor];
                }else{
                    button.selected = false;
                    button.titleLabel.textColor = [UIColor whiteColor];
                    button.backgroundColor = [UIColor blueColor];
                }
            }
                break;
                
            case 2:
            {
                UILabel* label = (UILabel*)view;
                label.text =[game name];
            }
                break;
                
            case 3:
            {
                //
                UIImageView* imV = (UIImageView *)view;
                imV.image = [UIImage imageNamed:@"noImage.jpg"];
                NSString* imageURL=@"";
                if (game.image != NULL){
                    imageURL = game.image;
                }
                
                if(game.imageData != NULL){
                    imV.image = [UIImage imageWithData:game.imageData];
                }else if(![imageURL isEqual: @""]){
                    //
                    
                    dispatch_queue_t q_global = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
                    dispatch_queue_t q_main = dispatch_get_main_queue();
                    dispatch_async(q_global, ^{
                        
                        NSData* data = [NSData dataWithContentsOfURL:[NSURL URLWithString:imageURL]];
                        game.imageData = data;
                        
                        dispatch_async(q_main, ^{
                            imV.image = [UIImage imageWithData:data];
                            
                        });
                        
                    });
                    
                }
            }
                break;
                
        }
    }
    
    //cell.textLabel.frame = CGRectMake(0, 0, 250, 60);
    
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self performSegueWithIdentifier:@"goDetail" sender:self];
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
                }else{
                    [selected changeUnuseState:1];
                }
            }
                break;
        }
    }
    
    [_tableView reloadData];
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


- (IBAction)reviewButton:(id)sender {
    NSUserDefaults* ud = [NSUserDefaults standardUserDefaults];
    NSString* url = [ud objectForKey:@"myituneURL"];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
}


@end
