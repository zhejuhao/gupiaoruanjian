//
//  ViewController.m
//  Stock
//
//  Created by 李旗 on 15/11/27.
//  Copyright (c) 2015年 李旗. All rights reserved.
//

#import "ViewController.h"
#import "DrawChart.h"
#import "AllKLine.h"
#import "BrokenLine.h"
#import "GetData.h"
#import "ImageViewController.h"
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.view.backgroundColor = [UIColor whiteColor];
    myTbaleView = [[UITableView alloc]initWithFrame:self.view.frame style:UITableViewStylePlain];
    myTbaleView.dataSource = self;
    myTbaleView.delegate = self;
    [self.view addSubview:myTbaleView];
    
    [self data_json];
    [self beginRefreshing];
   
}

-(void)data_json  //数据解析
{
    m_arr_all_stock_codes = [[NSMutableArray alloc]initWithCapacity:0];
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:@"http://smartbox.gtimg.cn/s3/?q=600&t=all"]];
    NSData *respose = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
    NSString *getData = [[NSString alloc]initWithData:respose encoding:NSUTF8StringEncoding];
    NSArray *data_array = [getData componentsSeparatedByString:@"^"];
    for (int i = 0; i < data_array.count; i ++)
    {
        NSArray *item_tmp = [[data_array objectAtIndex:i] componentsSeparatedByString:@"~"];
        NSString *str_sh = [item_tmp objectAtIndex:0];
        NSString *str_value = [NSString stringWithFormat:@"%@%@   %@",[str_sh substringFromIndex:str_sh.length-2],[item_tmp objectAtIndex:1],[item_tmp objectAtIndex:2]];
        if ([[str_sh substringFromIndex:str_sh.length-2]isEqualToString:@"sh"]||[[str_sh substringFromIndex:str_sh.length-2]isEqualToString:@"sz"])
        {
            [m_arr_all_stock_codes addObject:[self replaceUnicode:str_value]];
        }
    }
}
- (NSString*) replaceUnicode:(NSString*)aUnicodeString //unicode转化成utf8
{
    NSString *tempStr1 = [aUnicodeString stringByReplacingOccurrencesOfString:@"\\u" withString:@"\\U"];
    
    NSString *tempStr2 = [tempStr1 stringByReplacingOccurrencesOfString:@"\"" withString:@"\\\""];
    
    NSString *tempStr3 = [[@"\"" stringByAppendingString:tempStr2] stringByAppendingString:@"\""];
    
    NSData *tempData = [tempStr3 dataUsingEncoding:NSUTF8StringEncoding];
    
    NSString* returnStr = [NSPropertyListSerialization propertyListFromData:tempData mutabilityOption:NSPropertyListImmutable format:NULL errorDescription:NULL];
    return [returnStr stringByReplacingOccurrencesOfString:@"\\r\\n" withString:@"\n"];
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return m_arr_all_stock_codes.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    }
    cell.textLabel.text = [m_arr_all_stock_codes objectAtIndex:indexPath.row];
    return cell;
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray *code_array = [[m_arr_all_stock_codes objectAtIndex:[indexPath row]]componentsSeparatedByString:@"   "];
    NSString *code = [code_array objectAtIndex:0];
    
    ImageViewController *stock_image = [[ImageViewController alloc]initWithCode:code];
    [self.navigationController pushViewController:stock_image  animated:YES];
}
-(void)beginRefreshing
{
    refresh = [[UIRefreshControl alloc]init];
    refresh.tintColor = [UIColor lightGrayColor];
    refresh.attributedTitle = [[NSAttributedString alloc]initWithString:@"下拉刷新"];
    [refresh addTarget:self action:@selector(refreshTabelviewAction:) forControlEvents:UIControlEventValueChanged];
    
    
    
}
-(void)refreshTabelviewAction:(UIRefreshControl *)refreshs
{
    if(refreshs.refreshing)
    {
        refreshs.attributedTitle = [[NSAttributedString alloc]initWithString:@"正在刷新"];
        [self performSelector:@selector(refreshData) withObject:nil afterDelay:2];
    }
}
-(void)refreshData
{
    NSString *syseTime = nil;
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    [formatter setDateFormat:@"yyyy-mm-dd hh:mm:ss" ];
    syseTime = [formatter stringFromDate:[NSDate date]];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
