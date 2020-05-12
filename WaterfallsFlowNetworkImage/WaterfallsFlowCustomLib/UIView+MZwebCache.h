//
//  UIView+MZwebCache.h
//  Gray_main
//
//  Created by CE on 15/10/22.
//  Copyright © 2015年 CE. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^MZwebCacheBlock)(UIImage *image, BOOL bFromCache, NSError *error);
@interface UIView (MZwebCache)

- (void)setImageWithUrl:(NSURL *)url
            placeHolder:(UIImage *)holderImage
             completion:(MZwebCacheBlock)block;
- (void)setImageWithUrl:(NSURL *)url placeHolder:(UIImage *)holderImage;
- (void)setImageWithUrl:(NSURL *)url;

@end

@interface CachedImageManager : NSObject

+ (CachedImageManager *)shareInstance;
- (void)clearCache;                                    //清除缓存
- (BOOL)cacheUrl:(NSURL *)url WithData:(NSData *)data; //存入url
- (NSString *)imagePathForUrl:(NSURL *)url;            //取出url对应的path

@property (nonatomic, copy, readonly) NSString *cachePath; //缓存目录

@end
