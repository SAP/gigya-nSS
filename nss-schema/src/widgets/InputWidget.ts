import {mergeDeep} from "../common/utils";
import BoundWidget from "./BoundWidget";
import {withStoreAsArray, WithText} from "../common";
import {background, border, cornerRadius, font, margin, opacity, placeholderColor, size, withStyle} from "../styles";
import WidgetEntity from "./WidgetEntity";

export default new WidgetEntity('Input', mergeDeep({},
    BoundWidget,
    WithText,
    withStoreAsArray,
    withStyle(margin, size, background, cornerRadius, opacity, placeholderColor, ...border, ...font), {
    properties: {
        type: {
            enum: [
                'textInput',
                'emailInput',
                'passwordInput',
            ]
        },
        confirmPassword: {
            type: 'boolean',
            default: false
        },
        confirmPasswordPlaceholder: {
            type: 'string',
        },
        stack: {
            enum: [
                'vertical',
                'horizontal'
            ],
            default: 'vertical'
        },
    }
}));
