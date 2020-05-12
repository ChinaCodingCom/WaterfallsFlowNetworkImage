//
//  UIView+MZwebCache.m
//  Gray_main
//
//  Created by CE on 15/10/22.
//  Copyright © 2015年 CE. All rights reserved.
//

#import "UIView+MZwebCache.h"
#import <CommonCrypto/CommonDigest.h> //用于MD5

@implementation UIView (MZwebCache)

- (void)setImageWithUrl:(NSURL *)url
            placeHolder:(UIImage *)holderImage
             completion:(MZwebCacheBlock)block {
    __weak typeof(self) weakSelf = self;
    @autoreleasepool {
        //去找真实图片
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            // 1.搜索对应文件名
            NSString *savedName = [[CachedImageManager shareInstance] imagePathForUrl:url];
            
            // 2.如存在，则直接block;如果不存在，下载
            if (savedName) {
                UIImage *image = [UIImage imageWithContentsOfFile:savedName];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [weakSelf showImage:image];
                    if (block) {
                        block(image, YES, nil);
                    }
                });
            }
            else {
                if (url == nil) {
                    NSLog(@"图片地址为空");
                    return ;
                }
                
                //先加载holder
                holderImage ? [weakSelf showImage:holderImage] : nil;
                
                NSError *error = nil;
                NSData *imageData = [[NSData alloc] initWithContentsOfURL:url options:NSDataReadingMappedIfSafe error:&error];
                
                if (error) { //下载失败
                    if (block) {
                        block(nil, NO, error);
                    }
                }
                else { //下载成功
                    UIImage *image = [UIImage imageWithData:imageData];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [weakSelf showImage:image];
                        if (block) {
                            block(image, NO, nil);
                        }
                    });
                    
                    //缓存
                    if (![[CachedImageManager shareInstance] cacheUrl:url WithData:imageData]) {
                        NSLog(@"缓存失败");
                    }
                }
            }
        });
    }
}

- (void)setImageWithUrl:(NSURL *)url placeHolder:(UIImage *)holderImage {
    [self setImageWithUrl:url placeHolder:holderImage completion:nil];
}

- (void)setImageWithUrl:(NSURL *)url {
    [self setImageWithUrl:url placeHolder:nil completion:nil];
}

//设置图片到控件上
- (void)showImage:(UIImage *)image {
    if ([self isKindOfClass:[UIImageView class]]) {
        UIImageView *temp = (UIImageView *)self;
        [temp setImage:image];
    } else if ([self isKindOfClass:[UIButton class]]) {
        UIButton *temp = (UIButton *)self;
        [temp setBackgroundImage:image forState:UIControlStateNormal];
        temp.contentMode = UIViewContentModeScaleAspectFill;
        temp.layer.masksToBounds = YES;
    }
}

@end

#pragma mark - 已缓存图片文件管理
static dispatch_once_t once;
static CachedImageManager *manager = nil;
@interface
CachedImageManager () {
    NSString *plistPath;        //存储的plist路径
    NSFileManager *fileManager; //文件管理器
    NSMutableDictionary *plistContent; // plist里存储的内容
    NSDateFormatter *format; // date类型
}

@end

#define plistCacheName @"imageCache.plist"
@implementation CachedImageManager

+ (CachedImageManager *)shareInstance {
    dispatch_once(&once, ^{
        manager = [[CachedImageManager alloc] init];
    });
    return manager;
}

- (id)init {
    self = [super init];
    if (self) {
        format = [[NSDateFormatter alloc] init];
        format.dateFormat = @"yyyyMMdd-hhmmss";
        plistContent = [NSMutableDictionary dictionary];
        fileManager = [NSFileManager defaultManager];
        _cachePath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES)[0] stringByAppendingPathComponent:@"ZMZCache"];

        //如果不存在文件夹,则创建
        if (![fileManager fileExistsAtPath:_cachePath]) {
            NSError *error = nil;
            BOOL isok = [fileManager createDirectoryAtPath:_cachePath withIntermediateDirectories:YES attributes:nil error:&error];
            if (!isok) {
                NSLog(@"%@", error);
            }
        }

        plistPath = [_cachePath stringByAppendingPathComponent:plistCacheName];
        NSLog(@"%@", plistPath);

        //如果不存在plist文件，则创建
        if (![fileManager fileExistsAtPath:plistPath]) {
            [fileManager createFileAtPath:plistPath contents:nil attributes:nil];
        } else {
            //读取plist内容
            plistContent = [NSMutableDictionary dictionaryWithContentsOfFile:plistPath];
        }
    }
    return self;
}

#pragma mark - 清理缓存
- (void)clearCache {
    NSError *error;
    if ([fileManager removeItemAtPath:_cachePath error:&error]) {
        NSLog(@"清除image缓存成功");
    } else {
        NSLog(@"清除image缓存失败,原因：%@", error);
    }
}

#pragma mark - 缓存文件到本地
- (BOOL)cacheUrl:(NSURL *)url WithData:(NSData *)data {

    //计算名字
    NSString *cacheString = [self caculateNameForKey:url.absoluteString];
    NSString *writePath = [_cachePath stringByAppendingPathComponent:cacheString];

    //写入
    [data writeToFile:writePath atomically:NO];
    [plistContent setValue:cacheString forKey:url.absoluteString];
    [plistContent writeToFile:plistPath atomically:NO];

    return YES;
}

#pragma mark - url图片对应名称
- (NSString *)imagePathForUrl:(NSURL *)url {
    id searchResult = [plistContent valueForKey:url.absoluteString];
    if (searchResult) {
        return [_cachePath stringByAppendingPathComponent:searchResult];
    }
    return nil;
}

#pragma mark - 计算缓存名称
- (NSString *)caculateNameForKey:(NSString *)key {
    const char *str = [key UTF8String];
    if (str == NULL) {
        str = "";
    }
    unsigned char r[CC_MD5_DIGEST_LENGTH];
    CC_MD5(str, (CC_LONG) strlen(str), r);
    NSString *filename = [NSString
      stringWithFormat:
        @"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%@", r[0], r[1],
        r[2], r[3], r[4], r[5], r[6], r[7], r[8], r[9], r[10], r[11], r[12], r[13], r[14],
        r[15], [format stringFromDate:[NSDate date]]];

    return filename;
}

@end
