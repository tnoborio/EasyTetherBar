//
//  EBAppDelegate.m
//  EasyTetherBar
//
//  Created by Tokusei Noborio on 12/11/06.
//  Copyright (c) 2012年 Nyampass Corporation. All rights reserved.
//

#import "EBAppDelegate.h"

@implementation EBAppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // Insert code here to initialize your application
}

- (void)updateMenuTitle
{
    [statusItem setTitle: [self isRunningEasyTheger]? @"EasyTether(On)": @"EasyTether(Off)"];
}

-(void)awakeFromNib
{
    statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength];
    [statusItem setMenu:statusMenu];
    
    [self updateMenuTitle];
    
    [statusItem setHighlightMode:YES];
    
//    [self runDtrace:nil];
}

- (BOOL)isRunningEasyTheger
{
    NSTask *task;
    task = [[NSTask alloc] init];
    [task setLaunchPath: @"/usr/sbin/kextstat"];
    
    NSPipe *pipe;
    pipe = [NSPipe pipe];
    [task setStandardOutput: pipe];
    
    NSFileHandle *file;
    file = [pipe fileHandleForReading];
    
    [task launch];
    
    NSData *data;
    data = [file readDataToEndOfFile];
    
    NSString *string = [[NSString alloc] initWithData:data encoding: NSUTF8StringEncoding];
    return [string rangeOfString:@"EasyTether"].location != NSNotFound;
}

- (NSFileHandle *)run:(BOOL)isStart
{
    OSStatus myStatus;
    AuthorizationFlags myFlags=kAuthorizationFlagDefaults;
    AuthorizationRef myAuthorizationRef;
    
    myStatus=AuthorizationCreate(NULL, kAuthorizationEmptyEnvironment, myFlags, &myAuthorizationRef);
    if(myStatus!=errAuthorizationSuccess) return nil;
    
    do{
        {
            AuthorizationItem myItems={kAuthorizationRightExecute, 0, NULL, 0};
            AuthorizationRights myRights={1, &myItems};
            myFlags=kAuthorizationFlagDefaults | kAuthorizationFlagInteractionAllowed | kAuthorizationFlagPreAuthorize | kAuthorizationFlagExtendRights;
            myStatus=AuthorizationCopyRights(myAuthorizationRef, &myRights, NULL, myFlags, NULL);
        }
        if(myStatus!=errAuthorizationSuccess) break;
        
        {
            char *toolPath;
            if (isStart) {
                toolPath = "/sbin/kextload";
            } else {
                toolPath = "/sbin/kextunload";
            }

            char *arguments[2];
            FILE *pipe=NULL;
        
            arguments[0]="/System/Library/Extensions/EasyTetherUSBEthernet.kext";
            arguments[1]=NULL;

            myFlags=kAuthorizationFlagDefaults;
            myStatus=AuthorizationExecuteWithPrivileges(myAuthorizationRef, toolPath, myFlags, arguments, &pipe);
            if(myStatus==errAuthorizationSuccess){
                NSLog(@"launch success");
                AuthorizationFree(myAuthorizationRef, kAuthorizationFlagDefaults);
                return [[NSFileHandle alloc] initWithFileDescriptor:fileno(pipe)];
            }
        }
    }while(0);
    
    AuthorizationFree(myAuthorizationRef, kAuthorizationFlagDefaults); 
    return nil;
}

- (IBAction)doOn:(id)sender
{
    [self run:YES];
    [NSTimer scheduledTimerWithTimeInterval:0.1f target:self selector:@selector(updateMenuTitle) userInfo:nil repeats:nil];
//    [self updateMenuTitle];
}

- (IBAction)doOff:(id)sender
{
    [self run:NO];
    [self updateMenuTitle];

}

- (IBAction)doQuit:(id)sender
{
    [NSApp terminate:nil];
}


@end
