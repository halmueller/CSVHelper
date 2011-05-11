//
//  CSVDirectoryProcessor.m
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

#import "CSVDirectoryProcessor.h"
#import "CSVParser.h"

@implementation CSVDirectoryProcessor

@synthesize inputDirectory;
@synthesize outputDirectory;
@synthesize useCoreData;
@synthesize useMOGenerator;
@synthesize trimWhitespace;
@synthesize summary;
@synthesize classNames;
@synthesize headerFileStrings;
@synthesize implementationFileStrings;
@synthesize invocationMethods;
@synthesize callbackMethods;

//=========================================================== 
// - (id)init
//
//=========================================================== 
- (id)init
{
    if ((self = [super init])) {
        self.useCoreData = YES;
        self.useMOGenerator = YES;
		self.summary = [NSMutableString string];
        self.classNames = [NSMutableArray array];
        self.headerFileStrings = [NSMutableDictionary dictionary];
        self.implementationFileStrings = [NSMutableDictionary dictionary];
        self.invocationMethods = [NSMutableDictionary dictionary];
        self.callbackMethods = [NSMutableDictionary dictionary];
    }
    return self;
}


//=========================================================== 
// dealloc
//=========================================================== 
- (void)dealloc
{
    self.inputDirectory = nil;
    self.outputDirectory = nil;
    self.classNames = nil;
	self.summary = nil;
    self.headerFileStrings = nil;
    self.implementationFileStrings = nil;
    self.invocationMethods = nil;
    self.callbackMethods = nil;
	
    [super dealloc];
}

- (NSString *)boilerplateHForCSVFile:(NSDictionary *)headers
						   classname:(NSString *)classname
{
	[self.summary appendFormat:@"Class %@\n", classname];
	[headers enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
		[self.summary appendFormat:@"    %@\n", [obj lowercaseString]];
	}];
	[self.summary appendString:@"------------\n\n"];
	
	NSMutableString *result = [NSMutableString string];
	if (useCoreData) {
		if (useMOGenerator) {
			[result appendFormat:@"#import \"_%@.h\"\n\n", classname];
			[result appendFormat:@"@interface %@ : _%@ {\n", classname, classname];
		}
		else {
			[result appendFormat:@"@interface %@ : NSManagedObject {\n", classname, classname];			
		}
	}
	else {
		[result appendFormat:@"@interface %@ : NSObject {\n", classname, classname];			
	}
	
	if (!useMOGenerator) {
		[headers enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
			[result appendFormat:@"    NSObject *%@;\n", [obj lowercaseString]];
		}];	
	}
	[result appendString:@"}\n\n"];
	if (!useMOGenerator) {
		[headers enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
			[result appendFormat:@"@property (nonatomic, retain) NSObject *%@;\n", [obj lowercaseString]];
		}];	
	}
	[result appendString:@"@end\n\n"];
	return result;
}

- (NSString *)boilerplateMForCSVHeaders:(NSDictionary *)headers
							  classname:(NSString *)classname
{
	NSMutableString *result = [NSMutableString string];
	[result appendFormat:@"#import \"%@.h\"\n\n", classname];
	[result appendFormat:@"@implementation %@\n\n", classname];
	
	
	if (useCoreData && !useMOGenerator) {
		[headers enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
			[result appendFormat:@"@dynamic %@;\n", [obj lowercaseString]];
		}];	
	}
	else if (!useCoreData) {
		[headers enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
			[result appendFormat:@"@synthesize %@;\n", [obj lowercaseString]];
		}];	
	}
	[result appendString:@"\n\n@end\n\n"];
	return result;
}

- (NSString *)callbackNameForClassname:(NSString *)classname
{
	return [NSString stringWithFormat:@"handleParsed%@Row:", classname];
}

- (NSString *)contentsStringNameForClassname:(NSString *)classname
{
	return [NSString stringWithFormat:@"raw%@String", classname];
}

