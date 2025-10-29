//
//  DBOutshine.h
//  LibOutshine
//
//  Created by Dongdong Gao on 8/5/24.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef void (^AuthDataCallback)(NSString *_Nullable p1, NSString *data);

typedef void (^DecodeDataCallback)(id result);

__attribute__((visibility("default")))
@interface DBOutshine : NSObject

- (instancetype)init;

+ (BOOL)isSupported:(NSString *)patchInfo;

- (BOOL)encodeAuth:(NSString *)authData
          patchUid:(NSString *)patchUid
         patchInfo:(NSString *)patchInfo
              type:(int)type
          callback:(AuthDataCallback)callback
             error:(NSError **)error;

- (BOOL)libreCAParsing:(NSString *)p1
                  data:(NSString *)data
                 data2:(NSString *)data2
               data344:(NSString *)data344
             patchInfo:(NSString *)patchInfo
              patchUid:(NSString *)patchUid
              callback:(DecodeDataCallback)callback
                 error:(NSError **)error;

@end

NS_ASSUME_NONNULL_END
