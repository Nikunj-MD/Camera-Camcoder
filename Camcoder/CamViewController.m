//
//  CamViewController.m
//  Camcoder
//
//  Created by Nikunj Modi on 19/12/12.
//  Copyright (c) 2012 Nikunj Modi. All rights reserved.
//

#import "CamViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "TVCalibratedSlider.h"
#import "UIView+Glow.h"
#import "TVCalibratedSliderForInteger.h"
#import "ALAssetsLibrary+CustomPhotoAlbum.h"
#import <MediaPlayer/MediaPlayer.h>
#import "NonRotatingUIImagePickerControllerViewController.h"
#import "HZActivityIndicatorView.h"
#import "HZActivityIndicatorSubclassExample.h"
#import <MobileCoreServices/MobileCoreServices.h>

#define VERTICAL_OFFSET 10.0
#define HORIZONTAL_OFFSET 10.0
#define VERTICAL_SPACING 5.0
#define VERTICAL_HEIGHT 50.0

@interface CamViewController ()<TVCalibratedSliderDelegate,TVCalibratedSliderIntegerDelegate>
{
    TVCalibratedSlider *_cvSlider;
    TVCalibratedSliderForInteger *_cvSliderInteger;
}
@property (retain, nonatomic) IBOutlet UIView *containerView;
@end

@implementation CamViewController
{
    BOOL isStatic;
    BOOL hasBlur;
    int selectedFilter;
}
BOOL CameraMode;
int FilterFlag,LastCameramode;
@synthesize delegate,imageView,cameraToggleButton,
flashToggleButton,topBar,outputJPEGQuality,
filtersBackgroundImageView,containerView,
stopWatchLabel,stopWatchImageView,FilterTable,
ActivityMainView,ActivityInnerView,customIndicator,Act,AboutusView,Homebutton,txtvCopyright;

#pragma mark - View lifecycle

-(id) init {
    self = [super initWithNibName:@"CamViewController" bundle:nil];
    
    if (self) {
        self.outputJPEGQuality = 1.0;
    }
    
    return self;
}

- (void)viewDidLoad
{
    [self.imageView setFillMode:kGPUImageFillModePreserveAspectRatioAndFill];
    BOOL _flag = [self CheckIphone5];
    CameraMode = YES;
    FilterFlag = 0;
    LastCameramode = 0;
    PreviousFilterOption = 9999;
    if (_flag)
    {
        [Defult setImage:[UIImage imageNamed:@"Default-568h@2x.png"]];
        [aboutus setImage:[UIImage imageNamed:@"Aubotus-568h@2x.png"]];
        ActivityMainView.frame = CGRectMake(0,0,320,560);
        AboutusView.frame = CGRectMake(0,0,320,568);
        Homebutton.frame = CGRectMake(275,510,50,36);
        txtvCopyright.frame = CGRectMake(24,29,275,254);
        Copyright.frame = CGRectMake(24,14,275,275);
    }
    else
    {
        txtvCopyright.frame = CGRectMake(22,20,275,254);
        Copyright.frame = CGRectMake(21,11,275,275);
    }
    imagePicker =
    [[NonRotatingUIImagePickerControllerViewController alloc] init];
    imagePicker.delegate = self;
    
    [UIView beginAnimations:@"glow" context:nil];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
    [UIView setAnimationDuration:1.5f];
    for(int i=0;i<5;i++) {
        //[Defult setAlpha:0.0f];
    }
    [UIView commitAnimations];
    
    if (!_cvSlider) {
        _cvSlider = [[TVCalibratedSlider alloc] initWithFrame:CGRectMake(35,10,65,30) withStyle:TavicsaStyle];
    }
    
    [_cvSlider setThumbImage:nil forState:UIControlStateHighlighted];
    TVCalibratedSliderRange range2;
    range2.maximumValue = 1;
    range2.minimumValue = 0;
    [_cvSlider setRange:range2];
    [containerView addSubview:_cvSlider];
    [_cvSlider setTextColorForHighlightedState:[UIColor redColor]];
    [_cvSlider setMarkerImageOffsetFromSlider:5];
    [_cvSlider setMarkerValueOffsetFromSlider:10];
    [_cvSlider setDelegate:self] ;
    
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    self.wantsFullScreenLayout = YES;
    //set background color
    
    NSLog(@"%f,%f",self.imageView.frame.size.width,self.imageView.frame.size.height);
    
    staticPictureOriginalOrientation = UIImageOrientationUp;
    if (!filter) {
        
        filter = [[GPUImageFilter alloc] init];
    }
    
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        [self setUpCamera];
    });
    
    [self ADDActivityIndicatorview];
    [self AddLableinAboutus];
    videoCamera = [[GPUImageVideoCamera alloc] initWithSessionPreset:AVCaptureSessionPreset640x480 cameraPosition:AVCaptureDevicePositionBack];
    
   }

-(void) viewWillAppear:(BOOL)animated
{
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationSlide];
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    //[_cvSlider release];
    [super viewWillDisappear:animated];
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:NO];
}

-(void) dealloc {
    [self removeAllTargets];
    stillCamera = nil;
    filter = nil;
    staticPicture = nil;
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    NSLog(@"Memory Full");
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(BOOL)shouldAutorotate
{
    return NO;
}

- (NSUInteger)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskAll;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    return UIInterfaceOrientationPortrait;
}

#pragma mark - GPUImage Camera Setup and capture image Method
/*!
 @method      setUpCamera
 @abstract    It is a Method to set up our application camera functionality.
 @discussion  setUpCamera set GpuImage camera option and check camrea option.
 @result      setUpCamera set GpuImage camera option and check camrea option.
 */
-(void) setUpCamera {
    
    if ([UIImagePickerController isSourceTypeAvailable: UIImagePickerControllerSourceTypeCamera]) {
        
        //stillCamera = [[GPUImageStillCamera alloc] init];
        if (!stillCamera) {
            stillCamera = [[GPUImageStillCamera alloc] initWithSessionPreset:AVCaptureSessionPresetPhoto cameraPosition:AVCaptureDevicePositionBack];
        }
        
        
        stillCamera.outputImageOrientation = UIInterfaceOrientationPortrait;
        runOnMainQueueWithoutDeadlocking(^{
            [stillCamera startCameraCapture];
            if([stillCamera.inputCamera hasTorch]){
                [self.flashToggleButton setEnabled:YES];
            }else{
                [self.flashToggleButton setEnabled:NO];
            }
            [self prepareFilter];
        });
    } else {
        // No camera
        //NSLog(@"No camera");
        runOnMainQueueWithoutDeadlocking(^{
            [self prepareFilter];
        });
    }
    
}
/*!
 @method      setupFilter
 @abstract    It is a Method to set up our application filter option.
 @discussion  setupFilter set GpuImage filter according user tab on filter option and set in live camera.
 @result      setupFilter set GpuImage filter according user tab on filter option and set in live camera.
 */
