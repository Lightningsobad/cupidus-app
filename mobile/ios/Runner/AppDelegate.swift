import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)

    // REQ-016 STORY-003 P2 / AC-9. Android excludes the journal from Auto
    // Backup declaratively (res/xml/backup_rules.xml); iOS has no manifest
    // equivalent, so each directory must be tagged at runtime with
    // URLResourceValues.isExcludedFromBackup. Application Support is backed up
    // by default, and the tag is lost when a directory is deleted and
    // recreated, so JournalMediaStore calls this on every directory it
    // creates rather than a one-time setup step here.
    // Doc: https://developer.apple.com/documentation/foundation/urlresourcevalues/isexcludedfrombackup
    if let registrar = engineBridge.pluginRegistry.registrar(forPlugin: "CupidBackupExclusion") {
      let channel = FlutterMethodChannel(
        name: "com.snapsofts.cupid/backup_exclusion",
        binaryMessenger: registrar.messenger()
      )
      channel.setMethodCallHandler { call, result in
        guard call.method == "excludeFromBackup" else {
          result(FlutterMethodNotImplemented)
          return
        }
        guard let path = call.arguments as? String else {
          result(
            FlutterError(
              code: "invalid_argument",
              message: "excludeFromBackup expects a file system path",
              details: nil
            )
          )
          return
        }
        var url = URL(fileURLWithPath: path)
        var values = URLResourceValues()
        values.isExcludedFromBackup = true
        do {
          try url.setResourceValues(values)
          result(nil)
        } catch {
          result(
            FlutterError(
              code: "exclude_failed",
              message: error.localizedDescription,
              details: path
            )
          )
        }
      }
    }
  }
}
