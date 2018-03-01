//
//  UIViewController+Pagination.m
//  Pagination
//
//  Created by eden on 16/10/9.
//  Copyright © 2016年 eden. All rights reserved.
//

#import "UIViewController+Pagination.h"
#import "MJRefresh.h"
#import "objc/runtime.h"

static char currentPageKey;
static char pageSizeKey;
static char loadingPagekey;
static char scollViewKey;

#define startingPage        1   //The starting page number for your server
#define unusedLoadingPage   -1  //the value of unloaded data for loadingPage
#define defaultPageSize     20  //the default value for pageSize

@interface UIViewController()

///The page number in loading, a tmp variable when loading, is only assigned to the currentPage when the load is successful, and the value of unloaded data is -1
@property (nonatomic, assign) NSInteger loadingPage;

///The scollView who been add pull to refresh operation
@property (nonatomic, assign) UIScrollView *scollView;

@end

@implementation UIViewController (Pagination)

#pragma mark - Access

- (void)setCurrentPage:(NSInteger)currentPage
{
    objc_setAssociatedObject(self, &currentPageKey, @(currentPage), OBJC_ASSOCIATION_RETAIN);
}

- (NSInteger)currentPage
{
    NSNumber *currentPage = objc_getAssociatedObject(self, &currentPageKey);
    if (currentPage == nil) {
        self.currentPage = startingPage;
        return startingPage;
    }
    return [currentPage integerValue];
}

- (void)setPageSize:(NSInteger)pageSize
{
    objc_setAssociatedObject(self, &pageSizeKey, @(pageSize), OBJC_ASSOCIATION_RETAIN);
}

- (NSInteger)pageSize
{
    NSNumber *pageSize = objc_getAssociatedObject(self, &pageSizeKey);
    if (pageSize == nil) {
        self.pageSize = defaultPageSize;
        return defaultPageSize;
    }
    return [pageSize integerValue];
}

- (void)setLoadingPage:(NSInteger)loadingPage
{
    objc_setAssociatedObject(self, &loadingPagekey, @(loadingPage), OBJC_ASSOCIATION_RETAIN);
}

- (NSInteger)loadingPage
{
    NSNumber *loadingPage = objc_getAssociatedObject(self, &loadingPagekey);
    if (loadingPage == nil) {
        self.loadingPage = unusedLoadingPage;
        return unusedLoadingPage;
    }
    return [loadingPage integerValue];
}

- (void)setScollView:(UIScrollView *)scollView
{
    objc_setAssociatedObject(self, &scollViewKey, scollView, OBJC_ASSOCIATION_RETAIN);
}

- (UIScrollView *)scollView
{
    return objc_getAssociatedObject(self, &scollViewKey);
}

#pragma mark - functions

- (void)addPullDownToRefreshWithScollView:(UIScrollView*)scollView
                        refreshingHandler:(EDHRefreshingHandler)refreshingHandler
{
    __weak typeof(self) wSelf = self;
    scollView.mj_header = [MJRefreshStateHeader headerWithRefreshingBlock:^() {
        wSelf.loadingPage = startingPage;
        refreshingHandler(wSelf.loadingPage);
    }];
    self.scollView = scollView;
}

- (void)addPullUpToLoadMoreWithScollView:(UIScrollView*)scollView
                       refreshingHandler:(EDHRefreshingHandler)refreshingHandler
{
    __weak typeof(self) wSelf = self;
    MJRefreshBackNormalFooter *footer = [MJRefreshBackNormalFooter footerWithRefreshingBlock:^() {
        wSelf.loadingPage = wSelf.currentPage + 1;
        refreshingHandler(wSelf.loadingPage);
    }];

    //for iphone X, make footer out of screen
    CGSize size = [[UIScreen mainScreen] bounds].size;
    size = CGSizeMake(size.width * [UIScreen mainScreen].scale,
                      size.height * [UIScreen mainScreen].scale);
    if (size.height == 2436) {
        footer.ignoredScrollViewContentInsetBottom = 34.0f;
    }

    scollView.mj_footer = footer;
    self.scollView = scollView;
}

- (void)endRefreshingWithWithSucceed:(BOOL)succeed noMoreData:(BOOL)noMoreData
{
    [self endRefreshing];
    if (succeed) {
        if (self.loadingPage == unusedLoadingPage) {
            self.currentPage = startingPage;
        } else {
            self.currentPage = self.loadingPage;
        }
    }
    self.loadingPage = unusedLoadingPage;

    if (noMoreData) {
        [self.scollView.mj_footer endRefreshingWithNoMoreData];
    } else {
        [self.scollView.mj_footer resetNoMoreData];
    }
}

- (void)endRefreshing
{
    if (self.scollView.mj_header.state == MJRefreshStateRefreshing) {
        [self.scollView.mj_header endRefreshing];
    }
    if (self.scollView.mj_footer.state == MJRefreshStateRefreshing) {
        [self.scollView.mj_footer endRefreshing];
    }
}

- (void)startRefreshing
{
    [self.scollView.mj_header beginRefreshing];
}

@end
