import {mergeDeep} from "../common/utils";
import BoundWidget from "./BoundWidget";
import {WithText} from "../common";
import {background, border, cornerRadius, font, margin, opacity, placeholderColor, size, withStyle} from "../styles";
import WidgetEntity from "./WidgetEntity";

export default new WidgetEntity('Input', mergeDeep({},
    BoundWidget,
    WithText,
    withStyle(margin, size, background, cornerRadius, opacity, placeholderColor, ...border, ...font), {
    properties: {
        type: {
            enum: [
                'textInput',
                'emailInput',
                'passwordInput',
            ]
        }
    }
}));
