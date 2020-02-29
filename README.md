# accuterra-ios-samples
Sample apps for iOS built with the AccuTerra SDK

These sample apps are provided to demonstrate the capabilities of the AccuTerra Maps SDK. 

To run these apps, you will need Cocoapods installed. See the instructions here for more [details](https://sdk.accuterra.com/develop/ios-sdk-home/ios-getting-started/) if you need help with Cocoapods. Otherwise, follow these steps:

1. Clone the repo
2. In a terminal, "cd" to the directory containing the sample of interest. This will contain the project file, workspace, and Podfile
3. Type the following Cocoapods command:
```
pod install
```
4. Open the workspace file (not the project file)
5. Obtain access tokens from NeoTreks to run the sample applications
5. Replace the values for the AccuTerraClientToken and the AccuTerraMapToken in the info.plist file
6. Lauch the target application and you should see the demostrated functionality.

Access tokens to run the apps are required and maybe be obtained from [NeoTreks.com](mailto:austin@neotreks.com) and more information is available at the [AccuTerra Maps SDK website](http://sdk.accuterra.com).
