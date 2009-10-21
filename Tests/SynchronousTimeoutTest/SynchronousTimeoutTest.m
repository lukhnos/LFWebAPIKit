#import <Foundation/Foundation.h>
#import "LFHTTPRequest.h"

static NSString *kSourceURLString = @"http://localhost/~lukhnos/timeout.php";

@interface Foo : NSObject
@end

@implementation Foo
- (void)httpRequest:(LFHTTPRequest *)request didReceiveStatusCode:(NSUInteger)statusCode URL:(NSURL *)url responseHeader:(CFHTTPMessageRef)header
{
	NSLog(@"status: %d", statusCode);
	if (statusCode != 200) {
		[request cancelWithoutDelegateMessage];
		[self httpRequest:request didFailWithError:LFHTTPRequestConnectionError];
	}
}

- (void)httpRequestDidComplete:(LFHTTPRequest *)request
{
	NSLog(@"completed: %@", [[[NSString alloc] initWithData:request.receivedData encoding:NSUTF8StringEncoding] autorelease]);
}

- (void)httpRequest:(LFHTTPRequest *)request didFailWithError:(NSString *)error
{
	NSLog(@"error: %@, session info: %@", error, request.sessionInfo);
	
	if ([request.sessionInfo integerValue] == 5) {
		return;
	}
	else {
		// test reentrance
		
		request.sessionInfo = [NSNumber numberWithInteger:[request.sessionInfo integerValue] + 1];
		[request performMethod:LFHTTPRequestGETMethod onURL:[NSURL URLWithString:kSourceURLString] withData:nil];
	}
}
@end


int main (int argc, const char * argv[])
{
    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];

	Foo *foo = [[[Foo alloc] init] autorelease];
	
	LFHTTPRequest *request = [[[LFHTTPRequest alloc] init] autorelease];
	request.shouldWaitUntilDone = YES;
	request.delegate = foo;
	request.timeoutInterval = 2.0;
    
	NSLog(@"start");
	
	// Replace the URL with yours
	[request performMethod:LFHTTPRequestGETMethod onURL:[NSURL URLWithString:kSourceURLString] withData:nil];
	
	[pool drain];
    return 0;
}
