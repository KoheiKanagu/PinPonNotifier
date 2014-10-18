//
//  PinPonPublisher.m
//  PinPonNotifier
//
//  Created by Kohei on 2014/10/19.
//  Copyright (c) 2014年 KoheiKanagu. All rights reserved.
//

#import "PinPonPublisher.h"

#import "PinPonPublisher.h"
#define SERVICE_TYPE @"_pinponnotifier._tcp"

@implementation PinPonPublisher
@synthesize delegate;

#pragma mark - Publish
-(void)initPublish
{
    srand((unsigned)time(NULL));
    portNum = rand()%10000;
    
    self.mySocketPort = [[NSSocketPort alloc]initWithTCPPort:portNum];
    if(self.mySocketPort){
        [self initNetService];
    }else{
        NSLog(@"Publish : Socket init Error");
        NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:10
                                                          target:self
                                                        selector:@selector(socketPortInitTimerAction:)
                                                        userInfo:nil
                                                         repeats:YES];
        [timer fire];
    }
}

-(void)socketPortInitTimerAction:(NSTimer *)timer
{
    NSLog(@"Publish : Socket init");
    
    self.mySocketPort = [[NSSocketPort alloc]initWithTCPPort:portNum];
    if(self.mySocketPort){
        [timer invalidate];
        [self initNetService];
    }else{
        NSLog(@"Publish : Socket init Error(Timer)");
    }
}

-(void)initNetService
{
    self.myNetService = [[NSNetService alloc]initWithDomain:@"local."
                                                       type:SERVICE_TYPE
                                                       name:[[NSHost currentHost] localizedName]
                                                       port:portNum];
    if(self.myNetService){
        [self.myNetService setDelegate:self];
        [self.myNetService scheduleInRunLoop:[NSRunLoop currentRunLoop]
                                     forMode:NSRunLoopCommonModes];
        [self.myNetService publish];
    }else{
        NSLog(@"Publish : NetService init Error");
    }
}


#pragma mark - NetService

-(void)netService:(NSNetService *)sender didNotPublish:(NSDictionary *)errorDict
{
    NSLog(@"Publish : %@", [errorDict objectForKey:NSLocalizedDescriptionKey]);
}

-(void)netService:(NSNetService *)sender didNotResolve:(NSDictionary *)errorDict
{
    NSLog(@"Publish : %@", [errorDict objectForKey:NSLocalizedDescriptionKey]);
}

-(void)netServiceWillPublish:(NSNetService *)sender
{
    NSLog(@"Publish : Will%@", sender);
}

-(void)netServiceDidPublish:(NSNetService *)sender
{
    NSLog(@"Publish : Did%@", sender);
    self.mySocketHandle = [[NSFileHandle alloc]initWithFileDescriptor:[self.mySocketPort socket]
                                                       closeOnDealloc:YES];
    if(self.mySocketHandle){
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(acceptConnect:)
                                                     name:NSFileHandleConnectionAcceptedNotification
                                                   object:self.mySocketHandle];
        [self.mySocketHandle acceptConnectionInBackgroundAndNotify];
    }else{
        NSLog(@"Publish : SoketHandle init Error");
    }
}

-(void)acceptConnect:(NSNotification *)aNotification
{
    NSLog(@"Publish : Accept Connect");
    
    self.myReadHandle = [[aNotification userInfo] objectForKey:NSFileHandleNotificationFileHandleItem];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(recieveData:)
                                                 name:NSFileHandleDataAvailableNotification
                                               object:self.myReadHandle];
    [self.myReadHandle waitForDataInBackgroundAndNotify];
}

-(void)recieveData:(NSNotification *)aNotification
{
    NSData *data = [self.myReadHandle availableData];
    [delegate receivedData:data];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:NSFileHandleDataAvailableNotification
                                                  object:self.myReadHandle];
    [self.myReadHandle closeFile];
    [self.mySocketHandle acceptConnectionInBackgroundAndNotify];
}

-(void)stopPublish
{
    self.mySocketPort = nil;
    [self.mySocketHandle closeFile];
    [self.myNetService stop];
    [self.myReadHandle closeFile];
}

@end
