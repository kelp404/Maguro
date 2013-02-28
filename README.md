#Maguro

Kelp http://kelp.phate.org/  
[MIT License][mit]
[MIT]: http://www.opensource.org/licenses/mit-license.php


  Contact Us View  |  Search Knowledge Base  |  Knowledge Base
:---------:|:---------:|:---------:
<img src='https://raw.github.com/Kelp404/Maguro/master/_images/01.png' height='500px' width='257px' /> | <img src='https://raw.github.com/Kelp404/Maguro/master/_images/02.png' height='500px' width='257px' /> | <img src='https://raw.github.com/Kelp404/Maguro/master/_images/03.png' height='500px' width='257px' />




##Show Contact Us View
```objective-c
MaguroConfig *config = [MaguroConfig configWithSite:@"demo.uservoice.com"
                                             andKey:@"pZJocTBPbg5FN4bAwczDLQ"
                                          andSecret:@"Q7UKcxRYLlSJN4CxegUYI6t0uprdsSAGthRIDvYmI"];

config.subject = @"This ticket was submitted from iOS.";
config.name = @"User Name";
config.email = @"name@gmail.com";
//    config.navigationTintColor = [UIColor colorWithRed:0.216f green:0.369f blue:0.776f alpha:1];
//    config.backgroundColor = [UIColor whiteColor];

[Maguro showContactUsForParentViewController:self withConfig:config andCloseHandler:^{
    NSLog(@"Closed");
}];
```



##Reference
http://www.uservoice.com/ios/  
https://github.com/uservoice/uservoice-iphone-example  
https://github.com/uservoice/uservoice-iphone-sdk  
http://developer.uservoice.com/docs/api/reference/
