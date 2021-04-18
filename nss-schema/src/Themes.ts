import {JSONSchema7} from "json-schema";
import ColorSchema from "./styles/ColorSchema";
import {StyleSegment} from "./styles";
import {getRefsOf} from "./common/definitions";

export default {
    properties: {
        theme: {
            type: 'object',
            additionalProperties: false,
            properties: {
                primaryColor: ColorSchema.getRef(),
                secondaryColor: ColorSchema.getRef(),
                textColor: ColorSchema.getRef(),
                enabledColor: ColorSchema.getRef(),
                disabledColor: ColorSchema.getRef(),
                errorColor: ColorSchema.getRef(),
                linkColor: ColorSchema.getRef(),
            }
        },
        customThemes: {
            patternProperties: {
                '.*': {
                    anyOf: getRefsOf(StyleSegment)
                }
            }
        }
    }
} as JSONSchema7;