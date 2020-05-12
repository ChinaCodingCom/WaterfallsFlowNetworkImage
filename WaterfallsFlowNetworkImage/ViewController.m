//
//  ViewController.m
//  WaterfallsFlowNetworkImage
//
//  Created by CE on 2017/6/6.
//  Copyright © 2017年 CE. All rights reserved.
//

#import "ViewController.h"

#import "WaterFlowLayout.h"
#import "UIView+MZwebCache.h"

#import "AFNetworking.h"
#import "MJRefresh.h"
#import "UIImageView+WebCache.h"
#import "UIButton+WebCache.h"
#import "SDWebImageManager.h"
#import "SDWebImageDownloader.h"
#import "UIImage+GIF.h"
#import "NSData+ImageContentType.h"

#import "ToyDetailsBigImgaeViewController.h"


@interface ViewController ()<WaterFlowLayoutDelegate, UICollectionViewDataSource> {
   
    NSInteger lines;
    //cell高度
    CGFloat cellCurrentHight;
    //最大图片高度
    CGFloat imageMAXHight;
    
}

@property (nonatomic, strong) NSMutableArray *dataArray;
@property (nonatomic, strong) UICollectionView *collectionView;

@property (nonatomic,strong) NSArray *imagArray;
@property (nonatomic,strong) UIScrollView *backgroundScrollView;
@property (nonatomic,strong) NSMutableDictionary *MDic;

@end

@implementation ViewController

//屏幕尺寸
#define SCREEN_H [UIScreen mainScreen].bounds.size.height
#define SCREEN_W [UIScreen mainScreen].bounds.size.width

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.MDic = [[NSMutableDictionary alloc] init];
    [self createUI];
    
}

- (void)createUI{

    self.backgroundScrollView = [[UIScrollView alloc]initWithFrame:self.view.bounds];
    [self.view addSubview:self.backgroundScrollView];
    self.backgroundScrollView.scrollEnabled = YES;
    self.backgroundScrollView.contentSize = CGSizeMake(SCREEN_W, SCREEN_H * 1.2);
    self.backgroundScrollView.backgroundColor = [UIColor whiteColor];
    //是否回弹
    //self.backgroundScrollView.bounces = NO;
    self.backgroundScrollView.alwaysBounceVertical = YES;
    //self.backgroundScrollView.showsHorizontalScrollIndicator = NO;
    //self.backgroundScrollView.showsVerticalScrollIndicator = NO;
    
    WaterFlowLayout *flowOut = [[WaterFlowLayout alloc] init];
    flowOut.delegate = self;
    
    self.collectionView =
    [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_W, SCREEN_H * 1.2)
                       collectionViewLayout:flowOut];
    _collectionView.delegate = self;
    _collectionView.dataSource = self;
    _collectionView.alwaysBounceVertical = YES;
    _collectionView.scrollEnabled = NO;
    _collectionView.backgroundColor = [UIColor colorWithWhite:0.9 alpha:0.8];
    [self.backgroundScrollView addSubview:_collectionView];
    [_collectionView registerNib:[UINib nibWithNibName:@"MainCell" bundle:nil]
      forCellWithReuseIdentifier:@"MainCell"];
    
    //默认列数
    lines = 1;
    self.title = [NSString stringWithFormat:@"%ld列",lines];
    UISegmentedControl *segment = [[UISegmentedControl alloc]
                                   initWithItems:@[ @"1", @"2", @"3", @"4", @"5", @"6", @"7", @"8" ]];
    segment.frame = CGRectMake(0, SCREEN_H - 40, SCREEN_W, 40);
    segment.selectedSegmentIndex = 0;
    [self.view addSubview:segment];
    [segment addTarget:self
                action:@selector(changeLines:)
      forControlEvents:UIControlEventValueChanged];
    
    //加载数据
    [self prepareData];

}

