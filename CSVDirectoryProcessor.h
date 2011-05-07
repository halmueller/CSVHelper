//
//  CSVDirectoryProcessor.h
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

#import <Foundation/Foundation.h>


@interface CSVDirectoryProcessor : NSObject {
	NSURL *inputDirectory;
	NSURL *outputDirectory;
	BOOL useCoreData;
	BOOL useMOGenerator;
	BOOL trimWhitespace;
	NSMutableString *summary;
	NSMutableArray *classNames;
	NSMutableDictionary *headerFileStrings;
	NSMutableDictionary *implementationFileStrings;
	NSMutableDictionary *invocationMethods;
	NSMutableDictionary *callbackMethods;
}

@property (nonatomic, copy) NSURL *inputDirectory;
@property (nonatomic, copy) NSURL *outputDirectory;
@property (nonatomic) BOOL useCoreData;
@property (nonatomic) BOOL useMOGenerator;
@property (nonatomic) BOOL trimWhitespace;
@property (nonatomic, retain) NSMutableString *summary;
@property (nonatomic, retain) NSMutableArray *classNames;
@property (nonatomic, retain) NSMutableDictionary *headerFileStrings;
@property (nonatomic, retain) NSMutableDictionary *implementationFileStrings;
@property (nonatomic, retain) NSMutableDictionary *invocationMethods;
@property (nonatomic, retain) NSMutableDictionary *callbackMethods;

- (void)engage;
- (void)processInputs;
- (void)writeOutputs;
@end
