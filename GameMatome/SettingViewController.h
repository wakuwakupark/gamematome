//
//  SettingViewController.h
//  GameMatome
//
//  Created by Hiroyuki Yahagi on 2014/06/07.
//  Copyright (c) 2014年 Hiroyuki Yahagi. All rights reserved.
//

#import <UIKit/UIKit.h>

@class GADBannerView;

@interface SettingViewController : UIViewController<UITableViewDelegate,UITableViewDataSource>
{
    NSArray* gamesArray;
    
    
    GADBannerView* bannerView;
}

@property (weak, nonatomic) IBOutlet UITableView *tableView;


- (IBAction)reviewButton:(id)sender;


@end