- (void)setupFilter
{
    switch (filterType)
    {
        case GPUIMAGE_SHARPEN:
        {
            self.title = @"Sharpen";
            UITableViewCell *cell = (UITableViewCell *)[FilterTable viewWithTag:GPUIMAGE_SHARPEN];
            TVCalibratedSliderForInteger *_TempSlider = (TVCalibratedSliderForInteger *)[cell viewWithTag:GPUIMAGE_SHARPEN+2000];
            TVCalibratedSliderRangeInteger range;
            range.maximumValue = 4.0;
            range.minimumValue = -1.0;
            [_TempSlider setValue:0.0];
            [_TempSlider setRange:range];
            
            filter = [[GPUImageSharpenFilter alloc] init];
            
        }; break;
        case GPUIMAGE_SEPIA:
        {
            UITableViewCell *cell = (UITableViewCell *)[FilterTable viewWithTag:GPUIMAGE_SEPIA];
            TVCalibratedSliderForInteger *_TempSlider = (TVCalibratedSliderForInteger *)[cell viewWithTag:GPUIMAGE_SEPIA+2000];
            TVCalibratedSliderRangeInteger range;
            range.maximumValue = 1.0;
            range.minimumValue = 0.0;
            [_TempSlider setValue:1.0];
            [_TempSlider setRange:range];
            filter = [[GPUImageSepiaFilter alloc] init];
            
        }; break;
        case GPUIMAGE_PIXELLATE:
        {
            UITableViewCell *cell = (UITableViewCell *)[FilterTable viewWithTag:GPUIMAGE_PIXELLATE];
            TVCalibratedSliderForInteger *_TempSlider = (TVCalibratedSliderForInteger *)[cell viewWithTag:GPUIMAGE_PIXELLATE+2000];
            TVCalibratedSliderRangeInteger range;
            range.maximumValue = 0.3;
            range.minimumValue = 0.0;
            [_TempSlider setValue:0.05];
            [_TempSlider setRange:range];
            
            filter = [[GPUImagePixellateFilter alloc] init];
        }; break;
        case GPUIMAGE_SATURATION:
        {
            UITableViewCell *cell = (UITableViewCell *)[FilterTable viewWithTag:GPUIMAGE_SATURATION];
            TVCalibratedSliderForInteger *_TempSlider = (TVCalibratedSliderForInteger *)[cell viewWithTag:GPUIMAGE_SATURATION+2000];
            TVCalibratedSliderRangeInteger range;
            range.maximumValue = 2.0;
            range.minimumValue = 0.0;
            [_TempSlider setValue:1.0];
            [_TempSlider setRange:range];
            filter = [[GPUImageSaturationFilter alloc] init];
        }; break;
        case GPUIMAGE_CONTRAST:
        {
            UITableViewCell *cell = (UITableViewCell *)[FilterTable viewWithTag:GPUIMAGE_SHARPEN];
            TVCalibratedSliderForInteger *_TempSlider = (TVCalibratedSliderForInteger *)[cell viewWithTag:GPUIMAGE_CONTRAST+2000];
            TVCalibratedSliderRangeInteger range;
            range.maximumValue = 4.0;
            range.minimumValue = 0.0;
            [_TempSlider setValue:1.0];
            [_TempSlider setRange:range];
            filter = [[GPUImageContrastFilter alloc] init];
        }; break;
        case GPUIMAGE_BRIGHTNESS:
        {
            self.title = @"Brightness";
            UITableViewCell *cell = (UITableViewCell *)[FilterTable viewWithTag:GPUIMAGE_SHARPEN];
            TVCalibratedSliderForInteger *_TempSlider = (TVCalibratedSliderForInteger *)[cell viewWithTag:GPUIMAGE_BRIGHTNESS+2000];
            TVCalibratedSliderRangeInteger range;
            range.maximumValue = 1.0;
            range.minimumValue = -1.0;
            [_TempSlider setValue:0.0];
            [_TempSlider setRange:range];
            filter = [[GPUImageBrightnessFilter alloc] init];
        }; break;
        case GPUIMAGE_RGB:
        {
            self.title = @"RGB";
            UITableViewCell *cell = (UITableViewCell *)[FilterTable viewWithTag:GPUIMAGE_RGB];
            TVCalibratedSliderForInteger *_TempSlider = (TVCalibratedSliderForInteger *)[cell viewWithTag:GPUIMAGE_RGB+2000];
            TVCalibratedSliderRangeInteger range;
            range.maximumValue = 2.0;
            range.minimumValue = 0.0;
            [_TempSlider setValue:1.0];
            [_TempSlider setRange:range];
            filter = [[GPUImageRGBFilter alloc] init];
        }; break;
        case GPUIMAGE_HUE:
        {
            UITableViewCell *cell = (UITableViewCell *)[FilterTable viewWithTag:GPUIMAGE_HUE];
            TVCalibratedSliderForInteger *_TempSlider = (TVCalibratedSliderForInteger *)[cell viewWithTag:GPUIMAGE_HUE+2000];
            TVCalibratedSliderRangeInteger range;
            range.maximumValue = 360.0;
            range.minimumValue = 0.0;
            [_TempSlider setValue:90.0];
            [_TempSlider setRange:range];
            filter = [[GPUImageHueFilter alloc] init];
        }; break;
        case GPUIMAGE_SKETCH:
        {
            filter = [[GPUImageSketchFilter alloc] init];
            if (!CameraMode) {
                [videoCamera addTarget:filter];
            }
        }; break;
        case GPUIMAGE_THRESHOLDSKETCH:
        {
            UITableViewCell *cell = (UITableViewCell *)[FilterTable viewWithTag:GPUIMAGE_THRESHOLDSKETCH];
            TVCalibratedSliderForInteger *_TempSlider = (TVCalibratedSliderForInteger *)[cell viewWithTag:GPUIMAGE_THRESHOLDSKETCH+2000];
            TVCalibratedSliderRangeInteger range;
            range.maximumValue = 1.0;
            range.minimumValue = 0.9;
            [_TempSlider setValue:0.9];
            [_TempSlider setRange:range];
    
            filter = [[GPUImageThresholdSketchFilter alloc] init];
        }; break;
        case GPUIMAGE_EMBOSS:
        {
            UITableViewCell *cell = (UITableViewCell *)[FilterTable viewWithTag:GPUIMAGE_EMBOSS];
            TVCalibratedSliderForInteger *_TempSlider = (TVCalibratedSliderForInteger *)[cell viewWithTag:GPUIMAGE_EMBOSS+2000];
            TVCalibratedSliderRangeInteger range;
            range.maximumValue = 5.0;
            range.minimumValue = 0.0;
            [_TempSlider setValue:1.0];
            [_TempSlider setRange:range];
            filter = [[GPUImageEmbossFilter alloc] init];
        }; break;
        case GPUIMAGE_POSTERIZE:
        {
            self.title = @"Posterize";
            UITableViewCell *cell = (UITableViewCell *)[FilterTable viewWithTag:GPUIMAGE_POSTERIZE];
            TVCalibratedSliderForInteger *_TempSlider = (TVCalibratedSliderForInteger *)[cell viewWithTag:GPUIMAGE_POSTERIZE+2000];
            TVCalibratedSliderRangeInteger range;
            range.maximumValue = 20.0;
            range.minimumValue = 1.0;
            [_TempSlider setValue:10.0];
            [_TempSlider setRange:range];
            filter = [[GPUImagePosterizeFilter alloc] init];
        }; break;
        case GPUIMAGE_SWIRL:
        {
            self.title = @"Swirl";
            UITableViewCell *cell = (UITableViewCell *)[FilterTable viewWithTag:GPUIMAGE_SWIRL];
            TVCalibratedSliderForInteger *_TempSlider = (TVCalibratedSliderForInteger *)[cell viewWithTag:GPUIMAGE_SWIRL+2000];
            TVCalibratedSliderRangeInteger range;
            range.maximumValue = 2.0;
            range.minimumValue = 0.0;
            [_TempSlider setValue:1.0];
            [_TempSlider setRange:range];
            
            filter = [[GPUImageSwirlFilter alloc] init];
        }; break;
        case GPUIMAGE_TOON:
        {
            filter = [[GPUImageToonFilter alloc] init];
        }; break;
        case GPUIMAGE_SMOOTHTOON:
        {
            self.title = @"Smooth Toon";
            UITableViewCell *cell = (UITableViewCell *)[FilterTable viewWithTag:GPUIMAGE_SMOOTHTOON];
            TVCalibratedSliderForInteger *_TempSlider = (TVCalibratedSliderForInteger *)[cell viewWithTag:GPUIMAGE_SMOOTHTOON+2000];
            TVCalibratedSliderRangeInteger range;
            range.maximumValue = 1.0;
            range.minimumValue = 0.0;
            [_TempSlider setValue:0.5];
            [_TempSlider setRange:range];
            
            filter = [[GPUImageSmoothToonFilter alloc] init];
        }; break;
        case GPUIMAGE_EXPOSURE:
        {
            self.title = @"Exposure";
            UITableViewCell *cell = (UITableViewCell *)[FilterTable viewWithTag:GPUIMAGE_EXPOSURE];
            TVCalibratedSliderForInteger *_TempSlider = (TVCalibratedSliderForInteger *)[cell viewWithTag:GPUIMAGE_EXPOSURE+2000];
            TVCalibratedSliderRangeInteger range;
            range.maximumValue = 4.0;
            range.minimumValue = -4.0;
            [_TempSlider setValue:0.0];
            [_TempSlider setRange:range];
            
            filter = [[GPUImageExposureFilter alloc] init];
        }; break;
        case GPUIMAGE_WHITEBALANCE:
        {
            UITableViewCell *cell = (UITableViewCell *)[FilterTable viewWithTag:GPUIMAGE_WHITEBALANCE];
            TVCalibratedSliderForInteger *_TempSlider = (TVCalibratedSliderForInteger *)[cell viewWithTag:GPUIMAGE_WHITEBALANCE+2000];
            TVCalibratedSliderRangeInteger range;
            range.maximumValue = 7500.0;
            range.minimumValue = 2500.0;
            [_TempSlider setValue:5000.0];
            [_TempSlider setRange:range];
            
            filter = [[GPUImageWhiteBalanceFilter alloc] init];
        }; break;
        case GPUIMAGE_MONOCHROME:
        {
            UITableViewCell *cell = (UITableViewCell *)[FilterTable viewWithTag:GPUIMAGE_MONOCHROME];
            TVCalibratedSliderForInteger *_TempSlider = (TVCalibratedSliderForInteger *)[cell viewWithTag:GPUIMAGE_MONOCHROME+2000];
            TVCalibratedSliderRangeInteger range;
            range.maximumValue = 0.0;
            range.minimumValue = 1.0;
            [_TempSlider setValue:1.0];
            [_TempSlider setRange:range];
            
            filter = [[GPUImageMonochromeFilter alloc] init];
            [(GPUImageMonochromeFilter *)filter setColor:(GPUVector4){0.0f, 0.0f, 1.0f, 1.f}];
        }; break;
        case GPUIMAGE_FALSECOLOR:
        {
            filter = [[GPUImageFalseColorFilter alloc] init];
		}; break;
        case GPUIMAGE_COLORINVERT:
        {
            filter = [[GPUImageColorInvertFilter alloc] init];
        }; break;
        case GPUIMAGE_GRAYSCALE:
        {
            filter = [[GPUImageGrayscaleFilter alloc] init];
        }; break;
        case GPUIMAGE_TONECURVE:
        {
            UITableViewCell *cell = (UITableViewCell *)[FilterTable viewWithTag:GPUIMAGE_TONECURVE];
            TVCalibratedSliderForInteger *_TempSlider = (TVCalibratedSliderForInteger *)[cell viewWithTag:GPUIMAGE_TONECURVE+2000];
            TVCalibratedSliderRangeInteger range;
            range.maximumValue = 0.0;
            range.minimumValue = 1.0;
            [_TempSlider setValue:0.5];
            [_TempSlider setRange:range];
            
            filter = [[GPUImageToneCurveFilter alloc] init];
            [(GPUImageToneCurveFilter *)filter setBlueControlPoints:[NSArray arrayWithObjects:[NSValue valueWithCGPoint:CGPointMake(0.0, 0.0)], [NSValue valueWithCGPoint:CGPointMake(0.5, 0.5)], [NSValue valueWithCGPoint:CGPointMake(1.0, 0.75)], nil]];
        }; break;
        case GPUIMAGE_POLARPIXELLATE:
        {
            UITableViewCell *cell = (UITableViewCell *)[FilterTable viewWithTag:GPUIMAGE_POLARPIXELLATE];
            TVCalibratedSliderForInteger *_TempSlider = (TVCalibratedSliderForInteger *)[cell viewWithTag:GPUIMAGE_POLARPIXELLATE+2000];
            TVCalibratedSliderRangeInteger range;
            range.maximumValue = 0.1;
            range.minimumValue = -0.1;
            [_TempSlider setValue:0.05];
            [_TempSlider setRange:range];
            
            filter = [[GPUImagePolarPixellateFilter alloc] init];
        }; break;
        case GPUIMAGE_POLKADOT:
        {            
            UITableViewCell *cell = (UITableViewCell *)[FilterTable viewWithTag:GPUIMAGE_POLKADOT];
            TVCalibratedSliderForInteger *_TempSlider = (TVCalibratedSliderForInteger *)[cell viewWithTag:GPUIMAGE_POLKADOT+2000];
            TVCalibratedSliderRangeInteger range;
            range.maximumValue = 0.3;
            range.minimumValue = 0.0;
            [_TempSlider setValue:0.05];
            [_TempSlider setRange:range];
            
            filter = [[GPUImagePolkaDotFilter alloc] init];
        }; break;
        case GPUIMAGE_HALFTONE:
        {
            UITableViewCell *cell = (UITableViewCell *)[FilterTable viewWithTag:GPUIMAGE_HALFTONE];
            TVCalibratedSliderForInteger *_TempSlider = (TVCalibratedSliderForInteger *)[cell viewWithTag:GPUIMAGE_HALFTONE+2000];
            TVCalibratedSliderRangeInteger range;
            range.maximumValue = 0.05;
            range.minimumValue = 0.0;
            [_TempSlider setValue:0.01];
            [_TempSlider setRange:range];
            
            filter = [[GPUImageHalftoneFilter alloc] init];
        }; break;
        case GPUIMAGE_CROSSHATCH:
        {
            UITableViewCell *cell = (UITableViewCell *)[FilterTable viewWithTag:GPUIMAGE_CROSSHATCH];
            TVCalibratedSliderForInteger *_TempSlider = (TVCalibratedSliderForInteger *)[cell viewWithTag:GPUIMAGE_CROSSHATCH+2000];
            TVCalibratedSliderRangeInteger range;
            range.maximumValue = 0.06;
            range.minimumValue = 0.02;
            [_TempSlider setValue:0.03];
            [_TempSlider setRange:range];
            
            filter = [[GPUImageCrosshatchFilter alloc] init];
        }; break;
        case GPUIMAGE_TILTSHIFT:
        {
            UITableViewCell *cell = (UITableViewCell *)[FilterTable viewWithTag:GPUIMAGE_TILTSHIFT];
            TVCalibratedSliderForInteger *_TempSlider = (TVCalibratedSliderForInteger *)[cell viewWithTag:GPUIMAGE_TILTSHIFT+2000];
            TVCalibratedSliderRangeInteger range;
            range.maximumValue = 0.8;
            range.minimumValue = 0.02;
            [_TempSlider setValue:0.5];
            [_TempSlider setRange:range];
            
            filter = [[GPUImageTiltShiftFilter alloc] init];
            [(GPUImageTiltShiftFilter *)filter setTopFocusLevel:0.4];
            [(GPUImageTiltShiftFilter *)filter setBottomFocusLevel:0.6];
            [(GPUImageTiltShiftFilter *)filter setFocusFallOffRate:0.2];
            
        }; break;
        case GPUIMAGE_VIGNETTE:
        {
            UITableViewCell *cell = (UITableViewCell *)[FilterTable viewWithTag:GPUIMAGE_VIGNETTE];
            TVCalibratedSliderForInteger *_TempSlider = (TVCalibratedSliderForInteger *)[cell viewWithTag:GPUIMAGE_VIGNETTE+2000];
            TVCalibratedSliderRangeInteger range;
            range.maximumValue = 0.9;
            range.minimumValue = 0.5;
            [_TempSlider setValue:0.75];
            [_TempSlider setRange:range];
            
            filter = [[GPUImageVignetteFilter alloc] init];
        }; break;
        case GPUIMAGE_GAUSSIAN_SELECTIVE:
        {
            UITableViewCell *cell = (UITableViewCell *)[FilterTable viewWithTag:GPUIMAGE_GAUSSIAN_SELECTIVE];
            TVCalibratedSliderForInteger *_TempSlider = (TVCalibratedSliderForInteger *)[cell viewWithTag:GPUIMAGE_GAUSSIAN_SELECTIVE+2000];
            TVCalibratedSliderRangeInteger range;
            range.maximumValue = 0.0;
            range.minimumValue = 0.75f;
            [_TempSlider setValue:40.0/320.0];
            [_TempSlider setRange:range];
            
            filter = [[GPUImageGaussianSelectiveBlurFilter alloc] init];
            [(GPUImageGaussianSelectiveBlurFilter*)filter setExcludeCircleRadius:40.0/320.0];
        }; break;
        case GPUIMAGE_BULGE:
        {
            UITableViewCell *cell = (UITableViewCell *)[FilterTable viewWithTag:GPUIMAGE_BULGE];
            TVCalibratedSliderForInteger *_TempSlider = (TVCalibratedSliderForInteger *)[cell viewWithTag:GPUIMAGE_BULGE+2000];
            TVCalibratedSliderRangeInteger range;
            range.maximumValue = 1.0;
            range.minimumValue = -1.0;
            [_TempSlider setValue:0.5];
            [_TempSlider setRange:range];
            
            filter = [[GPUImageBulgeDistortionFilter alloc] init];
        }; break;
        case GPUIMAGE_PINCH:
        {
            UITableViewCell *cell = (UITableViewCell *)[FilterTable viewWithTag:GPUIMAGE_PINCH];
            TVCalibratedSliderForInteger *_TempSlider = (TVCalibratedSliderForInteger *)[cell viewWithTag:GPUIMAGE_PINCH+2000];
            TVCalibratedSliderRangeInteger range;
            range.maximumValue = 2.0;
            range.minimumValue = -2.0;
            [_TempSlider setValue:0.5];
            [_TempSlider setRange:range];

            filter = [[GPUImagePinchDistortionFilter alloc] init];
        }; break;
        case GPUIMAGE_GLASSSPHERE:
        {
            UITableViewCell *cell = (UITableViewCell *)[FilterTable viewWithTag:GPUIMAGE_GLASSSPHERE];
            TVCalibratedSliderForInteger *_TempSlider = (TVCalibratedSliderForInteger *)[cell viewWithTag:GPUIMAGE_GLASSSPHERE+2000];
            TVCalibratedSliderRangeInteger range;
            range.maximumValue = 1.0;
            range.minimumValue = 0.0;
            [_TempSlider setValue:0.15];
            [_TempSlider setRange:range];
            
            filter = [[GPUImageGlassSphereFilter alloc] init];
            [(GPUImageGlassSphereFilter *)filter setRadius:0.15];
            
        }; break;
        case GPUIMAGE_TRANSFORM:
        {            
            UITableViewCell *cell = (UITableViewCell *)[FilterTable viewWithTag:GPUIMAGE_TRANSFORM];
            TVCalibratedSliderForInteger *_TempSlider = (TVCalibratedSliderForInteger *)[cell viewWithTag:GPUIMAGE_TRANSFORM+2000];
            TVCalibratedSliderRangeInteger range;
            range.maximumValue = 6.28;
            range.minimumValue = 0.0;
            [_TempSlider setValue:2.0];
            [_TempSlider setRange:range];

            filter = [[GPUImageTransformFilter alloc] init];
            [(GPUImageTransformFilter *)filter setAffineTransform:CGAffineTransformMakeRotation(2.0)];
            //            [(GPUImageTransformFilter *)filter setIgnoreAspectRatio:YES];
        }; break;
        case GPUIMAGE_TRANSFORM3D:
        {
            UITableViewCell *cell = (UITableViewCell *)[FilterTable viewWithTag:GPUIMAGE_TRANSFORM3D];
            TVCalibratedSliderForInteger *_TempSlider = (TVCalibratedSliderForInteger *)[cell viewWithTag:GPUIMAGE_TRANSFORM3D+2000];
            TVCalibratedSliderRangeInteger range;
            range.maximumValue = 6.28;
            range.minimumValue = 0.0;
            [_TempSlider setValue:0.75];
            [_TempSlider setRange:range];
            
            filter = [[GPUImageTransformFilter alloc] init];
            CATransform3D perspectiveTransform = CATransform3DIdentity;
            perspectiveTransform.m34 = 0.4;
            perspectiveTransform.m33 = 0.4;
            perspectiveTransform = CATransform3DScale(perspectiveTransform, 0.75, 0.75, 0.75);
            perspectiveTransform = CATransform3DRotate(perspectiveTransform, 0.75, 0.0, 1.0, 0.0);
            
            [(GPUImageTransformFilter *)filter setTransform3D:perspectiveTransform];
		}; break;
        case GPUIMAGE_CGA:
        {
            filter = [[GPUImageCGAColorspaceFilter alloc] init];
        }; break;
        case GPUIMAGE_SPHEREREFRACTION:
        {
            UITableViewCell *cell = (UITableViewCell *)[FilterTable viewWithTag:GPUIMAGE_SPHEREREFRACTION];
            TVCalibratedSliderForInteger *_TempSlider = (TVCalibratedSliderForInteger *)[cell viewWithTag:GPUIMAGE_SPHEREREFRACTION+2000];
            TVCalibratedSliderRangeInteger range;
            range.maximumValue = 1.0;
            range.minimumValue = 0.0;
            [_TempSlider setValue:0.15];
            [_TempSlider setRange:range];
            
            filter = [[GPUImageSphereRefractionFilter alloc] init];
            [(GPUImageSphereRefractionFilter *)filter setRadius:0.15];
        }; break;
        case GPUIMAGE_GAMMA:
        {            
            UITableViewCell *cell = (UITableViewCell *)[FilterTable viewWithTag:GPUIMAGE_GAMMA];
            TVCalibratedSliderForInteger *_TempSlider = (TVCalibratedSliderForInteger *)[cell viewWithTag:GPUIMAGE_GAMMA+2000];
            TVCalibratedSliderRangeInteger range;
            range.maximumValue = 3.0;
            range.minimumValue = 0.0;
            [_TempSlider setValue:1.0];
            [_TempSlider setRange:range];
            
            filter = [[GPUImageGammaFilter alloc] init];
        }; break;
        case GPUIMAGE_CUSTOM:
        {
            filter = [[GPUImageFilter alloc] initWithFragmentShaderFromFile:@"CustomFilter"];
        }; break;
        case GPUIMAGE_MASK:
		{
            self.title = @"Mask";
            /*filter = [[GPUImageMaskFilter alloc] init];
            [(GPUImageFilter*)filter setBackgroundColorRed:12.0/255.0 green:0.0/255.0 blue:0.0/255.0 alpha:1.0];*/
			filter = [[GPUImageMultiplyBlendFilter alloc] init];
			
        }; break;
        default: break;
    }

}
/*!
 @method      prepareFilter
 @abstract    It is a Method to call prepare live filter method.
 @discussion  It is a Method to call prepare live filter method.
 @result      It is a Method to call prepare live filter method.
 */
