//
//  LSNetConnect.m
//  CreditCloud
//
//  Created by KZL on 16/12/2.
//  Copyright © 2016年 Panshi. All rights reserved.
//

#import "LSNetConnect.h"
#import "AFNetworking.h"
#import <SVProgressHUD/SVProgressHUD.h>

@interface LSNetConnect ()

@property (nonatomic ,strong) AFHTTPSessionManager *sessionManager;

@end



@implementation LSNetConnect




#pragma mark ---  请求数据

- (void)postWithPortName:(NSString *)name parameters:(NSDictionary *)parameters success:(LoadDataSuccess)success failure:(LoadDataFailure)failure{
    
    NSString *urlStr = [BASEURL stringByAppendingString:name];
    urlStr=[urlStr stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    [self fixManagerRequestHeader];
    __block NSURLSessionDataTask *task = [self.sessionManager POST:urlStr parameters:parameters progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        if([responseObject[@"businessCode"] isEqual:@"0035"]){
            
            
            [[NSNotificationCenter defaultCenter] postNotificationName:kAppLogoutNotifi object:nil];
            success(task, responseObject);
            
            
        }else if([responseObject[@"businessCode"] isEqual:@"0033"]){
            
            //重新发起请求
            [self detailTokenOutOfDateWithOriginPortName:name parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject) {
                
                success(task, responseObject);
                
                
            } failure:^(NSURLSessionDataTask *task, NSError *error) {
                
                
                failure(task, error);
                
            }];
            
            
        }else{
            
            success(task, responseObject);
            
        }
        
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        NSLog(@"Error Port Name = %@\n Error Reason = %@",urlStr, error);
        if (error.code == -999) {
            failure(task, error);
            return ;
        }else if (error.code == 3840){
            failure(task, error);
            
            return;
        }else if(error.code == -1009){
            
            [SVProgressHUD setFont:[UIFont systemFontOfSize:14]];
            [SVProgressHUD setDefaultStyle:SVProgressHUDStyleCustom];
            [SVProgressHUD setBackgroundColor:[UIColor grayColor]];
            [SVProgressHUD setForegroundColor:[UIColor whiteColor]];
            [SVProgressHUD setCornerRadius:4.0];
            [SVProgressHUD showImage:nil status:@"您的网络出现了问题，请检查"];
            [SVProgressHUD dismissWithDelay:1];
            failure(task, error);
        }else{
            
            failure(task, error);
            
        }
        
    }];
    
}


- (void)detailTokenOutOfDateWithOriginPortName:(NSString *)portName parameters:(NSDictionary *)para success:(LoadDataSuccess)success failure:(LoadDataFailure)failure{
    
    //token 置换
    [self postWithPortName:@"/app/retoken" parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        
        
        if (kCheckResponse) {
            
            NSString *newToken = responseObject[@"data"][@"token"];
            if (newToken) {
                
                [[User sharedUser] setToken:newToken];
                [[User sharedUser] archiverAndSave];
                //重新发起请求
                [self postWithPortName:portName parameters:para success:^(NSURLSessionDataTask *task, id responseObject) {
                    
                    success(task, responseObject);
                    
                } failure:^(NSURLSessionDataTask *task, NSError *error) {
                    
                    failure(task, error);
                }];
            }else{
                
                failure(task, nil);
            }
            
        }else{
            failure(task, nil);
        }
        
        
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        
        failure(task, error);
        
        
    }];
    
    
    
    
    
    
    
}














- (void)getWithPortName:(NSString *)name parameters:(NSDictionary *)parameters success:(LoadDataSuccess)success failure:(LoadDataFailure)failure{
    
    NSString *urlStr = [BASEURL stringByAppendingString:name];
    urlStr=[urlStr stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    
    [self.sessionManager GET:urlStr parameters:parameters progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        success(task, responseObject);
        
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        NSLog(@"Error = %@",error);
        
        //        failure(task, error);
        
    }];
    
}


- (void)deleteWithPortName:(NSString *)name parameters:(NSDictionary *)parameters success:(LoadDataSuccess)success failure:(LoadDataFailure)failure{
    
    NSString *urlStr = [BASEURL stringByAppendingString:name];
    urlStr=[urlStr stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    
    [self.sessionManager DELETE:urlStr parameters:parameters success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        success(task, responseObject);
        
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        //        failure(task, error);
        
    }];
    
}

- (void)fixManagerRequestHeader{
    
    [self.sessionManager.requestSerializer setValue:@"1" forHTTPHeaderField:@"signtype"];
    [self.sessionManager.requestSerializer setValue:[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"] forHTTPHeaderField:@"version"];
    [self.sessionManager.requestSerializer setValue:@"2" forHTTPHeaderField:@"channel"];
    //    [self.sessionManager.requestSerializer setValue:@"eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJleHQiOjE1MTM4NzU3NTU5NTMsImlhdCI6MTUxMzc1MDU5MjQzMywiY2lkIjoxfQ.nviBE-15B7-5Z9SfiFmyLfRXvDFfUs6t1gXU4voN2To" forHTTPHeaderField:@"token"];
    [self.sessionManager.requestSerializer setValue:[User sharedUser].token forHTTPHeaderField:@"token"];
    [self.sessionManager.requestSerializer setValue:[User sharedUser].clientId forHTTPHeaderField:@"clientId"];
    NSDate *date = [NSDate dateWithTimeIntervalSinceNow:0];
    NSTimeInterval times = [date timeIntervalSince1970]*1000;
    [self.sessionManager.requestSerializer setValue:[NSString stringWithFormat:@"%.0f",times] forHTTPHeaderField:@"timestamp"];
    
}




#pragma mark --- None base url inside

- (void)POST:(NSString *)URLString parameters:(id)parameters success:(LoadDataSuccess)success failure:(LoadDataFailure)failure{
    
    [self.sessionManager POST:URLString parameters:parameters progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        success(task, responseObject);
        
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        NSLog(@"Error = %@",error);
        //        failure(task, error);
    }];
    
    
}




- (void)cancleTask{
    
    [self.sessionManager.tasks makeObjectsPerformSelector:@selector(cancel)];
}

#pragma mark --- Singleton

+ (instancetype)sharedConnect{
    
    return [[super alloc] init];
}

+ (instancetype)allocWithZone:(struct _NSZone *)zone{
    
    static LSNetConnect *netConnect = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        netConnect = [super allocWithZone:zone];
        netConnect.sessionManager = [AFHTTPSessionManager manager];
        netConnect.sessionManager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript",@"text/plain",@"text/html", nil];
        netConnect.sessionManager.requestSerializer.timeoutInterval = 30;
        
        
    });
    
    return netConnect;
}



@end
