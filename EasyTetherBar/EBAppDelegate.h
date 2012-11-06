//
//  EBAppDelegate.h
//  EasyTetherBar
//
//  Created by Tokusei Noborio on 12/11/06.
//  Copyright (c) 2012年 Nyampass Corporation. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface EBAppDelegate : NSObject <NSApplicationDelegate>
{
    NSWindow *window;
    IBOutlet NSMenu *statusMenu;
    NSStatusItem * statusItem;
}

@property (assign) IBOutlet NSWindow *window;

- (IBAction)doOn:(id)sender;
- (IBAction)doOff:(id)sender;
- (IBAction)doQuit:(id)sender;

@end
