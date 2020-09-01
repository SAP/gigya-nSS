# SAP CDC (Gigya) Native Screen Set

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

## Platform Requirements

### iOS

```
SAP Customer Data Cloud iOS - Swift SDK v1.1 or above.
Apple iOS version 11 or above.
XCode version 11.4 or above.
```
```
To receive the Native Screen-Sets binaries - please open a support ticket.
```

### Android

```
SAP Customer Data Cloud Android SDK v 4.1 or above.
JAVA8 compatibility is required (update via the application's Gradle script).
MinSDK version 16 or above.
Android devices running on ARM processors only (99% of devices).
```
## Integrating the Screen-Sets Engine

### iOS - Swift

Download the GigyaNss bundle.

Unzip and place the entire folder into your project folder.
```
It is important to place the downloaded bundle as is. Do not move files from the GigyaNss bundle, it will break the build.
```
In order to link the provided debug library:

Go to the "GigyaNss/Debug" folder. Drag both frameworks to the Project -> General -> Frameworks -> Libraries and Embedded Content.

Mark them as Embed & Sign.

Go to Build Settings -> Framework Search Paths and Update GigyaNss/Debug to GigyaNss/$(CONFIGURATION) in both available options (Debug & Release)
```
If your application contains a custom configuration, update the above code to support your configuration.
```
Go to Build Phases. Add new Run Script Phase (tap on "+" icon).

Open and then add the following:
```
bash
“${BUILT_PRODUCTS_DIR}/${FRAMEWORKS_FOLDER_PATH}/GigyaNss.framework/engine.sh” GigyaNss
```
Check the Run script only when installing option.
```
Make sure the new script is placed before the Remove unused architectures script that is required for the core SDK setup.
```

## Android

```
To avoid crashing non ARM devices. Please use the"isSupported()" method of the GigyaNss instance in order to determine if the
device can support this feature. Use the web Screen-Sets as a fallback in either Android or iOS.
```
The NSS engine requires your app to declare the following source compatibility in your application's build.gradle file:
```
android {
  compileOptions {
    sourceCompatibility JavaVersion.VERSION_1_8
    targetCompatibility JavaVersion.VERSION_1_8
  }
}
```
Unzip the gigya-sdk-nss-engine.zip file and drag the folder to your root application folder.

In your project build.gradle file, add the following (this will allow the application to import the necessary Flutter dependencies and will link the NSS engine as a local reference).:
```
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
```
// Referencing the NSS native library (via Jitpack)
implementation 'com.github.SAP.gigya-android-sdk:gigya-android-auth:nss-v1.0.0'
```
```
// Referencing the NSS engine.
debugImplementation 'com.gigya.nss.engine:flutter_debug:+'
releaseImplementation 'com.gigya.nss.engine:flutter_release:+'
```

Finally, add the *NativeScreensetsActivity.class* reference to your application's *AndroidManifest.xml* file.

The NSS libraries are released as debug/release pairs. This is due to various build configurations in the Flutter framework that are builtto provide better performance definitions for debug/release builds.
```
<activity android:name="com.gigya.android.sdk.nss.NativeScreenSetsActivity" android:configChanges="orientation|keyboardHidden|keyboard|screenSize|loca le|layoutDirection|fontScale|screenLayout|density|uiMode" android:hardwareAccelerated="true" android:windowSoftInputMode="adjustResize" />
```

## Enabling Native Screen-Sets

In order to start your Native Screen-Sets flow, you are required to provide the JSON file as an application asset (its structure and content will be
described in detail below).

**Android**
 - Add the file to your application's assets folder.

**iOS**
 - Add the file to your project (does not require special folder placement).

### iOS - Swift

Add the following line to your AppDelegate.swift class.
```
GigyaNss.shared.register(scheme: <YOUR_SCHEME>.self)
```

To start the NSS flow:
```
GigyaNss.shared
   .load(asset: "init")
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
```
Hosting and loading the NSS JSON from the SAP Customer Data Cloud Admin Console is not currently supported.
```

### Android

