/*
 KOAuth
 MIT License
 https://github.com/Kelp404/KOAuth
 
 Fork from https://github.com/tweetdeck/TDOAuth Max Howell <max@tweetdeck.com>
 */

#import "KOAuth.h"
#import <CommonCrypto/CommonHMAC.h>

#if defined (__GNUC__) && (__GNUC__ >= 4)
#define KOAUTH_ATTRIBUTES(attr, ...) __attribute__((attr, ##__VA_ARGS__))
#else  // defined (__GNUC__) && (__GNUC__ >= 4)
#define KOAUTH_ATTRIBUTES(attr, ...)
#endif
#define KOAUTH_BURST_LINK static __inline__ KOAUTH_ATTRIBUTES(always_inline)



/*
 OAuth requires the UTC timestamp we send to be accurate. The user's device
 may not be, and often isn't. To work around this you should set this to the
 UTC timestamp that you get back in HTTP header from OAuth servers.
 */
#define KOAUTH_UTC_TIME_OFFSET 0


@interface KOAuth()

#pragma mark - Generate Request
- (NSMutableURLRequest *)getRequestWittURL:(NSURL *)url andMethod:(NSString *)method;
- (NSMutableString *)getParametersString:(NSDictionary *)unencodedParameters;

#pragma mark - Signature
- (NSString *)signatureWithURL:(NSURL *)url andMethod:(NSString *)method;
KOAUTH_BURST_LINK NSString *signatureBase(NSMutableDictionary *params, NSMutableDictionary *queryParams, NSString *method, NSURL *url);
- (NSString *)getAuthorization:(NSDictionary *)params url:(NSURL *)url method:(NSString *)method;

#pragma mark - Shared
KOAUTH_BURST_LINK NSString *urlEncode(NSString *source);
KOAUTH_BURST_LINK void chomp(NSMutableString *source);
KOAUTH_BURST_LINK NSString *nonce();
KOAUTH_BURST_LINK NSString *timestamp();
// If your input string isn't 20 characters this won't work.
KOAUTH_BURST_LINK NSString *base64(const uint8_t *input);

@end


@implementation KOAuth


#pragma mark - Init
- (id)initWithConsumerKey:(NSString *)consumerKey consumerSecret:(NSString *)consumerSecret accessToken:(NSString *)accessToken tokenSecret:(NSString *)tokenSecret
{
    _params = @{@"oauth_consumer_key" : consumerKey,
                    @"oauth_nonce" : nonce(),
                    @"oauth_timestamp" : timestamp(),
                    @"oauth_version" : @"1.0",
                    @"oauth_signature_method" : @"HMAC-SHA1",
                    @"oauth_token" : accessToken ? : @""
    };
    _signature_secret = [NSString stringWithFormat:@"%@&%@", consumerSecret, tokenSecret ? : @"" ];
    return self;
}

- (id)initForRequestTokenWithConsumerKey:(NSString *)consumerKey consumerSecret:(NSString *)consumerSecret
{
    _params = @{@"oauth_consumer_key" : consumerKey,
                    @"oauth_nonce" : nonce(),
                    @"oauth_timestamp" : timestamp(),
                    @"oauth_version" : @"1.0",
                    @"oauth_signature_method" : @"HMAC-SHA1",
                    @"oauth_callback" : @"oob"
    };
    _signature_secret = [NSString stringWithFormat:@"%@&%@", consumerSecret, @"" ];
    return self;
}

- (id)initForAccessTokenWithConsumerKey:(NSString *)consumerKey consumerSecret:(NSString *)consumerSecret requestToken:(NSString *)requestToken tokenSecret:(NSString *)tokenSecret oauthVerfier:(NSString *)oauthVerfier
{
    _params = @{@"oauth_consumer_key" : consumerKey,
                    @"oauth_nonce" : nonce(),
                    @"oauth_timestamp" : timestamp(),
                    @"oauth_version" : @"1.0",
                    @"oauth_signature_method" : @"HMAC-SHA1",
                    @"oauth_token" : requestToken ? : @"",
                    @"oauth_verifier" : oauthVerfier ? : @""
    };
    _signature_secret = [NSString stringWithFormat:@"%@&%@", consumerSecret, tokenSecret ? : @""  ];
    return self;
}


