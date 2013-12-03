//
//  HAMViewController.m
//  iosapp
//
//  Created by daiyue on 13-7-9.
//  Copyright (c) 2013年 Droplings. All rights reserved.
//768*1000
//

#import "HAMViewController.h"
#import "HAMFileTools.h"

@interface HAMViewController ()
						
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView_;
@end

@implementation HAMViewController
@synthesize scrollView_;

- (void)viewDidLoad{
    [super viewDidLoad];
    
    activeUsername=@"hamster";
}

-(void)viewWillAppear:(BOOL)animated
{    
    config=[[HAMConfig alloc] initFromDB];
    currentUUID=config.rootID;
    if (!config)
        return;
    
    userManager=[HAMUserManager new];
    userManager.config=config;
    
    HAMUser* currentUser=userManager.currentUser;
    
//    HAMViewInfo* viewInfo=[[HAMViewInfo alloc] initWithframe:[self.view frame] xnum:currentUser.layoutx ynum:currentUser.layouty h:0 minspace:30];
    HAMViewInfo* viewInfo = [[HAMViewInfo alloc] initWithXnum:currentUser.layoutx ynum:currentUser.layouty];
    
    gridViewTool=[[HAMGridViewTool alloc] initWithView:scrollView_ viewInfo:viewInfo config:config delegate:self edit:NO];
    [gridViewTool refreshView:currentUUID scrollToFirstPage:YES];
}

- (void)didReceiveMemoryWarning{
    [super didReceiveMemoryWarning];
}

#pragma mark -
#pragma mark Actions

-(IBAction) groupClicked:(id)sender{
    int index=[sender tag];
    if (index==-1)
        currentUUID=config.rootID;
    else
        currentUUID=[config childCardIDOfCat:currentUUID atIndex:index];
    
    [gridViewTool refreshView:currentUUID scrollToFirstPage:YES];
}

-(IBAction) leafClicked:(id)sender{
    
    if (audioPlayer!=nil)
        if ([audioPlayer isPlaying])
        {
            return;
        }
    
    int index = [sender tag];
    HAMRoom* room = [config roomOfCat:currentUUID atIndex:index];
    
    UIView* cardView = [[gridViewTool cardViewArray_] objectAtIndex:index];
    [HAMAnimation beginAnimation:room.animation_ onCardView:cardView];
    
    //NSString *musicPath= [[NSBundle mainBundle] pathForResource:[[card audio] localPath] ofType:@""];
    HAMCard* card = [config card:room.cardID_];
    NSString* musicPath=[HAMFileTools filePath:[[card audio] localPath]];
    
    if (musicPath){
        NSURL *musicURL = [NSURL fileURLWithPath:musicPath];
        audioPlayer = [[AVAudioPlayer alloc]  initWithContentsOfURL:musicURL  error:nil];
        [audioPlayer setDelegate:self];
        [audioPlayer play];
    }
}

#pragma mark -
#pragma mark Multi Touch

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    NSLog(@"touchNumber:%d", [touches count]);
    /*
    for(UITouch *touch in touches)
    {
        CGPoint pt = [touch locationInView:self.view];
        [pointLocation addObject:[NSValue valueWithCGPoint:pt]];
        
        NSLog(@"touchHash:%d",touch.hash);
    }//[pointLocation replaceObjectAtIndex:touchNumber withObject:[NSValue valueWithCGPoint:pt]];
    
    
     NSLog(@"%f,%f", pt.x, pt.y);
     NSLog(@"------touch point stored------");
     for (int i = 0; i < [pointLocation count]; i++) {
     CGPoint temp = [(NSValue *)[pointLocation objectAtIndex:i] CGPointValue];
     NSLog(@"存在点:%f, %f", temp.x, temp.y);
     }
     NSLog(@"------touch point stored------");
     
    
    if ([pointLocation count] == 3) {
        int a = 0;
        int b = 0;
        int c = 0;
        for (int i = 0; i < [pointLocation count]; i++) {
            CGPoint temp = [(NSValue *)[pointLocation objectAtIndex:i] CGPointValue];
            NSLog(@"存在点:%f, %f", temp.x, temp.y);
            if(temp.x < 100 && temp.y < 100)
                a = 1;
            if(temp.x < 100 && temp.y > 800)
                b = 1;
            if(temp.x > 700 && temp.y < 100)
                c = 1;
        }
        if(a == 1 && b == 1 && c == 1)
        {
            alertLabel.text = @"3 point !";
        }
    }*/
    
    
}

@end