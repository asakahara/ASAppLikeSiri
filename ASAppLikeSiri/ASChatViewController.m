//
//  ASViewController.m
//  ASAppLikeSiri
//
//  Created by sakahara on 2013/12/17.
//  Copyright (c) 2013年 Mocology. All rights reserved.
//

#import "ASChatViewController.h"
#import "ASChatManager.h"

static const NSString * kYou = @"あなた";
static const NSString * kOpponent = @"ひつじくん";

@interface ASChatViewController () <JSMessagesViewDataSource, JSMessagesViewDelegate>

@property (strong, nonatomic) NSMutableArray *messages;
@property (strong, nonatomic) NSMutableArray *timestamps;
@property (strong, nonatomic) NSMutableArray *subtitles;
@property (strong, nonatomic) NSDictionary *avatars;
@property (strong, nonatomic) NSString *context;

@end

@implementation ASChatViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	
    self.delegate = self;
    self.dataSource = self;
    
    [[JSBubbleView appearance] setFont: [UIFont systemFontOfSize:16.0]];
    
    self.title = @"Messages";
    
    self.messageInputView.textView.placeHolder = @"Message";
    
    self.messages = [[NSMutableArray alloc] init];
    self.timestamps = [[NSMutableArray alloc] init];
    self.subtitles = [[NSMutableArray alloc] init];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.messages.count;
}

#pragma mark - Messages view delegate: REQUIRED

- (void)didSendText:(NSString *)text
{
    [self.messages addObject:text];
    [self.timestamps addObject:[NSDate date]];
    [self.subtitles addObject:kYou];
    
    [self finishSend];
    [self scrollToBottomAnimated:YES];
    
    [JSMessageSoundEffect playMessageSentSound];
    
    __weak typeof(self) weakSelf = self;
    
    [[ASChatManager sharedManager]
     fetchChatRequest:text context:self.context completionHandler:^(NSDictionary *result, NSError *error) {
         if (!error) {
             
             [weakSelf.messages addObject:result[@"utt"]];
             [weakSelf.timestamps addObject:[NSDate date]];
             [weakSelf.subtitles addObject:kOpponent];
             
             weakSelf.context = result[@"context"];
             
             [weakSelf finishSend];
             [weakSelf scrollToBottomAnimated:YES];
             
             [JSMessageSoundEffect playMessageReceivedSound];
         }
    }];
}

- (JSBubbleMessageType)messageTypeForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self.subtitles[indexPath.row] isEqual:kYou]) {
        return JSBubbleMessageTypeOutgoing;
    }
    return JSBubbleMessageTypeIncoming;
}

- (UIImageView *)bubbleImageViewWithType:(JSBubbleMessageType)type
                       forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self.subtitles[indexPath.row] isEqual:kYou]) {
        return [JSBubbleImageViewFactory bubbleImageViewForType:type
                                                          color:[UIColor js_bubbleGreenColor]];
    }
    
    return [JSBubbleImageViewFactory bubbleImageViewForType:type
                                                      color:[UIColor js_bubbleLightGrayColor]];
}

- (JSMessagesViewTimestampPolicy)timestampPolicy
{
    return JSMessagesViewTimestampPolicyEveryThree;
}

- (JSMessagesViewAvatarPolicy)avatarPolicy
{
    return JSMessagesViewAvatarPolicyAll;
}

- (JSMessagesViewSubtitlePolicy)subtitlePolicy
{
    return JSMessagesViewSubtitlePolicyAll;
}

- (JSMessageInputViewStyle)inputViewStyle
{
    return JSMessageInputViewStyleFlat;
}

#pragma mark - Messages view delegate: OPTIONAL

- (BOOL)shouldPreventScrollToBottomWhileUserScrolling
{
    return YES;
}

#pragma mark - Messages view data source: REQUIRED

- (NSString *)textForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [self.messages objectAtIndex:indexPath.row];
}

- (NSDate *)timestampForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [self.timestamps objectAtIndex:indexPath.row];
}

- (UIImageView *)avatarImageViewForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return nil;
}

- (NSString *)subtitleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [self.subtitles objectAtIndex:indexPath.row];
}

@end
