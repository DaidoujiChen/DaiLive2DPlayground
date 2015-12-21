# Get a girl friend in programming

![image](https://s3-ap-northeast-1.amazonaws.com/daidoujiminecraft/Daidouji/DaiLive2DPlayground.gif)

雖然專案條是粉紅色的, 但卻是一個貨真價實 iOS 的專案, 在介接上, 用 `Swift` 去接 `C` 的 code 比較麻煩, 
所以還是選擇 `Objective-C` 當作起手, `Get a girl friend in programming` 這個 Slogan 來自於 [paiza](https://paiza.jp/poh/ando), 
一個靠著做 Programming 解鎖美少女配件的網站,  很喜歡這個 slogan, 所以借過來當作這個專案的副標, 
至於 [Live2D](http://www.live2d.com/), 是一個可以讓繪師將圖片輸出成程式可以控制的元件, 讓程式設計師可以做出各種想像中的應用, 
不會畫畫的人, 可以從官方下載 [sample data](http://sites.cybernoids.jp/cubism_e/samples) 來玩, 或是我後面會慢慢把檔案輸出補齊,
這是一個 for fun, 發揮想像力的專案, 希望大家可以做出心目中的女孩, O3Ob.

# 開發環境

 - Xcode 7.2
 - iOS 9.0 以上

# 建置屬於你自己的專案

建置的過程中有許多小地方需要注意, 為了避免自己忘記, 把這一份文件寫下來, 方便下次建置時不會再花時間, 也分享給想要嘗試 `Live2D` 的大家.

## Live2D Cubism SDK 下載
先到官方的網站下載最新版本的 iOS SDK, 這份文件用的版本是 `2.0.06_1`, 在這邊下載 [Live2D Cubism SDK](http://sites.cybernoids.jp/cubism-sdk2/ios/ios_dl)

下載完之後, 解壓縮開來應該可以看見像是這樣的結構, 

![image](https://s3-ap-northeast-1.amazonaws.com/daidoujiminecraft/Daidouji/%E8%9E%A2%E5%B9%95%E5%BF%AB%E7%85%A7+2015-12-21+%E4%B8%8B%E5%8D%882.12.19.png)

我們主要會需要 `lib`, `framework`, `include` 這三個部分, sample 的話可以打開來看看, 有些可以動, 有些不行, O3O.

## 開啟一個新專案
選擇一個普通的 `Single View Application` 當作起手, 

![image](https://s3-ap-northeast-1.amazonaws.com/daidoujiminecraft/Daidouji/%E8%9E%A2%E5%B9%95%E5%BF%AB%E7%85%A7+2015-12-21+%E4%B8%8B%E5%8D%882.18.03.png)

專案名稱任意, 這邊我們先一致叫他 `MyFirstLive2DProject`

![image](https://s3-ap-northeast-1.amazonaws.com/daidoujiminecraft/Daidouji/%E8%9E%A2%E5%B9%95%E5%BF%AB%E7%85%A7+2015-12-21+%E4%B8%8B%E5%8D%882.20.32.png)

## SDK 檔案設置
開啟 `Finder`, 我們移動到 `MyFirstLive2DProject` 這個專案下, 然後建立一個資料夾, 叫做 `Live2DSDK`

![image](https://s3-ap-northeast-1.amazonaws.com/daidoujiminecraft/Daidouji/%E8%9E%A2%E5%B9%95%E5%BF%AB%E7%85%A7+2015-12-21+%E4%B8%8B%E5%8D%882.26.08.png)

之後, 我們把剛剛解壓縮出來提到的三個項目(`lib`, `framework`, `include`), 完完全全的複製過來

![image](https://s3-ap-northeast-1.amazonaws.com/daidoujiminecraft/Daidouji/%E8%9E%A2%E5%B9%95%E5%BF%AB%E7%85%A7+2015-12-21+%E4%B8%8B%E5%8D%882.28.28.png)

然後先回到 Xcode 內, 為這些檔案做些設置.

## Xcode 設置
回到專案內, 我們開啟 `Build Setting` 分頁, 要設置幾個項目,

 1. `Other Linker Flags`, 設 `-lLive2D`, 前面的 `l` 不是多打的, 就是有個 `l` 在那

 ![image](https://s3-ap-northeast-1.amazonaws.com/daidoujiminecraft/Daidouji/%E8%9E%A2%E5%B9%95%E5%BF%AB%E7%85%A7+2015-12-21+%E4%B8%8B%E5%8D%882.34.07.png)

 2. `Library Search Paths`, Debug 的部分設 `"$(SRCROOT)/MyFirstLive2DProject/Live2DSDK/lib/$(CONFIGURATION)-$(PLATFORM_NAME)"`, Release 的部分設 `"$(SRCROOT)/MyFirstLive2DProject/Live2DSDK/lib/$(CONFIGURATION)-$(PLATFORM_NAME)"`

 ![image](https://s3-ap-northeast-1.amazonaws.com/daidoujiminecraft/Daidouji/%E8%9E%A2%E5%B9%95%E5%BF%AB%E7%85%A7+2015-12-21+%E4%B8%8B%E5%8D%882.41.10.png)
 
 3. `User Header Search Paths`, 設置 `"$(SRCROOT)/MyFirstLive2DProject/Live2DSDK/include"`, Debug / Release 都是

 ![image](https://s3-ap-northeast-1.amazonaws.com/daidoujiminecraft/Daidouji/%E8%9E%A2%E5%B9%95%E5%BF%AB%E7%85%A7+2015-12-21+%E4%B8%8B%E5%8D%882.48.38.png)
 
 4. `Preprocessor Macros`, 在 Debug 與 Releease 中, 都多加入一個值 `L2D_TARGET_IPHONE`

 ![image](https://s3-ap-northeast-1.amazonaws.com/daidoujiminecraft/Daidouji/%E8%9E%A2%E5%B9%95%E5%BF%AB%E7%85%A7+2015-12-21+%E4%B8%8B%E5%8D%882.53.26.png)
 
 5. Framework 加入 `GLKit`, `OpenGLES`

 ![image](https://s3-ap-northeast-1.amazonaws.com/daidoujiminecraft/Daidouji/%E8%9E%A2%E5%B9%95%E5%BF%AB%E7%85%A7+2015-12-21+%E4%B8%8B%E5%8D%882.43.49.png)
 
都設定好之後, 往下一個部分邁進.

## 加入 Model 及加速開發套件
由於在下手殘, 美術技能不足, 因此, 所有的 model 是從官方網站 [Live2D Sample Data](http://sites.cybernoids.jp/cubism_e/samples)抓下來的, 大家可以上去挑選一個喜歡的下來, 這邊我們用一個雙馬尾女僕 Haru 醬當作範例, 

 1. 先將這個 git 專案 `Download Zip` 一份下來到你的硬碟裡面, 按鈕在截圖的右下角
 
 ![image](https://s3-ap-northeast-1.amazonaws.com/daidoujiminecraft/Daidouji/%E8%9E%A2%E5%B9%95%E5%BF%AB%E7%85%A7+2015-12-21+%E4%B8%8B%E5%8D%883.21.58.png)
 
 2. 解壓縮開來之後, 我們先找到 `DaiLive2DViewController`, `HaruViewController`, `Live2DResource` 這三個資料夾

 ![image](https://s3-ap-northeast-1.amazonaws.com/daidoujiminecraft/Daidouji/%E8%9E%A2%E5%B9%95%E5%BF%AB%E7%85%A7+2015-12-21+%E4%B8%8B%E5%8D%883.35.43.png)
 
 `DaiLive2DViewController`, `HaruViewController` 是我自己寫的, 在包裝上, 會減少看到 c++ 的 code, 控制上, 也會較為的簡易, 有興趣的話可以詳細的去看下面是怎麼跟 `Live2DSDK` 作動, 這邊就不累述了.
 
 3. 把他們複製到 `MyFirstLive2DProject`

 ![image](https://s3-ap-northeast-1.amazonaws.com/daidoujiminecraft/Daidouji/%E8%9E%A2%E5%B9%95%E5%BF%AB%E7%85%A7+2015-12-21+%E4%B8%8B%E5%8D%883.37.58.png)
 
 4. 在 Xcode 裡面先加入 `DaiLive2DViewController`, `HaruViewController` 這兩個項目, 記得選取 `Create groups`

 ![image](https://s3-ap-northeast-1.amazonaws.com/daidoujiminecraft/Daidouji/%E8%9E%A2%E5%B9%95%E5%BF%AB%E7%85%A7+2015-12-21+%E4%B8%8B%E5%8D%883.32.26.png)
 
 5. 再加入 `Live2DResource`, 這個要選 `Create folder references`, 跟上面的是不一樣的喔, 切記!!

 ![image](https://s3-ap-northeast-1.amazonaws.com/daidoujiminecraft/Daidouji/%E8%9E%A2%E5%B9%95%E5%BF%AB%E7%85%A7+2015-12-21+%E4%B8%8B%E5%8D%883.40.15.png)
 
 最後完成的時候, 目錄結構會像是這樣, 
 
 ![image](https://s3-ap-northeast-1.amazonaws.com/daidoujiminecraft/Daidouji/%E8%9E%A2%E5%B9%95%E5%BF%AB%E7%85%A7+2015-12-21+%E4%B8%8B%E5%8D%883.42.04.png)
 
 有兩個 Framework, 一個藍色的 `Live2DResource`, 兩個黃色的 `DaiLive2DViewController`, `HaruViewController`, 然後我們終於要開始寫 code 啦, >3<
 
## 最後步驟
到目前的情況, 我們 build 按下去, 應該是不會出現任何的錯誤訊息, 如果有錯誤的話, 麻煩檢查一下上面的所有步驟是不是都有完整的設置.

由於 `Live2D` 是 c++ 的 code, 所以我們在 `AppDelegate.m` 裡面 init 他的時候, 需要把 `AppDelegate.m` 改為 `AppDelegate.mm`, 然後在這裡面的 code 會像是

`````objc
#import "AppDelegate.h"
#import "Live2D.h"

using namespace live2d;

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    Live2D::init();
    return YES;
}

@end
`````

在 `ViewController.m` 裡面的 code 會是

`````objc
#import "ViewController.h"
#import "HaruViewController.h"

@interface ViewController ()

@property (nonatomic, strong) DaiLive2DViewController *live2DViewController;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.live2DViewController = [HaruViewController new];
    self.live2DViewController.view.frame = self.view.bounds;
    [self.view addSubview:self.live2DViewController.view];
}

@end
`````

然後請把 `HaruViewController.m` 中, 有一行

`````objc
self = [super initFromBundlePath:@"/Haru/model.plist"];
`````

改為

`````objc
self = [super initFromBundlePath:@"/Live2DResource/Haru/model.plist"];
`````

主要是因為檔案路徑跟我原先的專案有些不同而已.

如果看見 Haru 醬出現在畫面裡面, 恭喜你就已經成功了!!

![image](https://s3-ap-northeast-1.amazonaws.com/daidoujiminecraft/Daidouji/%E8%9E%A2%E5%B9%95%E5%BF%AB%E7%85%A7+2015-12-21+%E4%B8%8B%E5%8D%883.58.53.png)