#pragma mark - Signature
- (NSString *)signatureWithURL:(NSURL *)url andMethod:(NSString *)method
{
    NSData *sigbase = [signatureBase([_params mutableCopy], [_queryParams mutableCopy], method, url) dataUsingEncoding:NSUTF8StringEncoding];
    NSData *secret = [_signature_secret dataUsingEncoding:NSUTF8StringEncoding];
	
    uint8_t digest[20] = {0};
    CCHmacContext cx;
    CCHmacInit(&cx, kCCHmacAlgSHA1, secret.bytes, secret.length);
    CCHmacUpdate(&cx, sigbase.bytes, sigbase.length);
    CCHmacFinal(&cx, digest);
    
    return base64(digest);
}
KOAUTH_BURST_LINK NSString *signatureBase(NSMutableDictionary *params, NSMutableDictionary *queryParams, NSString *method, NSURL *url)
{
    NSMutableString *p3 = [NSMutableString stringWithCapacity:256];
    [params addEntriesFromDictionary:queryParams];
    
    NSArray *keys = [[params allKeys] sortedArrayUsingSelector:@selector(compare:)];
    for (NSString *key in keys) {
        [p3 appendString:urlEncode(key)];
        [p3 appendString:@"="];
        [p3 appendString:[params objectForKey:key]];
        [p3 appendString:@"&"];
    }
    
    chomp(p3);
    
	NSString *result = [NSString stringWithFormat:@"%@&%@%%3A%%2F%%2F%@%%3A%@%@&%@",
                  method,
                  url.scheme.lowercaseString,
                  urlEncode(url.host.lowercaseString),
                  url.port,
                  urlEncode(url.path),
                  urlEncode(p3)];
	return result;
}
#pragma mark Authorization
- (NSString *)getAuthorization:(NSDictionary *)params url:(NSURL *)url method:(NSString *)method
{
    NSMutableString *header = [NSMutableString stringWithCapacity:512];
    [header appendString:@"OAuth "];
    for (NSString *key in params.allKeys) {
        [header appendString:key];
        [header appendString:@"=\""];
        [header appendString:[params objectForKey:key]];
        [header appendString:@"\", "];
    }
    [header appendString:@"oauth_signature=\""];
    [header appendString:urlEncode([self signatureWithURL:url andMethod:method])];
    [header appendString:@"\""];
    return header;
}


#pragma mark - Generate Request
- (NSMutableURLRequest *)getRequestWittURL:(NSURL *)url andMethod:(NSString *)method
{
    //TODO timeout interval depends on connectivity status
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setValue:[self getAuthorization:_params url:url method:method] forHTTPHeaderField:@"Authorization"];
    [request setHTTPMethod:method];
    return request;
}

#pragma mark add parameters and get encoded string
- (NSMutableString *)getParametersString:(NSDictionary *)unencodedParameters
{
    if (!unencodedParameters.count)
        return [NSMutableString string];
	
    NSMutableString *queryString = [NSMutableString string];
    NSMutableDictionary *encodedParameters = [NSMutableDictionary dictionaryWithDictionary:_queryParams];
    for (NSString *key in unencodedParameters.allKeys) {
        NSString *enkey = urlEncode(key);
        NSString *envalue = urlEncode([unencodedParameters objectForKey:key]);
        [encodedParameters setObject:envalue forKey:enkey];
        [queryString appendString:enkey];
        [queryString appendString:@"="];
        [queryString appendString:envalue];
        [queryString appendString:@"&"];
    }
    chomp(queryString);
	
    _queryParams = encodedParameters;
	
    return queryString;
}


