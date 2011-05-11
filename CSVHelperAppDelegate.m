//
//  CSVHelperAppDelegate.m
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

#import "CSVHelperAppDelegate.h"
#import "CSVParser.h"
#import "CSVDirectoryProcessor.h"

@implementation CSVHelperAppDelegate

@synthesize window;
@synthesize processor;

NSString *workingDirectoryKey = @"workingDirectory";
NSString *useCoreDataKey = @"useCoreData";
NSString *useMOGeneratorKey = @"useMOGenerator";
NSString *trimWhitespaceKey = @"trimWhitespace";

- (void)initializeDefaults {
	NSMutableDictionary *defaultValues = [NSMutableDictionary dictionary];
    
	[defaultValues setValue:NSHomeDirectory() forKey:workingDirectoryKey];
	[defaultValues setValue:[NSNumber numberWithBool:YES] forKey:useCoreDataKey];
	[defaultValues setValue:[NSNumber numberWithBool:YES] forKey:useMOGeneratorKey];
	[[NSUserDefaults standardUserDefaults] registerDefaults:defaultValues];
}

- (IBAction)changeWorkingDirectory:(id)sender
{
	// for this wrapper, I'm using the same directory for input and output, but CSVDirectoryProcessor supports separate directories
	LogMethod();
	NSOpenPanel *panel = [NSOpenPanel openPanel];
	panel.canChooseDirectories = YES;
	panel.canChooseFiles = NO;
	panel.directoryURL = [NSURL fileURLWithPath:[[NSUserDefaults standardUserDefaults] valueForKey:workingDirectoryKey]
									isDirectory:YES];
	[panel beginSheetModalForWindow:self.window
				  completionHandler:^(NSInteger result) 
	 {[[NSUserDefaults standardUserDefaults] setValue:[panel.directoryURL path]
											   forKey:workingDirectoryKey];}];
}

- (IBAction)go:(id)sender
{
	LogMethod();
	NSLog(@"%@", [[NSUserDefaults standardUserDefaults] valueForKey:workingDirectoryKey]);
	NSURL *from = [NSURL fileURLWithPath:[[NSUserDefaults standardUserDefaults] valueForKey:workingDirectoryKey]
							 isDirectory:YES];
	NSURL *to = [NSURL fileURLWithPath:[[NSUserDefaults standardUserDefaults] valueForKey:workingDirectoryKey]
						   isDirectory:YES];
	self.processor = [[CSVDirectoryProcessor alloc] init];
	self.processor.inputDirectory = from;
	self.processor.outputDirectory = to;
	self.processor.useCoreData = [[NSUserDefaults standardUserDefaults] boolForKey:useCoreDataKey];
	self.processor.useMOGenerator = [[NSUserDefaults standardUserDefaults] boolForKey:useMOGeneratorKey];
	self.processor.trimWhitespace = [[NSUserDefaults standardUserDefaults] boolForKey:trimWhitespaceKey];
	[self.processor engage];
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
	// Insert code here to initialize your application 
	[self initializeDefaults];
}

@end
