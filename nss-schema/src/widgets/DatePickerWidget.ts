import {mergeDeep} from "../common/utils";
import BoundWidget from "./BoundWidget";
import {WithText} from "../common";
import {background, border, cornerRadius, font, margin, opacity, placeholderColor, size, withStyle} from "../styles";
import WidgetEntity from "./WidgetEntity";

export default new WidgetEntity('DatePicker', mergeDeep({},
    WithText,
    withStyle(margin, size, background, cornerRadius, opacity, ...border, ...font), {
        properties: {
            type: {
                enum: [
                    'datePicker',
                ]
            },
            initialDisplay: {
                type: 'string',
                default: 'calendar'
            },
            startYear: {
                type: 'number',
                default: 1920
            },
            endYear: {
                type: 'number',
                default: 2025
            },
            datePickerStyle : {
                properties: {
                    primaryColor: {
                        type: 'string'
                    },
                }
            }
        }
    }));
