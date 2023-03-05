# SAP CDC (Gigya) Native Screen Sets

## Components

The Native Screen-Sets JSON is made from components starting from a collection of screens to the labels, inputs, etc., that are contained within them.

***General component properties:***

* **type - specifies the type of the component.**
* **textKey- specifies the displayed text content of the component (localized).**
* ***bind - specifies 4he path for the Account schema field's 2-way-binding, e.g., for displaying and/or editing the profile.firstName field.**

### Component Type: Screen

**<u>Usage</u>: Definition of a screen form container**

A screen component is the root of every displayed screen. It is defined by a unique <screen id> and can perform actions and route to another screen.  
The screen component is a container component. It may contain children components that stack to create the desired UI. See the container component for more information.

| Markup Type | Special Parameters                                    | Supported Styles | Default theme property | Special Characteristics |  
| ----------- | ----------------------------------------------------- | :--------------- | ---------------------- | ----------------------- |  
| "screen-id" | appBar<br/>action<br/>routing<br/>showOnlyFields<br/> | background<br/>  | primaryColor<br/>      | None                    |  

#### Action:

The screen's target action. Availble from the following options: login, register, setAccount, fogotPassword, otp.

A screen's action is invoked via the submit component.

#### Routing:

Create continuous flows of screen using the routing object. It is constructed using an "event" to "action" form.

An event can route the screen either to a special action or to another declared screen.

##### Available events:

* onSuccess - When the screen action ends successfully.
* onPendingRegistration - When the screen action receives a pending registration error.
* onPendingEmailVerification - When the screen action receives a pending verification error.

##### Available actions:

* _dismiss - Dismisses (closes) the screen (usually used when a flow is completed).
* _cancel - Dismisses (closes) the screen (usually used to force termination of the screen-set flow before completion). This will also invoke a cancel event.
* Any declared screen id. **You should not try to re-route to the same screen.**

#### showOnlyFields

The **showOnlyFields** property is an additional screen specific property which allows the engeine to perform  
background evaluation for bound fields.

Available options:

* empty - Bound fields which are considered "empty" will only be displayed. This is useful when user is required to input only missing data.

```json  
"login":{  
 "routing": { "onSuccess": "_dismiss", "onPendingRegistration": "account-update" }, "action": "login", "appBar": { "textKey": "verify SMS" },"children": []}  
```  

### Component type: submit

**<u>Usage</u>: Screen form submission according to given action**

The submit button is directly linked with the provided screen action. It cannot be used for linking purposes

| Markup Type     | Special Parameters       | Supported Styles                                             | Default theme property                                       | Special Characteristics                                      |  
| --------------- | ------------------------ | ------------------------------------------------------------ | ------------------------------------------------------------ | ------------------------------------------------------------ |  
| "type":"submit" | showIf<br/>disabled<br/> | size<br/>margin<br/>background<br/>opacity<br/>disabled<br/>fontSize<br/>fontColor<br/>fontWeight<br/>borderColor<br/>borderSize<br/>cornerRadius | <br/><br/>primaryColor<br/><br/><br/><br/>secondaryColor<br/><br/><br/><br/> | *Error* - once the adjacent submit request recieves an error, an under label will be displayed. The color of the error is defined in the main theme under "errorColor". The text is centered and cannot be styled. |  

```json  
{  
 "type": "submit", "style": { "size":[100, 44], "fontSize": 16, "background": "blue" }}  
```  

### Component type: container

**<u>Usage</u>: Stack children components horizontally or verically**

| Markup Type        | Special Parameters                  | Supported Styles                                             | Default theme property                                       | Special Characteristics                                      |  
| ------------------ | ----------------------------------- | ------------------------------------------------------------ | ------------------------------------------------------------ | ------------------------------------------------------------ |  
| "type":"container" | stack<br/>alignment<br/>showIf<br/> | size<br/>margin<br/>background<br/>opacity<br/>disabled<br/>fontSize<br/>fontColor<br/>fontWeight<br/>borderColor<br/>borderSize<br/>cornerRadius | <br/><br/>primaryColor<br/><br/><br/><br/>secondaryColor<br/><br/><br/><br/> | Valid values for "stack" property are "horizontally" and "vertical". |  