-(void) prepareFilter {
    [self prepareLiveFilter];
}
/*!
 @method      prepareLiveFilter
 @abstract    It is a Method to set filter image processing.
 @discussion  prepareLiveFilter mehtod process image and after that add filter in still camera and check filter option.
 @result      prepareLiveFilter mehtod process image and after that add filter in still camera and check filter option.
 */
-(void) prepareLiveFilter
{
    if (CameraMode)
    {
        [filter prepareForImageCapture];
        [stillCamera addTarget:filter];
        if ( (filterType == GPUIMAGE_SPHEREREFRACTION) || (filterType == GPUIMAGE_GLASSSPHERE) )
        {
            GPUImageGaussianBlurFilter *gaussianBlur = [[GPUImageGaussianBlurFilter alloc] init];
            [stillCamera addTarget:gaussianBlur];
            gaussianBlur.blurSize = 2.0;
            
            blendFilter = [[GPUImageAlphaBlendFilter alloc] init];
            blendFilter.mix = 1.0;
            [gaussianBlur addTarget:blendFilter];
            
            [filter addTarget:blendFilter];
            
            [blendFilter addTarget:self.imageView];
            
        }
        else if(filterType == GPUIMAGE_MASK)
        {
			inputImage = [UIImage imageNamed:@"mask2"];
            staticPicture = [[GPUImagePicture alloc] initWithImage:inputImage smoothlyScaleOutput:YES];
            [staticPicture processImage];
            [staticPicture addTarget:filter];
            [filter addTarget:self.imageView];
        }
        else
        {
            [filter addTarget:self.imageView];   
        }
    }
    else
    {
        [videoCamera addTarget:filter];
        if(filterType == GPUIMAGE_MASK)
        {
			inputImage = [UIImage imageNamed:@"mask2"];
            staticPicture = [[GPUImagePicture alloc] initWithImage:inputImage smoothlyScaleOutput:YES];
            staticPictureOriginalOrientation = UIInterfaceOrientationPortrait;
            [staticPicture processImage];
            [staticPicture addTarget:filter];
            [filter addTarget:self.imageView];
        }
        else
        {
            [filter addTarget:self.imageView];
        }
        
        [videoCamera startCameraCapture];
        [videoCamera.inputCamera lockForConfiguration:nil];
        if(self.flashToggleButton.selected &&
           [videoCamera.inputCamera hasTorch]){
            [videoCamera.inputCamera setTorchMode:AVCaptureTorchModeOn];
        }
    }
    

}
/*!
 @method      prepareForCapture
 @abstract    It is a Method to call capture image process.
 @discussion  prepareForCapture mehtod check camera option and then call capture image method.
 @result     repareForCapture mehtod check camera option and then call capture image method.
 */
-(void) prepareForCapture {
    
    [stillCamera.inputCamera lockForConfiguration:nil];
    if(self.flashToggleButton.selected &&
       [stillCamera.inputCamera hasTorch]){
        [stillCamera.inputCamera setTorchMode:AVCaptureTorchModeOn];
        [self performSelector:@selector(captureImage)
                   withObject:nil
                   afterDelay:0.25];
    }else{
        
        [self captureImage];
    }
    
}
/*!
 @method      captureImage
 @abstract    It is a Method to process image according filter option.
 @discussion  captureImage mehtod check filter option and then image processing after that return nsdata for filter image.
 @result     captureImage mehtod check filter option and then image processing after that return nsdata for filter image.
 */
-(void)captureImage {
    //NSLog(@"Two Times");
    if ( (filterType == GPUIMAGE_SPHEREREFRACTION) || (filterType == GPUIMAGE_GLASSSPHERE) )
    {
        [stillCamera capturePhotoAsJPEGProcessedUpToFilter:blendFilter withCompletionHandler:^(NSData *processedJPEG, NSError *error){
            if (!Imageforanimation) {
                
                //            Imageforanimation = [[UIImage alloc] initWithData:processedJPEG];
                Imageforanimation = [[UIImage alloc] init];
            }
            
            [Imageforanimation initWithData:processedJPEG];
            
        }];
    }
    else
    {
        [stillCamera capturePhotoAsJPEGProcessedUpToFilter:filter withCompletionHandler:^(NSData *processedJPEG, NSError *error){
            if (!Imageforanimation) {
                
                //            Imageforanimation = [[UIImage alloc] initWithData:processedJPEG];
                Imageforanimation = [[UIImage alloc] init];
            }
            
            [Imageforanimation initWithData:processedJPEG];
            
        }];
    }
    staticPictureOriginalOrientation = Imageforanimation.imageOrientation;
    //NSLog(@"%@",[Imageforanimation description]);
    if(self.flashToggleButton.selected &&
       [stillCamera.inputCamera hasTorch]){
        [stillCamera.inputCamera setTorchMode:AVCaptureTorchModeOff];
    }
}
/*!
 @method      removeAllTargets
 @abstract    It is a Method to remove stillcamera static picture and current filter.
 @discussion  It is a Method to remove stillcamera static picture and current filter.
 @result      It is a Method to remove stillcamera static picture and current filter. 
 */
-(void) removeAllTargets
{
    if (!CameraMode)
    {
        [videoCamera removeAllTargets];
    }
    else
    {
        [stillCamera removeAllTargets];
    }
    [staticPicture removeAllTargets];
    [filter removeAllTargets];
}

#pragma mark - UIImagePickerDelegate Method

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    [picker dismissModalViewControllerAnimated:NO];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissModalViewControllerAnimated:NO];
}

