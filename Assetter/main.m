//
//  main.m
//  Assetter
//
//  Created by Peter Bukowinski on 6/6/13.
//  Copyright (c) 2013 Peter Bukowinski. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import <AppleScriptObjC/AppleScriptObjC.h>

int main(int argc, char *argv[])
{
    [[NSBundle mainBundle] loadAppleScriptObjectiveCScripts];
    return NSApplicationMain(argc, (const char **)argv);
}
