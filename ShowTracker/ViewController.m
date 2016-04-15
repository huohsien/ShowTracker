//
//  RWViewController.m
//  ShowTracker
//
//  Created by Joshua on 3/1/14.
//  Copyright (c) 2014 Ray Wenderlich. All rights reserved.
//

#import "ViewController.h"
#import "TraktAPIClient.h"
#import <AFNetworking/UIKit+AFNetworking.h>
#import <Nimbus/NIAttributedLabel.h>
#import <SAMCategories/UIScreen+SAMAdditions.h>

@interface ViewController ()

@end

@implementation ViewController

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.previousPage = -1;
    
    TraktAPIClient *client = [TraktAPIClient sharedClient];
    
    [client getTrendingShowsWithSuccess:^(NSURLSessionDataTask *task, id responseObject) {
                        
                        NSLog(@"Success -- %@", responseObject);
                        // Save response object
                        self.jsonResponse = responseObject;
                        
                        // Get the number of shows
                        NSInteger shows = [self.jsonResponse count];
                        
                        // Set up page control
                        self.showsPageControl.numberOfPages = shows;
                        self.showsPageControl.currentPage = 0;
                        
                        // Set up scroll view
                        self.showsScrollView.contentSize = CGSizeMake(CGRectGetWidth(self.view.bounds) * shows, CGRectGetHeight(self.showsScrollView.frame));
                        
                        // Load first show
                        [self loadShow:0];
                    } failure:^(NSURLSessionDataTask *task, NSError *error) {
                        
                        NSLog(@"Failure -- %@", error);
                    }];
    
}

- (void)loadShow:(NSInteger)index
{
    // 1 - Find the show for the given index
    NSDictionary *show = nil;
    
    if (index < [self.jsonResponse count])
        show = [self.jsonResponse objectAtIndex:index];
    else
        return;
    
    // 4 - Load the show information
    
    NSDictionary *showDict = show[@"show"];
    
    // 5 - Display the show title
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(index * CGRectGetWidth(self.showsScrollView.bounds) + 20, 40, CGRectGetWidth(self.showsScrollView.bounds) - 40, 40)];
    titleLabel.text = showDict[@"title"];
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.font = [UIFont boldSystemFontOfSize:18];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    [self addEpisodeLabelOfShow:show OnPageNumber:index];
    // Add to scroll view
    [self.showsScrollView addSubview:titleLabel];
}

- (void)addEpisodeLabelOfShow:(NSDictionary *)show OnPageNumber:(NSInteger)index{
    // Create formatted airing date
    if (index < [self.jsonResponse count])
        show = [self.jsonResponse objectAtIndex:index];
    else
        return;
    
    
    NSString *yearString = show[@"show"][@"year"];
    
    // Create label to display episode info
    UILabel *episodeLabel = [[UILabel alloc] initWithFrame:CGRectMake(index * CGRectGetWidth(self.showsScrollView.bounds), 360, CGRectGetWidth(self.showsScrollView.bounds), 40)];
    
    episodeLabel.text = [NSString stringWithFormat:@"Year: %@\n", yearString];
    episodeLabel.numberOfLines = 0;
    episodeLabel.textAlignment = NSTextAlignmentCenter;
    episodeLabel.textColor = [UIColor whiteColor];
    episodeLabel.backgroundColor = [UIColor clearColor];
    
    CGSize size = [episodeLabel sizeThatFits:CGSizeMake(CGRectGetWidth(self.view.frame),
                                                        CGRectGetHeight(self.view.frame) - CGRectGetMinY(episodeLabel.frame))];
    CGRect frame = episodeLabel.frame;
    frame.size.width = self.view.frame.size.width;
    frame.size.height = size.height;
    episodeLabel.frame = frame;
    
    [self.showsScrollView addSubview:episodeLabel];
    
    
}

#pragma mark - Actions

- (IBAction)pageChanged:(id)sender
{
    // Set flag
    self.pageControlUsed = YES;
    
    // Get previous page number
    NSInteger page = self.showsPageControl.currentPage;
    self.previousPage = page;
    
    // Call loadShow for the new page
    [self loadShow:page];
    
    // Scroll scroll view to new page
    CGRect frame = self.showsScrollView.frame;
    frame.origin.x = frame.size.width * page;
    frame.origin.y = 0;
    [UIView animateWithDuration:.5 animations:^{
        [self.showsScrollView scrollRectToVisible:frame animated:NO];
    } completion:^(BOOL finished) {
        self.pageControlUsed = NO;
    }];
}



- (void)scrollViewDidScroll:(UIScrollView *)sender
{
    // Was the scrolling initiated via page control?
    if (self.pageControlUsed)
        return;
    
    // Figure out page to scroll to
    CGFloat pageWidth = sender.frame.size.width;
    NSInteger page = floor((sender.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    
    // Do not do anything if we're trying to go beyond the available page range
    if (page == self.previousPage || page < 0 || page >= self.showsPageControl.numberOfPages)
        return;
    self.previousPage = page;
    
    // Set the page control page display
    self.showsPageControl.currentPage = page;
    
    // Load the page
    [self loadShow:page];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    self.pageControlUsed = NO;
}

@end
