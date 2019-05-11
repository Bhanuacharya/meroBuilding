#include "AppDelegate.h"
#include "GeneratedPluginRegistrant.h"
// Add the GoogleMaps import.
#import "GoogleMaps/GoogleMaps.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application
    didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
  // Add the following line with your API key.
  [GMSServices provideAPIKey:@"AIzaSyBjjVrpHnY5s0eYA5uqI0-HXhV11cOsQ4s"];
  [GeneratedPluginRegistrant registerWithRegistry:self];
  return [super application:application didFinishLaunchingWithOptions:launchOptions];
}
@end