@import Foundation;
@import JavaScriptCore;

NS_ASSUME_NONNULL_BEGIN

@protocol MeshAPIObjcExports <JSExport>

+ (instancetype)getInstance;

- (NSString *)getMyID;

- (void)registerPeerAppearedHandler:(void (^)(NSString *))fn;

@end

@interface MeshAPIObjc : NSObject <MeshAPIObjcExports>

@end

NS_ASSUME_NONNULL_END
