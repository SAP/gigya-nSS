import {JSONSchema7} from "json-schema";
import {getRefTo} from "./definitions";

export const ScreenChildRef = `ScreenChildWidget`;
export default {
    properties: {
        stack: {
            enum: [
                'vertical',
                'horizontal'
            ],
            default: 'vertical'
        },
        alignment: {
            enum: [
                'start',
                'end',
                'center',
            ],
            default: 'start'
        },
        children: {
            type: 'array',
            items: getRefTo(ScreenChildRef)
        }
    }
} as JSONSchema7;