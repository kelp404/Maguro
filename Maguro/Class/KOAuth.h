/*
 KOAuth
 MIT License
 https://github.com/Kelp404/KOAuth
 
 Fork from https://github.com/tweetdeck/TDOAuth Max Howell <max@tweetdeck.com>
 */

#import <Foundation/Foundation.h>

/*
 This OAuth implementation doesn't cover the whole spec (eg. it’s HMAC only).
 But you'll find it works with almost all the OAuth implementations you need
 to interact with in the wild. How ace is that?!
 */
@interface KOAuth : NSObject {
    NSString *_signature_secret;
    NSDictionary *_params; // these are pre-percent encoded
    NSDictionary *_queryParams; // these are pre-percent encoded
}

// *all keys and values of parameters should be NSString*
// get request with oauth
+ (NSMutableURLRequest *)URLRequestForUrl:(NSURL *)url GETParameters:(NSDictionary *)unencodedParameters consumerKey:(NSString *)consumerKey consumerSecret:(NSString *)consumerSecret accessToken:(NSString *)accessToken tokenSecret:(NSString *)tokenSecret;
// post request with oauth
+ (NSMutableURLRequest *)URLRequestForUrl:(NSURL *)url POSTParameters:(NSDictionary *)unencodedParameters consumerKey:(NSString *)consumerKey consumerSecret:(NSString *)consumerSecret accessToken:(NSString *)accessToken tokenSecret:(NSString *)tokenSecret;

// request for request_token
+ (NSMutableURLRequest *)URLRequestForRequestTokenWithUrl:(NSURL *)url consumerKey:(NSString *)consumerKey consumerSecret:(NSString *)consumerSecret;
// request for access_token
+ (NSMutableURLRequest *)URLRequestForAccessTokenWithUrl:(NSURL *)url consumerKey:(NSString *)consumerKey consumerSecret:(NSString *)consumerSecret requestToken:(NSString *)requestToken tokenSecret:(NSString *)tokenSecret oauthVerfier:(NSString *)oauthVerfier;

@end
