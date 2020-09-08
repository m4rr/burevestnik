#import "MeshAPIObjc.h"

@implementation MeshAPIObjc

- (NSString *)getMyID {
  return @"OBJCCCCCC";
}

- (void)registerPeerAppearedHandler:(nonnull void (^)(NSString *))fn {

}

+ (nonnull instancetype)getInstance {
  return [[MeshAPIObjc alloc] init];
}

@end