#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return (GPUIMAGE_NUMFILTERS - 1);
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSString *CellIdentifier = [NSString stringWithFormat:@"Cell%i",indexPath.row];
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                       reuseIdentifier:CellIdentifier] autorelease];
        UIView *SliderView = [[UIView alloc] initWithFrame:CGRectMake(0,0,320,40)];
        
        UIButton * button = [UIButton buttonWithType:UIButtonTypeCustom];
        [button setBackgroundImage:[UIImage imageNamed:@"overlay_button.png"] forState:UIControlStateNormal];
        button.frame = CGRectMake(6,4, 62.0f, 32.0f);
        [button addTarget:self
                   action:@selector(filterClicked:)
         forControlEvents:UIControlEventTouchUpInside];
        button.tag = indexPath.row+1000;
        button.selected = YES;
        
        UIImageView* imageView2 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:[NSString stringWithFormat:@"%i.png",indexPath.row]]];
        imageView2.frame = CGRectMake(25,8, 24.0f, 24.0f);
        imageView2.tag = indexPath.row + 500;
        
        cell.tag = indexPath.row;
        
        _cvSliderInteger = [[TVCalibratedSliderForInteger alloc] initWithFrame:CGRectMake(55,-12,200,40) withStyle:TavicsaStyleInteger];
        
        [_cvSliderInteger setThumbImage:nil forState:UIControlStateHighlighted];
        TVCalibratedSliderRangeInteger range2;
        
        range2.maximumValue = 1;
        range2.minimumValue = 0;
        
        [_cvSliderInteger setRange:range2];
        [_cvSliderInteger setTextColorForHighlightedState:[UIColor redColor]];
        [_cvSliderInteger setMarkerImageOffsetFromSlider:5];
        [_cvSliderInteger setMarkerValueOffsetFromSlider:10];
        [_cvSliderInteger setDelegate:self];
        _cvSliderInteger.hidden = YES;
        
        _cvSliderInteger.tag = indexPath.row + 2000;
        
        //NSLog(@"%@",[_cvSliderInteger description]);
        [SliderView addSubview:button];
        [SliderView addSubview:imageView2];
        if ([indexPath row]!= GPUIMAGE_CGA && [indexPath row]!=GPUIMAGE_CUSTOM && [indexPath row]!=GPUIMAGE_SKETCH && [indexPath row]!=GPUIMAGE_TOON && [indexPath row] != GPUIMAGE_FALSECOLOR && [indexPath row] != GPUIMAGE_COLORINVERT)
        {
            //NSLog(@"%i",[indexPath row]);
            [SliderView addSubview:_cvSliderInteger];    
        }
        [imageView2 release];
        [cell addSubview:SliderView];
        [_cvSliderInteger release];
        [SliderView release];
        
        
        UILabel *lblEffectname=[[UILabel alloc] initWithFrame:CGRectMake(6,40,60,15)];
        UIColor *color = [UIColor colorWithRed:3/255.0f green:190/255.0f blue:251/255.0f alpha:1.0];
        lblEffectname.layer.shadowColor = [color CGColor];
        lblEffectname.layer.shadowRadius = 4.0f;
        lblEffectname.layer.shadowOpacity = .9;
        lblEffectname.layer.shadowOffset = CGSizeZero;
        lblEffectname.layer.masksToBounds = NO;
        lblEffectname.font = [UIFont fontWithName:@"DS-Digital-BoldItalic" size:13.0];
        lblEffectname.textColor=[UIColor colorWithRed:3/255.0f green:190/255.0f blue:251/255.0f alpha:1.0];
        lblEffectname.textAlignment = UITextAlignmentCenter;
        lblEffectname.backgroundColor=[UIColor colorWithRed:0/255.0f green:0/255.0f blue:0/255.0f alpha:0.5];
        lblEffectname.layer.cornerRadius = 3.0;
        [lblEffectname.layer setMasksToBounds:YES];
        //lblEffectname.alpha = 0.5;
        switch ([indexPath row])
        {
            case GPUIMAGE_SATURATION: lblEffectname.text = @"Saturation"; break;
            case GPUIMAGE_CONTRAST: lblEffectname.text = @"Contrast"; break;
            case GPUIMAGE_BRIGHTNESS: lblEffectname.text = @"Brightness"; break;
            case GPUIMAGE_EXPOSURE: lblEffectname.text = @"Exposure"; break;
            case GPUIMAGE_RGB: lblEffectname.text = @"RGB"; break;
            case GPUIMAGE_HUE: lblEffectname.text = @"Hue"; break;
            case GPUIMAGE_WHITEBALANCE: lblEffectname.text = @"White balance"; break;
            case GPUIMAGE_MONOCHROME: lblEffectname.text = @"Monochrome"; break;
            case GPUIMAGE_FALSECOLOR: lblEffectname.text = @"False color"; break;
            case GPUIMAGE_SHARPEN: lblEffectname.text = @"Sharpen"; break;
            case GPUIMAGE_TRANSFORM: lblEffectname.text = @"Transform (2-D)"; break;
            case GPUIMAGE_TRANSFORM3D: lblEffectname.text = @"Transform (3-D)"; break;
            case GPUIMAGE_COLORINVERT: lblEffectname.text = @"Color invert"; break;
            case GPUIMAGE_GRAYSCALE: lblEffectname.text = @"Grayscale"; break;
            case GPUIMAGE_SEPIA: lblEffectname.text = @"Sepia tone"; break;
            case GPUIMAGE_PIXELLATE: lblEffectname.text = @"Pixellate"; break;
            case GPUIMAGE_POLARPIXELLATE: lblEffectname.text = @"Polar pixellate"; break;
            case GPUIMAGE_POLKADOT: lblEffectname.text = @"Polka dot"; break;
            case GPUIMAGE_HALFTONE: lblEffectname.text = @"Halftone"; break;
            case GPUIMAGE_CROSSHATCH: lblEffectname.text = @"Crosshatch"; break;
            case GPUIMAGE_SKETCH: lblEffectname.text = @"Sketch"; break;
            case GPUIMAGE_THRESHOLDSKETCH: lblEffectname.text = @"Threshold Sketch"; break;
            case GPUIMAGE_TOON: lblEffectname.text = @"Toon"; break;
            case GPUIMAGE_SMOOTHTOON: lblEffectname.text = @"Smooth toon"; break;
            case GPUIMAGE_TILTSHIFT: lblEffectname.text = @"Tilt shift"; break;
            case GPUIMAGE_CGA: lblEffectname.text = @"CGA colorspace"; break;
            case GPUIMAGE_EMBOSS: lblEffectname.text = @"Emboss"; break;
            case GPUIMAGE_POSTERIZE: lblEffectname.text = @"Posterize"; break;
            case GPUIMAGE_SWIRL: lblEffectname.text = @"Swirl"; break;
            case GPUIMAGE_BULGE: lblEffectname.text = @"Bulge"; break;
            case GPUIMAGE_SPHEREREFRACTION: lblEffectname.text = @"Sphere refraction"; break;
            case GPUIMAGE_GLASSSPHERE: lblEffectname.text = @"Glass sphere"; break;
            case GPUIMAGE_PINCH: lblEffectname.text = @"Pinch"; break;
            case GPUIMAGE_CUSTOM: lblEffectname.text = @"Custom"; break;
            case GPUIMAGE_TONECURVE: lblEffectname.text = @"Tone curve"; break;
            case GPUIMAGE_VIGNETTE: lblEffectname.text = @"Vignette"; break;
            //case GPUIMAGE_Carzy:lblEffectname.text = @"Crazy";break;
            case GPUIMAGE_GAMMA: lblEffectname.text = @"Gamma"; break;
            case GPUIMAGE_GAUSSIAN_SELECTIVE: lblEffectname.text = @"Gaussian selective blur"; break;
            case GPUIMAGE_MASK: lblEffectname.text = @"mask"; break;
                
        }
        
      
        [cell addSubview:lblEffectname];
        [lblEffectname release];
    }
    if(PreviousFilterOption != indexPath.row)
    {
//        UITableViewCell *cell = (UITableViewCell *)[FilterTable viewWithTag:PreviousFilterOption-1000];
//        UIButton *_btntemp = (UIButton *)[cell viewWithTag:PreviousFilterOption];
//        if (_btntemp.selected==0)
//        {
//            //NSLog(@"%i",_btntemp.selected);
//            _btntemp.selected = !_btntemp.selected;
//        }
//        [NSThread detachNewThreadSelector:@selector(SliderClose:) toTarget:self withObject:(UIButton *)[cell viewWithTag:PreviousFilterOption]];
        //[self SliderClose:(UIButton *)[cell viewWithTag:PreviousFilterOption]];
        UITableViewCell *cell = (UITableViewCell *)[FilterTable viewWithTag:PreviousFilterOption-1000];
        UIButton *_btntemp = (UIButton *)[cell viewWithTag:PreviousFilterOption];
        TVCalibratedSliderForInteger *_TempSlider = (TVCalibratedSliderForInteger *)[cell viewWithTag:cell.tag+2000];
        _TempSlider.hidden = YES;
        UIImage* image2 = [[UIImage imageNamed:@"overlay_button.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(18, 18, 18, 18)];
        
        [_btntemp setBackgroundImage:image2 forState:UIControlStateNormal];
        [_btntemp setBackgroundImage:image2 forState:UIControlStateHighlighted];
        _btntemp.frame = CGRectMake(6,4, 62, 32);
        
        UIImageView *_TempImg = (UIImageView *)[cell viewWithTag:PreviousFilterOption-500];
        _TempImg.frame = CGRectMake(25,8, 24.0,24.0);
        
        [_TempImg setImage:[UIImage imageNamed:[NSString stringWithFormat:@"%i.png",PreviousFilterOption-1000]]];
        if (_btntemp.selected==0)
        {
            //NSLog(@"%i",_btntemp.selected);
            _btntemp.selected = !_btntemp.selected;
        }
        PreviousFilterOption = 9999;
        FilterFlag = 0;
    }
    return cell;
}


#pragma mark IBAction Method
/*!
 @method      ShowphotolibraryClick
 @abstract    It is an IBAction Method to open photo library.
 @discussion  On clicking the photo Button,it's open photo library.
 @result      On clicking the photo Button,it's open photo library.
 */
- (IBAction)ShowphotolibraryClick:(id)sender
{
    imagePicker.sourceType =
    UIImagePickerControllerSourceTypePhotoLibrary;
    imagePicker.allowsEditing = YES;
    imagePicker.mediaTypes =
    [[NSArray alloc] initWithObjects: (NSString *) kUTTypeMovie,(NSString *)kUTTypeImage, nil];
    [self presentModalViewController:imagePicker animated:YES];
    
}
/*!
 @method      ShowFilterOptionClick
 @abstract    It is an IBAction Method to open filter option.
 @discussion  On clicking the filter Button,it's open filter option.
 @result      On clicking the filter Button,it's open filter option.
 */
- (IBAction)ShowFilterOptionClick:(UIButton *)sender
{
    //NSLog(@"%i",sender.selected);
    if (!sender.selected)
    {
        FilterTable.hidden = NO;
        [self Slideupview];
    }
    else
    {
        [self Slidedownview];
    }
    
    sender.selected = !sender.selected;
}
/*!
 @method      VideoStart_EndClick
 @abstract    It is an IBAction Method to video start and stop process.
 @discussion  On clicking the video button,it's start video recroding after use tab on same button video stop recording.
 @result      On clicking the video button,it's start video recroding after use tab on same button video stop recording.
 */
- (IBAction)VideoStart_EndClick:(id)sender
{
    if (btnVideoled.selected)
    {
        btnVideoled.selected = !btnVideoled.selected;
        [filter removeTarget:movieWriter];
        videoCamera.audioEncodingTarget = nil;
        [movieWriter finishRecording];
        if (!Imageforanimation) {
            
            Imageforanimation = [[UIImage alloc] init];
        }
        //Imageforanimation = [self imageFromMovie:movieURL atTime:0.5];
        //NSLog(@"Movie completed");
        [self ShowActivityview];
//        if(self.flashToggleButton.selected &&
//           [stillCamera.inputCamera hasTorch]){
//            [stillCamera.inputCamera setTorchMode:AVCaptureTorchModeOff];
//        }
        
        ALAssetsLibrary* library = [[ALAssetsLibrary alloc] init];
        [library saveVideo:movieURL toAlbum:@"Camcoder" withCompletionBlock:^(NSError *error)
         {
             NSString *message;
             NSString *title;
             if (!error) {
                 title = NSLocalizedString(@"Message", @"");
                 message = NSLocalizedString(@"Image save successfully", @"");
                 [self HideActivityview];
             }
             else {
                 
                 title = NSLocalizedString(@"Error", @"");
                 message = NSLocalizedString(@"Image is not save", @"");
             }
             
         }];
        [library release];
        [self.stopWatchImageView setHidden:YES];
        [self.stopWatchLabel setHidden:YES];
        [self onStopPressed];
        [btnVideoled stopGlowing];
        _cvSlider.userInteractionEnabled = YES;
        _cvSlider.alpha = 1.0;
        [movieWriter release];
        movieWriter = nil;
        
        if (btnfilteroption.selected != 0)
        {
                FilterTable.hidden = NO;
        }
        btnfilteroption.enabled = TRUE;
        btnphotolibrary.enabled = TRUE;
        flashToggleButton.hidden = FALSE;
        cameraToggleButton.hidden = FALSE;
    }
    else
    {
        //btnfilteroption.selected = !btnfilteroption.selected;
        btnVideoled.selected = !btnVideoled.selected;
        NSString *pathToMovie = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/Movie.m4v"];
        unlink([pathToMovie UTF8String]); // If a file already exists, AVAssetWriter won't let you record new frames, so delete the old movie
        movieURL = [[NSURL fileURLWithPath:pathToMovie] retain];
        videoCamera.outputImageOrientation = UIInterfaceOrientationPortrait;
        [videoCamera addTarget:filter];
        movieWriter = [[GPUImageMovieWriter alloc] initWithMovieURL:movieURL size:CGSizeMake(480.0, 640.0)];
        
        [filter addTarget:movieWriter];
    
        [videoCamera startCameraCapture];
        videoCamera.audioEncodingTarget = movieWriter;
        [movieWriter startRecording];
        
        UIColor *color = stopWatchLabel.textColor;
        stopWatchLabel.layer.shadowColor = [color CGColor];
        stopWatchLabel.layer.shadowRadius = 4.0f;
        stopWatchLabel.layer.shadowOpacity = .9;
        stopWatchLabel.layer.shadowOffset = CGSizeZero;
        stopWatchLabel.layer.masksToBounds = NO;
        stopWatchLabel.font = [UIFont fontWithName:@"DS-Digital-BoldItalic" size:22.0];
        [self.stopWatchImageView setHidden:NO];
        [self.stopWatchLabel setHidden:NO];
        [self onStartPressed];
        [btnVideoled startGlowing];
        _cvSlider.userInteractionEnabled = NO;
        _cvSlider.alpha = 0.5;
        [videoCamera.inputCamera lockForConfiguration:nil];
        if(self.flashToggleButton.selected &&
           [videoCamera.inputCamera hasTorch]){
            [videoCamera.inputCamera setTorchMode:AVCaptureTorchModeOn];
        }
        FilterTable.hidden = YES;
        btnfilteroption.enabled = FALSE;
        btnphotolibrary.enabled = FALSE;
        flashToggleButton.hidden = TRUE;
        cameraToggleButton.hidden = TRUE;
        
    }
}
/*!
 @method      takePhoto
 @abstract    It is an IBAction Method to capture image.
 @discussion  On clicking the camera button,it's capture image.
 @result      On clicking the camera button,it's capture image.
 */
-(IBAction) takePhoto:(id)sender
{
    [stillCamera.inputCamera lockForConfiguration:nil];
    if(self.flashToggleButton.selected &&
       [stillCamera.inputCamera hasTorch]){
        [stillCamera.inputCamera setTorchMode:AVCaptureTorchModeOn];
        [self performSelector:@selector(captureImage)
                   withObject:nil
                   afterDelay:0.25];
    }else{
        
        [self captureImage];
    }
    NSURL *soundURL = [[NSBundle mainBundle] URLForResource:@"Grab"
                                              withExtension:@"aif"];
    AVAudioPlayer *avSound = [[AVAudioPlayer alloc]
                              initWithContentsOfURL:soundURL error:nil];
    
    [avSound play];
    
    // Flash the screen white and fade it out to give UI feedback that a still image was taken
    float WidthFlash;
    BOOL _flag = [self CheckIphone5];
    if (_flag)
    {
        WidthFlash = 600;
    }
    else
    {
        WidthFlash = 509;
    }
    UIView *flashView = [[UIView alloc] initWithFrame:CGRectMake(0,0,320,WidthFlash)];
    [flashView setBackgroundColor:[UIColor whiteColor]];
    [[[self view] window] addSubview:flashView];
    
    [UIView animateWithDuration:.4f
                     animations:^{
                         [flashView setAlpha:0.f];
                         
                         runOnMainQueueWithoutDeadlocking(^{
                             //[self ShowActivityview];
                             //[self performSelector:@selector(ShowActivityview)withObject:nil afterDelay:0.35];
                             [self ShowActivityview];
                         });
                         
                     }
                     completion:^(BOOL finished){
                         [flashView removeFromSuperview];
                         [flashView release];
                         runOnMainQueueWithoutDeadlocking(^{
                             [self performSelector:@selector(save2AlbumButtonClicked)withObject:nil afterDelay:1];
                         });
                     }
     ];
    [UIView commitAnimations];
    [avSound release];
    
}
/*!
 @method      toggleFlash
 @abstract    It is an IBAction Method to flash on off camera option.
 @discussion  On clicking the flash button,it's toggle button for flash option.
 @result      On clicking the flash button,it's toggle button for flash option.
 */
-(IBAction)toggleFlash:(UIButton *)button
{
    [button setSelected:!button.selected];
    if (!CameraMode) {
        if (button.selected)
        {
            [videoCamera.inputCamera lockForConfiguration:nil];
            if(self.flashToggleButton.selected &&
               [videoCamera.inputCamera hasTorch]){
                [videoCamera.inputCamera setTorchMode:AVCaptureTorchModeOn];
            }
        }
        else
        {
            [stillCamera.inputCamera setTorchMode:AVCaptureTorchModeOff];
        }
        
    }
}
/*!
 @method      switchCamera
 @abstract    It is an IBAction Method to camera change option.
 @discussion  On clicking the camera button,it's toggle button for camera front and rearoption.
 @result      On clicking the camera button,it's toggle button for camera front and rear option.
 */
-(IBAction) switchCamera
{
    [self.cameraToggleButton setEnabled:NO];
        
    if (CameraMode)
    {
        [stillCamera rotateCamera];
    }
    else
    {
        [videoCamera rotateCamera];
    }
    
    [self.cameraToggleButton setEnabled:YES];
    
    if ([UIImagePickerController isSourceTypeAvailable: UIImagePickerControllerSourceTypeCamera] && stillCamera) {
        if ([stillCamera.inputCamera hasFlash] && [stillCamera.inputCamera hasTorch]) {
            [self.flashToggleButton setEnabled:YES];
        } else {
            [self.flashToggleButton setEnabled:NO];
        }
    }
    
    if (!CameraMode)
    {
        if ([UIImagePickerController isSourceTypeAvailable: UIImagePickerControllerSourceTypeCamera] && videoCamera) {
            if ([videoCamera.inputCamera hasFlash] && [videoCamera.inputCamera hasTorch]) {
                [self.flashToggleButton setEnabled:YES];
                if(self.flashToggleButton.selected)
                {
                    [videoCamera.inputCamera setTorchMode:AVCaptureTorchModeOn];
                }
                
            } else {
                [self.flashToggleButton setEnabled:NO];
            }
        }
    }
}
/*!
 @method      HomeClick
 @abstract    It is an IBAction Method to flip aboutus to camera screen.
 @discussion  On clicking the home button,it's flip aboutus screen to camera screen.
 @result      On clicking the home button,it's flip aboutus screen to camera screen.
 */
- (IBAction)HomeClick:(id)sender
{
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.75];
    [UIView setAnimationDelegate:self];
    
    // If view one is visible, hides it and add the new one with the "Flip" style transition
    [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromLeft forView:self.view cache:YES];
    //[self.flipViewOneController.view removeFromSuperview];
    [AboutusView removeFromSuperview];
    
    // Commit animations to show the effect
    [UIView commitAnimations];
     AboutusView.alpha = 0.0;
}
/*!
 @method      AboutusClick
 @abstract    It is an IBAction Method to flip camera to aboutus screen.
 @discussion  On clicking the home button,it's flip camera screen to aboutus screen.
 @result      On clicking the home button,it's flip camera screen to aboutus screen.
 */
