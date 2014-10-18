//
//  PinPonSearcher.h
//  PinPonNotifier
//
//  Created by Kohei on 2014/10/19.
//  Copyright (c) 2014年 KoheiKanagu. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol PinPonSearcherDelegate <NSObject>
@required
-(void)findNetService:(NSNetService *)aNetService;
-(void)removeNetService:(NSNetService *)aNetService;
@end


@interface PinPonSearcher : NSObject <NSNetServiceDelegate, NSNetServiceBrowserDelegate, NSStreamDelegate>
{
    NSOutputStream *outputStream;
    NSData *willSendData;
}

@property NSNetServiceBrowser *myServiceBrowser;
@property NSNetService *myNetService;


@property id<PinPonSearcherDelegate>delegate;

-(void)initSearch;
-(void)connectionTo:(NSNetService *)netService sendData:(NSData *)data;
-(void)stopSearch;

@end

