import {mergeDeep} from "../common/utils";
import BoundWidget from "./BoundWidget";
import {withStoreAsArray, WithText} from "../common";
import {background, border, cornerRadius, font, margin, opacity, placeholderColor, size, withStyle} from "../styles";
import WidgetEntity from "./WidgetEntity";

export default new WidgetEntity('PhoneInput', mergeDeep({},
    BoundWidget,
    WithText,
    withStoreAsArray,
    withStyle(margin, size, background, cornerRadius, opacity, placeholderColor, ...border, ...font), {
        properties: {
            type: {
                enum: [
                    'phoneInput',
                ]
            },
            countries: {
                type: 'object',
                properties: {
                    defaultSelected: {
                        type: 'string',
                        default: 'auto'
                    },
                    showIcons: {
                        type: 'boolean',
                        default: true
                    },
                    include: {
                        type: 'array'
                    },
                    exclude: {
                        type: 'array'
                    }
                }
            }
        }
    }));
