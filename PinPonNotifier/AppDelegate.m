//
//  AppDelegate.m
//  PinPonNotifier
//
//  Created by Kohei on 2014/10/19.
//  Copyright (c) 2014年 KoheiKanagu. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate ()

@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    [self setupStatusItem];
    
    users = [NSMutableArray new];
    
    pinPublisher = [[PinPonPublisher alloc]init];
    [pinPublisher setDelegate:self];
    [pinPublisher initPublish];
    
    pinSearcher = [[PinPonSearcher alloc]init];
    [pinSearcher setDelegate:self];
    [pinSearcher initSearch];
}

-(void)applicationWillTerminate:(NSNotification *)aNotification
{
    [[NSNotificationCenter defaultCenter] removeObserver:pinPublisher];
    [pinPublisher stopPublish];
    [pinSearcher stopSearch];
}

-(void)setupStatusItem
{
    NSStatusBar *systemStatusBar = [NSStatusBar systemStatusBar];
    statusItem = [systemStatusBar statusItemWithLength:NSVariableStatusItemLength];
    [statusItem setHighlightMode:YES];
    [statusItem setTitle:@"P"];
    [statusItem setMenu:myMenu];
}


-(void)findNetService:(NSNetService *)aNetService
{
    [users addObject:aNetService];
    
    NSMenuItem *item = [[NSMenuItem alloc]initWithTitle:aNetService.name
                                                 action:@selector(clickedMenuItem:)
                                          keyEquivalent:@""];
    [myMenu insertItem:item
               atIndex:[users indexOfObject:aNetService]];
}

-(void)removeNetService:(NSNetService *)aNetService
{
    NSInteger index = [users indexOfObject:aNetService];
    [users removeObject:aNetService];
    
    [myMenu removeItemAtIndex:index];
}

-(void)clickedMenuItem:(NSMenuItem *)item
{
    NSInteger index = [myMenu indexOfItem:item];
    NSNetService *service = users[index];
    [pinSearcher connectionTo:service
                     sendData:[self makeSendData]];
}

-(NSData *)makeSendData
{
    NSDictionary *dic = @{@"name" : [[NSHost currentHost] localizedName]};
    return [NSArchiver archivedDataWithRootObject:dic];
}


-(void)receivedData:(NSData *)data
{
    NSDictionary *dic = [NSUnarchiver unarchiveObjectWithData:data];
    [self deliverNotificationFrom:[dic objectForKey:@"name"]];
}


-(void)deliverNotificationFrom:(NSString *)name
{
    NSUserNotification *myNotification = [[NSUserNotification alloc]init];
    [myNotification setTitle:[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleDisplayName"]];
    [myNotification setSubtitle:@"ピンポン!"];
    [myNotification setSoundName:NSUserNotificationDefaultSoundName];
    [myNotification setInformativeText:[NSString stringWithFormat:@"%@さんが呼んでます。", name]];
    [[NSUserNotificationCenter defaultUserNotificationCenter] deliverNotification:myNotification];
    
    NSLog(@"%@", myNotification);
}

@end
