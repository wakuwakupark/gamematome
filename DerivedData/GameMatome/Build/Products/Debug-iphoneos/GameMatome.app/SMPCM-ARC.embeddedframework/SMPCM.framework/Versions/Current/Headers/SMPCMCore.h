//
//  SMPCMCore.h
//  SMPCMDemo
//
//  Created by Akira Matsuda on 2014/02/13.
//  Copyright (c) 2014年 Link-U. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 SMPCM SDKの機能を呼び出すためのクラスです。
 ARCにのみ対応しております。
 アプリのインストール追跡や、サーバへ広告表示の成果通知の処理をすべて担います。
 */
@interface SMPCMCore : NSObject

/**
 *  広告の表示モード
 */
typedef NS_ENUM(NSUInteger, SMPCMPlayerType) {
	/**
	 *  ポップアップで広告を表示します。
	 */
	SMPCMPlayerTypePopUp,
	/**
	 *  フルスクリーンで広告を表示します。動画がキャッシュされていない場合はポップアップで広告を表示します。
	 */
	SMPCMPlayerTypeFullscreen,
};

/**
 SDKのバージョンを示す文字列を返します。
 
 @return バージョンの文字列
 */
+ (NSString *)getVersionString;

/**
 SDKによる処理を開始します。
 
 @warning 起動時に広告を表示するに必ず呼び出さなければならなりません。デフォルトではポップアップで広告を表示します。
 */
+ (void)start;

/**
 *  SDKによる処理を開始します。
 *
 *  @param type 広告の表示モードを指定します。
 */
+ (void)startWithPlayerType:(SMPCMPlayerType)type;

/**
 保存するキャッシュの最大容量を設定します。
 
 @warning 明示的に設定しない場合は、10MBがキャッシュの最大容量となります。

 @param byte バイト数
 */
+ (void)setTotalFileSize:(NSInteger)byte;

/**
 *  キャッシュしているファイルをすべて削除します。
 */
+ (void)clearCache;

/**
 メディアキーの設定をします。

 @param mediaKey メディアキーの文字列
 */
+ (void)setMediaKey:(NSString *)mediaKey;

/**
 *  全画面で動画広告を表示します。
 *
 *  @param checkpoint 表示したタイミングの名前
 */
+ (void)showFullscreenView:(NSString *)checkpoint;

/**
 ポップアップ広告を表示します。

 @param checkpoint 表示したタイミングの名前
 */
+ (void)showPopUpView:(NSString *)checkpoint;

@end
