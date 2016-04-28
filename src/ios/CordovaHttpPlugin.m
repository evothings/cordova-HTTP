#import "CordovaHttpPlugin.h"
#import "TextResponseSerializer.h"
#import "HttpManager.h"

@interface CordovaHttpPlugin()

- (void)setRequestHeaders:(NSDictionary*)headers;

@end


@implementation CordovaHttpPlugin {
    AFHTTPRequestSerializer *requestSerializer;
}

- (void)pluginInitialize {
    requestSerializer = [AFHTTPRequestSerializer serializer];
}

- (void)setRequestHeaders:(NSDictionary*)headers {
    [HttpManager sharedClient].requestSerializer = [AFHTTPRequestSerializer serializer];
    [requestSerializer.HTTPRequestHeaders enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        [[HttpManager sharedClient].requestSerializer setValue:obj forHTTPHeaderField:key];
    }];
    [headers enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        [[HttpManager sharedClient].requestSerializer setValue:obj forHTTPHeaderField:key];
    }];
}

- (void)useBasicAuth:(CDVInvokedUrlCommand*)command {
    NSString *username = [command.arguments objectAtIndex:0];
    NSString *password = [command.arguments objectAtIndex:1];

    [requestSerializer setAuthorizationHeaderFieldWithUsername:username password:password];

    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)setHeader:(CDVInvokedUrlCommand*)command {
    NSString *header = [command.arguments objectAtIndex:0];
    NSString *value = [command.arguments objectAtIndex:1];

    [requestSerializer setValue:value forHTTPHeaderField: header];

    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)enableSSLPinning:(CDVInvokedUrlCommand*)command {
    bool enable = [[command.arguments objectAtIndex:0] boolValue];
    if (enable) {
        [HttpManager sharedClient].securityPolicy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeCertificate];
        [HttpManager sharedClient].securityPolicy.validatesCertificateChain = NO;
    } else {
        [HttpManager sharedClient].securityPolicy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeNone];
    }

    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)acceptAllCerts:(CDVInvokedUrlCommand*)command {
    CDVPluginResult* pluginResult = nil;
    bool allow = [[command.arguments objectAtIndex:0] boolValue];

    [HttpManager sharedClient].securityPolicy.allowInvalidCertificates = allow;

    pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)post:(CDVInvokedUrlCommand*)command {
   HttpManager *manager = [HttpManager sharedClient];
   NSString *url = [command.arguments objectAtIndex:0];
   NSDictionary *parameters = [command.arguments objectAtIndex:1];
   NSDictionary *headers = [command.arguments objectAtIndex:2];
   [self setRequestHeaders: headers];

   CordovaHttpPlugin* __weak weakSelf = self;
   manager.responseSerializer = [TextResponseSerializer serializer];
   [manager POST:url parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
      NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
      [dictionary setObject:[NSNumber numberWithInt: (int)operation.response.statusCode] forKey:@"status"];
      [dictionary setObject:responseObject forKey:@"data"];
      CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:dictionary];
      [weakSelf.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
   } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
      NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
      [dictionary setObject:[NSNumber numberWithInt: (int)operation.response.statusCode] forKey:@"status"];
      [dictionary setObject:[error localizedDescription] forKey:@"error"];
      CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsDictionary:dictionary];
      [weakSelf.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
   }];
}

- (void)get:(CDVInvokedUrlCommand*)command {
   HttpManager *manager = [HttpManager sharedClient];
   NSString *url = [command.arguments objectAtIndex:0];
   NSDictionary *parameters = [command.arguments objectAtIndex:1];
   NSDictionary *headers = [command.arguments objectAtIndex:2];
   [self setRequestHeaders: headers];

   CordovaHttpPlugin* __weak weakSelf = self;

   manager.responseSerializer = [TextResponseSerializer serializer];
   [manager GET:url parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
      NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
      [dictionary setObject:[NSNumber numberWithInt: (int)operation.response.statusCode] forKey:@"status"];
      [dictionary setObject:responseObject forKey:@"data"];
      CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:dictionary];
      [weakSelf.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
   } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
      NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
      [dictionary setObject:[NSNumber numberWithInt: (int)operation.response.statusCode] forKey:@"status"];
      [dictionary setObject:[error localizedDescription] forKey:@"error"];
      CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsDictionary:dictionary];
      [weakSelf.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
   }];
}

@end
