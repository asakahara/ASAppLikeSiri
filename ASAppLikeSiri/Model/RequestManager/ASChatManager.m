//
//  ASChatRequestManager.m
//  ASAppLikeSiri
//
//  Created by sakahara on 2013/12/17.
//  Copyright (c) 2013年 Mocology. All rights reserved.
//

#import "ASChatManager.h"
#import "AFHTTPRequestOperationManager.h"

@implementation ASChatManager

static const NSString * API_KEY = @"xxxxx";

+ (instancetype)sharedManager
{
    static ASChatManager *_sharedManager= nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedManager = [[ASChatManager alloc] init];
    });
    
    return _sharedManager;
}

- (void)fetchChatRequest:(NSString *)comment context:(NSString *)context completionHandler:(void (^)(NSDictionary *result, NSError *error)) completionHandler
{
    AFHTTPRequestOperationManager* manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    
    if (!context) context = @"";
    
    // パラメータの設定
    NSDictionary* param = @{@"utt" : comment, @"context" : context};
    [manager POST:[NSString stringWithFormat:
                   @"https://api.apigw.smt.docomo.ne.jp/dialogue/v1/dialogue?APIKEY=%@", API_KEY]
       parameters:param success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSLog(@"response: %@", responseObject);
        
        if (completionHandler) {
            completionHandler(responseObject, nil);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
        
        if (completionHandler) {
            completionHandler(nil, error);
        }
    }];
}

@end