To start the Native Screen-Sets flow:
```
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

```
{
  "routing": {
     "initial": "login",
     "default": {
         "onSuccess": "_dismiss"
    }
  },
  "screens": {
       ...
  }
}
```

### Routing

**Initial**

 - The screen ID that should be opened by default if not defined explicitly when showing the Native Screen-Sets.

**Default**

 - The default routing object all screens will inherit from; see the screen component routing below.

### Screens

An object map of the Native Screen-Sets screen IDs to their screen component.

### Components

The Native Screen-Sets JSON is made from components starting from a collection of screens to the labels, inputs, etc., that are contained within them.

type
 - The type of the component.

textKey
 - The displayed content of the component.

bind
 - The path for the Account schema field's 2-way-binding, e.g., for displaying and/or editing the profile.firstName field.

#### screen

A screen component is the root of every displayed screen. It is defined by a unique <screen id> and can perform actions and route to another screen.
The screen component is a container component. It may contain children components that stack to create the desired UI. See the container component for more information.

 - appBar
   - Defines the bar at the top of the app.
 - action
   - The screen's target action from the following valid values: 
     - login
     - register
     - setAccount
   - The screen's action is invoked via the submit component.
   - The screen's action is invoked with the relevant bound values of the screen's child components. 
  - routing
    - By routing from one screen to another, you can use NSS to create a continuous flow of screens.
    - This routing object is made of entries in the following structure: "[event]": "[action]" 
      - event
        - If an event is not handled by the screen,
            - it will be handled according to the root's routing.default object;
            - If it is also not handled there, an error will be raised.
         - Valid values:
            - onSuccess
                - When the screen action ends successfully.
            - onPendingRegistration
                - When the screen action receives a pending registration error.
            - onPendingEmailVerification
                - When the screen action receives a pending verification error.
        - action
            - Can be either of the following:
                - <screen id>.
            - In order to route to the specified screen
                - _dismiss
                    - Dismisses (closes) the screen (usually used when a flow is completed).
                - _cancel
                    - Dismisses (closes) the screen (usually used to force termination of the screen-set flow before completion).
                    - invokes the onCancel event.
```json
"login-screen": {
   "routing": {
      "onSuccess": "account-screen"
   },
  "action": "login",
      "appBar": {
      "textKey": "login"
      },
     "stack": "vertical",
     "children": [
         ...
     ]
},
"account-screen": {
    "routing": {
       "onSuccess": "_dismiss"
    },
    "action": "setAccount",
    "appBar": {
        "textKey": "account info"
    },
    "stack": "horizontal",
    "children": [
        ...
    ]
}
```

#### submit

The submit component is a button for triggering the screen's action.
 - A single screen component can only have a single submit component.

```json
{
  "type": "submit",
  "textKey": "Submit"
}
```
#### container

A container component's role is to stack its child components horizontally or vertically.
```
The screen component extends the container component.
```
 - stack
    - Defines how children components are stacked.
    - Valid values are:
        - horizontal
        - vertical
 - alignment (optional)
    - Defines how the children components will align to each other within the directional stack.
    - Valid values are:
        - start (default) - Align all children components to the starting (main axis) point of the Container.
        - end - Align all children components to the ending point (main axis) of the Container.
        - center - Align all children components to the center position of the Container.
        - spread - Spread out all children components to the available positions, placing free space evenly between them.
        - equal_spacing - Place all children with even spaces. Including the first and last child component.
```
{
  "type": "container",
  "stack": "horizontal",
  "alignment": "start",
  "children": [
      ...
  ]
}
```

#### label

The label component displays a text label on the defined field.
- In addition to the textKey property, it is possible to provide thebind property to allow Account schema binding - with a fallback to the text Key value.

```json
{
  "type": "label",
  "textKey": "Example text"
}
```

#### Links

You are able to link specific parts of your label component texts in order to support:
 - External URL links.
 - Internal screen navigation - using the next screen name.

Linking is available using this text pattern:
```
Some random text [visible inline link text](actual link URI)
//'(register)' points to the internal "register" screen
```
Example Uses
```json
{
  "type": "label",
  "textKey": "I don't have an account. [Register now](register).", 
}
```
Will result in the following displayed text:
 - I don't have an account. Register now.

Pressing on the words 'Register now' will navigate the user to the registration screen (which needs to be set as "register" in the screen-set markup).
```json
{
  "type": "label",
  "textKey": "By clicking submit you are agreeing to these [terms of use](https://www.yourtermsofuseurl.com).",
}
```
Will result in the following displayed text:

 - By clicking submit you are agreeing to these terms of use.

Pressing on the words "terms of use" will open the devices default browser and display the defined URL.

#### textInput

The textInput component allows textual input.

 - textKey
    - Placeholder value
 - Valid type values:
    - text-input
        - Plain text input
    - email-input
        - On focus opens an email keyboard.
    - password-input
        - Masks the content of the field.

```
{
  "type": "textInput"|"email"|"password",
  "bind": "profile.firstName",
  "textKey": "First name"
}
```

#### socialLoginButton

The social login button allows you to add the simple button liked to a specific social provider. This component supports all button related styling
components with the addition of these specific styling types:
 - iconEnabled - boolean field to enable/disable the provider icon.
 - iconURL - the option to provide you own URL resource for this specific button.

```json
{
  "type": "socialLoginButton",
  "provider": "facebook",
  "textKey": "social-sign-in-facebook",
  "style": {
     "margin": [4, 0, 4, 0],
     "cornerRadius": 5,
     "elevation": 0
  }
},
```

#### socialLoginGrid

The social login grid allow you to add multiple social login buttons that are arranged within a grid. This allows you to preserve screen real estate and compact all social providers in one display box. The grid will arrange itself automatically according to the columns & rows parameters.

In case your provider count is larger than the number available to display on the grid, the component will provide paging and include a bottom indicator which can be styled using the "indicatorColor" styling property.

**The max available rows is currently set to 2**ץ

```
All icons used for the "socialLoginGrid" components are aligned with each provider's branding guidelines. Therefore, customization is
unavailable.
The usage "socialLoginButton" & "socialLoginGrid" components are dependent upon each social provider being setup in the core native
SDKs. 
The NSS Library does not implement them for you.
 - amazon
 - apple
 - facebook
 - google
 - line
 - linkedin
 - twitter
 - vkontakte
 - wechat
 - yahoo
 - yahooJapan
