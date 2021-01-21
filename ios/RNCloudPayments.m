#import "RNCloudPayments.h"
#import "SDK/Card.m"
#import "SDWebViewController/SDWebViewController.h"
#import "SDWebViewController/SDWebViewDelegate.h"
#import "NSString+URLEncoding.h"

typedef void (^RCTPromiseResolveBlock)(id result);
typedef void (^RCTPromiseRejectBlock)(NSString *code, NSString *message, NSError *error);

@interface RNCloudPayments () <SDWebViewDelegate>

@property (nonatomic, retain) UINavigationController *navigationController;

@property (nonatomic) RCTPromiseResolveBlock resolveWebView;
@property (nonatomic) RCTPromiseRejectBlock rejectWebView;
@property NSString* termUrl;
@property BOOL didCallResolve;

@end

@implementation RNCloudPayments

RCT_EXPORT_MODULE();

RCT_EXPORT_METHOD(isValidNumber: (NSString *)cardNumber
                  resolve: (RCTPromiseResolveBlock)resolve
                  reject: (RCTPromiseRejectBlock)reject)
{
    if([Card isCardNumberValid: cardNumber]) {
        resolve(@YES);
    } else {
        resolve(@NO);
    }
};

RCT_EXPORT_METHOD(isValidExpired: (NSString *)cardExp
                  resolve: (RCTPromiseResolveBlock)resolve
                  reject: (RCTPromiseRejectBlock)reject)
{
    if([Card isExpiredValid: cardExp]) {
        resolve(@YES);
    } else {
        resolve(@NO);
    }
};

RCT_EXPORT_METHOD(getType: (NSString *)cardNumber
                  cardExp: (NSString *)cardExp
                  cardCvv: (NSString *)cardCvv
                  resolve: (RCTPromiseResolveBlock)resolve
                  reject: (RCTPromiseRejectBlock)reject)
{
    CardType cardType = [Card cardTypeFromCardNumber: cardNumber];
    NSString *cardTypeString = [Card cardTypeToString: cardType];

    resolve(cardTypeString);
}

RCT_EXPORT_METHOD(createCryptogram: (NSString *)cardNumber
                  cardExp: (NSString *)cardExp
                  cardCvv: (NSString *)cardCvv
                  publicId: (NSString *)publicId
                  resolve: (RCTPromiseResolveBlock)resolve
                  reject: (RCTPromiseRejectBlock)reject)
{
    Card *_card = [[Card alloc] init];

    NSString *cryptogram = [_card makeCardCryptogramPacket: cardNumber andExpDate:cardExp andCVV:cardCvv andMerchantPublicID:publicId];

    resolve(cryptogram);
}

RCT_EXPORT_METHOD(show3DS: (NSString *)url
                  transactionId: (NSString *)transactionId
                  token: (NSString *)token
                  termUrl: (NSString *) termUrl
                  resolve: (RCTPromiseResolveBlock)resolve
                  reject: (RCTPromiseRejectBlock)reject)
{
    self.resolveWebView = resolve;
    self.rejectWebView = reject;
    self.termUrl = termUrl;

    // Show WebView
    SDWebViewController *webViewController = [[SDWebViewController alloc] initWithURL:url transactionId:transactionId token:token termUrl:termUrl];
    webViewController.m_delegate = self;
    self.didCallResolve = false;
    self.navigationController = [[UINavigationController alloc] initWithRootViewController:webViewController];
    dispatch_sync(dispatch_get_main_queue(), ^{
        [self.navigationController.navigationBar setTranslucent:true];
        [[self topViewController] presentViewController:self.navigationController animated:YES completion:nil];
    });
}

#pragma MARK: - SDWebViewDelegate

- (void)webView:(WKWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType: (UIWebViewNavigationType)navigationType {

    // Detect url
    NSString *urlString = request.URL.absoluteString;

    if ([urlString isEqualToString:self.termUrl]) {
        self.didCallResolve = true;
        self.resolveWebView(nil);
        [self.navigationController dismissViewControllerAnimated:YES completion:nil];
    }
}

- (void)webViewDidClose:(WKWebView *)webView {
    if (!self.didCallResolve) {
        self.rejectWebView(@"", @"", nil);
        self.didCallResolve = true;
    }
}

#pragma MARK: - ViewController

- (UIViewController *)topViewController {
    UIViewController *baseVC = UIApplication.sharedApplication.keyWindow.rootViewController;
    if ([baseVC isKindOfClass:[UINavigationController class]]) {
        return ((UINavigationController *)baseVC).visibleViewController;
    }

    if ([baseVC isKindOfClass:[UITabBarController class]]) {
        UIViewController *selectedTVC = ((UITabBarController*)baseVC).selectedViewController;
        if (selectedTVC) {
            return selectedTVC;
        }
    }

    if (baseVC.presentedViewController) {
        return baseVC.presentedViewController;
    }

    return baseVC;
}

@end
