import BaseWidget from "./BaseWidget";
import {mergeDeep} from "../common/utils";
import {WithText} from "../common";
import {background, border, cornerRadius, elevation, font, withStyle,} from "../styles";
import WidgetEntity from "./WidgetEntity";
import {ContainerStyles} from "./ContainerWidget";

export const ButtonStyles = [...ContainerStyles, elevation, cornerRadius, background, ...font, ...border];

export default new WidgetEntity('Button', mergeDeep({},
    BaseWidget,
    WithText,
    withStyle(...ButtonStyles), {
    properties: {
        type: {enum: ['submit','Button']},
        api: {
            type: 'string'
        },
        showIf: {
            type: 'string'
        },
        iconEnabled: {
            type: 'boolean'
        },

    }
}));
