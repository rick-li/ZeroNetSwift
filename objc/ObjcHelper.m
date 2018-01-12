//
//  ObjcHelper.m
//  LearnSwiftPackageDescription
//
//  Created by Rick Li on 1/6/18.
//

#import <Foundation/Foundation.h>
#import "ObjcHelper.h"

@implementation ObjcHelper

-(void) hello{
    NSLog(@"Hello, World!");

}
- (NSString *) ntoa: (NSData *)input{
    struct sockaddr_in *socketAddress = (struct sockaddr_in *) [input bytes];
    NSLog(@"==== %s ", inet_ntoa(socketAddress->sin_addr));
}
@end