- (IBAction)AboutusClick:(id)sender
{
    AboutusView.alpha = 1.0;
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.75];
    [UIView setAnimationDelegate:self];

    // If view one is visible, hides it and add the new one with the "Flip" style transition
    [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromRight forView:self.view cache:YES];
    //[self.flipViewOneController.view removeFromSuperview];
    [self.view addSubview:AboutusView];
        
    // Commit animations to show the effect
    [UIView commitAnimations];
}

#pragma mark Class local methods
-(void)VideoSave
{
    btnVideoled.selected = !btnVideoled.selected;
    [filter removeTarget:movieWriter];
    videoCamera.audioEncodingTarget = nil;
    [movieWriter finishRecording];
    if (!Imageforanimation) {
        
        Imageforanimation = [[UIImage alloc] init];
    }
    //Imageforanimation = [self imageFromMovie:movieURL atTime:0.5];
    //NSLog(@"Movie completed");
    [self ShowActivityview];
    //        if(self.flashToggleButton.selected &&
    //           [stillCamera.inputCamera hasTorch]){
    //            [stillCamera.inputCamera setTorchMode:AVCaptureTorchModeOff];
    //        }
    
    ALAssetsLibrary* library = [[ALAssetsLibrary alloc] init];
    [library saveVideo:movieURL toAlbum:@"Camcoder" withCompletionBlock:^(NSError *error)
     {
         NSString *message;
         NSString *title;
         if (!error) {
             title = NSLocalizedString(@"Message", @"");
             message = NSLocalizedString(@"Image save successfully", @"");
             [self HideActivityview];
         }
         else {
             
             title = NSLocalizedString(@"Error", @"");
             message = NSLocalizedString(@"Image is not save", @"");
         }
         
     }];
    [library release];
    [self.stopWatchImageView setHidden:YES];
    [self.stopWatchLabel setHidden:YES];
    [self onStopPressed];
    [btnVideoled stopGlowing];
    _cvSlider.userInteractionEnabled = YES;
    _cvSlider.alpha = 1.0;
    [movieWriter release];
    movieWriter = nil;
    [self Slidedownview];
    btnfilteroption.enabled = TRUE;
    btnphotolibrary.enabled = TRUE;
    flashToggleButton.hidden = FALSE;
    cameraToggleButton.hidden = FALSE;
    FilterTable.hidden = NO;
}
/*!
 @method      valueChanged
 @param1      It will be pass current slider object.
 @abstract    It is a Method to handle slider value for camera to video vise versa.
 @discussion  User swap slider then camera mode will be change.
 @result      User swap slider then camera mode will be change.
 */
