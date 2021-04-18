import BaseWidget from "./BaseWidget";
import {mergeDeep} from "../common/utils";
import {WithText} from "../common";
import {JSONSchema7} from "json-schema";
import {font, margin, opacity, size, withStyle} from "../styles";
import WidgetEntity from "./WidgetEntity";

export default new WidgetEntity('Label', mergeDeep({},
    BaseWidget,
    WithText,
    withStyle(margin, size, opacity, ...font), {
    properties: {
        type: {
            enum: ['label']
        }
    }
} as JSONSchema7));