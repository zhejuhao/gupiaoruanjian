//
//  KLine.m
//  Stock
//
//  Created by 李旗 on 15/12/1.
//  Copyright (c) 2015年 李旗. All rights reserved.
//

#import "AllKLine.h"
#import "GetData.h"

@implementation AllKLine
-(id)initWithFrame:(CGRect)frame :(NSArray *)begin :(NSArray *)end :(NSArray *)highest :(NSArray *)lowest :(double)chart_height :(double)line_with_cu :(double)line_with_xi :(double)spacing

{
    self = [super initWithFrame:frame];
    if (self)
    {
        m_margin_left= 2;
        UIImage *kline_image = [self draw_kline:begin :end :highest :lowest :chart_height :line_with_cu :line_with_xi :spacing];
        self.backgroundColor = [UIColor clearColor];
        UIImageView *imageKline = [[UIImageView alloc]initWithImage:kline_image];
        [self addSubview:imageKline];

    }
    return self;
}

-(UIImage *)draw_kline :(NSArray *)begin :(NSArray *)end :(NSArray *)highest :(NSArray *)lowest :(double)chart_height :(double)line_with_cu :(double)line_with_xi :(double)spacing
{
    
    int  arr_range = (int)(self.frame.size.width-m_margin_left*2)/(spacing+line_with_cu);
    int arr_begin = begin.count - arr_range;
    NSArray *highest_new = [highest subarrayWithRange:NSMakeRange(arr_begin,arr_range)];
    NSArray *lowest_new = [lowest subarrayWithRange:NSMakeRange(arr_begin, arr_range)];
    max = [[highest_new valueForKeyPath:@"@max.doubleValue"] doubleValue];
    min = [[lowest_new valueForKeyPath:@"@min.doubleValue"] doubleValue];
    kline_proportion = (max - min)/chart_height;
    UIGraphicsBeginImageContext(self.frame.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    for (int i = arr_begin; i < begin.count; i++)
    {
        if ([[begin objectAtIndex:i]doubleValue] > [[end objectAtIndex:i]doubleValue])
        {
            CGContextSetStrokeColorWithColor(context, [UIColor greenColor].CGColor);//线条颜色
        }
        else
        {
            CGContextSetStrokeColorWithColor(context, [UIColor redColor].CGColor);
        }
        CGContextSetLineWidth(context, line_with_cu);
        CGContextMoveToPoint(context, m_margin_left+ (line_with_cu+1)/2 +(i-arr_begin)*(line_with_cu+spacing),(max-[[begin objectAtIndex:i]doubleValue])/kline_proportion );//开始画线, x，y 为开始点的坐标
        CGContextAddLineToPoint(context, m_margin_left+(line_with_cu+1)/2+(i-arr_begin)*(line_with_cu+spacing), (max - [[end objectAtIndex:i]doubleValue])/kline_proportion);//画直线, x，y 为线条结束点的坐标
        CGContextStrokePath(context); //开始画线  画的是粗线
        
        
        CGContextSetLineWidth(context, line_with_xi);
        CGContextMoveToPoint(context, m_margin_left+ (line_with_cu+1)/2 +(i-arr_begin)*(line_with_cu+spacing),(max - [[highest objectAtIndex:i]doubleValue])/kline_proportion);//开始画线, x，y 为开始点的坐标
        CGContextAddLineToPoint(context, m_margin_left+ (line_with_cu+1)/2 +(i-arr_begin)*(line_with_cu+spacing), (max -[[lowest objectAtIndex:i]doubleValue])/kline_proportion);//画直线, x，y 为线条结束点的坐标
        CGContextStrokePath(context); //开始画线   画的是细线
    }
    


    
    UIImage *kline_image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return  kline_image;
}

@end
