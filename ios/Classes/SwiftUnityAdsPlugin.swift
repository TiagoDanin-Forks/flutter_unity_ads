import Flutter
import UnityAds

public class SwiftUnityAdsPlugin: NSObject, FlutterPlugin {
    
    static var viewController : UIViewController =  UIViewController();
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        viewController =
        (UIApplication.shared.delegate?.window??.rootViewController)!;
        let messenger = registrar.messenger()
        
        let placementChannels = [String: FlutterMethodChannel]()
        let channel = FlutterMethodChannel(name: UnityAdsConstants.MAIN_CHANNEL, binaryMessenger: messenger)
        let privacyConsent = PrivacyConsent()
        channel.setMethodCallHandler({
            (call: FlutterMethodCall, result: @escaping FlutterResult) -> Void in
            let args = call.arguments as! NSDictionary
            switch call.method {
            case UnityAdsConstants.INIT_METHOD:
                result(initialize(args, channel: channel))
            case UnityAdsConstants.LOAD_METHOD:
                result(load(args, messenger: messenger, placementChannels: placementChannels))
            case UnityAdsConstants.SHOW_VIDEO_METHOD:
                result(showVideo(args, messenger: messenger, placementChannels: placementChannels))
            case UnityAdsConstants.PRIVACY_CONSENT_SET_METHOD:
                result(privacyConsent.set(args))
            default:
                result(FlutterMethodNotImplemented)
            }
        })
        
        registrar.register(
            BannerAdFactory(messenger: messenger),
            withId: UnityAdsConstants.BANNER_AD_CHANNEL
        )
        
    }
    
    static func initialize(_ args: NSDictionary, channel: FlutterMethodChannel) -> Bool {
        let gameId = args[UnityAdsConstants.GAME_ID_PARAMETER] as! String
        let testMode = args[UnityAdsConstants.TEST_MODE_PARAMETER] as! Bool
        UnityAds.initialize(gameId, testMode: testMode, initializationDelegate: UnityAdsInitializationListener(channel: channel))
        return true
    }
    
    static func load(_ args: NSDictionary, messenger: FlutterBinaryMessenger, placementChannels: [String: FlutterMethodChannel]) -> Bool {
        let placementId = args[UnityAdsConstants.PLACEMENT_ID_PARAMETER] as! String
        UnityAds.load(placementId, loadDelegate: UnityAdsLoadListener(messenger: messenger, placementChannels: placementChannels))
        return true
    }
    
    static func showVideo(_ args: NSDictionary, messenger: FlutterBinaryMessenger, placementChannels: [String: FlutterMethodChannel]) -> Bool {
        let placementId = args[UnityAdsConstants.PLACEMENT_ID_PARAMETER] as! String
        let serverId = args[UnityAdsConstants.SERVER_ID_PARAMETER] as? String
        if (serverId != nil) {
            let playerMetaData = UADSPlayerMetaData()
            playerMetaData.setServerId(serverId)
            playerMetaData.commit()
        }
        UnityAds.show(viewController, placementId: placementId, showDelegate: UnityAdsShowListener(messenger: messenger, placementChannels: placementChannels))
        return true
    }
}