Alignment (optional) - Defines how the children components will align to each other within the directional stack.

Valid alignment values:

- **start (default)** - Align all children components to the starting (main axis) point of the Container.
- **end** - Align all children components to the ending point (main axis) of the Container.
- **center** - Align all children components to the center position of the Container.
- **spread** - Spread out all children components to the available positions, placing free space evenly between them.
- **equal_spacing** - Place all children with even spaces. Including the first and last child component

```json  
{  
 "type": "container", "stack": "horizontal", "alignment": "start", "children": []}  
```  

### Component Type: Label

**<u>Usage</u>: Simple text display with available linking action using standard linking format**

| Markup Type    | Special Parameters       | Supported Styles                                             | Default theme property                                     | Special Characteristics                                      |  
| -------------- | ------------------------ | :----------------------------------------------------------- | ---------------------------------------------------------- | ------------------------------------------------------------ |  
| "type":"label" | showIf<br/>disabled<br/> | size<br/>margin<br/>background<br/>opacity<br/>fontSize<br/>fontColor<br/>fontWeight,<br/>textAlign<br/>linkColor | <br/><br/><br/><br/><br/>textColor<br/><br/><br/>linkColor | *Flexible* - will take as much space as needed according to content<br/>*Linkify* - support standart linking format. Linking is available for external webpages and internal routes. |  

#### Linking format:

```  
[displayed link lable](actual link: external web page or internal screen)  
```  

```json  
{  
 "type": "label", "textKey": "I don't have an account. [Register now](register).", "style":{ "linkColor":"red", "fontSize": 14, "fontWeight": "bold" } }  
```  

**Another example:**

```json  
{  
 "type": "label", "textKey": "By clicking submit you are agreeing to these [terms of use](https://www.yourtermsofuseurl.com)."}  
```  

### Component Type: TextInput

**<u>Usage</u>: Allows textual input and data binding**

Text input can be cusomized for specific input types: **emailInput, passwordInput.**

| Markup Type                                                  | Special Parameters       | Supported Styles                                             | Default theme property                                       | Special Characteristics                                      |  
| ------------------------------------------------------------ | ------------------------ | :----------------------------------------------------------- | ------------------------------------------------------------ | ------------------------------------------------------------ |  
| "type":"textInput<br/>"type":"emailInput<br/>"type":"passwordInput<br/> | showIf<br/>disabled<br/> | size<br/>margin<br/>background<br/>opacity<br/>fontSize<br/>fontColor<br/>fontWeight,<br/>textAlign<br/>borderColor<br/>borderSize<br/>cornerRadius<br/>placeholderColor | <br/><br/><br/><br/><br/>textColor<br/><br/><br/><br/><br/><br/>textColor(0.5 opacity) | *Flexible* - will take as much space as needed according to content. |  

```json  
{  
 "type": "textInput"|"email"|"password", "bind": "profile.firstName", "textKey": "First name", "style":{ "placeholderColor":"#add8e6" "textAlign":"center" }}  
```  
If using a "passwordInput" the text will be obfuscated by default and a "showText" icon will be presented at the end of the input box.

#### Password confirmation
TextInput allows additional parameters to be added when using "passwordInput" to apply password confirmation:

* confirmPassword - set to "true" to enable the option.
* confirmPasswordPlaceholder - to set custom placeholder for the password confirmation input field.
*  stack - vertical/horizontal to set the placement of the adjacent input fields.

### Component Type: Social Login Button

**<u>Usage</u>: Initiate provider specific social login flow**

| Markup Type                | Special Parameters                                 | Supported Styles                                             | Default theme property                       | Special Characteristics |  
| -------------------------- | -------------------------------------------------- | :----------------------------------------------------------- | -------------------------------------------- | ----------------------- |  
| "type":"socialLoginButton" | showIf<br/>iconEnabled<br/>showIf<br/>iconURL<br/> | size<br/>margin<br/>background<br/>opacity<br/>fontSize<br/>fontColor<br/>fontWeight,<br/>borderColor<br/>borderSize<br/>cornerRadius<br/>textAlign<br/> | <br/><br/><br/><br/><br/>textColor<br/><br/> |                         |  

