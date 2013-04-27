//
//  SCNavigationViewController.m
//  是男人就点一百下
//
//  Created by wupeng on 12-11-13.
//
//

#import "SCNavigationViewController.h"

@interface SCNavigationViewController ()

@end

@implementation SCNavigationViewController

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
    [self addAdMobBanner];
    
    // Do any additional setup after loading the view from its nib.
}
-(void)addAdMobBanner{
    
    gAdBannerView= [[GADBannerView alloc]
                    initWithFrame:CGRectMake(0.0,
                                             self.view.frame.size.height -
                                             GAD_SIZE_320x50.height,
                                             GAD_SIZE_320x50.width,
                                             GAD_SIZE_320x50.height)];
    
    gAdBannerView.adUnitID = @"a150a1f7cfbfdae";
    
    // 告知运行时文件，在将用户转至广告的展示位置之后恢复哪个 UIViewController
    // 并将其添加至视图层级结构。
    gAdBannerView.rootViewController = self;
    [self.view addSubview:gAdBannerView];
    
    // 启动一般性请求并在其中加载广告。
    [gAdBannerView loadRequest:[GADRequest request]];
}


-(void)viewWillAppear:(BOOL)animated{
    [self.view bringSubviewToFront:gAdBannerView];
    [super viewWillAppear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(BOOL) shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation{
    return toInterfaceOrientation == UIInterfaceOrientationPortrait;
}

@end
