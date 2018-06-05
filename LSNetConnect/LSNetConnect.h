//
//  LSNetConnect.h
//  CreditCloud
//
//  Created by KZL on 16/12/2.
//  Copyright © 2016年 Panshi. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface LSNetConnect : NSObject

/// Post Get Delete
typedef NS_ENUM(NSInteger, LSRequestStyle) {
    
    LSRequestStylePost ,
    LSRequestStyleGet ,
    LSRequestStyleDelete
    
};

///定义 加载数据 成功 失败回调
typedef void (^LoadDataSuccess)(NSURLSessionDataTask *task, id responseObject);

typedef void(^LoadDataFailure)(NSURLSessionDataTask *task, NSError *error);

/**
        Singleton

 @return an object can connect to web
 */
+ (instancetype)sharedConnect;

/**
        Post

 @param name 端口名
 @param parameters 参数列表
 */
- (void)postWithPortName:(NSString *)name parameters:(NSDictionary *)parameters success:(LoadDataSuccess)success failure:(LoadDataFailure)failure;

/**
        Get
 
 @param name 端口名
 @param parameters 参数列表
 */
- (void)getWithPortName:(NSString *)name parameters:(NSDictionary *)parameters success:(LoadDataSuccess)success failure:(LoadDataFailure)failure;


/**
        Delete

 @param name 端口名
 @param parameters 参数列表
 */
- (void)deleteWithPortName:(NSString *)name parameters:(NSDictionary *)parameters success:(LoadDataSuccess)success failure:(LoadDataFailure)failure;




/**
        Post private url
 
 */
- (void)POST:(NSString *)URLString parameters:(id)parameters success:(LoadDataSuccess)success failure:(LoadDataFailure)failure;




- (void)cancleTask;

@end
