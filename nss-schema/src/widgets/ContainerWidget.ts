import {mergeDeep} from "../common/utils";
import {JSONSchema7} from "json-schema";
import WithChildren from "../common/WithChildren";
import BaseWidget from "./BaseWidget";
import {margin, opacity, size, withStyle} from "../styles";
import WidgetEntity from "./WidgetEntity";
import JsExp from "../common/JsExp";

export const ContainerStyles = [margin, size, opacity];

export default new WidgetEntity('Container', mergeDeep({},
    BaseWidget,
    WithChildren,
    withStyle(...ContainerStyles), {
    properties: {
        type: {
            enum: ['container']
        },
        showIf: JsExp.getRef()
    }
} as JSONSchema7));