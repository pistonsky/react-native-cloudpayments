//
//  SDWebViewController.h
//  SDWebViewController
//
//  Created by Dmitry Sytsevich on 5/30/19.
//  Copyright © 2019 Dmitry Sytsevich. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <WebKit/WebKit.h>

@protocol SDWebViewDelegate;
@interface SDWebViewController : UIViewController

@property (weak, nonatomic) id<SDWebViewDelegate> m_delegate;

- (id)initWithURL:(id)url transactionId:(NSString *)transactionId token:(NSString *)token termUrl:(NSString *)termUrl;
- (NSString *)stringByURLEncoding;

@end
