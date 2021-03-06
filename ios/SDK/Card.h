#import <Foundation/Foundation.h>

typedef enum {
    Unknown,
    Visa,
    MasterCard,
    Maestro,
    Mir,
    JCB
} CardType;

@interface Card : NSObject {
    NSMutableArray *keyRefs;
}

+(BOOL) isCardNumberValid: (NSString *) cardNumberString;

+(BOOL) isExpiredValid: (NSString *) expiredString;

/**
 * Create cryptogram
 *    cardNumberString    valid card number stirng
 *    expDateString         string in format YYMM
 *     CVVString            3-digit number
 *     storePublicID        public_id of store
 */
-(NSString *) makeCardCryptogramPacket: (NSString *) cardNumberString andExpDate: (NSString *) expDateString andCVV: (NSString *) CVVString andMerchantPublicID: (NSString *) merchantPublicIDString;

+(CardType) cardTypeFromCardNumber:(NSString *)cardNumberString;
+(NSString *) cardTypeToString:(CardType)cardType;
@end

