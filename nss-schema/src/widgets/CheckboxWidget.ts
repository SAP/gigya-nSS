import {mergeDeep} from "../common/utils";
import BoundWidget from "./BoundWidget";
import {withStoreAsArray, WithText} from "../common";
import {background, font, margin, opacity, size, withStyle,} from "../styles";
import WidgetEntity from "./WidgetEntity";

export default new WidgetEntity('Checkbox', mergeDeep({},
    BoundWidget,
    WithText,
    withStoreAsArray,
    withStyle(margin, size, background, opacity, ...font), {
    properties: {
        type: {
            enum: [
                'checkbox',
            ]
        },
        default: {
            type: "boolean"
        }
    }
}));
