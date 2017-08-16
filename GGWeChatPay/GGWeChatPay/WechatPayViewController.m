//
//  AppDelegate.h
//  GGWeChatPay
//
//  Created by mac on 2017/8/16.
//  Copyright © 2017年 mac. All rights reserved.
//

#import "WechatPayViewController.h"
#import "HYBNetworking.h"
#import "WXApi.h"
#import "NSString+MD5.h"

@interface WechatPayViewController ()

//商户关键信息 ,微信分配给商户的appID,商户号,商户的密钥
@property (nonatomic,strong) NSString *appId,*mchId,*spKey;
@end

@implementation WechatPayViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    UIButton *payButton = [UIButton buttonWithType:UIButtonTypeCustom];
    payButton.center = self.view.center;
    payButton.bounds = CGRectMake(0, 0, 200, 200);
    [payButton setImage:[UIImage imageNamed:@"wechatPay_icon@2x"] forState:UIControlStateNormal];
    [payButton addTarget:self action:@selector(payClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:payButton];
    
    // 判断 用户是否安装微信
    //如果判断结果一直为NO,可能appid无效,这里的是无效的
   if([WXApi isWXAppInstalled])
    
    {
        // 监听一个通知
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getOrderPayResult:) name:@"ORDER_PAY_NOTIFICATION" object:nil];
    }

}

-(void)payClick {
    [self easyPay];
}


/**
 *  @author LQQ, 16-02-29 17:02:47
 *
 *  http://wxpay.weixin.qq.com/pub_v2/app/app_pay.php为测试数据,一般可以从这儿拿到的数据都可以让服务器端去完成,客户端只需获取到然后配置到PayReq,即可吊起微信;
 */
-(void)easyPay {
    [HYBNetworking getWithUrl:@"http://wxpay.weixin.qq.com/pub_v2/app/app_pay.php" params:nil success:^(id response) {
        NSLog(@"%@",response);
        
        //配置调起微信支付所需要的参数
        
        PayReq *req  = [[PayReq alloc] init];
        
        req.partnerId = [response objectForKey:@"partnerid"];
        req.prepayId = [response objectForKey:@"prepayid"];
        req.package = [response objectForKey:@"package"];
        req.nonceStr = [response objectForKey:@"noncestr"];
        req.timeStamp = [[response objectForKey:@"timestamp"]intValue];
        req.sign = [response objectForKey:@"sign"];
        
        //调起微信支付
        if ([WXApi sendReq:req]) {
            NSLog(@"吊起成功");
        }

        
    } fail:^(NSError *error) {
        NSLog(@"%@",error);
    }];
}

#pragma mark - 收到支付成功的消息后作相应的处理
- (void)getOrderPayResult:(NSNotification *)notification
{
    if ([notification.object isEqualToString:@"success"]) {
        NSLog(@"支付成功");
    } else {
        NSLog(@"支付失败");
    }

}


#pragma mark -- ***************************************
//有的服务器没有对sign字段进行二次签名,需要客户端进行,下面这些是对吊起支付时的sign字段进行二次签名的,这些操作可以和服务器协商全让服务器做了,因为签名算法都是一样的,后台已经进行了第一次的签名,第二次只是多了prePayid,算法都是一样的没必要客户端再写一次算法

//注意:下面的方法不能直接使用,这里只是给出了算法和参数配置,相应的填充数据就行
//创建package签名
-(NSString*) createMd5Sign:(NSMutableDictionary*)dict
{
    NSMutableString *contentString  =[NSMutableString string];
    NSArray *keys = [dict allKeys];
    //按字母顺序排序
    NSArray *sortedArray = [keys sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        return [obj1 compare:obj2 options:NSNumericSearch];
    }];
    //拼接字符串
    for (NSString *categoryId in sortedArray) {
        if (   ![[dict objectForKey:categoryId] isEqualToString:@""]
            && ![categoryId isEqualToString:@"sign"]
            && ![categoryId isEqualToString:@"key"]
            )
        {
            [contentString appendFormat:@"%@=%@&", categoryId, [dict objectForKey:categoryId]];
        }
        
    }
    //添加key字段
    [contentString appendFormat:@"key=%@", self.spKey];
    //得到MD5 sign签名
    NSString *md5Sign =[contentString MD5];
    
    return md5Sign;
}

- (NSMutableDictionary*)payWithprePayid:(NSString*)prePayid

{
    if(prePayid == nil)
    {
        NSLog(@"prePayid 为空");
        return nil;
    }
    
    //获取到prepayid后进行第二次签名
    NSString    *package, *time_stamp, *nonce_str;
    //设置支付参数
    time_t now;
    time(&now);
    time_stamp  = [NSString stringWithFormat:@"%ld", now];
    nonce_str = [time_stamp MD5];
    //重新按提交格式组包，微信客户端暂只支持package=Sign=WXPay格式，须考虑升级后支持携带package具体参数的情况
    //package       = [NSString stringWithFormat:@"Sign=%@",package];
    package         = @"Sign=WXPay";
    //第二次签名参数列表
    NSMutableDictionary *signParams = [NSMutableDictionary dictionary];
    NSLog(@"%@",signParams);
    [signParams setObject: self.appId  forKey:@"appid"];
    [signParams setObject: self.mchId  forKey:@"partnerid"];
    [signParams setObject: nonce_str    forKey:@"noncestr"];
    [signParams setObject: package      forKey:@"package"];
    [signParams setObject: time_stamp   forKey:@"timestamp"];
    [signParams setObject: prePayid     forKey:@"prepayid"];
    
    //生成签名
    // NSString *sign  = @"7175C293D3F706F4B40EAD092A3FBAB8";
    NSString *sign  = [self createMd5Sign:signParams];
    
    //添加签名
    [signParams setObject: sign         forKey:@"sign"];
    
    
    //返回参数列表
    return signParams;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