#pragma mark - KOAuth alloc URLRequest
#pragma mark HTTP GET
+ (NSMutableURLRequest *)URLRequestForUrl:(NSURL *)url GETParameters:(NSDictionary *)unencodedParameters consumerKey:(NSString *)consumerKey consumerSecret:(NSString *)consumerSecret accessToken:(NSString *)accessToken tokenSecret:(NSString *)tokenSecret
{
    if (!url)
        return nil;
	
    KOAuth *oauth = [[KOAuth alloc] initWithConsumerKey:consumerKey consumerSecret:consumerSecret accessToken:accessToken tokenSecret:tokenSecret];
	
    NSMutableString *parms = [oauth getParametersString:unencodedParameters];
    if (parms.length > 0) {
        [parms insertString:@"?" atIndex:0];
    }
    
    NSMutableURLRequest *request = [oauth getRequestWittURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@", url.absoluteString, parms]] andMethod:@"GET"];
    return request;
}
#pragma mark HTTP POST
+ (NSMutableURLRequest *)URLRequestForUrl:(NSURL *)url POSTParameters:(NSDictionary *)unencodedParameters consumerKey:(NSString *)consumerKey consumerSecret:(NSString *)consumerSecret accessToken:(NSString *)accessToken tokenSecret:(NSString *)tokenSecret
{
    if (!url) {
        return nil;
    }
    
    KOAuth *oauth = [[KOAuth alloc] initWithConsumerKey:consumerKey
                                           consumerSecret:consumerSecret
                                              accessToken:accessToken
                                              tokenSecret:tokenSecret];
    NSMutableString *postbody = [oauth getParametersString:unencodedParameters];
    NSMutableURLRequest *request = [oauth getRequestWittURL:url andMethod:@"POST"];
	
    if (postbody.length) {
        [request setHTTPBody:[postbody dataUsingEncoding:NSUTF8StringEncoding]];
        [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
        [request setValue:[NSString stringWithFormat:@"%u", request.HTTPBody.length] forHTTPHeaderField:@"Content-Length"];
    }
	
    return request;
}
#pragma mark request for request_token
+ (NSMutableURLRequest *)URLRequestForRequestTokenWithUrl:(NSURL *)url consumerKey:(NSString *)consumerKey consumerSecret:(NSString *)consumerSecret
{
    if (!url)
        return nil;
	
    KOAuth *oauth = [[KOAuth alloc] initForRequestTokenWithConsumerKey:consumerKey consumerSecret:consumerSecret];
    
	NSMutableURLRequest *rq = [oauth getRequestWittURL:url andMethod:@"POST"];
    return rq;
}
#pragma mark request for access_token
+ (NSMutableURLRequest *)URLRequestForAccessTokenWithUrl:(NSURL *)url consumerKey:(NSString *)consumerKey consumerSecret:(NSString *)consumerSecret requestToken:(NSString *)requestToken tokenSecret:(NSString *)tokenSecret oauthVerfier:(NSString *)oauthVerfier
{
    if (!url)
        return nil;
	
    KOAuth *oauth = [[KOAuth alloc] initForAccessTokenWithConsumerKey:consumerKey
                                                      consumerSecret:consumerSecret
                                                         requestToken:requestToken
                                                          tokenSecret:tokenSecret
                                                         oauthVerfier:oauthVerfier];
	
    NSMutableURLRequest *rq = [oauth getRequestWittURL:url andMethod:@"POST"];
    return rq;
}


#pragma mark - Shared
KOAUTH_BURST_LINK NSString *urlEncode(NSString *source)
{
    CFStringRef cfstring = CFURLCreateStringByAddingPercentEscapes(NULL, (__bridge CFStringRef) source, NULL, (CFStringRef) @"!*'();:@&=+$,/?%#[]", kCFStringEncodingUTF8);
    NSString *result = [NSString stringWithString:(__bridge NSString *)cfstring];
    CFRelease(cfstring);
    return result;
}
// remove the last char of source string
KOAUTH_BURST_LINK void chomp(NSMutableString *source)
{
    if (source.length > 0)
        [source deleteCharactersInRange:NSMakeRange(source.length - 1, 1)];
}
KOAUTH_BURST_LINK NSString *nonce()
{
    static const char map[] = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789";
    char *buffer = malloc(6);
    NSUInteger selector;
    for (NSUInteger index = 0; index < 5; index++) {
        selector = arc4random() % 62;
        buffer[index] = map[selector];
    }
    buffer[5] = '\0';
    NSString *result = [NSString stringWithCString:buffer encoding:NSASCIIStringEncoding];
    free(buffer);
    
    return result;
}
KOAUTH_BURST_LINK NSString *timestamp()
{
    time_t t;
    time(&t);
    mktime(gmtime(&t));
    return [NSString stringWithFormat:@"%lu", t + KOAUTH_UTC_TIME_OFFSET];
}
KOAUTH_BURST_LINK NSString *base64(const uint8_t *input)
{
    static const char map[] = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";
	
    NSMutableData *data = [NSMutableData dataWithLength:28];
    uint8_t *dataUnit = (uint8_t*) data.mutableBytes;
	
    for (NSInteger i = 0; i < 20;) {
        NSInteger v  = 0;
        for (NSInteger n = i + 3; i < n; i++) {
            v <<= 8;
            v |= 0xFF & input[i];
        }
        *dataUnit++ = map[v >> 18 & 0x3F];
        *dataUnit++ = map[v >> 12 & 0x3F];
        *dataUnit++ = map[v >> 6 & 0x3F];
        *dataUnit++ = map[v >> 0 & 0x3F];
    }
    dataUnit[-2] = map[(input[19] & 0x0F) << 2];
    dataUnit[-1] = '=';
    return [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
}


@end