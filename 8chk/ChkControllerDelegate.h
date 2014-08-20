//
//  ChkControllerDelegate.h
//  8chk
//
//  Ver 5.3.2
//
//  Created by Tatsuya Uemura on 11/09/03.
//  Copyright 2011 8crops inc. All rights reserved.
//

@protocol ChkControllerDelegate <NSObject>

- (void) chkControllerDataListWithSuccess:(NSDictionary *)data;
- (void) chkControllerDataListWithError:(NSError*)error;

@optional
- (void) chkControllerDataListWithNotFound:(NSDictionary *)data;

@end