- (NSString *)parserCallbackForHeaders:(NSDictionary *)headers
							 classname:(NSString *)classname
{
	NSMutableString *result = [NSMutableString stringWithFormat:@"- (void)%@(NSDictionary *)theRecord\n{\n",
							   [self callbackNameForClassname:classname]];
	if (self.useCoreData) {
		if (self.useMOGenerator) {
			// CoreData with MOGenerator
			[result appendFormat:@"\%@ *theInstance = [%@ insertInManagedObjectContext:self.managedObjectContext];\n",
			 classname, classname];
		}
		else {
			// vanilla Core Data
			[result appendFormat:@"\%@ *theInstance = (%@ *)[NSEntityDescription insertNewObjectForEntityForName:%@ inManagedObjectContext:self.managedObjectContext];\n",
			 classname, classname, classname];
		}
	}
	else {
		// NSObjects
		[result appendFormat:@"\%@ *theInstance = [[%@ alloc] init];\n\n",
		 classname, classname];
	}
	
	[headers enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
		if (self.trimWhitespace) {
			[result appendFormat:@"theInstance.%@ = [[theRecord objectForKey:@\"%@\"] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];\n",
			 [obj lowercaseString], obj];
		}
		else{
			[result appendFormat:@"theInstance.%@ = [theRecord objectForKey:@\"%@\"];\n",
			 [obj lowercaseString], obj];
		}
	}];
	
	if (!self.useCoreData) {
		[result appendFormat:@"\n// before releasing, should do something with theInstance\n[theInstance release];\n"];
	}
	[result appendString:@"}\n\n"];
	return result;
}

- (NSString *)parserCallsForCSVFile:(NSURL *)csvfile
							headers:(NSDictionary *)headers
						  classname:(NSString *)classname
{
	NSMutableString *result = [NSMutableString string];
	NSString *parserVar = [NSString stringWithFormat:@"%@Parser", classname];
	
	[result appendFormat:@"NSString *%@ = [NSString stringWithContentsOfURL:[NSURL URLWithString:@\"%@\"]\n\
	 encoding:NSUTF8StringEncoding\n\
	 error:nil];\nNSAssert(%@, @\"could not read %@\");\n\n",
	 [self contentsStringNameForClassname:classname], 
	 [csvfile absoluteString], 
	 [self contentsStringNameForClassname:classname], [csvfile absoluteString]];
	
	[result appendFormat:@"CSVParser *%@ = \n\
	 [[CSVParser alloc]\n\
	 initWithString:%@\n\
	 separator:@\",\"\n\
	 hasHeader:YES\n\
	 fieldNames:[NSArray arrayWithObjects:", parserVar, [self contentsStringNameForClassname:classname]];
	
	[headers enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {[result appendFormat:@"@\"%@\",", obj];}];
	[result appendFormat:@"\n    nil]];\n\
	 [%@ parseRowsForReceiver:self selector:@selector(%@)];\n\
	 [%@ release];\n\n\n", 
	 parserVar, [self callbackNameForClassname:classname], parserVar];
	
	return result;
}

- (NSDictionary *)generateClassFilesAndHeadersForCSVFile:(NSURL *)csvfile
											   classname:(NSString *)classname
{
	MGLog(@"%@ %@", csvfile, classname);
	
	NSError *error;
	NSString *csvString = [NSString stringWithContentsOfURL:csvfile
												   encoding:NSUTF8StringEncoding
													  error:&error];
	if (!csvString)
		[NSApp presentError:error];
	CSVParser *parser = [[CSVParser alloc] initWithString:csvString
												separator:@","
												hasHeader:NO
											   fieldNames:nil];
	NSArray *allRows = [parser arrayOfParsedRows];
	NSDictionary *headers = nil;
	if (allRows.count > 0)
		headers = [allRows objectAtIndex:0];
	NSString *interfaceFileContents = [self boilerplateHForCSVFile:headers 
														 classname:classname];
	[self.headerFileStrings setObject:interfaceFileContents forKey:classname];
	
	NSString *implementationFileContents = [self boilerplateMForCSVHeaders:headers 
																 classname:classname];
	[self.implementationFileStrings setObject:implementationFileContents forKey:classname];
	
	[parser release];
	
	return headers;
}

- (void)engage
{
	[self processInputs];
	[self writeOutputs];
}

