- (void)handleParsedAustralianpostcodesRow:(NSDictionary *)theRecord
{
Australianpostcodes *theInstance = [[Australianpostcodes alloc] init];

theInstance.longitude = [theRecord objectForKey:@"longitude"];
theInstance.latitude = [theRecord objectForKey:@"latitude"];
theInstance.type = [theRecord objectForKey:@"type"];
theInstance.postoffice = [theRecord objectForKey:@"postOffice"];
theInstance.state = [theRecord objectForKey:@"state"];
theInstance.suburb = [theRecord objectForKey:@"suburb"];
theInstance.postcode = [theRecord objectForKey:@"postcode"];

// before releasing, should do something with theInstance
[theInstance release];
}



- (void)performImport:(id)sender
{
NSString *rawAustralianpostcodesString = [NSString stringWithContentsOfURL:[NSURL URLWithString:@"file://localhost/Users/hal/Downloads/CSVImporter/AustralianPostcodes.csv"]
	 encoding:NSUTF8StringEncoding
	 error:nil];
NSAssert(rawAustralianpostcodesString, @"could not read file://localhost/Users/hal/Downloads/CSVImporter/AustralianPostcodes.csv");

CSVParser *AustralianpostcodesParser = 
	 	[[CSVParser alloc]
	 	  initWithString:rawAustralianpostcodesString
		  separator:@","
		  hasHeader:YES
	 fieldNames:[NSArray arrayWithObjects:@"longitude",@"latitude",@"type",@"postOffice",@"state",@"suburb",@"postcode",
    nil]];
	 [AustralianpostcodesParser parseRowsForReceiver:self selector:@selector(handleParsedAustralianpostcodesRow:)];
	 [AustralianpostcodesParser release];



}