- (void)valueChanged:(TVCalibratedSlider *)sender
{
    BOOL Animatingflag;
    if (LastCameramode != [sender value])
    {
        [NSThread detachNewThreadSelector:@selector(ShowActivityview) toTarget:self withObject:nil];
        Animatingflag = YES;
    }
    else
    {
        Animatingflag = NO;
        return;
    }
    if ([sender value] == 0)
    {
        [self removeAllTargets];
        [stillCamera release];
        stillCamera = nil;
        [btnVideoled setHidden:YES];
        [btnVideoled setAlpha:0.0f];
        [btnCamera setHidden:NO];
        [UIView beginAnimations:@"glow" context:nil];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
        [UIView setAnimationDuration:0.8f];
        for(int i=0;i<5;i++) {
            [btnCamera setAlpha:0.25*i];
        }
        [UIView commitAnimations];
        CameraMode = YES;
        //if (!stillCamera) {
        if (videoCamera.cameraPosition == AVCaptureDevicePositionBack)
        {
            stillCamera = [[GPUImageStillCamera alloc] initWithSessionPreset:AVCaptureSessionPresetPhoto cameraPosition:AVCaptureDevicePositionBack];
        }
        else
        {
            stillCamera = [[GPUImageStillCamera alloc] initWithSessionPreset:AVCaptureSessionPresetPhoto cameraPosition:AVCaptureDevicePositionFront];
        }
            
        //}
        stillCamera.outputImageOrientation = UIInterfaceOrientationPortrait;
        
        
        [stillCamera startCameraCapture];
        if([stillCamera.inputCamera hasTorch]){
            [self.flashToggleButton setEnabled:YES];
        }else{
            [self.flashToggleButton setEnabled:NO];
        }
        [self prepareFilter];
        if(self.flashToggleButton.selected &&
           [videoCamera.inputCamera hasTorch] && [videoCamera.inputCamera torchMode]==AVCaptureTorchModeOn)
        {
            [videoCamera.inputCamera setTorchMode:AVCaptureTorchModeOff];
        }
        LastCameramode = 0;
    }
    else
    {
        [self removeAllTargets];
        [videoCamera release];
        videoCamera = nil;
        [btnCamera setHidden:YES];
        [btnCamera setAlpha:0.0f];
        [btnVideoled setHidden:NO];
        [UIView beginAnimations:@"glow" context:nil];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
        [UIView setAnimationDuration:0.8f];
        for(int i=0;i<5;i++) {
            [btnVideoled setAlpha:0.25*i];
        }
        [UIView commitAnimations];
        CameraMode = NO;
        if (stillCamera.cameraPosition == AVCaptureDevicePositionBack)
        {
            videoCamera = [[GPUImageVideoCamera alloc] initWithSessionPreset:AVCaptureSessionPreset640x480 cameraPosition:AVCaptureDevicePositionBack];
        }
        else
        {
            videoCamera = [[GPUImageVideoCamera alloc] initWithSessionPreset:AVCaptureSessionPreset640x480 cameraPosition:AVCaptureDevicePositionFront];
        }
        //if (!videoCamera)
        //{
         //   videoCamera = [[GPUImageVideoCamera alloc] initWithSessionPreset:AVCaptureSessionPreset640x480 cameraPosition:AVCaptureDevicePositionBack];
        //}
        videoCamera.outputImageOrientation = UIInterfaceOrientationPortrait;
        videoCamera.horizontallyMirrorFrontFacingCamera = NO;
        videoCamera.horizontallyMirrorRearFacingCamera = NO;
        
        [videoCamera.inputCamera lockForConfiguration:nil];
        if(self.flashToggleButton.selected &&
           [videoCamera.inputCamera hasTorch] && [videoCamera.inputCamera torchMode]==AVCaptureTorchModeOff)
        {
            [videoCamera.inputCamera setTorchMode:AVCaptureTorchModeOn];
        }
        if (!filter)
        {
            
            filter = [[GPUImageFilter alloc] init];
        }
        [self prepareFilter];
//        [videoCamera addTarget:filter];
//        [filter addTarget:self.imageView];
//        [videoCamera startCameraCapture];
        LastCameramode = 1;
    }
    if (Animatingflag)
    {
        [self performSelector:@selector(HideActivityviewforchange)];
    }
}
/*!
 @method      updateTimer
 @abstract    It is a Method to handle video recording timer.
 @discussion  User can tab on start video so timer will be start.
 @result      User can tab on start video so timer will be start.
 */
- (void)updateTimer
{
    NSDate *currentDate = [NSDate date];
    NSTimeInterval timeInterval = [currentDate timeIntervalSinceDate:startDate];
    NSDate *timerDate = [NSDate dateWithTimeIntervalSince1970:timeInterval];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"HH:mm:ss"];
    [dateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0.0]];
    NSString *timeString=[dateFormatter stringFromDate:timerDate];
    stopWatchLabel.text = timeString;
    [dateFormatter release];
}
/*!
 @method      onStartPressed
 @abstract    It is a Method to handle start recording timer.
 @discussion  User can tab on start recording video so timer will be start.
 @result      User can tab on start recording video so timer will be start.
 */
- (void)onStartPressed
{
    startDate = [[NSDate date]retain];
    stopWatchLabel.text = @"00:00:00";
    // Create the stop watch timer that fires every 10 ms
    stopWatchTimer = [NSTimer scheduledTimerWithTimeInterval:1.0
                                                      target:self
                                                    selector:@selector(updateTimer)
                                                    userInfo:nil
                                                     repeats:YES];
}
/*!
 @method      onStopPressed
 @abstract    It is a Method to handle stop recording timer.
 @discussion  User can tab on stop recording video so timer will be start.
 @result      User can tab on stop recording video so timer will be start.
 */
- (void)onStopPressed
{
    [stopWatchTimer invalidate];
    stopWatchTimer = nil;
    [self updateTimer];
}
/*!
 @method      filterClicked
 @param1      It will be pass current tab button object.
 @abstract    It is a Method to handle filter option.
 @discussion  User tab on filter option according to filter tableview.
 @result      User tab on filter option according to filter tableview.
 */
-(void) filterClicked:(UIButton *) sender {
    
    if (!CameraMode && stopWatchLabel.hidden == FALSE)
    {
        [self VideoSave];
        
    }
    
    NSURL *soundURL = [[NSBundle mainBundle] URLForResource:@"TapSound"
                                              withExtension:@"wav"];
    AVAudioPlayer *avSound = [[AVAudioPlayer alloc]
                              initWithContentsOfURL:soundURL error:nil];
    
    [avSound play];
    //NSLog(@"%i",sender.selected);
    if (PreviousFilterOption != 9999 && PreviousFilterOption !=sender.tag)
    {
        UITableViewCell *cell = (UITableViewCell *)[FilterTable viewWithTag:PreviousFilterOption-1000];
        //[NSThread detachNewThreadSelector:@selector(SliderClose:) toTarget:self withObject:(UIButton *)[cell viewWithTag:PreviousFilterOption]];
        //[self performSelector:@selector(SliderClose:) withObject:(UIButton *)[cell viewWithTag:PreviousFilterOption] afterDelay:0.1];
        if (FilterFlag == 0)
        {
            [self SliderClose:(UIButton *)[cell viewWithTag:PreviousFilterOption]];
        }
        UIButton *_btntemp = (UIButton *)[cell viewWithTag:PreviousFilterOption];
        _btntemp.selected = !_btntemp.selected;
    }
    if (sender.selected)
    {
        if (FilterFlag == 0)
        {
            FilterFlag = 1;
            PreviousFilterOption = sender.tag;
            FilterTable.userInteractionEnabled = NO;
            [self SliderOpen:sender];
            filterType = sender.tag-1000;
            [self setupFilter];
            [self removeAllTargets];
            [self prepareFilter];
        }
        else
        {
            return;
        }
    }
    else
    {
        FilterFlag = 0;
        //NSLog(@"%@",[sender description]);
        PreviousFilterOption = 9999;
        [self SliderClose:sender];
    }
    sender.selected = !sender.selected;
    selectedFilter = sender.tag-1000;
    
}
/*!
 @method      valueChangedforInteger
 @param1      It will be pass current filter slider object.
 @abstract    It is a Method to handle slider value according tofilter option versa.
 @discussion  User swap on filter slider then effects will be change in live camera.
 @result      User swap on filter slider then effects will be change in live camera.
 */
- (void)valueChangedforInteger:(TVCalibratedSliderForInteger *)sender
{
    //NSLog(@"%f",[sender value]);
    switch(filterType)
    {
        case GPUIMAGE_SEPIA: [(GPUImageSepiaFilter *)filter setIntensity:[(TVCalibratedSliderForInteger *)sender value]]; break;
        case GPUIMAGE_PIXELLATE: [(GPUImagePixellateFilter *)filter setFractionalWidthOfAPixel:[(TVCalibratedSliderForInteger *)sender value]]; break;
        case GPUIMAGE_POLARPIXELLATE: [(GPUImagePolarPixellateFilter *)filter setPixelSize:CGSizeMake([(TVCalibratedSliderForInteger *)sender value], [(TVCalibratedSliderForInteger *)sender value])]; break;
        case GPUIMAGE_POLKADOT: [(GPUImagePolkaDotFilter *)filter setFractionalWidthOfAPixel:[(TVCalibratedSliderForInteger *)sender value]]; break;
        case GPUIMAGE_SATURATION: [(GPUImageSaturationFilter *)filter setSaturation:[(TVCalibratedSliderForInteger *)sender value]]; break;
        case GPUIMAGE_CONTRAST: [(GPUImageContrastFilter *)filter setContrast:[(TVCalibratedSliderForInteger *)sender value]]; break;
        case GPUIMAGE_BRIGHTNESS: [(GPUImageBrightnessFilter *)filter setBrightness:[(UISlider *)sender value]]; break;
        case GPUIMAGE_EXPOSURE: [(GPUImageExposureFilter *)filter setExposure:[(TVCalibratedSliderForInteger *)sender value]]; break;
        case GPUIMAGE_MONOCHROME: [(GPUImageMonochromeFilter *)filter setIntensity:[(TVCalibratedSliderForInteger *)sender value]]; break;
        case GPUIMAGE_RGB: [(GPUImageRGBFilter *)filter setGreen:[(TVCalibratedSliderForInteger *)sender value]]; break;
        case GPUIMAGE_HUE: [(GPUImageHueFilter *)filter setHue:[(TVCalibratedSliderForInteger *)sender value]]; break;
        case GPUIMAGE_SHARPEN: [(GPUImageSharpenFilter *)filter setSharpness:[(TVCalibratedSliderForInteger *)sender value]]; break;
        case GPUIMAGE_POSTERIZE: [(GPUImagePosterizeFilter *)filter setColorLevels:round([(UISlider*)sender value])]; break;
        case GPUIMAGE_EMBOSS: [(GPUImageEmbossFilter *)filter setIntensity:[(TVCalibratedSliderForInteger *)sender value]]; break;
        case GPUIMAGE_SWIRL: [(GPUImageSwirlFilter *)filter setAngle:[(TVCalibratedSliderForInteger *)sender value]]; break;
        case GPUIMAGE_SMOOTHTOON: [(GPUImageSmoothToonFilter *)filter setBlurSize:[(TVCalibratedSliderForInteger*)sender value]]; break;
        case GPUIMAGE_WHITEBALANCE: [(GPUImageWhiteBalanceFilter *)filter setTemperature:[(TVCalibratedSliderForInteger *)sender value]]; break;
        case GPUIMAGE_TONECURVE: [(GPUImageToneCurveFilter *)filter setBlueControlPoints:[NSArray arrayWithObjects:[NSValue valueWithCGPoint:CGPointMake(0.0, 0.0)], [NSValue valueWithCGPoint:CGPointMake(0.5, [(TVCalibratedSliderForInteger *)sender value])], [NSValue valueWithCGPoint:CGPointMake(1.0, 0.75)], nil]]; break;
        case GPUIMAGE_HALFTONE: [(GPUImageHalftoneFilter *)filter setFractionalWidthOfAPixel:[(TVCalibratedSliderForInteger *)sender value]]; break;
        case GPUIMAGE_CROSSHATCH: [(GPUImageCrosshatchFilter *)filter setCrossHatchSpacing:[(TVCalibratedSliderForInteger *)sender value]]; break;
        case GPUIMAGE_TILTSHIFT:
        {
            CGFloat midpoint = [(TVCalibratedSliderForInteger *)sender value];
            [(GPUImageTiltShiftFilter *)filter setTopFocusLevel:midpoint - 0.1];
            [(GPUImageTiltShiftFilter *)filter setBottomFocusLevel:midpoint + 0.1];
        }; break;
        case GPUIMAGE_VIGNETTE: [(GPUImageVignetteFilter *)filter setVignetteEnd:[(TVCalibratedSliderForInteger *)sender value]]; break;
        //case GPUIMAGE_MOSAIC:  [(GPUImageMosaicFilter *)filter setDisplayTileSize:CGSizeMake([(TVCalibratedSliderForInteger *)sender value], [(TVCalibratedSliderForInteger *)sender value])]; break;
        case GPUIMAGE_BULGE: [(GPUImageBulgeDistortionFilter *)filter setScale:[(TVCalibratedSliderForInteger *)sender value]]; break;    
        case GPUIMAGE_PINCH: [(GPUImagePinchDistortionFilter *)filter setScale:[(UISlider *)sender value]]; break;
        case GPUIMAGE_TRANSFORM: [(GPUImageTransformFilter *)filter setAffineTransform:CGAffineTransformMakeRotation([(TVCalibratedSliderForInteger*)sender value])]; break;
        case GPUIMAGE_TRANSFORM3D:
        {
            CATransform3D perspectiveTransform = CATransform3DIdentity;
            perspectiveTransform.m34 = 0.4;
            perspectiveTransform.m33 = 0.4;
            perspectiveTransform = CATransform3DScale(perspectiveTransform, 0.75, 0.75, 0.75);
            perspectiveTransform = CATransform3DRotate(perspectiveTransform, [(TVCalibratedSliderForInteger*)sender value], 0.0, 1.0, 0.0);
            
            [(GPUImageTransformFilter *)filter setTransform3D:perspectiveTransform];
        }; break;
        case GPUIMAGE_SPHEREREFRACTION: [(GPUImageSphereRefractionFilter *)filter setRadius:[(TVCalibratedSliderForInteger *)sender value]]; break;
        case GPUIMAGE_GAMMA: [(GPUImageGammaFilter *)filter setGamma:[(TVCalibratedSliderForInteger *)sender value]]; break;
        case GPUIMAGE_GAUSSIAN_SELECTIVE: [(GPUImageGaussianSelectiveBlurFilter *)filter setExcludeCircleRadius:[(TVCalibratedSliderForInteger*)sender value]]; break;
        case GPUIMAGE_THRESHOLDSKETCH: [(GPUImageThresholdSketchFilter *)filter setThreshold:[(TVCalibratedSliderForInteger *)sender value]]; break;
        case GPUIMAGE_GLASSSPHERE: [(GPUImageGlassSphereFilter *)filter setRadius:[(TVCalibratedSliderForInteger *)sender value]]; break;
        default: break;
    }

    
}