```json  
{  
 "type": "socialLoginButton", "provider": "facebook", "iconEnabled": false, "textKey": "Sign in with Facebook", "style": { "margin": [4, 0, 4, 0], "cornerRadius": 5, "elevation": 0 }},  
```  

### Component Type: Social Login Grid

**<u>Usage</u>: Display multiple selection for social login providers**

| Markup Type              | Special Parameters                                           | Supported Styles                                             | Default theme property                            | Special Characteristics                                      |  
| ------------------------ | ------------------------------------------------------------ | :----------------------------------------------------------- | ------------------------------------------------- | ------------------------------------------------------------ |  
| "type":"socialLoginGrid" | indicatorColor<br/>hideTitles<br/>columns<br/>rows<br/>providers<br/>showIf<br/>disabled<br/> | size<br/>margin<br/>background<br/>elevation<br/>opacity<br/>fontSize<br/>fontColor<br/>fontWeight<br/>cornerRadius<br/> | <br/><br/><br/><br/><br/><br/>textColor<br/><br/> | - Providers parameter supports and array of string elements.<br/>- Max available rows are currently sert to 2. |  

NSS supports the following social providers:

**amazon, apple, facebook, google, line, linkedin, twitter, vkontakte, wechat, yahoo, yahooJapan**

```json  
{  
 "type": "socialLoginGrid", "providers": [ "facebook", "google", "wechat", "yahoo", "twitter", "apple", "line", "amazon"], "hideTitles": false, "columns": 4, "rows": 2, "style": { "cornerRadius": 6, "fontSize": 14, "fontColor": "black", "fontWeight": "bold", "elevation" : 2, "indicatorColor": "grey" }}  
```  

### Component Type: Image

**<u>Usage</u>: display remote hosted image files or native internal assets**

| Markup Type    | Special Parameters                            | Supported Styles                                             | Default theme property | Special Characteristics                                      |  
| -------------- | --------------------------------------------- | :----------------------------------------------------------- | ---------------------- | ------------------------------------------------------------ |  
| "type":"image" | url<br/>fallback<br/>showIf<br/>disabled<br/> | size<br/>margin<br/>background<br/>elevation<br/>opacity<br/>borderColor<br/>borderSize<br/>cornerRadius<br/> |                        | - When using the elevation property make sure you apply a background color to the image.<br/>- When using an internal image you are required to use the resource name only. No need for the file extension. |  

```json  
{  
 "type": "image", "url": "IMAGE URL OR INTERNAL ASSET FILE NAME", "fallback": "FALLBACK IMAGE URL OR INTERNAL ASSET FILE NAME"}  
```  

### Component Type: Profile Photo

**<u>Usage</u>: display the users profile photo as linked in the "profile.photoURL" schema field**

| Markup Type           | Special Parameters                                           | Supported Styles                                             | Default theme property | Special Characteristics                                      |  
| --------------------- | ------------------------------------------------------------ | :----------------------------------------------------------- | ---------------------- | ------------------------------------------------------------ |  
| "type":"profilePhoto" | url<br/>fallback<br/>allowUpload<br/>showIf<br/>disabled<br/> | size<br/>margin<br/>background<br/>elevation<br/>opacity<br/>borderColor<br/>borderSize<br/>cornerRadius<br/> |                        | - Supports same characteristics of the image componenet.<br/>- The *"allowUpload"* property will determine if the component will handle click events in order to provide image updating. |  

```json  
{  
 "type": "profilePhoto", "allowUpload": false, "default": "DEFAULT PHOTO URL OR INTERNAL ASSET FILE NAME"}  
```  

### Component Type: Checkbox

**<u>Usage</u>: Provide basic toggle state indication for data binding**

| Markup Type       | Special Parameters       | Supported Styles                                             | Default theme property                                     | Special Characteristics                                      |  
| ----------------- | ------------------------ | :----------------------------------------------------------- | ---------------------------------------------------------- | ------------------------------------------------------------ |  
| "type":"checkbox" | showIf<br/>disabled<br/> | size<br/>margin<br/>background<br/>opacity<br/>fontSize<br/>fontColor<br/>fontWeight,<br/>textAlign<br/>linkColor | <br/><br/><br/><br/><br/>textColor<br/><br/><br/>linkColor | *Linkify* - support standart linking format. Linking is available for external webpages and internal routes. |  

