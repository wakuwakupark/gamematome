//
//  BrouserViewController.m
//  GameMatome
//
//  Created by Hiroyuki Yahagi on 2014/06/07.
//  Copyright (c) 2014年 Hiroyuki Yahagi. All rights reserved.
//

#import "BrouserViewController.h"
#import "News.h"
#import "Memo.h"
#import "Site.h"
#import "Game.h"
#import "ForUseCoreData.h"

@interface BrouserViewController ()

@end

@implementation BrouserViewController

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
    
    //広告の設定
    bannerView = [[GADBannerView alloc]initWithAdSize:kGADAdSizeBanner];
    bannerView.adUnitID = @"ca-app-pub-9624460734614700/2398975874";
    bannerView.rootViewController = self;
    [self.view addSubview:bannerView];
    [bannerView loadRequest:[GADRequest request]];
    int height = [[UIScreen mainScreen] bounds].size.height;
    [bannerView setFrame:CGRectMake(0, height-94, 320, 50)];
    
    _editButton.enabled = YES;
    if(_showingNews != NULL){
        _naviItem.title = _showingNews.title;
    }else{
        if (_showingSite !=NULL) {
            _naviItem.title = _showingSite.name;
        }else{
            _editButton.enabled = NO;
            _naviItem.title = _buffer;
        }
    }
    
    _doneButton.hidden = YES;
    _textView.hidden = YES;
    _backgroundView.hidden = YES;
    
    _webView.delegate = self;
    
    _backButton.enabled = NO;
    _proceedButton.enabled = NO;
    
    [self registerForKeyboardNotifications];
    
    /* 左スワイプ */
    UISwipeGestureRecognizer* swipeRightGesture = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(goBackListButtonPressed:)];
    
    // 左スワイプを認識するように設定
    swipeRightGesture.direction = UISwipeGestureRecognizerDirectionRight;
    
    // ビューにジェスチャーを追加
    [self.view addGestureRecognizer:swipeRightGesture];

}

- (void)viewDidAppear:(BOOL)animated
{
    //_firstURL = [[_firstURL componentsSeparatedByString:@"\n"] objectAtIndex:0];
    
    
    if(_firstHTML != NULL){
        [_webView loadHTMLString:_firstHTML baseURL:[NSURL URLWithString: _firstURL]];
    }else{
        [_webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString: _firstURL]]];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [[ForUseCoreData getManagedObjectContext] save:NULL];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



- (IBAction)BackButtonPressed:(id)sender {
    [_webView goBack];
}

- (IBAction)ProceedButtonPressed:(id)sender {
    [_webView goForward];
}

- (IBAction)refreshButtonPressed:(id)sender {
    [_webView reload];
}

- (IBAction)goBackListButtonPressed:(id)sender {
    [self dismissViewControllerAnimated:YES completion:NULL];
}

- (IBAction)noteButtonPressed:(id)sender {
    _editingMemo = [_showingNews memo];
    if(_editingMemo == NULL){
        _editingMemo = (Memo*)[NSEntityDescription insertNewObjectForEntityForName:@"Memo" inManagedObjectContext:[ForUseCoreData getManagedObjectContext]];
    }
    
    //データの読み込み
    _textView.text = _editingMemo.contents;
    initialTextOfEditingMemo = _editingMemo.contents;
    
    //表示
    [self fadeinMemoView];
    
    
}

- (IBAction)editDoneButtonPressed:(id)sender {
    
    [_textView resignFirstResponder];
    
    _editingMemo.contents = _textView.text;
    
    _showingNews.memo = _editingMemo;
    _editingMemo.news = _showingNews;
    
    if(![initialTextOfEditingMemo isEqualToString:[_textView text]]){
        _editingMemo.updateDate =  [NSDate date];
    }
    
    [[ForUseCoreData getManagedObjectContext] save:NULL];
    
    [self fadeOutMemoView];
}


- (IBAction)actionButtonPressed:(id)sender {
    
    //アクションシートの生成と設定
    UIActionSheet *sheet = [[UIActionSheet alloc] init];
    
    //デリゲートをセット
    sheet.delegate = self;
    
    //タイトルとボタンの文言設定
    
    [sheet addButtonWithTitle:@"Lineで共有"];
    [sheet addButtonWithTitle:@"twitterで共有"];
    [sheet addButtonWithTitle:@"Safariで開く"];
    
    if(_showingNews != NULL){
        [sheet addButtonWithTitle:@"お気に入りに追加"];
        
        [sheet addButtonWithTitle:@"キャンセル"];
        
        //キャンセルボタンをボタン3に設定
        sheet.cancelButtonIndex = 4;
        
    }else if (_showingSite != NULL){
        if([[_showingSite unuse] integerValue] == 0){
            [sheet addButtonWithTitle:@"購読しない"];
        }else{
            [sheet addButtonWithTitle:@"購読する"];
        }
        
        [sheet addButtonWithTitle:@"キャンセル"];
    
        //キャンセルボタンをボタン3に設定
        sheet.cancelButtonIndex = 4;
    }else{
        [sheet addButtonWithTitle:@"キャンセル"];
        
        //キャンセルボタンをボタン3に設定
        sheet.cancelButtonIndex = 3;
    }
    
    //アクションシートのスタイルを
    sheet.actionSheetStyle = UIActionSheetStyleDefault;
    
    //アクションシートを表示
    [sheet showInView:self.view];
    
}

