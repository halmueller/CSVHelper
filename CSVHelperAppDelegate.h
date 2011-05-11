//
//  CSVHelperAppDelegate.h
//  CSVHelper
//
//  Created by Hal Mueller on 5/5/11.
//  Copyright 2011 Hal Mueller. All rights reserved.
//
//  Permission is given to use this source code file, free of charge, in any
//  project, commercial or otherwise, entirely at your risk, with the condition
//  that any redistribution (in part or whole) of source code must retain
//  this copyright and permission notice. Attribution in compiled projects is
//  appreciated but not required.
//

#import <Cocoa/Cocoa.h>

@class CSVDirectoryProcessor;
@interface CSVHelperAppDelegate : NSObject <NSApplicationDelegate> {
    NSWindow *window;
	IBOutlet NSTextField *workingDirectoryField;
	CSVDirectoryProcessor *processor;
}

@property (assign) IBOutlet NSWindow *window;
@property (retain, nonatomic) CSVDirectoryProcessor *processor;

#pragma mark defaults
extern NSString *workingDirectoryKey;
extern NSString *useCoreDataKey;
extern NSString *useMOGeneratorKey;
extern NSString *trimWhitespaceKey;

- (IBAction)go:(id)sender;
- (IBAction)changeWorkingDirectory:(id)sender;

@end
