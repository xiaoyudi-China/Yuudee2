//
//  HAMNodeSelectorViewController.m
//  iosapp
//
//  Created by daiyue on 13-7-24.
//  Copyright (c) 2013年 Droplings. All rights reserved.
//

#import "HAMNodeSelectorViewController.h"

@interface HAMNodeSelectorViewController ()

@end

@implementation HAMNodeSelectorViewController

@synthesize config;
@synthesize parentID;
@synthesize index;
@synthesize cardListTableView;
@synthesize deleteBtn;

@synthesize editNodeController;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];	
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    mode=0;
    self.title=@"选择词条/分类";
}

- (void)viewDidUnload {
    [self setCardListTableView:nil];
    [super viewDidUnload];
}

-(void)viewWillAppear:(BOOL)animated
{
    [cardListTableView reloadData];
    
    if (index==-1)
    {
        if (!deleteBtn)
            deleteBtn = [[UIBarButtonItem alloc] initWithTitle:@"删除" style:UIBarButtonItemStyleBordered target:self action:@selector(deleteBtnPressed:)];
        self.navigationItem.rightBarButtonItem = deleteBtn;
    }
    else
    {
        cardListTableView.editing=NO;
        self.navigationItem.rightBarButtonItem=nil;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -
#pragma mark Table View Data Source Methods
-(NSInteger)tableView:(UITableView*)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self currentListCount]; 
}

-(NSMutableArray*)currentList{
    
    switch (mode) {
        case 0:
            //return [config allList];
            break;
            
        case 1:
            //return [config cardList];
            break;
            
        case 2:
            //return [config catList];
            break;
            
        default:
            break;
    }
    return 0;
}

-(HAMCard*)currentListAt:(int)pos
{
    if (index!=-1)
        pos--;
    return [self currentList][pos];
}

-(int)currentListCount
{
    int count=[[self currentList] count];
    if (index!=-1)
        count++;
    return count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString* cardListIdentifier=@"nodeListIdentifier";
    
    UITableViewCell *cell =[tableView dequeueReusableCellWithIdentifier:cardListIdentifier];
    
    if(cell==nil)
    {
        cell=[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cardListIdentifier];
    }
    
    NSUInteger row =[indexPath row];
    
    if (index==-1)
        //cell.editingStyle=UITableViewCellEditingStyleDelete;
        cell.accessoryType=UITableViewCellAccessoryDisclosureIndicator;
    else
        cell.accessoryType=UITableViewCellAccessoryNone;
    
    if (index!=-1 && row==0)
    {
        cell.textLabel.text=@"清除";
        return cell;
    }
    cell.textLabel.text=[self currentListAt:row].name;
    
    return cell;
}

#pragma mark -
#pragma mark Table View Delegate Methods

-(void)tableView:(UITableView*)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    int row=[indexPath row];
    NSString* childID;
    if (index!=-1 && row==0)
        childID=nil;
    else
    {
        childID=[[self currentListAt:row] UUID];
    }
    
    if ([childID isEqualToString:config.rootID])
    {
         [cardListTableView deselectRowAtIndexPath:indexPath animated:YES];
        return;
    }
    
    if (index!=-1)
    {
        [config updateRoomOfCat:parentID with:[[HAMRoom alloc] initWithCardID:childID animation:ROOM_ANIMATION_SCALE] atIndex:index];
        [self.navigationController popViewControllerAnimated:YES];
    }
    else
    {
        [self gotoEditNode:childID];
    }
}

-(void)updateTableNewRow:(int)newRowNum oldRow:(int)oldRowNum
{
    //update row num
    [cardListTableView beginUpdates];
    NSMutableArray* affectNodes=[NSMutableArray arrayWithCapacity:abs(newRowNum-oldRowNum)];
    
    int i;
    if(newRowNum<oldRowNum)
    {
        for(i=newRowNum;i<oldRowNum;i++)
            [affectNodes addObject:[NSIndexPath indexPathForRow:i inSection:0]];
        [cardListTableView deleteRowsAtIndexPaths:affectNodes withRowAnimation:UITableViewRowAnimationFade];
    }
    else if (newRowNum>oldRowNum)
    {
        for(i=oldRowNum;i<newRowNum;i++)
            [affectNodes addObject:[NSIndexPath indexPathForRow:i inSection:0]];
        [cardListTableView insertRowsAtIndexPaths:affectNodes withRowAnimation:UITableViewRowAnimationFade];
    }
    
    NSMutableArray* allNodes=[NSMutableArray arrayWithCapacity:newRowNum];
    
    [cardListTableView endUpdates];
    
    //update row content
    [cardListTableView beginUpdates];
    
    i=0;
    if (index!=-1)
        i++;
    for (;i<newRowNum;i++)
    {
        [allNodes addObject:[NSIndexPath indexPathForRow:i inSection:0]];
    }
    [cardListTableView reloadRowsAtIndexPaths: allNodes withRowAnimation: UITableViewRowAnimationAutomatic];
    
    [cardListTableView endUpdates];
}

- (void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item {
    
    int oldRowNum=[self currentListCount];
    mode=[item tag];
    int newRowNum=[self currentListCount];
    
    [self updateTableNewRow:newRowNum oldRow:oldRowNum];
}

-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0 && mode!=1)
        return NO;
    
    return YES;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
        if (index==-1)
            return UITableViewCellEditingStyleDelete;     //return UITableViewCellEditingStyleInsert;
        else
            return UITableViewCellEditingStyleNone;
    }

- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath{
    return @"删除词条";
}

-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath

{
    NSUInteger row = [indexPath row];
    [config deleteCard:[self currentListAt:row].UUID];
    [cardListTableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]withRowAnimation:UITableViewRowAnimationLeft];
}

#pragma mark -
#pragma mark Delete Methods

-(void)deleteBtnPressed:(id)sender
{
    if (self.cardListTableView.editing)
    {
        self.cardListTableView.editing=NO;
        [sender setTitle:@"删除"];
    }
    else
    {
        self.cardListTableView.editing=YES;
        [sender setTitle:@"返回"];
    }
}

#pragma mark -
#pragma mark Goto View

-(void)gotoEditNode:(NSString*)cardID
{
    if (editNodeController==nil)
    {
        editNodeController=[[HAMEditNodeViewController alloc]
                            initWithNibName:@"HAMEditNodeViewController" bundle:nil];
        editNodeController.config=config;
    }
    editNodeController.newFlag=-1;
    editNodeController.card=[[HAMCard alloc] initWithID:cardID];
    [self.navigationController pushViewController:editNodeController animated:YES];
}

@end
