/**
 
 ClassName:: ALAssetsLibrary
 
 Class Description:: ALAssetsLibrary category to handle a custom photo album.
 
 Version:: 1.0
 
 Author:: Nikunj Modi
 
 Created Date:: 18/09/12.
 
 */

#import <Foundation/Foundation.h>
#import <AssetsLibrary/AssetsLibrary.h>

typedef void(^SaveImageCompletion)(NSError* error);

@interface ALAssetsLibrary(CustomPhotoAlbum)

-(void)saveImage:(UIImage*)image toAlbum:(NSString*)albumName withCompletionBlock:(SaveImageCompletion)completionBlock;
-(void)addAssetURL:(NSURL*)assetURL toAlbum:(NSString*)albumName withCompletionBlock:(SaveImageCompletion)completionBlock;

- (void)saveVideo:(NSURL *)videoUrl toAlbum:(NSString *)albumName
withCompletionBlock:(SaveImageCompletion)completionBlock;
@end