//
//  ObjcHelper.h
//  LearnSwift
//
//  Created by Rick Li on 1/6/18.
//

#import <Foundation/Foundation.h>
#include <arpa/inet.h>

@interface ObjcHelper : NSObject

-(void) hello;
-(NSString *) ntoa: (NSData *)input;
@end
