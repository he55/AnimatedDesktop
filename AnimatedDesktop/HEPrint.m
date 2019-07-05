//
//  HEPrint.m
//  ThunderClean
//
//  Created by He55 on 2019/6/1.
//  Copyright © 2019 He55. All rights reserved.
//

#import "HEPrint.h"

#define __printf_ex(file, format, isLine) \
        va_list arguments; \
        va_start(arguments, format); \
        printf_ex(file, format, isLine, arguments); \
        va_end(arguments)

static void printf_ex(FILE *file, NSString *format, BOOL isLine, va_list arguments) {
    if (isLine) {
        format = [format stringByAppendingString:@"\n"];
    }
    
    NSString *formatString = [[NSString alloc] initWithFormat:format arguments:arguments];
    fprintf(file, "%s", [formatString UTF8String]);
}

void HEPrint(NSString *format, ...) {
    __printf_ex(stdout, format, NO);
}

void HEPrintln(NSString *format, ...) {
    __printf_ex(stdout, format, YES);
}

void HEFprint(FILE *file, NSString *format, ...) {
    __printf_ex(file, format, NO);
}

void HEFprintln(FILE *file, NSString *format, ...) {
    __printf_ex(file, format, YES);
}