-(void)actionSheet:(UIActionSheet*)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    switch (buttonIndex) {
        case 3:
            //お気に入り追加/購読
            if(_showingNews != NULL){
                [[self showingNews] setFavorite:@(1)];
            }else if(_showingSite != NULL){
                if([[_showingSite unuse] integerValue] == 0){
                    [[self showingSite] changeUnuseState:1];
                }else{
                    [[self showingSite] changeUnuseState:0];
                    [[[self showingSite] game] setUnuse:@(0)];
                }
            }
            break;
            
        case 0:
            //facebook
            [self sendLine];
            break;
        case 1:
            //twitter
            [self sendTwitter];
            break;
        case 2:
        {
            //safari
            NSURL *url = [NSURL URLWithString:[_webView stringByEvaluatingJavaScriptFromString:@"document.URL"]];
            [[UIApplication sharedApplication] openURL:url];
        }
            break;
    }
    
}


- (void) fadeinMemoView
{
    //Viewを透明にする
    [_backgroundView setAlpha:0.0];
    
    // アニメーション
    [UIView beginAnimations:nil context:NULL];
    // 秒数設定
    [UIView setAnimationDuration:0.1];
    [_backgroundView setAlpha:1];
    
    _doneButton.hidden = NO;
    _textView.hidden = NO;
    _backgroundView.hidden = NO;
    
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

- (void) sendLine
{
    NSString *plainString = [NSString stringWithFormat:@"%@\n%@\n%@",[_naviItem title],[self urlForSend],[[NSUserDefaults standardUserDefaults] objectForKey:@"myituneURL"]];
    
    NSString *contentKey = (__bridge NSString *)
    CFURLCreateStringByAddingPercentEscapes(NULL,
                                            (CFStringRef)plainString,
                                            NULL,
                                            (CFStringRef)@"!*'();:@&=+$,/?%#[]",
                                            kCFStringEncodingUTF8 );
    NSString *contentType = @"text";
    NSString *urlString = [NSString
                           stringWithFormat: @"http://line.naver.jp/R/msg/%@/?%@",
                           contentType, contentKey];
    NSURL *url = [NSURL URLWithString:urlString];
    [[UIApplication sharedApplication] openURL:url];
}

- (void) sendFacebook
{
    SLComposeViewController *facebookPostVC = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeFacebook];
    NSString* postContent = [_naviItem title];
    [facebookPostVC setInitialText:postContent];
    [facebookPostVC addURL:[NSURL URLWithString:[self urlForSend]]]; // URL文字列_
//    [facebookPostVC addImage:[UIImage imageNamed:@"image_name_string"]]; // 画像名（文字列）
    [self presentViewController:facebookPostVC animated:YES completion:nil];
}

- (void) sendTwitter
{
    NSString* postContent = [_naviItem title];
    
    NSURL* appURL = [NSURL URLWithString:[[NSUserDefaults standardUserDefaults] objectForKey:@"myituneURL"]];
    
    
    
    // =========== iOSバージョンで、処理を分岐 ============
    // iOS Version
    NSString *iosVersion = [[[UIDevice currentDevice] systemVersion] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    // Social.frameworkを使う
    if ([iosVersion floatValue] >= 6.0) {
        SLComposeViewController *twitterPostVC = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
        [twitterPostVC setInitialText:postContent];
        [twitterPostVC addURL:appURL]; // アプリURL
        [self presentViewController:twitterPostVC animated:YES completion:nil];
    }
    // Twitter.frameworkを使う
    else if ([iosVersion floatValue] >= 5.0) {
        // Twitter画面を保持するViewControllerを作成する。
        TWTweetComposeViewController *twitter = [[TWTweetComposeViewController alloc] init];
        // 初期表示する文字列を指定する。
        [twitter setInitialText:postContent];
        // TweetにURLを追加することが出来ます。
        [twitter addURL:appURL];
        // Tweet後のコールバック処理を記述します。
        // ブロックでの記載となり、引数にTweet結果が渡されます。
        twitter.completionHandler = ^(TWTweetComposeViewControllerResult res) {
            if (res == TWTweetComposeViewControllerResultDone)
                NSLog(@"tweet done.");
            else if (res == TWTweetComposeViewControllerResultCancelled)
                NSLog(@"tweet canceled.");
        };
        // Tweet画面を表示します。
        [self presentModalViewController:twitter animated:YES];
    }
}

- (NSString*) urlForSend
{
    if(_showingNews == NULL){
        return [_showingSite pageURL];
    }else{
        return [_showingNews contentURL];
    }
}


#pragma mark webView

- (void)webViewDidStartLoad:(UIWebView *)webView {

    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    
    _backButton.enabled = [webView canGoBack];
    _proceedButton.enabled = [webView canGoForward];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {

    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    
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
    [_doneButton setFrame:CGRectMake(254.0, 100, 46.0, 30.0)];
    [_textView setFrame:CGRectMake(20,140, 280, 200)];
}


- (void)keyboardWillBeHidden:(NSNotification*)aNotification
{
    [_doneButton setFrame:CGRectMake(254.0, 144.0, 46.0, 30.0)];
    [_textView setFrame:CGRectMake(20,182, 280, 267)];
}



@end
