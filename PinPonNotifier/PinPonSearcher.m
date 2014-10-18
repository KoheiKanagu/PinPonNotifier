//
//  PinPonSearcher.m
//  PinPonNotifier
//
//  Created by Kohei on 2014/10/19.
//  Copyright (c) 2014年 KoheiKanagu. All rights reserved.
//

#import "PinPonSearcher.h"

#import "PinPonSearcher.h"
#define SERVICE_TYPE @"_pinponnotifier._tcp"

@implementation PinPonSearcher
@synthesize delegate;

-(void)initSearch
{
    self.myServiceBrowser = [[NSNetServiceBrowser alloc]init];
    [self.myServiceBrowser setDelegate:self];
    [self.myServiceBrowser searchForServicesOfType:SERVICE_TYPE
                                          inDomain:@"local."];
}

-(void)netServiceBrowser:(NSNetServiceBrowser *)aNetServiceBrowser didFindService:(NSNetService *)aNetService moreComing:(BOOL)moreComing
{
    NSLog(@"Searcher : Find %@", aNetService);
    [delegate findNetService:aNetService];
}

-(void)netServiceBrowser:(NSNetServiceBrowser *)aNetServiceBrowser didRemoveService:(NSNetService *)aNetService moreComing:(BOOL)moreComing
{
    NSLog(@"Searcher : Remove %@", aNetService);
    [delegate removeNetService:aNetService];
}

-(void)netServiceBrowser:(NSNetServiceBrowser *)aNetServiceBrowser didNotSearch:(NSDictionary *)errorDict
{
    NSLog(@"Searcher : %@", [errorDict objectForKey:NSLocalizedDescriptionKey]);
}

-(void)connectionTo:(NSNetService *)netService sendData:(NSData *)data
{
    willSendData = data;
    self.myNetService = [[NSNetService alloc]initWithDomain:[netService domain]
                                                       type:[netService type]
                                                       name:[netService name]];
    if(self.myNetService){
        [self.myNetService setDelegate:self];
        [self.myNetService resolveWithTimeout:5];
        NSLog(@"Searcher : Connect %@", netService);
    }else{
        NSLog(@"Searcher : NetService init Error");
    }
}

-(void)netService:(NSNetService *)sender didNotResolve:(NSDictionary *)errorDict
{
    NSLog(@"Searcher : %@", [errorDict objectForKey:NSLocalizedDescriptionKey]);
}

-(void)netServiceDidResolveAddress:(NSNetService *)sender
{
    NSInputStream *inputStream;
    
    if([sender getInputStream:&inputStream
                 outputStream:&outputStream]){
        NSLog(@"Searcher : Resolved %@", sender);
    }else{
        NSLog(@"Searcher : Get input output Error");
        return;
    }
    
    if(outputStream){
        [outputStream open];
        [outputStream write:[willSendData bytes]
                  maxLength:[willSendData length]];
        [outputStream close];
        [inputStream close];
        
        willSendData = nil;
        NSLog(@"Searcher : Send");
    }
}

-(void)stopSearch
{
    [self.myServiceBrowser stop];
    [self.myNetService stop];
}


@end
