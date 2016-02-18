//
//  LWImageBrowser.m
//  LWAsyncLayerDemo
//
//  Created by 刘微 on 16/2/16.
//  Copyright © 2016年 Warm+. All rights reserved.
//

#import "LWImageBrowser.h"
#import "LWImageBrowserAnimator.h"

#define kPageControlHeight 40.0f
#define kImageBrowserWidth ([UIScreen mainScreen].bounds.size.width + 10.0f)
#define kImageBrowserHeight [UIScreen mainScreen].bounds.size.height

@interface LWImageBrowser ()<UIViewControllerTransitioningDelegate,UIScrollViewDelegate>

@property (nonatomic,strong) UIScrollView* scrollView;
@property (nonatomic,strong) UIPageControl* pageControl;
@property (nonatomic,strong) UIViewController* parentVC;
@property (nonatomic,assign) CGFloat lastOffset;

@end

@implementation LWImageBrowser


#pragma mark - Init

- (id)initWithParentViewController:(UIViewController *)parentVC
                             style:(LWImageBrowserStyle)style
                       imageModels:(NSArray *)imageModels
                      currentIndex:(NSInteger)index {
    self  = [super init];
    if (self) {
        self.parentVC = parentVC;
        self.style = style;
        self.imageModels = imageModels;
        self.currentIndex = index;
    }
    return self;
}

- (void)show {
    switch (self.style) {
        case LWImageBrowserStyleDetail: {
            [self.parentVC.navigationController pushViewController:self animated:YES];
        }
            break;
        default: {
            [self.parentVC presentViewController:self animated:YES completion:^{}];
        }
            break;
    }
}


#pragma mark - Setter&Getter

- (LWImageItem *)previousImageView {
    if (!_previousImageView) {
        _previousImageView = [[LWImageItem alloc] initWithFrame:CGRectMake(0.0f,
                                                                           0.0f,
                                                                           SCREEN_WIDTH,
                                                                           SCREEN_HEIGHT)];
    }
    return _previousImageView;
}

- (LWImageItem *)currentImageView {
    if (!_currentImageView) {
        _currentImageView = [[LWImageItem alloc] initWithFrame:CGRectMake(kImageBrowserWidth,
                                                                          0.0f,
                                                                          SCREEN_WIDTH,
                                                                          SCREEN_HEIGHT)];
    }
    return _currentImageView;
}

- (LWImageItem *)nextImageView {
    if (!_nextImageView) {
        _nextImageView = [[LWImageItem alloc] initWithFrame:CGRectMake(2 * kImageBrowserWidth,
                                                                       0.0f,
                                                                       SCREEN_WIDTH,
                                                                       SCREEN_HEIGHT)];
    }
    return _nextImageView;
}

- (UIScrollView *)scrollView {
    if (!_scrollView) {
        _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0.0f,
                                                                     0.0f,
                                                                     kImageBrowserWidth,
                                                                     kImageBrowserHeight)];
        _scrollView.backgroundColor = [UIColor clearColor];
        _scrollView.bounces = YES;
        _scrollView.scrollEnabled = YES;
        _scrollView.delegate = self;
        _scrollView.pagingEnabled = YES;
        if (self.imageModels.count <3) {
            _scrollView.contentSize = CGSizeMake(kImageBrowserWidth * self.imageModels.count, kImageBrowserHeight);
        }
        else {
            _scrollView.contentSize = CGSizeMake(3 * kImageBrowserWidth, kImageBrowserHeight);
        }
        [_scrollView addSubview:self.previousImageView];
        [_scrollView addSubview:self.currentImageView];
        [_scrollView addSubview:self.nextImageView];
    }
    return _scrollView;
}

- (UIPageControl *)pageControl {
    if (!_pageControl) {
        _pageControl = [[UIPageControl alloc] initWithFrame:CGRectMake(0.0f,
                                                                       SCREEN_HEIGHT - kPageControlHeight - 10.0f,
                                                                       SCREEN_WIDTH,
                                                                       kPageControlHeight)];
        _pageControl.numberOfPages = self.imageModels.count;
        _pageControl.currentPage = self.currentIndex;
    }
    return _pageControl;
}


#pragma mark - ViewControllerLifeCycle

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor blackColor];
    self.transitioningDelegate = self;
    [self.view addSubview:self.scrollView];
    if (self.style == LWImageBrowserStyleDefault) {
        [self.view addSubview:self.pageControl];
    }
    if (self.imageModels.count < 3) {
        [self.scrollView setContentOffset:CGPointMake(self.currentIndex * kImageBrowserWidth, 0.0f)];
    }
    else {
        [self.scrollView setContentOffset:CGPointMake(kImageBrowserWidth, 0.0f)];
    }
    self.lastOffset = self.scrollView.contentOffset.x;
}


#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    CGFloat currentOffset = self.scrollView.contentOffset.x;
    //左滑
    if (currentOffset > self.lastOffset) {
        self.lastOffset = self.scrollView.contentOffset.x;
        self.currentIndex ++;
        self.pageControl.currentPage = self.currentIndex;
    }
    //右滑
    else if (currentOffset < self.lastOffset){
        self.lastOffset = self.scrollView.contentOffset.x;
        self.currentIndex --;
        self.pageControl.currentPage = self.currentIndex;
    }
    [self.scrollView setContentOffset:CGPointMake(kImageBrowserWidth, 0.0f) animated:NO];
    NSLog(@"currentOffset:%f....lastOffset:%f..",currentOffset,self.lastOffset);
}

- (void)setCurrentIndex:(NSInteger)currentIndex {
    _currentIndex = currentIndex;
    NSLog(@"currentIndex:%ld",self.currentIndex);
    [self _loadImage];
}

#pragma mark - Private

- (void)_loadImage {
    if (self.currentIndex > 0) {
        self.previousImageView.imageModel = [self.imageModels objectAtIndex:self.currentIndex - 1];
    }
    self.currentImageView.imageModel = [self.imageModels objectAtIndex:self.currentIndex];
    if (self.currentIndex + 1 <= self.imageModels.count) {
        self.nextImageView.imageModel = [self.imageModels objectAtIndex:self.currentIndex + 1];
    }
}

#pragma mark - UIViewControllerTransitioningDelegate

- (nullable id <UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented
                                                                            presentingController:(UIViewController *)presenting
                                                                                sourceController:(UIViewController *)source {
    LWImageBrowserPresentAnimator* animator = [[LWImageBrowserPresentAnimator alloc] init];
    return animator;
}

- (nullable id <UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed {
    LWImageBrowserDismissAnimator* animator = [[LWImageBrowserDismissAnimator alloc] init];
    return animator;
}


@end
