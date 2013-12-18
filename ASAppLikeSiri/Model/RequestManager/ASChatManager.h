//
//  ASChatRequestManager.h
//  ASAppLikeSiri
//
//  Created by sakahara on 2013/12/17.
//  Copyright (c) 2013年 Mocology. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ASChatManager : NSObject

+ (instancetype)sharedManager;

- (void)fetchChatRequest:(NSString *)comment context:(NSString *)context completionHandler:(void (^)(NSDictionary *result, NSError *error)) completionHandler;

@end
