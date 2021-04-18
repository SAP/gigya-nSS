import {JSONSchema7} from "json-schema";
import {getRefTo} from "./definitions";

export const ChildRef = `ChildWidget`;
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
                'spread',
                'equal_spacing'
            ],
            default: 'start'
        },
        children: {
            type: 'array',
            items: getRefTo(ChildRef)
        }
    }
} as JSONSchema7;