- (void)prepareData {
    _imagArray = @[        //图片链接
                           @"http://r.photo.store.qq.com/psb?/V14FKYxo4VCpyi/QVQTlkgfGtvY8Ml1e5*C.0.r2rvYkiNmkuEgOxChKdE!/r/dIIBAAAAAAAA",
                           @"http://r.photo.store.qq.com/psb?/V14FKYxo4VCpyi/d6DS.ut7JDKCngxXd0CaTDVjzkZCCjDfPQgRVThM9vE!/r/dG0BAAAAAAAA",
                           @"http://r.photo.store.qq.com/psb?/V14FKYxo4VCpyi/*TawSnqTpDyDN9StiXJlG6naEToM6KLa0XoRAFgOxi4!/r/dGwBAAAAAAAA",
                           @"http://a3.qpic.cn/psb?/V14FKYxo0UhIAP/py.OcSKU4wVb4vXlqxv.DKIY.XEkzx7U.n838lTPfak!/b/dN0AAAAAAAAA&bo=gAJTGwAAAAAFB.4!&rf=viewer_4",
                           @"http://r.photo.store.qq.com/psb?/V14FKYxo4VCpyi/Vjr2oZ*N4wty.iWKnF4TGfqh7SBFusq2bYZ7pzgISNQ!/r/dGwBAAAAAAAA",
                           @"http://r.photo.store.qq.com/psb?/V14FKYxo4VCpyi/tSDFJivi0z0vnoXdiEdkYUr6pnwmedJYdt*Y2QgXBg8!/r/dG4BAAAAAAAA",
                           @"http://r.photo.store.qq.com/psb?/V14FKYxo4VCpyi/gCOv8dKdS0v21xG9MX2UngH655hg5AsuWyIu*0u5WZk!/r/dGwBAAAAAAAA",
                           @"http://r.photo.store.qq.com/psb?/V14FKYxo4VCpyi/x2TP3LgwjRjrLWhK*TwGOUvfB9Ipyv8pXS10FQPJRQY!/r/dGwBAAAAAAAA",
                           @"http://r.photo.store.qq.com/psb?/V14FKYxo4VCpyi/wCAh6JN5RffRMbIabosoKoOqEFz8RP7FuFZl2vMVwkI!/r/dG0BAAAAAAAA",
                           @"http://r.photo.store.qq.com/psb?/V14FKYxo4VCpyi/1M7RPK9zA5EWUIkzf01qfx*Q*fdlGcq7jAFZqC40m5g!/r/dG0BAAAAAAAA",
                           @"http://r.photo.store.qq.com/psb?/V14FKYxo4VCpyi/XnxwggzMNrYrhLWdEMSfCazNiJuO8nDysOyZ0Qx3DhQ!/r/dGwBAAAAAAAA",
                           @"http://r.photo.store.qq.com/psb?/V14FKYxo4VCpyi/TMJrjlo3D*oMYXrpLJmDNyfrW0dKnzPZF2DMSW8Y.Ek!/r/dIMBAAAAAAAA",
                           @"http://r.photo.store.qq.com/psb?/V14FKYxo4VCpyi/DK7tRNLecsbzH9FB7hT1pzrlQnz6vfKsCrg3GqE5qRA!/r/dIQBAAAAAAAA",];
    self.dataArray = [NSMutableArray array];
    for (NSInteger i = 0; i < _imagArray.count; i++) {
        MainModel *model = [[MainModel alloc] init];
        model.imageUrl = _imagArray[i % _imagArray.count];
        [_dataArray addObject:model];
    }
}

//更改列数
- (void)changeLines:(UISegmentedControl *)segment {
    lines = segment.selectedSegmentIndex + 1;
    [_collectionView reloadData];
    self.title = [NSString stringWithFormat:@"%ld列",lines];
}

#pragma mark - UICollectionView DataSource Methods
- (NSInteger)collectionView:(UICollectionView *)collectionView
     numberOfItemsInSection:(NSInteger)section {
    return _dataArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    __weak typeof(self) weakSelf = self;
    MainCell *cell = (MainCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"MainCell" forIndexPath:indexPath];
    cell.indexPath = indexPath;
    cell.model = _dataArray[indexPath.row];
    cell.sizeChanged = ^() {
    //这里每次加载完图片后，得到图片的比例会再次调用刷新此item，重新计算位置，会导致效率低。最优做法是服务器返回图片宽高比例；其次把加载完成后的宽高数据也缓存起来。
        [weakSelf.collectionView reloadItemsAtIndexPaths:@[indexPath]];
    };
    return cell;
}

