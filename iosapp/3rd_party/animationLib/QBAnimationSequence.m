/*
 Copyright (c) 2013 Katsuma Tanaka
 
 Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */

#import "QBAnimationSequence.h"

#import "QBAnimationGroup.h"
#import "QBAnimationItem.h"

@interface QBAnimationSequence ()

@property (nonatomic, assign) NSUInteger currentGroup;
@property (nonatomic, assign) NSUInteger finishedCount;

- (void)performNextGroup;
- (void)animationFinished;

@end

@implementation QBAnimationSequence

@synthesize running;

+ (instancetype)sequence
{
    return [[self alloc] init];
}

+ (instancetype)sequenceWithAnimationGroups:(NSArray *)groups
{
    return [[self alloc] initWithAnimationGroups:groups];
}

+ (instancetype)sequenceWithAnimationGroups:(NSArray *)groups repeat:(BOOL)repeat
{
    return [[self alloc] initWithAnimationGroups:groups repeat:repeat];
}

- (instancetype)initWithAnimationGroups:(NSArray *)groups
{
    return [self initWithAnimationGroups:groups repeat:NO];
}

- (instancetype)initWithAnimationGroups:(NSArray *)groups repeat:(BOOL)repeat
{
    self = [super init];
    
    if (self) {
        self.groups = groups;
        self.repeat = repeat;
        
        self.running = NO;
    }
    
    return self;
}

- (instancetype)init
{
    return [self initWithAnimationGroups:nil repeat:NO];
}


#pragma mark - Animation

- (void)start
{
    if (self.running) return;
    
    self.running = YES;
    
    self.currentGroup = 0;
    self.finishedCount = 0;
    
    [self performNextGroup];
}

- (void)stop
{
    self.running = NO;
}

- (void)performNextGroup
{
    if (!self.running) return;
    
    if (self.currentGroup >= self.groups.count) {
        if (self.repeat) {
            self.running = NO;
            
            [self start];
        }
        
        //TODO: I add the following line. Might cause bug?
        self.running = NO;
        return;
    }
    
    QBAnimationGroup *group = (QBAnimationGroup *)(self.groups)[self.currentGroup];
    
    for (NSInteger i = 0; i < group.items.count; i++) {
        QBAnimationItem *item = (QBAnimationItem *)(group.items)[i];
        
        if (group.waitUntilDone) {
            [UIView animateWithDuration:item.duration delay:item.delay options:item.options animations:item.animations completion:^(BOOL finished) {
                if (finished) {
                    [self animationFinished];
                }
                else {
                    self.running = NO;
                }
            }];
        } else {
            [UIView animateWithDuration:item.duration delay:item.delay options:item.options animations:item.animations completion:nil];
        }
    }
    
    if (!group.waitUntilDone) {
        self.currentGroup++;
        
        [self performNextGroup];
    }
}

- (void)animationFinished
{
    self.finishedCount++;
    
    QBAnimationGroup *group = (QBAnimationGroup *)(self.groups)[self.currentGroup];
    
    if (self.finishedCount == group.items.count) {
        self.finishedCount = 0;
        
        self.currentGroup++;
        [self performNextGroup];
    }
}

@end
