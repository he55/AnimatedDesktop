//
//  HEPrint.m
//  ThunderClean
//
//  Created by He55 on 2019/6/1.
//  Copyright © 2019 He55. All rights reserved.
//

#import "HEPrint.h"

#define __printf_ex(file, format, line)\
va_list arguments;\
va_start(arguments, (format));\
printf_ex((file), (format), (line), arguments);\
va_end(arguments);

static void printf_ex(FILE *file, NSString *format, BOOL line, va_list arguments) {
    if (line) {
        format = [format stringByAppendingString:@"\n"];
    }
    
    NSString *msg = [[NSString alloc] initWithFormat:format arguments:arguments];
    fprintf(file, "%s", [msg UTF8String]);
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
