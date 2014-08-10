//
//  DetailSettingViewController.h
//  GameMatome
//
//  Created by Hiroyuki Yahagi on 2014/08/10.
//  Copyright (c) 2014年 Hiroyuki Yahagi. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Game;

@interface DetailSettingViewController : UIViewController
<UITableViewDataSource, UITableViewDelegate>
{
    NSMutableArray* sitesArray;
}

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, retain) Game* selectedGame;


@property (weak, nonatomic) IBOutlet UINavigationItem *naviItem;


- (IBAction)doneButtonPressed:(id)sender;

@end
