//
//  PinPonPublisher.h
//  PinPonNotifier
//
//  Created by Kohei on 2014/10/19.
//  Copyright (c) 2014年 KoheiKanagu. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol PinPonPublisherDelegate <NSObject>
@required
-(void)receivedData:(NSData *)data;
@end


@interface PinPonPublisher : NSObject <NSNetServiceDelegate>
{
    int portNum;
}

@property id<PinPonPublisherDelegate>delegate;
@property NSSocketPort *mySocketPort;
@property NSNetService *myNetService;
@property NSFileHandle *mySocketHandle;
@property NSFileHandle *myReadHandle;

-(void)initPublish;
-(void)stopPublish;

@end