```json  
{  
 "type": "checkbox", "bind": "data.terms", "textKey": "Accept terms"}  
```  

### Component Type: Radio Group

**<u>Usage</u>: displays multiple radio button for the user to choose from**

| Markup Type    | Special Parameters                   | Supported Styles                                             | Default theme property                       | Special Characteristics                                      |  
| -------------- | ------------------------------------ | :----------------------------------------------------------- | -------------------------------------------- | ------------------------------------------------------------ |  
| "type":"radio" | options<br/>showIf<br/>disabled<br/> | size<br/>margin<br/>background<br/>opacity<br/>fontSize<br/>fontColor<br/>fontWeight,<br/>textAlign | <br/><br/><br/><br/><br/>textColor<br/><br/> | - The options parameter contains an array of option objects (only one can be set as "default") - **see example**. |  

```json  
{  
 "type": "radio", "bind": "data.favGuitar", "options": [ { "default": true, "value": "PRS", "textKey": "Paul Reed Smith" }, { "value": "Rubato", "textKey": "Rubato Guitars" }, { "value": "Parker", "textKey": "Parker Guitars" } ]}  
```  

### Component Type: Dropdown menu.

**<u>Usage</u>: displays a drop-down list of options from which the user can choose from**

| Markup Type       | Special Parameters                   | Supported Styles                                             | Default theme property                       | Special Characteristics                                      |  
| ----------------- | ------------------------------------ | :----------------------------------------------------------- | -------------------------------------------- | ------------------------------------------------------------ |  
| "type":"dropdown" | options<br/>showIf<br/>disabled<br/> | size<br/>margin<br/>background<br/>opacity<br/>fontSize<br/>fontColor<br/>fontWeight,<br/>textAlign | <br/><br/><br/><br/><br/>textColor<br/><br/> | - The options parameter contains an array of option objects (only one can be set as "default") - **see example**. |  

```json  
{  
 "type": "dropdown", "bind": "data.favGuitar", "options": [ { "default": true, "value": "PRS", "textKey": "Paul Reed Smith" }, { "value": "Rubato", "textKey": "Rubato Guitars" }, { "value": "Parker", "textKey": "Parker Guitars" } ]}  
```  

Dropdown and Radio components are interchangeable - their structure is exact and you can toggle betwen the "type" identifier in order to view which one suits your screen best.

### Component Type: Phone number input

**<u>Usage</u>: Input field specifically for phone number which icludes a country code selection**

| Markup Type         | Special Parameters                     | Supported Styles                                             | Default theme property                       | Special Characteristics |  
| ------------------- | -------------------------------------- | :----------------------------------------------------------- | -------------------------------------------- | ----------------------- |  
| "type":"phoneInput" | countries<br/>showIf<br/>disabled<br/> | size<br/>margin<br/>background<br/>opacity<br/>fontSize<br/>fontColor<br/>fontWeight,<br/>borderColor<br/>borderSize<br/>cornerRadius<br/> | <br/><br/><br/><br/><br/>textColor<br/><br/> |                         |  

```json  
{  
 "type": "phoneInput", "bind": "#phoneNumber", "textKey": "enter your phone number", "style": { "margin": [ 16, 20, 16, 4 ] }
 }  
```  

The countries object - Allows additional customization.

* **defaultSelected** - Will define which country code will be selected by default. If not supplied, the device will choose the country code from the SIM card.
* **showIcons** - Determine if flag icons will be displayed.
* **Inclide** - Include only specific iso3166 country codes that will be displayed in the selection.
* **exclude** - Exclude only specific iso3166 country codes from the entire list.

```json  
{  
 "type": "phoneInput", "bind": "#phoneNumber", "textKey": "enter your phone number", "countries": { "defaultSelected": "us", "showIcons": true, "include": ["us", "es", "it"] }}  
```  


### Component Type: Date Picker
**<u>Usage</u>: Use this widget for any date related field input**

