//
//  AppDelegate.h
//  PinPonNotifier
//
//  Created by Kohei on 2014/10/19.
//  Copyright (c) 2014年 KoheiKanagu. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "PinPonPublisher.h"
#import "PinPonSearcher.h"

@interface AppDelegate : NSObject <NSApplicationDelegate, PinPonSearcherDelegate, PinPonPublisherDelegate>
{
    IBOutlet NSMenu *myMenu;
    NSStatusItem *statusItem;
    
    PinPonPublisher *pinPublisher;
    PinPonSearcher *pinSearcher;
    
    NSMutableArray *users;
}

@end