- (void)addParserInvocationForClass:(NSString *)classname
							headers:(NSDictionary *)headers
							dataURL:(NSURL *)dataURL
{
	[self.invocationMethods setObject:[self parserCallsForCSVFile:dataURL
														  headers:headers
														classname:classname]
							   forKey:classname];
}

- (void)addParserCallbackForClass:(NSString *)classname
						  headers:(NSDictionary *)headers
{
	[self.callbackMethods setObject:[self parserCallbackForHeaders:headers
														 classname:classname]
							 forKey:classname];
}

- (void)processInputs
{
	LogMethod();
	NSError *error;
	NSArray *allFiles = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:[self.inputDirectory path]
																			error:&error];
	if (!allFiles) {
		NSLog(@"inputDirectory %@", self.inputDirectory);
		[NSApp presentError:error];
		return;
	}
	
	for (NSString *filename in allFiles) {
		if ([filename hasSuffix:@".csv"]) {
			NSString *classname = [[filename stringByDeletingPathExtension] capitalizedString];
			[self.classNames addObject:classname];
			NSURL *dataURL = [self.inputDirectory 
							  URLByAppendingPathComponent:filename];
			NSDictionary *headers = [self generateClassFilesAndHeadersForCSVFile:dataURL
																	   classname:classname];
			
			[self addParserInvocationForClass:classname
									  headers:headers
									  dataURL:dataURL];
			[self addParserCallbackForClass:classname
									headers:headers];
		}
	}
}

- (void)writeOutputs
{
	NSString *summaryPath = [[self.outputDirectory URLByAppendingPathComponent:@"CSV classes summary.txt"] path];
	if (![[NSFileManager defaultManager] createFileAtPath:summaryPath
												 contents:[self.summary dataUsingEncoding:NSUTF8StringEncoding]
											   attributes:nil])
		NSLog(@"failed to create summary.txt");
	
	NSMutableString *invocationsText = [NSMutableString string];
	NSMutableString *callbacksText = [NSMutableString string];
	NSMutableString *importsText = [NSMutableString string];
	
	for (NSString *classname in self.classNames) {
		[importsText appendFormat:@"#import \"%@.h\"\n", classname];
		[invocationsText appendString:[self.invocationMethods objectForKey:classname]];
		[invocationsText appendFormat:@"NSLog(@\"%@ complete\");\n\n", classname];
		[callbacksText appendString:[self.callbackMethods objectForKey:classname]];
		
		if ((self.useCoreData && !self.useMOGenerator) ||
			!self.useCoreData) {
			NSString *headerPath = [[self.outputDirectory URLByAppendingPathComponent:[NSString stringWithFormat:@"%@.h", classname]] path];
			NSString *implementationPath = [[self.outputDirectory URLByAppendingPathComponent:[NSString stringWithFormat:@"%@.m", classname]] path];
			BOOL headerOK = [[NSFileManager defaultManager] createFileAtPath:headerPath
																	contents:[[self.headerFileStrings objectForKey:classname] dataUsingEncoding:NSUTF8StringEncoding]
																  attributes:nil];
			if (!headerOK)
				NSLog(@"failed to create header file %@", headerPath);
			
			BOOL implementationOK = [[NSFileManager defaultManager] createFileAtPath:implementationPath
																			contents:[[self.implementationFileStrings objectForKey:classname] dataUsingEncoding:NSUTF8StringEncoding]
																		  attributes:nil];
			if (!implementationOK)
				NSLog(@"failed to create implementation file %@", implementationPath);
		}
	}
	
	NSString *allCode = [NSString stringWithFormat:@"%@\n\n%@\n\n- (void)performImport:(id)sender\n{\n%@\n}\n",
						 importsText, callbacksText, invocationsText];
	NSString *invocationsPath = [[self.outputDirectory URLByAppendingPathComponent:@"MyDocument-partial.m"] path];
	if (![[NSFileManager defaultManager] createFileAtPath:invocationsPath
												 contents:[allCode dataUsingEncoding:NSUTF8StringEncoding]
											   attributes:nil])
		NSLog(@"failed to create MyDocument-partial.m");
}
@end
