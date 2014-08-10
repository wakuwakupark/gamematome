//
//  ForUseCoreData.m
//  GameMatome
//
//  Created by Hiroyuki Yahagi on 2014/08/02.
//  Copyright (c) 2014年 Hiroyuki Yahagi. All rights reserved.
//

#import "ForUseCoreData.h"

@implementation ForUseCoreData

static NSManagedObjectContext* managedObjectContext;


#define MODEL_NAME @"GameMatome"
#define DB_NAME @"GameMatome.splite"

+ (NSURL*)createStoreURL {
    NSArray *directories = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *path = [[directories lastObject] stringByAppendingPathComponent:DB_NAME];
    NSURL *storeURL = [NSURL fileURLWithPath:path];
    return storeURL;
}

+ (NSURL*)createModelURL {
    NSBundle *mainBundle = [NSBundle mainBundle];
    NSString *path = [mainBundle pathForResource:MODEL_NAME ofType:@"momd"];
    NSURL *modelURL = [NSURL fileURLWithPath:path];
    return modelURL;
}

+ (NSManagedObjectContext*)createManagedObjectContext {
    NSURL *modelURL = [self createModelURL];
    NSURL *storeURL = [self createStoreURL];
    NSError *error = nil;
    NSManagedObjectModel *managedObjectModel=[[NSManagedObjectModel alloc]initWithContentsOfURL:modelURL];
    NSPersistentStoreCoordinator *persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:managedObjectModel];
    [persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error];
    NSManagedObjectContext *managedObjectContent = [[NSManagedObjectContext alloc] init];
    [managedObjectContent setPersistentStoreCoordinator:persistentStoreCoordinator];
    return managedObjectContent;
}

+ (void) setManagedObejctContext: (NSManagedObjectContext*) man{
    managedObjectContext = man;
}

+ (NSManagedObjectContext*) getManagedObjectContext{
    if(managedObjectContext == NULL)
        managedObjectContext = [self createManagedObjectContext];
    
    return managedObjectContext;
}

+ (NSArray *)getEntityDataEntityNameWithEntityName:(NSString *)entityName
{
    NSEntityDescription *entity = [NSEntityDescription entityForName:entityName inManagedObjectContext:[self getManagedObjectContext]];
    
    NSFetchRequest *request = [[NSFetchRequest alloc]init];
    //取ってくるエンティティの設定を行う
    [request setEntity:entity];

    //比較対象を直接描くのがポイント
//    NSPredicate *predicate =[NSPredicate predicateWithFormat:@"labelA == %@",searchString];
//    [request setPredicate:predicate];
    
    NSError *error = nil;
    
    //データのフェッチを行う Data Fetching.
    return [[self getManagedObjectContext] executeFetchRequest:request error:&error];
    
}

+(NSArray *)getEntityDataEntityNameWithEntityName:(NSString *)entityName condition:(NSString *)condition
{
    NSEntityDescription *entity = [NSEntityDescription entityForName:entityName inManagedObjectContext:[self getManagedObjectContext]];
    
    NSFetchRequest *request = [[NSFetchRequest alloc]init];
    //取ってくるエンティティの設定を行う
    [request setEntity:entity];
    
    //比較対象を直接描く
    NSPredicate *predicate =[NSPredicate predicateWithFormat:condition];
    [request setPredicate:predicate];
    
    NSError *error = nil;
    
    //データのフェッチを行う Data Fetching.
    return [[self getManagedObjectContext] executeFetchRequest:request error:&error];
}

+ (NSArray *)getAllNewsOrderByDate
{
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"News" inManagedObjectContext:[self getManagedObjectContext]];
    
    NSFetchRequest *request = [[NSFetchRequest alloc]init];
    //取ってくるエンティティの設定を行う
    [request setEntity:entity];
    
    NSPredicate *predicate =[NSPredicate predicateWithFormat:@"unuse==0"];
    [request setPredicate:predicate];
    
    //dateでソート
    NSSortDescriptor *sortDesc =[NSSortDescriptor sortDescriptorWithKey:@"date" ascending:NO];
    [request setSortDescriptors:[NSArray arrayWithObject:sortDesc]];
    
    NSError *error = nil;
    
    //データのフェッチを行う Data Fetching.
    return [[self getManagedObjectContext] executeFetchRequest:request error:&error];
}

+ (NSArray *)getFavoriteNewsOrderByDate
{
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"News" inManagedObjectContext:[self getManagedObjectContext]];
    
    NSFetchRequest *request = [[NSFetchRequest alloc]init];
    //取ってくるエンティティの設定を行う
    [request setEntity:entity];
    
    
    NSPredicate *predicate =[NSPredicate predicateWithFormat:@"favorite==1&&unuse==0"];
    [request setPredicate:predicate];
    
    
    //dateでソート
    NSSortDescriptor *sortDesc =[NSSortDescriptor sortDescriptorWithKey:@"date" ascending:NO];
    [request setSortDescriptors:[NSArray arrayWithObject:sortDesc]];
    
    NSError *error = nil;
    
    //データのフェッチを行う Data Fetching.
    return [[self getManagedObjectContext] executeFetchRequest:request error:&error];
}


+ (void)deleteObjectsFromTable:(NSString*) entity
{
    //削除対象のフェッチ情報を生成
    NSFetchRequest *deleteRequest = [[NSFetchRequest alloc] init];
    [deleteRequest setEntity:[NSEntityDescription entityForName:entity inManagedObjectContext:managedObjectContext]];
    [deleteRequest setIncludesPropertyValues:NO]; //managed object IDのみフェッチ
    
    NSError *error = nil;
    
    //生成したフェッチ情報からデータをフェッチ
    NSArray *results = [managedObjectContext executeFetchRequest:deleteRequest error:&error];
    //[deleteRequest release]; //ARCオフの場合
    
    //フェッチしたデータを削除処理
    for (NSManagedObject *data in results) {
        [managedObjectContext deleteObject:data];
    }
    
    NSError *saveError = nil;
    
    //削除を反映
    [managedObjectContext save:&saveError];
}

+ (void)deleteAllObjects
{
    [self deleteObjectsFromTable:@"Memo"];
    [self deleteObjectsFromTable:@"News"];
    [self deleteObjectsFromTable:@"Site"];
    [self deleteObjectsFromTable:@"Game"];
    
}



@end
