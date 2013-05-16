//
//  NSSet_vs_NSDictionary_test.m
//  TestDictionary
//
//  Created by Amos Elmaliah on 5/15/13.
//  Copyright (c) 2013 Amos Elmaliah. All rights reserved.
//

#import "NSSet_vs_NSDictionary_test.h"
#import <mach/mach_time.h>

@implementation NSSet_vs_NSDictionary_test
{
    double                  machTimerMillisMult;
}

-(NSData*)createRandomNSData
{
    int sizeInKB           = 209;
    NSMutableData* theData = [NSMutableData dataWithCapacity:sizeInKB];
    for( unsigned int i = 0 ; i < sizeInKB/4 ; ++i )
    {
        u_int32_t randomBits = arc4random();
        [theData appendBytes:(void*)&randomBits length:4];
    }
    return theData;
}


-(void)displayResult:(uint64_t)duration withPrefix:(NSString*)prefix {
    
    double millis = duration * machTimerMillisMult;
    NSLog(@"%@ took %f milliseconds", prefix, millis);
}

-(void) runTest {
    
    mach_timebase_info_data_t info;
    mach_timebase_info(&info);
    machTimerMillisMult = (double)info.numer / ((double)info.denom * 1000000.0);
    
    NSUInteger size = 1000;
    NSMutableDictionary* dictioary = [[NSMutableDictionary alloc] initWithCapacity:size];
    NSMutableSet* set = [[NSMutableSet alloc] initWithCapacity:size];
    for (int i = 0; i < size; i++) {
        NSData *data  = [self createRandomNSData];
        [dictioary setObject:data forKey:[NSString stringWithFormat:@"%ld", (unsigned long)data.hash]];
        [set addObject:data];
    }
    
    // find a specific object
    
    
    NSUInteger tests = 200;
    NSMutableArray* testArray = [[NSMutableArray alloc] initWithCapacity:tests];
    
    //create tests array:
    for (int i = 0; i < tests; i++) {
        
        NSUInteger randomIndex = arc4random() % size;
        NSObject* object = [[dictioary allValues] objectAtIndex:randomIndex];
        [testArray addObject:object];
        
    }
    
    // test 1
    uint64_t start = mach_absolute_time();
    
    for (NSObject* object  in testArray) {
        
        NSString* key = [NSString stringWithFormat:@"%ld", (unsigned long)object.hash];
        
        if (![dictioary objectForKey:key]) {
            NSLog(@"didn't find object");
            break;
        }
    }
    
    [self displayResult:mach_absolute_time() - start withPrefix:@"dictionary"];
    
    // test 2
    start = mach_absolute_time();
    
    for (NSObject* object  in testArray) {
        
        if (![set member:object]) {
            NSLog(@"didn't find object");
            break;
        }
    }
    
    [self displayResult:mach_absolute_time() - start withPrefix:@"set"];

}

@end