```

```json
{
  "type": "socialLoginGrid",
   "providers": [ "facebook", "google", "wechat", "yahoo", "twitter", "apple", "line", "amazon"],
   "columns": 4,
   "rows": 2,
   "style": {
     "cornerRadius": 6,
     "fontSize": 14,
     "fontColor": "black",
     "fontWeight": "bold",
     "elevation" : 2,
     "indicatorColor": "grey"
   }
}
```
### Styling

In order to style your screen-set, you are able to add specific styling properties to each component.

Available styling parameters:

 - margin - Will set the outer component margin and space it from its adjacent components.
    - Supported values:
        - Number (floating point available) - Will be used for all directions.
        - Array of numbers (floating point available) following this pattern: [left, top, right, bottom].
    - Supported Components:
        - container
        - label
        - all inputs
        - submit
        - checkbox
        - dropdown
        - radio
 - size - Set the exact component size (in pixels).
    - Supported values:
        - Array of numbers (floating point available) following this pattern: [width, height]
    - Supported Components:
        - container
        - label
        - all inputs
        - submit
        - checkbox
        - dropdown
        - radio
 - background - Set the component background.
    - Supported values:
        - Color - (string) You can pass the color value using either any of the supported colors by name, or any hex formatted CSS color.
            - name - available options:
                - blue
                - red
                - green
                - grey
                - yellow
                - orange
                - white
                - black
                - transparent
            - HEX code - Any value following this pattern:
                - #bcbcbc
    - Supported Components:
        - screen
        - container
        - all inputs
        - submit
        - checkbox
        - radio
 - fontColor - Set the color of the displayed component text.
    - Supported values:
        - Color - (string) You can pass the color value using either any of the supported colors by name, or any hex formatted CSS color.
            - name - available options:
                - blue
                - red
                 - green
                - grey
                - yellow
                - orange
                - white
                - black
                - transparent
            - HEX code - Any value following this pattern:
                - #bcbcbc
    - Supported Components:
        - label
        - all inputs
        - submit
        - checkbox
        - dropdown
        - radio
 - fontSize - Sets the size of the displayed component text.
    - Supported values:
        - Number (floating point available).
    - Supported Components:
        - label
        - all inputs
        - submit
        - checkbox
        - dropdown
        - radio
 - fontWeight - Set the weight of the displayed component text.
    - Supported values:
        - Number (integer) between 1-9.
        - bold
    - Supported Components:
        - label
        - all inputs
        - submit
        - checkbox
        - dropdown
        - radio
 - cornerRadius - Round component corners.
    - Supported values:
        - Number (floating point available). Be sure not to use a number that is bigger than (component.height / 2).
    - Supported Components:
        - all inputs
        - submit
 - borderColor - Sets the color of the component border.
    - Supported values:
        - Color - (string) You can pass the color value using either any of the supported colors by name, or any hex formatted CSS color.
        - name - available options:
            - blue
            - red
            - green
            - grey
            - yellow
            - orange
            - white
            - black
            - transparent
        - HEX code - Any value following this pattern:
            - #bcbcbc
    - Supported Components:
        - all inputs
        - dropdown
 - borderSize - Sets the size of the component border.
    - Supported values:
        - Number (floating point available)
    - Supported Components:
        - all inputs
        - dropdown
 - Opacity - Sets the component opacity value.
    - Supported values:
        - Number - between 0-1.
    - Supported Components:
        - container
        - label
        - all inputs
        - submit
        - checkbox
        - dropdown
        - radio
 - Elevation - Sets the Z axis position of the component.
    - Supported values:
        - Number (floating point available) between 0-10.
    - Supported Components:
        - submit

#### Theme

You are able to apply a global theme to your screen-sets providing an additional "theme" tag to your markup or by providing an additional asset
file.

Available theme parameters:
- primaryColor
- secondaryColor
- textColor
 - enabledColor
 - disabledColor
 - errorColor

Example:

```json
"theme" : {
   "primaryColor": "red",
   "secondaryColor": "white",
   "textColor": "white",
   "enabledColor": "green",
   "disabledColor": "grey",
   "errorColor": "red"
 }