/*!
 @method save2AlbumButtonClicked
 @abstract It is store image in iphone album.
 @discussion It is store image in iphone album.
 @result User can see our app image in photo library.
 */
-(void)save2AlbumButtonClicked
{
    ALAssetsLibrary* library = [[ALAssetsLibrary alloc] init];
    [library saveImage:Imageforanimation toAlbum:@"Camcoder" withCompletionBlock:^(NSError *error) {
        NSString *message;
        NSString *title;
        if (!error) {
            title = NSLocalizedString(@"Message", @"");
            message = NSLocalizedString(@"Image save successfully", @"");
            NSLog(@"Image save successfully");
            [self HideActivityview];
            [library release];
        }
        else {
            NSLog(@"Error: %@ %@", error, [error userInfo]); 
            title = NSLocalizedString(@"Error", @"");
            message = NSLocalizedString(@"Image is not save", @"");
             NSLog(@"Image is not save");
        }
        
    }];
    
}
/*!
 @method      imageFromMovie
 @param1      It will be pass current movie url.
 @param1      It will be pass current movie time.
 @abstract    It is a Method to create thumbnail from url.
 @discussion  For animation process user want thumbnail image for video.
 @result      This method is given thumbnail image from video url.
 */
- (UIImage *)imageFromMovie:(NSURL *)movieURL1 atTime:(NSTimeInterval)time {
    // set up the movie player
    MPMoviePlayerController *mp = [[MPMoviePlayerController alloc]
                                   initWithContentURL:movieURL1];
    mp.shouldAutoplay = NO;
    mp.initialPlaybackTime = time;
    mp.currentPlaybackTime = time;
    // get the thumbnail
    UIImage *thumbnail = [mp thumbnailImageAtTime:time
                                       timeOption:MPMovieTimeOptionNearestKeyFrame];
    // clean up the movie player
    [mp stop];
    [mp release];
    return(thumbnail);
}

/*!
 @method      getThumbnailImageOfHouse
 @abstract    It is a Method to create thumbnail from image.
 @discussion  Create thumbnail from actual image capture.
 @result      This method is given thumbnail image from actual image.
 */
- (UIImage *)getThumbnailImageOfHouse {
    
    CGSize destinationSize = CGSizeMake(100, 100);
    
    UIGraphicsBeginImageContext(destinationSize);
    [Imageforanimation drawInRect:CGRectMake(0,0,destinationSize.width,destinationSize.height)];
    UIImage *newImageResized = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImageResized;
}
/*!
 @method      CheckIphone5
 @abstract    It is a Method to check device.
 @discussion  This method check what is actually version of user device.
 @result     This method check what is actually version of user device and return bool value yes or no.
 */
- (BOOL)CheckIphone5
{
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone){
        if ([[UIScreen mainScreen] respondsToSelector: @selector(scale)]) {
            CGSize result = [[UIScreen mainScreen] bounds].size;
            CGFloat scale = [UIScreen mainScreen].scale;
            result = CGSizeMake(result.width * scale, result.height * scale);
            
            if(result.height == 960) {
                return NO;
                
            }
            if(result.height == 1136) {
                return YES;
            }
        }
        else{
            //NSLog(@"Standard Resolution");
        }
    }
    return NO;
}
/*!
 @method      AddLableinAboutus
 @abstract    It is a Method to add three different label accroding to device version.
 @discussion  This method add three different label accroding to device version and with glow effect.
 @result      This method add three different label accroding to device version and with glow effect.
 */
-(void)AddLableinAboutus
{
    UILabel *lblCodedname,*lblDesignname,*lblGuidename,*lblCopyright,*lblUnderline;
    BOOL _flag = [self CheckIphone5];
    if (_flag)
    {
        lblCodedname=[[UILabel alloc] initWithFrame:CGRectMake(108,325,100,15)];
        lblDesignname=[[UILabel alloc] initWithFrame:CGRectMake(15,325,100,15)];
        lblGuidename=[[UILabel alloc] initWithFrame:CGRectMake(203,325,110,15)];
        lblCopyright=[[UILabel alloc] initWithFrame:CGRectMake(175,360,150,15)];
        lblUnderline=[[UILabel alloc] initWithFrame:CGRectMake(175,370,150,15)];
    }
    else
    {
        lblCodedname=[[UILabel alloc] initWithFrame:CGRectMake(108,315,100,15)];
        lblDesignname=[[UILabel alloc] initWithFrame:CGRectMake(15,315,100,15)];
        lblGuidename=[[UILabel alloc] initWithFrame:CGRectMake(203,315,110,15)];
        lblCopyright=[[UILabel alloc] initWithFrame:CGRectMake(175,360,150,15)];
        lblUnderline=[[UILabel alloc] initWithFrame:CGRectMake(175,370,150,15)];
    }
    
    UIColor *color = [UIColor colorWithRed:3/255.0f green:190/255.0f blue:251/255.0f alpha:1.0];
    lblCodedname.layer.shadowColor = [color CGColor];
    lblCodedname.layer.shadowRadius = 4.0f;
    lblCodedname.layer.shadowOpacity = .9;
    lblCodedname.layer.shadowOffset = CGSizeZero;
    lblCodedname.layer.masksToBounds = NO;
    lblCodedname.font = [UIFont fontWithName:@"DS-Digital-BoldItalic" size:16.0];
    lblCodedname.textColor=[UIColor colorWithRed:3/255.0f green:190/255.0f blue:251/255.0f alpha:1.0];
    lblCodedname.textAlignment = UITextAlignmentCenter;
    lblCodedname.backgroundColor=[UIColor clearColor];
    lblCodedname.text = @"Nikunj Modi";
    [AboutusView addSubview:lblCodedname];
    [lblCodedname release];
    
    lblDesignname.layer.shadowColor = [color CGColor];
    lblDesignname.layer.shadowRadius = 4.0f;
    lblDesignname.layer.shadowOpacity = .9;
    lblDesignname.layer.shadowOffset = CGSizeZero;
    lblDesignname.layer.masksToBounds = NO;
    lblDesignname.font = [UIFont fontWithName:@"DS-Digital-BoldItalic" size:16.0];
    lblDesignname.textColor=[UIColor colorWithRed:3/255.0f green:190/255.0f blue:251/255.0f alpha:1.0];
    lblDesignname.textAlignment = UITextAlignmentCenter;
    lblDesignname.backgroundColor=[UIColor clearColor];
    lblDesignname.text = @"Nirav Mistri";
    [AboutusView addSubview:lblDesignname];
    [lblDesignname release];

    lblGuidename.layer.shadowColor = [color CGColor];
    lblGuidename.layer.shadowRadius = 4.0f;
    lblGuidename.layer.shadowOpacity = .9;
    lblGuidename.layer.shadowOffset = CGSizeZero;
    lblGuidename.layer.masksToBounds = NO;
    lblGuidename.font = [UIFont fontWithName:@"DS-Digital-BoldItalic" size:16.0];
    lblGuidename.textColor=[UIColor colorWithRed:3/255.0f green:190/255.0f blue:251/255.0f alpha:1.0];
    lblGuidename.textAlignment = UITextAlignmentCenter;
    lblGuidename.backgroundColor=[UIColor clearColor];
    lblGuidename.text = @"Sanjeev Dutta";
    [AboutusView addSubview:lblGuidename];
    [lblGuidename release];
    
    lblCopyright.layer.shadowColor = [color CGColor];
    lblCopyright.layer.shadowRadius = 4.0f;
    lblCopyright.layer.shadowOpacity = .9;
    lblCopyright.layer.shadowOffset = CGSizeZero;
    lblCopyright.layer.masksToBounds = NO;
    lblCopyright.font = [UIFont fontWithName:@"DS-Digital-BoldItalic" size:12.0];
    lblCopyright.textColor=[UIColor colorWithRed:3/255.0f green:190/255.0f blue:251/255.0f alpha:1.0];
    lblCopyright.textAlignment = UITextAlignmentCenter;
    lblCopyright.backgroundColor=[UIColor clearColor];
    lblCopyright.text = @"copyright & disclaimer";
    lblCopyright.tag = 8000;
    [AboutusView addSubview:lblCopyright];
    [lblCopyright release];
    
    lblUnderline.layer.shadowColor = [color CGColor];
    lblUnderline.layer.shadowRadius = 4.0f;
    lblUnderline.layer.shadowOpacity = .9;
    lblUnderline.layer.shadowOffset = CGSizeZero;
    lblUnderline.layer.masksToBounds = NO;
    lblUnderline.font = [UIFont fontWithName:@"DS-Digital-BoldItalic" size:12.0];
    lblUnderline.textColor=[UIColor colorWithRed:3/255.0f green:190/255.0f blue:251/255.0f alpha:1.0];
    lblUnderline.textAlignment = UITextAlignmentCenter;
    lblUnderline.backgroundColor=[UIColor clearColor];
    lblUnderline.text = @"----------------------";
    lblUnderline.tag = 8001;
    [AboutusView addSubview:lblUnderline];
    [lblUnderline release];
    
    UIButton * button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(175,360,150,18);
    [button addTarget:self
               action:@selector(CopyrightClick:)
     forControlEvents:UIControlEventTouchUpInside];
    button.selected = NO;
    [AboutusView addSubview:button];
    //[self.view addSubview:AboutusView];
}
-(void)CopyrightClick:(UIButton *)sender
{
    if (sender.selected)
    {
        Copyright.hidden = YES;
        txtvCopyright.hidden = YES;
        UILabel *_templable = (UILabel *)[AboutusView viewWithTag:8000];
        _templable.text = @"copyright & disclaimer";
        UILabel *_templableunderline = (UILabel *)[AboutusView viewWithTag:8001];
        _templableunderline.text = @"----------------------";

    }
    else
    {
        Copyright.hidden = NO;
        txtvCopyright.hidden = NO;
        UILabel *_templable = (UILabel *)[AboutusView viewWithTag:8000];
        _templable.text = @"About Us";
        UILabel *_templableunderline = (UILabel *)[AboutusView viewWithTag:8001];
        _templableunderline.text = @"----------";

    }
    sender.selected = !sender.selected;
}

-(void)StartCameraObject
{
    if (CameraMode)
    {
        [NSThread sleepForTimeInterval:1];
        [stillCamera startCameraCapture];
    }
    else
    {
        [NSThread sleepForTimeInterval:1];
        [videoCamera startCameraCapture];
    }
}
#pragma mark Animation view methods

/*!
 @method      Slideupview
 @abstract    It is a Method for slide up view and play sound
 @discussion  slide up drawer view method and also play drawer open sound.
 @result      slide up drawer view method and also play drawer open sound.
 */
-(void) Slideupview
{
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:.8];
    NSURL *url = [NSURL fileURLWithPath:[[NSBundle mainBundle]
                                         pathForResource:@"SlideScifi"
                                         ofType:@"wav"]];
    
    NSError *error;
    AVAudioPlayer *audioPlayer = [[AVAudioPlayer alloc]
                   initWithContentsOfURL:url
                   error:&error];
    if (error)
    {
        NSLog(@"Error in audioPlayer: %@",
              [error localizedDescription]);
    } else {
        audioPlayer.delegate = self;
        [audioPlayer prepareToPlay];
    }
    [audioPlayer play];
    BOOL _flag = [self CheckIphone5];
    if (_flag)
    {
        [FilterTable setFrame:CGRectMake(0,40,80,476)];
    }
    else
    {
        [FilterTable setFrame:CGRectMake(0,40,80,385)];
    }
    [UIView commitAnimations];
}
/*!
 @method      Slidedownview
 @abstract    It is a Method for slide down view and play sound
 @discussion  slide down drawer view method and also play drawer close sound.
 @result      slide down drawer view method and also play drawer close sound.
 */