#pragma mark - UICollectionView Delegate Methods
- (CGFloat)collectionView:(UICollectionView *)collectionView
                   layout:(UICollectionViewLayout *)collectionViewLayout
minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return 5;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView
                   layout:(UICollectionViewLayout *)collectionViewLayout
minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return 5;
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView
                        layout:(UICollectionViewLayout *)collectionViewLayout
        insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(10, 10, 10, 10);
}

//返回每个小方块宽高，但由于是在WaterFlowLayout处理，只取了高，宽是由列数平均分
- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout *)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath {

    MainModel *model = _dataArray[indexPath.row];
    NSInteger lineNum = [self collectionView:_collectionView numberOfLineForSection:0];
    CGFloat width = ((SCREEN_W - 10) - (lineNum - 1) * 5) / lineNum;
    if (model.imageSize.width > 0) {
        CGSize imageSize = model.imageSize;
        
        //获取每个cell的高度 存入字典
        CGFloat HHH = width / imageSize.width * imageSize.height;
        NSLog(@"HHH = %f",width / imageSize.width * imageSize.height);
        
        NSLog(@"indexPath.row = %ld",indexPath.row);
        
        NSNumber *cellHight = [NSNumber numberWithFloat:HHH];
        
        NSString *indexPathRow = [NSString stringWithFormat:@"%ld",indexPath.row];
        NSLog(@"indexPathRow = %@",indexPathRow);
        
        [self.MDic setValue:cellHight forKey:indexPathRow];
        
        NSLog(@"self.MDic = %@",self.MDic);
        
        NSArray *otherCellHightArray = [self.MDic allValues];
        
        cellCurrentHight = 0;
        
        for (NSNumber *cellHightNumber  in otherCellHightArray) {
            CGFloat cellHightFloat = [cellHightNumber floatValue];
            cellCurrentHight += cellHightFloat;
            if (indexPath.row == 0) {
               imageMAXHight = cellHightFloat;
            }
            
            if (imageMAXHight < cellHightFloat) {
                imageMAXHight = cellHightFloat;
            }
        }
        
        cellCurrentHight = cellCurrentHight / lines;
        
        if (imageMAXHight > cellCurrentHight) {
            
            cellCurrentHight = imageMAXHight;
        }

        NSLog(@"cellCurrentHight = %f",cellCurrentHight);
        
        //赋值
        self.backgroundScrollView.contentSize = CGSizeMake(SCREEN_W, cellCurrentHight + 64 + 40 + 40);
        _collectionView.frame = CGRectMake(0, 0, SCREEN_W, cellCurrentHight + 64 + 40 + 40);
        NSLog(@"cellCurrentHight = %f",cellCurrentHight);
        return CGSizeMake(width, width / imageSize.width * imageSize.height);
    }
    return CGSizeMake(width, 300);
}

- (void)collectionView:(UICollectionView *)collectionView
didSelectItemAtIndexPath:(nonnull NSIndexPath *)indexPath {
    NSLog(@"点击了第%ld个", indexPath.row);
    ToyDetailsBigImgaeViewController *toyDetailsBigImgaeVC = [[ToyDetailsBigImgaeViewController alloc] init];
    NSString *url = _imagArray[indexPath.row];
    toyDetailsBigImgaeVC.url = url;
    [self.navigationController pushViewController:toyDetailsBigImgaeVC animated:NO];
}

#pragma mark - WaterFlowout代理，请填入返回多少列
- (NSInteger)collectionView:(UICollectionView *)collectionView
     numberOfLineForSection:(NSInteger)section {
    return lines;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

@implementation MainCell

- (void)setModel:(MainModel *)model {
    _model = model;
    __weak typeof(self) weakSelf = self;
    [_mainImgv setImageWithUrl:[NSURL URLWithString:model.imageUrl] placeHolder:[UIImage imageNamed:@"loading.jpg"] completion:^(UIImage *image, BOOL bFromCache, NSError *error) {
        if (!error && image) {
            if (model.imageSize.width < 0.0001) {
                model.imageSize = image.size;
                if (weakSelf.sizeChanged) {
                    weakSelf.sizeChanged();
                }
            }
        }
    }];
}

- (void)dealloc {
    NSLog(@"self = %@ [self class] = %@",self ,[self class]);
}

@end

@implementation MainModel

@end





