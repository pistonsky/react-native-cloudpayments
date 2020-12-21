//
//  SDWebViewController.m
//  SDWebViewController
//
//  Created by Dmitry Sytsevich on 5/30/19.
//  Copyright © 2019 Dmitry Sytsevich. All rights reserved.
//

#define IBT_BGCOLOR             [UIColor whiteColor]
#define IBT_ADDRESS_TEXT_COLOR  [UIColor colorWithRed:.44 green:.45  blue:.46  alpha:1]
#define IBT_PROGRESS_COLOR      [UIColor colorWithRed:0   green:.071 blue:.75  alpha:1]

#define POST_BACK_URL @"https://demo.cloudpayments.ru/WebFormPost/GetWebViewData"

#import "SDWebViewController.h"
#import "SDWebViewDelegate.h"
#import <WebKit/WebKit.h>
#import "NSString+URLEncoding.h"

@interface SDWebViewController () <WKNavigationDelegate> {
    
    // Address bar
    UIImageView *m_addressBarView;
    UILabel *m_addressLabel;
    
    // URL
    NSURL *m_currentUrl;
    
    BOOL m_bAutoSetTitle;
}
@property (strong, nonatomic) WKWebView *m_webView;

@property (strong, nonatomic) NSString *m_initUrl;
@property (strong, nonatomic) NSString *m_transactionId;
@property (strong, nonatomic) NSString *m_token;
@property (strong, nonatomic) NSString *m_termUrl;
@property (strong, nonatomic) NSMutableDictionary *m_extraInfo;

- (void)initWebView;
- (void)initAddressBarView;
- (void)removeAddressBar;
- (void)initNavigationBarItem;

@end

@implementation SDWebViewController

#pragma mark -

- (id)initWithURL:(id)url transactionId:(NSString *)transactionId token:(NSString *)token termUrl:(NSString *)termUrl {
    self = [super init];
    if (!self) {
        return nil;
    }
    
    self.m_initUrl = url;
    self.m_transactionId = transactionId;
    self.m_token = token;
    self.m_termUrl = termUrl;
    
    
    if ([url isKindOfClass:[NSString class]]) {
        self.m_initUrl = url;
    }
    else if ([url isKindOfClass:[NSURL class]]) {
        self.m_initUrl = [NSString stringWithFormat:@"%@", url];
    }
    
    m_bAutoSetTitle = YES;
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = IBT_BGCOLOR;
    
    if ([self respondsToSelector:@selector(setEdgesForExtendedLayout:)]) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    
    [self initNavigationBarItem];
    [self initAddressBarView];
    [self initWebView];
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [self.m_webView stopLoading];
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    //    self.m_webView.delegate = nil;
    
    m_addressBarView = nil;
    m_addressLabel = nil;
    
    m_currentUrl = nil;
}

#pragma MARK: - Private Method

- (void)initWebView {
    self.m_webView = [[WKWebView alloc] initWithFrame:self.view.bounds];
    self.m_webView.backgroundColor = [UIColor clearColor];
    //    self.m_webView.delegate = self;
    //    self.m_webView.scalesPageToFit = YES;
    self.m_webView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.m_webView.navigationDelegate = self;
    [self.view addSubview:self.m_webView];
    
    [self loadURL:self.m_initUrl transactionId:self.m_transactionId token:self.m_token termUrl:self.m_termUrl];
}

- (void)updateDisplayTitle:(NSString *)nsTitle {
    self.title = nsTitle;
}

#pragma MARK: - Address Bar

- (NSString *)getAddressBarHostText:(NSURL *)url {
    if ([url.host length] > 0) {
        return [NSString stringWithFormat:NSLocalizedString(@"Provided by %@", nil), url.host];
    } else {
        return @"";
    }
}

- (void)initAddressBarView {
    if (!m_addressBarView) {
        m_addressBarView = [[UIImageView alloc] init];
        m_addressBarView.frame = (CGRect){
            .origin.x = 0,
            .origin.y = 0,
            .size.width = CGRectGetWidth(self.view.bounds),
            .size.height = 40
        };
        
        m_addressLabel = [[UILabel alloc] init];
        m_addressLabel.frame = CGRectInset(m_addressBarView.bounds, 10, 6);
        m_addressLabel.textColor = [UIColor clearColor];
        m_addressLabel.textAlignment = NSTextAlignmentCenter;
        m_addressLabel.textColor = IBT_ADDRESS_TEXT_COLOR;
        m_addressLabel.font = [UIFont systemFontOfSize:12];
        
        [m_addressBarView addSubview:m_addressLabel];
    }
    
    [self.view addSubview:m_addressBarView];
}

- (void)removeAddressBar {
    [m_addressBarView removeFromSuperview];
    m_addressBarView = nil;
    m_addressLabel = nil;
}

#pragma MARK: - Navigation Bar

- (void)initNavigationBarItem {
    UIBarButtonItem *backItem =
    [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Done", nil)
                                     style:UIBarButtonItemStylePlain
                                    target:self
                                    action:@selector(onCloseAction:)];
    
    self.navigationItem.rightBarButtonItems = @[ backItem ];
    
}

- (void)onCloseAction:(__unused id)sender {
    [self.presentingViewController dismissViewControllerAnimated:YES completion:NULL];
}

#pragma MARK: - WebView Action

- (BOOL)isTopLevelNavigation:(NSURLRequest *)req {
    if (req.mainDocumentURL) {
        return [req.URL isEqual:req.mainDocumentURL];
    } else {
        return YES;
    }
}

- (void) makeRequest {
    NSString *postData = [NSString stringWithFormat: @"MD=%@&PaReq=%@&TermUrl=%@", self.m_token, self.m_transactionId, self.m_termUrl];
    NSString *urlString = @"https://demo.cloudpayments.ru/acs";
    NSString *jscript = [NSString stringWithFormat:@"post('%@', {%@});", urlString, postData];
    NSLog(@"Javascript: %@", jscript);
    [self.m_webView evaluateJavaScript:jscript completionHandler:nil];
}

- (void)loadURL:(NSString *)url transactionId:(NSString *)transactionId token:(NSString *)token termUrl:(NSString *)termUrl {
    NSString *body = [NSString stringWithFormat: @"MD=%@&PaReq=%@&TermUrl=%@", token, transactionId, termUrl];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString: url]];
    [request setHTTPMethod: @"POST"];
    body = [body stringByURLEncoding];
    [request setHTTPBody: [body dataUsingEncoding: NSUTF8StringEncoding]];
    [request addValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [self.m_webView loadRequest: request];
}

- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler{
    if ([_m_delegate respondsToSelector:@selector(webView:shouldStartLoadWithRequest:navigationType:)]) {
        [_m_delegate webView:webView shouldStartLoadWithRequest:navigationAction.request navigationType:navigationAction.navigationType];
    }
    
    m_currentUrl = navigationAction.request.mainDocumentURL;
    m_addressLabel.text = [self getAddressBarHostText:m_currentUrl];
    decisionHandler(WKNavigationActionPolicyAllow);
}

- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(null_unspecified WKNavigation *)navigation{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    
    if ([_m_delegate respondsToSelector:@selector(onWebViewDidStartLoad:)]) {
        [_m_delegate onWebViewDidStartLoad:webView];
    }
    
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(null_unspecified WKNavigation *)navigation{
    [self makeRequest];
}

- (void)webView:(WKWebView *)webView didFailNavigation:(null_unspecified WKNavigation *)navigation withError:(NSError *)error{
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
}
@end