-(void) Slidedownview
{
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:.8];
    NSURL *url = [NSURL fileURLWithPath:[[NSBundle mainBundle]
                                         pathForResource:@"SlideSound"
                                         ofType:@"wav"]];
    
    NSError *error;
    AVAudioPlayer *audioPlayer = [[AVAudioPlayer alloc]
                   initWithContentsOfURL:url
                   error:&error];
    if (error)
    {
        NSLog(@"Error in audioPlayer: %@",
              [error localizedDescription]);
    } else {
        audioPlayer.delegate = self;
        [audioPlayer prepareToPlay];
    }
    [audioPlayer play];
    [FilterTable setFrame:CGRectMake(0,520,80,476)];
    // Move footer on screen
    [UIView commitAnimations];
    for (int i = 0;i<GPUIMAGE_NUMFILTERS-1;i++)
    {
        UITableViewCell *cell = (UITableViewCell *)[FilterTable viewWithTag:i];
        UIButton *_btntemp = (UIButton *)[cell viewWithTag:i+1000];
        TVCalibratedSliderForInteger *_TempSlider = (TVCalibratedSliderForInteger *)[cell viewWithTag:i+2000];
            _TempSlider.hidden = YES;
        UIImage* image2 = [[UIImage imageNamed:@"overlay_button.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(18, 18, 18, 18)];
        
        [_btntemp setBackgroundImage:image2 forState:UIControlStateNormal];
        [_btntemp setBackgroundImage:image2 forState:UIControlStateHighlighted];
        _btntemp.frame = CGRectMake(6,4, 62, 32);
        UIImageView *_TempImg = (UIImageView *)[cell viewWithTag:i+500];
        _TempImg.frame = CGRectMake(25,8, 24.0,24.0);
        _btntemp.selected = YES;
    }
    PreviousFilterOption = 9999;
    FilterOption = 0;
}
/*!
 @method      AnimationForStorephotogallery
 @abstract    It is a Method animate thumbnail image drop down into photo library. 
 @discussion  It is a Method animate thumbnail image drop down into photo library.
 @result      It is a Method animate thumbnail image drop down into photo library.
 */
-(void)AnimationForStorephotogallery
{
    // create new duplicate image
    //NSLog(@"%@",[Imageforanimation description]);
    UIImageView *starView;
    if (CameraMode)
    {
        starView = [[UIImageView alloc] initWithImage:[self getThumbnailImageOfHouse]];
    }
    else
    {
        starView = [[UIImageView alloc] initWithImage:[self imageFromMovie:movieURL atTime:0.5]];
    }
	
    [starView setFrame:CGRectMake(160,200,100,100)];
	starView.layer.cornerRadius=5;
	starView.layer.borderColor=[[UIColor blackColor]CGColor];
	starView.layer.borderWidth=1;
    [self.view addSubview:starView];
	
	// begin ---- apply position animation
	CAKeyframeAnimation *pathAnimation = [CAKeyframeAnimation animationWithKeyPath:@"position"];
    pathAnimation.calculationMode = kCAAnimationPaced;
    pathAnimation.fillMode = kCAFillModeForwards;
    pathAnimation.removedOnCompletion = NO;
    pathAnimation.duration=0.65;
	pathAnimation.delegate=self;
	CGPoint endPoint;
	// tab-bar right side item frame-point = end point
    BOOL _flag = [self CheckIphone5];
    if (_flag)
    {
        endPoint = CGPointMake(75,470);
    }
    else
    {
        endPoint = CGPointMake(75,430);
    }
	//NSLog(@"rect is %f,%f",endPoint.x,endPoint.y);
    
	CGMutablePathRef curvedPath = CGPathCreateMutable();
    CGPathMoveToPoint(curvedPath, NULL, starView.frame.origin.x, starView.frame.origin.y);
    CGPathAddCurveToPoint(curvedPath, NULL, endPoint.x, starView.frame.origin.y, endPoint.x, starView.frame.origin.y, endPoint.x, endPoint.y);
    pathAnimation.path = curvedPath;
    CGPathRelease(curvedPath);
	// end ---- apply position animation
	
	// apply transform animation
	CABasicAnimation *basic=[CABasicAnimation animationWithKeyPath:@"transform"];
	[basic setToValue:[NSValue valueWithCATransform3D:CATransform3DMakeScale(0.25, 0.25, 0.25)]];
	[basic setAutoreverses:NO];
	[basic setDuration:0.80];
	
	[starView.layer addAnimation:pathAnimation forKey:@"curveAnimation"];
	[starView.layer addAnimation:basic forKey:@"transform"];
	
    BOOL flag = [self CheckIphone5];
    if (flag)
    {
        if (CameraMode)
        {
            [starView performSelector:@selector(removeFromSuperview) withObject:nil afterDelay:0.90];
        }
        else
        {
            [starView performSelector:@selector(removeFromSuperview) withObject:nil afterDelay:0.70];
        }
    }
    else
    {
        
        [starView performSelector:@selector(removeFromSuperview) withObject:nil afterDelay:0.70];
        
    }
    [starView release];
    
    if (CameraMode)
    {
        [stillCamera stopCameraCapture];
        staticPicture = nil;
        [Imageforanimation release];
        
        filter = nil;
        [self removeAllTargets];
        [stillCamera performSelector:@selector(startCameraCapture) withObject:nil afterDelay:0.65];
        //[stillCamera startCameraCapture];
        if (!filter)
        {
            [self setupFilter];
        }
        [self prepareFilter];
    }
    else
    {
        filter = nil;
        [self removeAllTargets];
        if (!filter)
        {
            [self setupFilter];
        }
        [self prepareFilter];
    }
    
    Imageforanimation = nil;
}
/*!
 @method      ADDActivityIndicatorview
 @abstract    It is a Method set corner radius for activity indicator view.
 @discussion  It is a Method set corner radius for activity indicator view.
 @result      It is a Method set corner radius for activity indicator view.
 */
-(void)ADDActivityIndicatorview
{
    ActivityInnerView.layer.cornerRadius = 5.0f;
}
/*!
 @method      ShowActivityview
 @abstract    It is a Method add activity indicator on window and set animation.
 @discussion  It is a Method add activity indicator on window and set animation.
 @result      It is a Method add activity indicator on window and set animation.
 */
-(void)ShowActivityview
{
    [ActivityMainView setAlpha:1.0];
    [[[self view] window] addSubview:ActivityMainView];
    [Act startAnimating];
}
/*!
 @method      ShowActivityview
 @abstract    It is a Method remove activity indicator from window and stop animation.
 @discussion  It is a Method remove activity indicator from window and stop animation.
 @result      It is a Method remove activity indicator from window and stop animation.
 */
-(void)HideActivityview
{
    NSLog(@"Hide");
    [Act stopAnimating];
    [ActivityMainView setAlpha:0.0f];
    [ActivityMainView removeFromSuperview];
    [self AnimationForStorephotogallery];
    //[NSThread detachNewThreadSelector:@selector(AnimationForStorephotogallery) toTarget:self withObject:nil];
}
/*!
 @method      ShowActivityview
 @abstract    It is a Method remove activity indicator from window and stop animation.
 @discussion  It is a Method remove activity indicator from window and stop animation.
 @result      It is a Method remove activity indicator from window and stop animation.
 */
-(void)HideActivityviewforchange
{
    NSLog(@"Hide");
    [Act stopAnimating];
    [ActivityMainView setAlpha:0.0f];
    [ActivityMainView removeFromSuperview];
}
/*!
 @method      SliderOpen
 @param1      It will be pass current slider object.       
 @abstract    It is a Method for slide open filter option view.
 @discussion  slide open filter option view method.
 @result      slide open filter option view method.
 */
-(void) SliderOpen:(UIButton *)sender
{
    if (sender.tag-1000!= GPUIMAGE_CGA && sender.tag-1000 !=GPUIMAGE_CUSTOM && sender.tag-1000!=GPUIMAGE_SKETCH && sender.tag-1000 != GPUIMAGE_TOON && sender.tag-1000 != GPUIMAGE_FALSECOLOR && sender.tag-1000 != GPUIMAGE_COLORINVERT)
    {
        UITableViewCell *cell = (UITableViewCell *)[FilterTable viewWithTag:sender.tag-1000];
        
        [UIView animateWithDuration:0.5f // This can be changed.
                         animations:^{
                             
                             BOOL _flag = [self CheckIphone5];
                             if (_flag)
                             {
                                 [FilterTable setFrame:CGRectMake(0,40,320,476)];
                             }
                             else
                             {
                                 [FilterTable setFrame:CGRectMake(0,40,320,385)];
                             }
                             UIImage* image2 = [[UIImage imageNamed:@"overlay_button.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(18, 18, 18, 18)];
                             
                             [sender setBackgroundImage:image2 forState:UIControlStateNormal];
                             [sender setBackgroundImage:image2 forState:UIControlStateHighlighted];
                             sender.frame = CGRectMake(sender.frame.origin.x,sender.frame.origin.y, 300.0, image2.size.height);
                             
                             UIImageView *_TempImg = (UIImageView *)[cell viewWithTag:sender.tag-500];
                             _TempImg.frame = CGRectMake(260,8, 24.0,24.0);
                             [_TempImg setImage:[UIImage imageNamed:[NSString stringWithFormat:@"%i_h.png",sender.tag-1000]]];
                             FilterOption++;
                             image2 = nil;
                         }
                         completion:^(BOOL finished){
                             TVCalibratedSliderForInteger *_TempSlider = (TVCalibratedSliderForInteger *)[cell viewWithTag:sender.tag+1000];
                             _TempSlider.hidden = NO;
                             FilterFlag = 0;
                             FilterTable.userInteractionEnabled = YES;
                         }];
        [UIView commitAnimations];
        //FilterTable.userInteractionEnabled = YES;
    }else{
        FilterFlag = 0;
        FilterTable.userInteractionEnabled = YES;
    }
}
/*!
 @method      SliderClose
 @abstract    IIt is a Method for slide close filter option view.
 @discussion  slide close filter option view method.
 @result      slide close filter option view method.
 */
-(void) SliderClose:(UIButton *)sender
{
    if (sender.tag-1000!= GPUIMAGE_CGA && sender.tag-1000 !=GPUIMAGE_CUSTOM && sender.tag-1000!=GPUIMAGE_SKETCH && sender.tag-1000 != GPUIMAGE_TOON && sender.tag-1000 != GPUIMAGE_FALSECOLOR && sender.tag-1000 != GPUIMAGE_COLORINVERT)
    {
        UITableViewCell *cell = (UITableViewCell *)[FilterTable viewWithTag:sender.tag-1000];
        TVCalibratedSliderForInteger *_TempSlider = (TVCalibratedSliderForInteger *)[cell viewWithTag:cell.tag+2000];
        _TempSlider.hidden = YES;
        NSLog(@"%@",[_TempSlider description]);
        [UIView animateWithDuration:0.5f // This can be changed.
                         animations:^{
                             UIImage* image2 = [[UIImage imageNamed:@"overlay_button.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(18, 18, 18, 18)];
                             
                             [sender setBackgroundImage:image2 forState:UIControlStateNormal];
                             [sender setBackgroundImage:image2 forState:UIControlStateHighlighted];
                             sender.frame = CGRectMake(6,4, 62, 32);
                             UIImageView *_TempImg = (UIImageView *)[cell viewWithTag:sender.tag-500];
                             _TempImg.frame = CGRectMake(25,8, 24.0f, 24.0f);
                             [_TempImg setImage:[UIImage imageNamed:[NSString stringWithFormat:@"%i.png",sender.tag-1000]]];
                             FilterOption--;
                             image2 = nil;
                         }
                         completion:^(BOOL finished){
                             BOOL _flag = [self CheckIphone5];
                             if (_flag)
                             {
                                 if (FilterOption == 0)
                                 {
                                     [FilterTable setFrame:CGRectMake(0,40,80,476)];
                                 }
                             }
                             else
                             {
                                 if (FilterOption == 0)
                                 {
                                     [FilterTable setFrame:CGRectMake(0,40,80,385)];
                                 }
                             }
                         }];
        [UIView commitAnimations];
    }
}
@end
