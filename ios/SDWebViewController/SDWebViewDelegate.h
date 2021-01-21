//
//  SDWebViewDelegate.h
//  SDWebViewController
//
//  Created by Dmitry Sytsevich on 5/30/19.
//  Copyright © 2019 Dmitry Sytsevich. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <WebKit/WebKit.h>

@protocol SDWebViewDelegate <NSObject>

@optional
- (void)webView:(WKWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType: (WKNavigationType)navigationType;
- (void)webViewDidClose:(WKWebView *)webView;
- (void)onWebViewDidFinishLoad:(WKWebView *)webView;
- (void)onWebViewDidStartLoad:(WKWebView *)webView;
- (void)webViewFailToLoad:(NSError *)error;

@end
