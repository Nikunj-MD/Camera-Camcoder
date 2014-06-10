//
//  CamViewController.h
//  Camcoder
//
//  Created by Nikunj Modi on 19/12/12.
//  Copyright (c) 2012 Nikunj Modi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "GPUImage.h"
#import "HZActivityIndicatorView.h"
#import "NonRotatingUIImagePickerControllerViewController.h"
@class CamViewController;
typedef enum {
/*0*/GPUIMAGE_SHARPEN,
/*1*/GPUIMAGE_BRIGHTNESS,
/*2*/    GPUIMAGE_CONTRAST,
/*3*/    GPUIMAGE_EXPOSURE,
/*4*/    GPUIMAGE_WHITEBALANCE,
/*31*/    GPUIMAGE_TRANSFORM,
/*32*/    GPUIMAGE_TRANSFORM3D,
/*5*/    GPUIMAGE_SATURATION,
/*6*/    GPUIMAGE_RGB,
/*7*/    GPUIMAGE_HUE,
/*8*/    GPUIMAGE_SEPIA,
/*9*/    GPUIMAGE_PIXELLATE,
/*10*/    GPUIMAGE_SKETCH,
/*11*/    GPUIMAGE_THRESHOLDSKETCH,
/*12*/    GPUIMAGE_POSTERIZE,
/*13*/    GPUIMAGE_EMBOSS,
/*14*/    GPUIMAGE_SWIRL,
/*15*/    GPUIMAGE_TOON,
/*16*/    GPUIMAGE_SMOOTHTOON,
/*17*/    GPUIMAGE_MONOCHROME,
/*18*/    GPUIMAGE_FALSECOLOR,
/*19*/    GPUIMAGE_COLORINVERT,
/*20*/    GPUIMAGE_GRAYSCALE,
/*21*/    GPUIMAGE_TONECURVE,
/*22*/    GPUIMAGE_POLARPIXELLATE,
/*23*/    GPUIMAGE_POLKADOT,
/*24*/    GPUIMAGE_HALFTONE,
/*25*/    GPUIMAGE_CROSSHATCH,
/*26*/    GPUIMAGE_TILTSHIFT,
/*27*/    GPUIMAGE_VIGNETTE,
/*28*/    GPUIMAGE_BULGE,
/*29*/    GPUIMAGE_PINCH,
/*30*/    GPUIMAGE_GLASSSPHERE,
/*33*/    GPUIMAGE_CGA,
/*34*/    GPUIMAGE_SPHEREREFRACTION,
/*35*/    GPUIMAGE_GAMMA,
/*36*/    GPUIMAGE_GAUSSIAN_SELECTIVE,
/*37*/    GPUIMAGE_CUSTOM,
/*38*/    GPUIMAGE_MASK,
          GPUIMAGE_Carzy,
/*39*/    GPUIMAGE_NUMFILTERS
} GPUImageShowcaseFilterType;

@protocol CamcoderImagePickerDelegate <NSObject>
@optional
- (void)imagePickerController:(CamViewController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info;
- (void)imagePickerControllerDidCancel:(CamViewController *)picker;
@end


@interface CamViewController : UIViewController<GPUImageVideoCameraDelegate,UINavigationControllerDelegate,UIImagePickerControllerDelegate,UITableViewDelegate,AVAudioPlayerDelegate>
{
    GPUImageStillCamera *stillCamera;
    GPUImageVideoCamera *videoCamera;
    GPUImageMovieWriter *movieWriter;
    GPUImageOutput<GPUImageInput> *filter;
    GPUImagePicture *staticPicture;
    GPUImageShowcaseFilterType filterType;
    GPUImageAlphaBlendFilter *blendFilter;
    UIImageOrientation staticPictureOriginalOrientation;
    IBOutlet UIImageView *Defult,*aboutus,*Copyright;
    IBOutlet UIButton *btnVideoled,*btnCamera,*btnfilteroption,*btnphotolibrary;
    NSTimer *stopWatchTimer; // Store the timer that fires after a certain time
    NSDate *startDate; // Stores the date of the click on the start button
    int FilterOption;
    UIImage *Imageforanimation;
    NSURL *movieURL;
    int PreviousFilterOption;
    NonRotatingUIImagePickerControllerViewController *imagePicker;
    UIImage *inputImage;
    
}

@property (nonatomic, retain) IBOutlet GPUImageView *imageView;
@property (nonatomic, retain) id <CamcoderImagePickerDelegate> delegate;

@property (nonatomic, retain) IBOutlet UIButton *cameraToggleButton;
@property (nonatomic, retain) IBOutlet UIButton *flashToggleButton,*Homebutton;

@property (nonatomic, retain) IBOutlet UIImageView *filtersBackgroundImageView;

@property (nonatomic, retain) IBOutlet UIView *topBar;
@property (nonatomic, retain) IBOutlet UIView *ActivityMainView;
@property (nonatomic, retain) IBOutlet UIView *ActivityInnerView;
@property (nonatomic, retain) IBOutlet UIView *AboutusView;

@property (nonatomic, retain) IBOutlet UILabel *stopWatchLabel;
@property (nonatomic, retain) IBOutlet UIImageView *stopWatchImageView;

@property (nonatomic, assign) CGFloat outputJPEGQuality;

@property (unsafe_unretained, nonatomic) IBOutlet HZActivityIndicatorView *customIndicator;

@property (nonatomic,retain)IBOutlet UITableView *FilterTable;

@property (nonatomic, retain) IBOutlet UIActivityIndicatorView *Act;
@property (nonatomic, retain) IBOutlet UITextView *txtvCopyright;
- (IBAction)VideoStart_EndClick:(id)sender;
- (IBAction)ShowphotolibraryClick:(id)sender;
- (IBAction)ShowFilterOptionClick:(id)sender;
- (IBAction)HomeClick:(id)sender;
- (IBAction)AboutusClick:(id)sender;
- (BOOL)CheckIphone5;
- (void)AnimationForStorephotogallery;
- (UIImage *)imageFromMovie:(NSURL *)movieURL atTime:(NSTimeInterval)time;
-(void)StartCameraObject;
- (void)setupFilter;
@end