| Markup Type         | Special Parameters                     | Supported Styles                                             | Default theme property                       | Special Characteristics |  
| ------------------- | -------------------------------------- | :----------------------------------------------------------- | -------------------------------------------- | ----------------------- |  
| "type":"datePicker" | initialDisplay<br/>startYear<br/>endYear<br/>showIf<br/>datePickerStyle<br>disabled<br/> | size<br/>margin<br/>background<br/>opacity<br/>fontSize<br/>fontColor<br/>fontWeight,<br/>borderColor<br/>borderSize<br/>cornerRadius<br/> | <br/><br/><br/><br/><br/>textColor<br/><br/> | - The date picker can be displayed in "input" or "calendar" mode.<br>Use "intialDisplay" property to vary modes.                     | 

```json
 {      
  "type": "datePicker",      
  "initialDisplay": "input",      
  "textKey": "Birth date:",      
  "bind": {      
    "type": "date",      
   "day": "profile.birthDay",      
   "month": "profile.birthMonth",      
   "year": "profile.birthYear"      
  },      
  "startYear": 2000,      
  "endYear": 2025,      
  "datePickerStyle" : {      
     "primaryColor": "blue"      
  },      
  "style": {      
    "fontSize": 16,      
   "cornerRadius": 15,      
   "borderSize": 2,      
   "fontColor": "black",      
"margin": [ 16, 10, 16, 8 ] } }
 ```   

**Date picker binding:** The widgets allows binding to be set in two ways:
1. As an object (see example) aligning each date property to a different schema binding field.
2. As a single schema bind field using a **Iso8601** standard.


**The datePickerStyle object** - Allows customizing the picker dialog.    
Available customization options:
- primaryColor
- labelColor
- labelText

### Component Type: FIDO authentication button
**<u>Usage</u>: Displays a FIDO authentication button in selected screens**

| Markup Type         | Special Parameters                     | Supported Styles                                             | Default Theme Property                       | Special Characteristics |  
| ------------------- | -------------------------------------- | :----------------------------------------------------------- | -------------------------------------------- | ----------------------- |  
| "type":"button" | api<br/>showIf<br/>useRouting<br/> | Same as submit button |  | API property varies according to button state              | 

To begin implementing FIDO authentication, please follow the relevant platform setup:
[Android](https://sap.github.io/gigya-android-sdk/sdk-core/#fidowebauthn-authentication)
[iOS](https://sap.github.io/gigya-swift-sdk/GigyaSwift/#fidowebauthn-authentication)

The **FIDO authentication button** supports 3 different states using the "api" property:
* **webAuthnRegister** - Used for registering a new FIDO passKey.
* **webAuthnRevoke** - Used for revoking a valid FIDO passkey.
* **webAuthnLogin** - Used to start the login flow using a valid FIDO passkey.

In addition, the markup supports a specific setup for the "showIf" property that handles the widget visibility according to the application's FIDO state.
Implementation example:
When adding a FIDO revoke state button, the "showIf" property will automatically be set to:
```json
"showIf": "Gigya.webAuthn.isExists == true && Gigya.isLoggedIn == true && Gigya.webAuthn.isSupported == true",
```
This setting indicates that the button is visible only if:
1. Gigya.webAuthn.isExists == true -> The device has a valid FIDO passkey registered.
2. Gigya.isLoggedIn == true -> A valid session is available. The user is logged in.
3. Gigya.webAuthn.isSupported == true -> [The Android device supports FIDO authentication](https://sap.github.io/gigya-android-sdk/sdk-core/#sdk-prerequisites)

The **useRouting** property is set when you require the engine to use the specified screen routing once the FIDO action is complete.
If it's not included or set to "false", screen navigation will not apply.

**UI builder options:**
The FIDO button is available only on specific screen actions:
**login**
**setAccount**
Therefore, it will only be available when using login, register, and account update default screens.

Note: The UI Builder preview does not yet support "showIf" fields. A preview of visibility changes of the FIDO buttons is supported on mobile only.


#### Disabling

All widgets can be disabled using the **"disabled" property. Disabling a component will grey out its display and and add an opacity effect to it.
