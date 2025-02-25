# SAP CDC (Gigya) Native Screen Sets

## Styling and Theming

### Styling

In order to style your screen-set, you are able to add specific styling properties to each component.

```json
{
  "type": "label",
  "style": {
    "fontSize": 14,
    "fontColor": "black"
  }
}
```

<u>Available styling parameters:</u>

| Sytle parameter | Supported values                                             |
| --------------- | ------------------------------------------------------------ |
| margin          | Number - can use floating point. Using a single numner will apply margin to all directions (l,r,t,b).<br/>Number array - [ left, top, right, bottom]. |
| size            | Number array (pixels) - [width, height].<br/>Do not use 0 number when applying custom sizing |
| background      | Color string - blue, red, green, grey, yellow, orange, white, black, transparent.<br/>HEX color - Any value following this format: #bcbcbc.<br/> |
| fontColor       | Color string - blue, red, green, grey, yellow, orange, white, black, transparent.<br/>HEX color - Any value following this format: #bcbcbc. |
| fontSize        | Number - floating point available.                           |
| fontWeight      | Number between 1-9.<br/>bold                                 |
| cornerRadius    | Number - floating point avalilable - Be sure not to use a number that is bigger than (component.height / 2). |
| borderColor     | Color string - blue, red, green, grey, yellow, orange, white, black, transparent.<br/>HEX color - Any value following this format: #bcbcbc. |
| borderSize      | Number - floating point avalilable                           |
| opacity         | Number between 0 - 1.                                        |
| elevation ( z ) | Number between 0 - 10.                                       |
| linkColor       | Color string - blue, red, green, grey, yellow, orange, white, black, transparent.<br/>HEX color - Any value following this format: #bcbcbc. |

### Theming 

You are able to apply a global theme to your screen-sets providing an additional "theme" tag to your markup or by providing an additional asset
file.

<u>Available theme parameters:</u>

- primaryColor
- secondaryColor
- textColor
 - enabledColor
 - disabledColor
 - errorColor

<u>Example</u>:

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
Add json object to the root of the markup.
For example:

```json
{
  "customThemes" : {
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

```json
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

*** Container components currently do not support custom themeing ***

Note: "Theme" & "CustomTheme" tags are required when using file markups. They can remain empty if not used but cannot be removed from the JSON schema.