```

#### Design Notes:

- Primary & Secondary colors parameters should be contrasting colors.
 - In order to add an additional asset file, you are required to name the theme file exactly as you named the screen-sets markup file, adding.theme.json" suffix.

For example:
If the markup file is: gigya-nss-example.json, your theme file should be named: gigya-nss-example.theme.json.
Be sure to remove the "theme" parameter if you use a different file. An example is available in the sample applications.

#### Using custom themes

You can add customized themes and use them as a reference to a specific component.
For example:
```json
{
  "theme" : {
    "primaryColor": "red",
    "secondaryColor": "white",
    "textColor": "white",
    "enabledColor": "green",
    "disabledColor": "grey",
    "errorColor": "red",
    "title": {
       "fontSize": 22,
       "fontWeight": "bold"
    },
    "flatButton": {
       "fontSize": 16,
       "elevation": 0
    }
  }
}
```

In order to apply these themes you will need to reference them to their specific component as follows:

```
{
...
  {
   "type" : "label",
   "theme" : "title
  }
   ...
  {
   "type" : "submit",
   "theme" : "flatButton"
  }
 ...
}
```

### Input validations

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
       "value": "^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\\.[a-zA-Z]+",
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

#### checkbox

The checkbox component shows a checkbox for basic Boolean toggle indication.
```json
{
  "type": "checkbox",
  "bind": "data.terms",
  "textKey": "Accept terms"
}
```

#### radio

The radio component displays multiple radio button for the user to choose from.
 - options
    - An array of option objects: only one can be default;
    - On selecting an option, its value will be set to the bound Account schema field.
```json
{
  "type": "radio",
  "bind": "data.favGuitar",
  "options": [
    {
    "default": true,
    "value": "PRS",
    "textKey": "Paul Reed Smith"
    },
    {
    "value": "Rubato",
    "textKey": "Rubato Guitars"
    },
    {
    "value": "Parker",
    "textKey": "Parker Guitars"
    }
  ]
}
```

#### dropdown

The dropdown component displays a drop-down list of options from which the user can choose from.

 - options
    - An array of option objects; only one can be the default;
    - On selecting an option, its value will be set to the bound Account schema field.
```json
{
  "type": "dropdown",
  "bind": "data.favGuitar",
  "options": [
     {
      "default": true,
      "value": "PRS",
      "textKey": "Paul Reed Smith"
     },
     {
       "value": "Rubato",
       "textKey": "Rubato Guitars"
     },
     {
       "value": "Parker",
       "textKey": "Parker Guitars"
     }
   ]
}
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

### Binding - In depth

When using component binding you will be required to distinguish between two field types:

 - Property field
    - This type is used to describe components (usually input/selection type components) that need to be bound to a specific parameter in order to perform endpoint operations.
        - Property fields are prefixed using a "#". The following example binds the "loginID" & "password" parameters in order to perform a login operation.
        
         ```
        Schema validations are irrelevant on property field types and you will be required to use markup Input validations.
        ```
```
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
            "login": "Iniciar sesión",
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

## Known Issues

Native Screen-Sets engine versioning is still under development.

## How to obtain support
Via SAP standard support.
https://developers.gigya.com/display/GD/Opening+A+Support+Incident

## Contributing
Via pull request to this repository.

## Known Issues
iOS – Debugging is currently available only on simulators.

