import Foundation
import Photos

@objc(Photos)
public class Photos : AVCPlugin {
  static let DEFAULT_QUANTITY = 25
  static let DEFAULT_TYPES = "photos"
  
  func fetchResultAssetsToJs(_ result: PHFetchResult<PHAsset>) -> [String:Any] {
    var ret = [String:Any]()
    
    result.enumerateObjects { (asset, count: Int, stop: UnsafeMutablePointer<ObjCBool>) in
      print("Got asset item", asset, count)
    }
    
    return ret
  }
  
  
  @objc func getPhotos(_ call: AVCPluginCall) {
    let quantity = call.getInt("quantity", defaultValue: Photos.DEFAULT_QUANTITY)!
    let after = call.getString("after")
    let types = call.getString("types") ?? Photos.DEFAULT_TYPES
  
    checkAuthorization(call) {
      var fetchResult: PHFetchResult<PHAsset>!
      let options = PHFetchOptions()
      options.fetchLimit = quantity
      options.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: true)]
      fetchResult = PHAsset.fetchAssets(with: options)
      
      let photos = self.fetchResultAssetsToJs(fetchResult)
      
      call.success([
        "photos": photos
      ])
    }

  }
  
  @objc func saveToPhotos(_ call: AVCPluginCall) {
    guard let path = call.getString("path") else {
      call.error("Must provide a path")
      return
    }
  }

  func checkAuthorization(_ call: AVCPluginCall, _ processBlock: @escaping () -> Void) {
    let status = PHPhotoLibrary.authorizationStatus()
    if status == PHAuthorizationStatus.authorized {
      processBlock()
    } else {
      PHPhotoLibrary.requestAuthorization({ (newStatus) in
        if newStatus == PHAuthorizationStatus.authorized {
          processBlock()
        } else {
          call.error("User denied access")
        }
      })
    }
  }
}

