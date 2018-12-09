//
//  AESEngine.m
//  
//
//  Created by User on 10/10/17.
//  Copyright © 2017 User. All rights reserved.
//


#import "AESEngine.h"

NSString* uniqueIDGenerator(void) {
    char string[16];
    for (NSUInteger index = 0; index < sizeof(string) - 1; index++) {
        if (!arc4random_uniform(2)) {
            string[index] = arc4random_uniform(6) + 48;
        }
        else string[index] = arc4random_uniform(5) + 97;
    }
    string[sizeof(string) - 1] = '\0';
    string[4] = '-';
    string[9] = '-';
    return [NSString stringWithCString:string encoding:NSASCIIStringEncoding];
}
