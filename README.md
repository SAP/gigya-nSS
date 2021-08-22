# SAP CDC (Gigya) Native Screen Sets
[![REUSE status](https://api.reuse.software/badge/github.com/SAP/gigya-nSS)](https://api.reuse.software/info/github.com/SAP/gigya-nSS)


[![REUSE status](https://api.reuse.software/badge/github.com/SAP/gigya-nSS)](https://api.reuse.software/info/github.com/SAP/gigya-nSS)

## Description
Native Screen-Sets allow your app to maintain the native experience while enjoying the benefits of SAP Customer Data Cloud web Screen-Sets.
 It is a low-code solution for delivering a highly customizable user interface for a consistent user experience.

## Overview

Native Screen-Sets allow your app to maintain the native experience while enjoying the benefits of SAP Customer Data Cloud web Screen-Sets. It is a low-code solution for delivering a highly customizable user interface for a consistent user experience.

While web Screen-Sets are rendered based on an extended version of HTML, Native Screen-Sets are rendered based on a single JSON object.

When designing login, registration and profile update flows for mobile apps, these flows are not only functional but can also as enrich the user's
experience in the app itself.

To support Native Screen-Sets, 3 SAP Customer Data Cloud libraries need to be implemented in your Android/iOS project:

**Core SDK** -  for supporting SAP Customer Data Cloud flows on Android & iOS.
**Native Screen-Sets library** -  Connecting the core SDK flows with the Native Screen-Sets engine.
**Native Screen-Sets engine** -  The engine that will parse the JSON and render the Native Screen-Sets (developed with Google's [Flutter](https://flutter.dev/) framework).

## Requirements

### iOS

```
SAP Customer Data Cloud iOS - Swift SDK v1.1 or above.
Apple iOS version 11 or above.
XCode version 11.4 or above.
```
### Android

```
SAP Customer Data Cloud Android SDK v 4.1 or above.
JAVA8 compatibility is required (update via the application's Gradle script).
MinSDK version 19 or above.
Android devices running on ARM processors only (99% of devices).
```

## Download and Installation

### iOS - Swift

The native screen-sets package is available via CocoaPods.
In order to add the Gigya Native Screen-Sets library via CocoaPods to your project, you need to create a specific target per configuration (Debug / Release).
Now add the following to you *pod* file:
```
// For Debug target:
pod 'GigyaNss'
// For Release target:
pod 'GigyaNssRelease'
```
So, your code should look similar to this:
```
target 'GigyaDemoApp-Debug' do
  pod 'Gigya'
  pod 'GigyaTfa'
  pod 'GigyaAuth'
  pod 'GigyaNss'
end
target 'GigyaDemoApp-Release' do
  pod 'Gigya'
  pod 'GigyaTfa'
  pod 'GigyaAuth'
  pod 'GigyaNssRelease'
end
```
Once you have completed the changes above, run the pod install command.

Now add the following line to your AppDelegate.swift class.

```swift
GigyaNss.shared.register(scheme: <YOUR_SCHEME>.self)
```

## Android

```
To avoid crashing non ARM devices. Please use the"isSupported()" method of the GigyaNss instance in order to determine if the
device can support this feature. Use the web Screen-Sets as a fallback in either Android or iOS.
```
The NSS engine requires your app to declare the following source compatibility in your application's build.gradle file:
```gradle
android {
  compileOptions {
    sourceCompatibility JavaVersion.VERSION_1_8
    targetCompatibility JavaVersion.VERSION_1_8
  }
}
```
Unzip the gigya-sdk-nss-engine.zip file and drag the folder to your root application folder.

In your project build.gradle file, add the following (this will allow the application to import the necessary Flutter dependencies and will link the NSS engine as a local reference).:
```gradle
allprojects {
  repositories {
    google()
    jcenter()
    mavenCentral()
    maven { url 'https://jitpack.io' }
    maven {
      url '../gigya-sdk-nss-engine/host/outputs/repo'
    }
    maven {
      url 'https://storage.googleapis.com/download.flutter.io'
    }
  }
}
```

Copy the following Android archive libraries into your application's /libs folder and add these references to your application's build.gradle file:
```gradle
// Referencing the NSS native library (via Jitpack)
implementation 'com.github.SAP.gigya-android-sdk:gigya-android-nss:nss-v1.2.0'
```
```gradle
// Referencing the NSS engine.
debugImplementation 'com.gigya.gigyaNativeScreensetsEngine:flutter_debug:1.2.0'
releaseImplementation 'com.gigya.gigyaNativeScreensetsEngine:flutter_release:1.2.0'
```

Finally, add the *NativeScreensetsActivity.class* reference to your application's *AndroidManifest.xml* file.

The NSS libraries are released as debug/release pairs. This is due to various build configurations in the Flutter framework that are builtto provide better performance definitions for debug/release builds.
```xml
<activity android:name="com.gigya.android.sdk.nss.NativeScreenSetsActivity" android:configChanges="orientation|keyboardHidden|keyboard|screenSize|loca le|layoutDirection|fontScale|screenLayout|density|uiMode" android:hardwareAccelerated="true" android:windowSoftInputMode="adjustResize" />
```

## Loading a screen-set

Loading a screen-set is available using hosted set or provided by an asset file.

#### iOS loading of the DEFAULT hosted screen-set

```swift
GigyaNss.shared
   .load(screenSetId: "DEFAULT")
   .lang(name: "en")
   .initialRoute(name: "login")
   .events(UserHost.self) { result in
      switch result {
      case .success(let screenId, let action, let account):
        // success
      case .error(let screenId, let error):
       // error
      case .canceled:
        // canceled
     }
   }
   .show(viewController: self)
```

#### Android loading of an asset screen-set file

```kotlin
GigyaNss.getInstance()
   .load("gigya-nss-example") // No need to add the .json suffix.
   .initialRoute("register")
   .events(object : NssEvents<MyAccount>() {
      override fun onError(screenId: String, error: GigyaError) {
         // Handle nss exception here.
         GigyaLogger.debug("NSS", "onError")
     }

     override fun onCancel() {
       // Handle nss cancel event if needed.
       GigyaLogger.debug("NSS", "onCancel")
     }

     override fun onScreenSuccess(screenId: String, action: String, accountObj: MyAccount) {
       // Handle login event here if needed.
       GigyaLogger.debug("NSS", "onSuccess for screen: $screenId and action: $action")
     }
  })
  .show(this)
```

## Introduction to the Native Screen-Set JSON Schema

In order for the Native Screen-Sets engine to interpret and display the customized screens, we provide a simple JSON based markup language pattern.

This will allow simple to complex UI designs that will grow and facilitate more and more customization tools that will help the application flows to be richer and easier to implement.
```
Default templates will be provided with each upcoming release in order to give clear reference points.
```
## The Root Schema

```json
{
  "routing": {
    "initial": "login",
    "default": {
      "onSuccess": "_dismiss"
    }
  },
  "screens": {
    
  }
}
```

### The Routing object

**Initial** - The screen ID that should be opened by default if not defined explicitly when showing the Native Screen-Sets.

**default** - The default routing object all screens will inherit from; see the screen component routing below.

### Screens

An object map of the Native Screen-Sets screen IDs to their screen component.

## [Components](https://github.com/SAP/gigya-nSS/blob/main/docs/COMPONENTS.md)

## [Styling](https://github.com/SAP/gigya-nSS/blob/main/docs/STYLING.md)

## Input validations

All input components support these two validation options:
 - required
 - regex

In order to apply validation please follow this example as reference:
Example for loginID email input with email regex validations.
```json
{
  "bind": "#loginID",
  "type": "emailInput",
  "textKey": "Email",
  "theme": "input",
  "validations": {
     "required": {
       "enabled": true,
       "errorKey": "This field is required."
    },
    "regex": {
       "enabled": true,
       "format": "^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\\.[a-zA-Z]+",
       "errorKey": "Invalid email format."
    }
  }
},
```

```
Error display value is declared in the "errorKey" string value.
```

```
The NSS engine is written in Dart. Dart regular expressions have the same syntax and semantics as JavaScript regular expressions.
See ecma-international.org/ecma-262/9.0/#sec-regexp-regular-expression-objects for the specification of JavaScript regular
expressions.
```


## Schema validations

Schema validation allows your markup fields to be automatically validated according to your site's schema parameters & custom validators (required/regex).

In order to use schema validation add the following to the root of your markup JSON file:
```
{
  "useSchemaValidations": true,
  "routing": {
    ...
   },
  "screens": {
      ...
  }
}
```
When setting the value to TRUE, the NSS engine will perform validations on all your schema related fields in order to assure the integrity of the data passed to the servers.

 - In the event of schema errors you will be notified with the following methods:
    - A visual error will be rendered on the screen instead of the component containing the binding error. This will occur only on DEBUG mode to avoid unwanted production issues.
    - An error log will be throttled to your main runner logs.

## Binding - In depth

When using component binding you will be required to distinguish between two field types:

 - Property field
    - This type is used to describe components (usually input/selection type components) that need to be bound to a specific parameter in order to perform endpoint operations.
        - Property fields are prefixed using a "#". The following example binds the "loginID" & "password" parameters in order to perform a login operation.
        
         ```
        Schema validations are irrelevant on property field types and you will be required to use markup Input validations.
         ```
```json
{
  "bind": "#loginID",
  "type": "emailInput",
  "textKey": "common-email",
  "theme": "input",
  "style": {
     "cornerRadius": 10,
     "borderSize": 1
  },
  {
   "bind": "#password",
   "type": "passwordInput",
   "textKey": "common-password",
   "theme": "input",
   "style": {
       "cornerRadius": 10,
       "borderSize": 1
   }
}
```

 - Schema field
    - This type is used to bind a specific schema field in order to allow the correct data to be displayed or updated accordingly.
    - The following example binds the "profile.lastName" & "profile.firstName" schema fields to allow the correct data to display & update.
```json
{
  "bind": "profile.lastName",
  "type": "textInput",
  "textKey": "common-last-name",
  "theme": "input"
},
{
  "bind": "profile.email",
  "type": "textInput",
  "textKey": "common-email",
  "theme": "input"
 },
```

The *sendAs* property is also available in order to extend the basic binding scheme.
For instance, if you would like to bind a specific value to an input field but send it as a different property on submission.
```json
{
    "type": "input"
    "bind": "profile.email"
    "saveAs": "loginID"
}
In this example the display will be bound to the *profile.email* field but on submission the parameter sent to the adjacent action
endpoint will be **loginID**.
```

## Evaluating expressions

Added in version 1.1.0 is the ability to conditionaly display a *container* according to a specific expression.
This pattern is useful in specifc flows in which you would like to display certain components according to available data or the actual data content.

To use this add the **showIf** property to your **container** and add an expression to evaluate the data.
```
Expression are written in JavaScript much like the web screen-sets feature
```

Here is an example:
```json
 {
   "type": "container",
   "showIf": "conflictingAccounts.loginProviders.includes('site')",
   "children": [
   ...
   ]
```
In this example (Accout linking) wea re evaluating if our conflicting accounts object contains the 'site' provider.
In this case the container will only be visible if the expression is true.

## Account linking

Account linking is a common flow when using a combination of social/site login providers.
In order to complete this flow without any additional coding you are able to use the **onLoginIdentifierExists** routing interruption.

Here is a complete example:

First add the interruption to your required markup screen.
In this case we chose the login screen.

```json
"login": {
      "routing": {
        "onPendingRegistration": "account-update",
        "onLoginIdentifierExists": "link-account",
        "onSuccess": "_dismiss"
      },
      ...
}
```

Next add your **link-account** screen markup implementation.
A detailed example is available in both SDK example applications (Android & iOS).

```
When a "onLoginIdentifierExists" interruption occurs, a specific **conflictingAccounts** object will be available for evaluation
within your **link-account** screen.
This object is a part of the core SDK. Please review it in order to familiarise with the object structure.
```

In the example implementation of the **link-account** screen we added two **conditionaly visible containers**
This in order to dynamically detect what kind of linking is required. Site or social.

```json
{
  "type": "container",
  "showIf": "conflictingAccounts.loginProviders.filter(p => p != 'site').length > 0",
  "children": [
       {
         "type": "socialLoginGrid",
         ...
       }
  ]
}
{
  "type": "container",
  "showIf": "conflictingAccounts.loginProviders.includes('site')",
   "children": [
   ...
   ]
}
```
Here each container uses the **showIf** conditional parameter in order to determine its visibility state.

The first condition idicates when there are social providers available for display within the **conflictingAccounts** object
And therefore will show a **socialLoginGrid* accordigly. Note that the **socialLoginGrid** is smart enough to decide what providers
are needed to be displayed when the **onflictingAccounts** object is available therefore you do not need to specifiy its providers manually.

The second condition idicates if the **conflictingAccounts** object contains a 'site' provider and therefore the user will be
required to link his account using his loginID/password combination.

```
No addition coding is needed. When linknig a social account the social componenets will take care of the linking process.
If liking to a 'site' provider, be sure to add a **submit** component in order to correctly sumbit the input data.
```

## Localization
In order to utilize the **"textKey"** property of each UI component, adding a localization key/value map is
available using the following format:
```json
{
    "i18n": {
         "_default": {
             "login": "Login"
         },
         "es": {
            "login": "Iniciar sesión"
         }
    }
}
```

## Multiple JSON file support for themes & localization
In order to keep the markup JSON file smaller and readable, splitting the theme & localization datas is available.
In order for multiple file support to work you will need to keep this format for all files.
```<markup-file-name>.theme.json for separate theme file.```
```<markup-file-name>.i18n.json for separate localization file.```
Here is an example of a theme file:
```json
{
  "primaryColor": "blue",
  "secondaryColor": "white",
  "textColor": "black",
  "enabledColor": "blue",
  "disabledColor": "grey",
  "errorColor": "red",
  "customTheme": {
    "title": {
      "fontWeight": "bold",
      "fontSize": 22
    },
    "subtitle": {
      "fontSize": 16,
      "fontWeight": 6
    }
  }
}
```
Here is an example of a localization file:
```json
{
  "_default": {
    "login": "Login"
  },
  "es": {
    "login": "Iniciar sesión"
  }
}
```

## Global error keys
The engine provides several global error keys which are customizable using the localization sections.

<u>Available keys:</u>
**error-schema-required-validation** for fields that can produce a *"required"* error.
**error-schema-regex-validation** for fields that can produce a *"regex" error.
**error-schema-checkbox-validation** for checkbox feilds which are required. 
**error-photo-failed-upload** for a failed profile photo upload.
**error-photo-image-size** for indicating that the profile photo image exceeds the size limit.

## Screen events
The NSS engine provides the ability to listen and interact with varius screen events.
Registring to these events is done in the native application using the NSS builder.

Android
```kotlin
GigyaNss.getInstance()...
    .eventsFor("login", object: NssScreenEvents() {
    
          override fun screenDidLoad() {
               // Screen loaded.
          }
          
          override fun routeFrom(screen: ScreenEventsModel) {
              screen.`continue`()
          }
          
          override fun routeTo(screen: ScreenEventsModel) {
              screen.`continue`()    
          }
          
          override fun submit(screen: ScreenEventsModel) {
              screen.`continue`()         
          }
          
          override fun fieldDidChange(screen: ScreenEventsModel, field: FieldEventModel) {
               when (field.id) {
                  "profile.zip" -> {
                    // Do some kind of validation.
                  }
                  else -> {
                     screen.`continue`()
                  }
               }           
          }
```

iOS
```swift
GigyaNss.shared...
        }.eventsFor(screen: "login", handler: { (event) in
            switch event {
            case .screenDidLoad:
                break
            case .routeFrom(screen: let screen):
                screen.continue()
            case .routeTo(screen: var screen):
                screen.continue()
            case .submit(var screen):
                screen.continue()
            case .fieldDidChange(let screen, let field):
                switch field.id {
                case "profile.zip":
                    // Do some kind of validation.
                    screen.showError("profile.zip is not valid")
                    // or
                    screen.continue()
                    break
                default:
                    screen.continue()
                }
                break
            }
```

### Available events:
**screenDidLoad** - Screen finished it's first load and is fully rendered.
**routeFrom** - Indicates the entry point of the current screen.
    You are able to mutate the data passed in the *screen* model.
**routeTo** - Indicates the expected route once screen submission is done.
    You are able to mutate both the data passed in the *screen* model and the *nextRoute* if needed.
**submit** - Exposes the submission data after the screen has been validated.
    You are able to mutate the submission data passed in the *screen* model.
    You are able to inject an error message to the screen.
**fieldDidChange** - Event triggered when an input component has changed its data.
    The field's identifier corresponds withe the **bind** property you have set in the markup.
    You are able to inject an error message to the screen.

**<u>Note</u>:**
**When overriding the *fieldDidChange* event you are required to use the *screen* model's *continue* method.**

**How to properly use NSS events:**
When you override a specific event you are able to use the provided *screen* model in order to evaluate or mutate its current
*data*. 

In order for the flow to be completed, when overriding the event, you must call the *continue* method on the *screen* model.
This will ensure that the connection to the engine will hang as it awaits your result.
Events such as *submit* and *fieldDidChange* also provide the option to inject an error to the screen using the *showError* method 
of the *screen* model.




## Known Issues

Native Screen-Sets engine versioning is still under development.

## How to obtain support
Via SAP standard support.
https://developers.gigya.com/display/GD/Opening+A+Support+Incident

## Contributing
Via pull request to this repository.

## Known Issues
iOS – Debugging is currently available only on simulators.

## Licensing
Please see our [LICENSE](https://github.com/SAP/gigya-nSS/blob/main/LICENSES/Apache-2.0.txt) for copyright and license information. Detailed information including third-party components and their licensing/copyright information is available [via the REUSE tool](https://api.reuse.software/info/github.com/SAP/gigya-nSS).
