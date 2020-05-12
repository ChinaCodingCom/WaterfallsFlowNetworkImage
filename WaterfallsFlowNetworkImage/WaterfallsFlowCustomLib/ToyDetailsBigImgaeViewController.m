//
//  ToyDetailsBigImgaeViewController.m
//  WaterfallsFlowNetworkImage
//
//  Created by CE on 2017/6/6.
//  Copyright © 2017年 CE. All rights reserved.
//

#import "ToyDetailsBigImgaeViewController.h"
#import "UIImageView+WebCache.h"
#import "ViewController.h"

@interface ToyDetailsBigImgaeViewController ()<UIScrollViewDelegate>{
    UIScrollView *_scrollView;
}

@end

@implementation ToyDetailsBigImgaeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self createScrollView];
    self.navigationController.navigationBar.hidden = YES;
}

- (void)viewWillDisappear:(BOOL)animated{
    self.navigationController.navigationBar.hidden = NO;
}

- (void)createScrollView{
    _scrollView = [[UIScrollView alloc]initWithFrame:self.view.frame];
    _scrollView.backgroundColor = [UIColor grayColor];
    UIImageView *imageView = [[UIImageView alloc]initWithFrame:self.view.frame];
    //UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_W, SCREEN_LH)];
    [_scrollView addSubview:imageView];
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    [imageView sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@",self.url]]];
    //尺寸
    _scrollView.contentSize = imageView.frame.size;
    //偏移量
    _scrollView.contentOffset = CGPointMake(1000, 500);
    //设置是否回弹
    _scrollView.bounces = NO;
    //设置边距
    //_scrollView.contentInset = UIEdgeInsetsMake(10, 10, 10, 10);
    _scrollView.contentInset = UIEdgeInsetsMake(1, 1, 1, 1);
    
    //设置是否可以滚动
    _scrollView.scrollEnabled = YES;
    //是否可以会到顶部
    _scrollView.scrollsToTop = YES;
    //按页滚动
    //scrollView.pagingEnabled = YES;
    //设置滚动条
    _scrollView.showsHorizontalScrollIndicator = YES;
    _scrollView.showsVerticalScrollIndicator = NO;
    //设置滚动条的样式
    _scrollView.indicatorStyle = UIScrollViewIndicatorStyleWhite;
    
    imageView.userInteractionEnabled = YES;
    
    //代理
    _scrollView.delegate = self;
    
    //CGFloat imageWidth = imageView.frame.size.width;
    //设置最小和最大缩放比例
    //_scrollView.minimumZoomScale = SCREEN_W/imageWidth;
    //_scrollView.maximumZoomScale = 1.5;
    
    _scrollView.minimumZoomScale = 0.2;
    //_scrollView.maximumZoomScale = 2.0;
    _scrollView.maximumZoomScale = imageView.frame.size.width * 3 / self.view.frame.size.width;

    [self.view addSubview:_scrollView];
    
    //给imageView添加手势
    //创建单击双击手势
    UITapGestureRecognizer *oneTgr = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapClick:)];
    //oneTgr.numberOfTapsRequired = 1;
    [imageView addGestureRecognizer:oneTgr];
    
    UITapGestureRecognizer *tgr = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapClick:)];
    tgr.numberOfTapsRequired = 2;
    [imageView addGestureRecognizer:tgr];
    
    [oneTgr requireGestureRecognizerToFail:tgr];
}

- (void)tapClick:(UITapGestureRecognizer *)tap{
    if (tap.numberOfTapsRequired == 1) {
        printf("单击手势识别成功\n");
        [self.navigationController popViewControllerAnimated:NO];
        
    } else {
        printf("双击手势识别成功\n");
        //zoomScale当前的缩放比例
        if (_scrollView.zoomScale == 1.0) {
            [_scrollView setZoomScale:_scrollView.maximumZoomScale animated:YES];
        } else {
            [_scrollView setZoomScale:1.0 animated:YES];
            
        }
        
    }
    
}

#pragma mark - 代理

//- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
//
//    NSLog(@"滚动");
//
//}

- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(nullable UIView *)view atScale:(CGFloat)scale {
    if (scale <= 0.5) {
        //当缩放比例小于0.5时返回上一级
        [self.navigationController popViewControllerAnimated:NO];
        
    }
}

//只要缩放就会调用此方法
- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    
    NSLog(@"发生缩放");
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    NSLog(@"将要开始拖动");
    
}
- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset {
    NSLog(@"将要结束拖动");
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    NSLog(@"拖动结束");
}

- (void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView{
    
    NSLog(@"将要开始减速");
    
}
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    NSLog(@"已经结束减速");//停止滚动
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView{
    NSLog(@"滚动动画结束");
    
}

- (nullable UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView{
    NSLog(@"正在缩放");
    //放回对那个子视图进行缩放  前提是有缩放比例
    return scrollView.subviews[0];
}

- (void)scrollViewWillBeginZooming:(UIScrollView *)scrollView withView:(nullable UIView *)view{
    NSLog(@"缩放开始");
}

//- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(nullable UIView *)view atScale:(CGFloat)scale{
//    NSLog(@"%@",view);
//
//
//#if 0
//
//    //放大时会出现问题
//    if (scale <1.0) {
//        CGPoint center = view.center;
//        center.y = HEIGHT/2-64;
//        view.center = center;
//    }
//
//#endif
//
//
//    if (view.frame.size.width > SCREEN_W) {
//        scrollView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
//
//    } else {
//
//        //距边框的距离
//        [UIView animateWithDuration:0.5 animations:^{
//            scrollView.contentInset = UIEdgeInsetsMake((SCREEN_LH-view.frame.size.width)/2, 0, 0, 0 );
//
//        }];
//    }
//
//    NSLog(@"缩放结束");
//}

//是否可以滚动到顶部 前提是前面scrollToTop = YES;
- (BOOL)scrollViewShouldScrollToTop:(UIScrollView *)scrollView{
    return YES;
}
- (void)scrollViewDidScrollToTop:(UIScrollView *)scrollView{
    NSLog(@"已经滚动到顶部");
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
