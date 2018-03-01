//
//  UIViewController+Pagination.h
//  Pagination
//
//  Created by eden on 16/10/9.
//  Copyright © 2016年 eden. All rights reserved.
//

#import <UIKit/UIKit.h>

///currentPage The page being refreshed
typedef void (^EDHRefreshingHandler)(NSInteger currentPage);

@interface UIViewController (Pagination)

@property (nonatomic, readonly) NSInteger currentPage;    //The page being refreshed
@property (nonatomic, assign) NSInteger pageSize;   //size for per page, Default is 20

/**
 * Add pull down to refresh for specified scollView
 * @param scollView     The scollView who want to add pull down to refresh
 * @param refreshingHandler   pull down to refresh operation handler
 */
- (void)addPullDownToRefreshWithScollView:(UIScrollView*)scollView
                        refreshingHandler:(EDHRefreshingHandler)refreshingHandler;

/**
 * Add pull up to load more for specified scollView
 * @param scollView     The scollView who want to add pull up to load more
 * @param refreshingHandler   pull up to load more operation handler
 */
- (void)addPullUpToLoadMoreWithScollView:(UIScrollView*)scollView
                       refreshingHandler:(EDHRefreshingHandler)refreshingHandler;

/**
 * When the data is loaded,manually call this function to end refreshing
 * @param succeed     Whether the data is refreshed successfully
 * @param noMoreData   All data has been loaded
 */
- (void)endRefreshingWithWithSucceed:(BOOL)succeed noMoreData:(BOOL)noMoreData;

/**
 end refreshing
 */
- (void)endRefreshing;

/**
 start refreshing
 */
- (void)startRefreshing;

@end
