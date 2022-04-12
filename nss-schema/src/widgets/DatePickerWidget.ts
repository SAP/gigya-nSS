import {mergeDeep} from "../common/utils";
import BoundWidget from "./BoundWidget";
import {WithText} from "../common";
import {background, border, cornerRadius, font, margin, opacity, placeholderColor, size, withStyle} from "../styles";
import WidgetEntity from "./WidgetEntity";
import Global from "./Global";
import AccountField from "../dynEnums/AccountField";
import SpecialField from "../SpecialField";
import DatePickerBind from "../dynEnums/DatePickerBind";

export default new WidgetEntity('DatePicker', mergeDeep({},
    Global,
    WithText,
    withStyle(margin, size, background, cornerRadius, opacity, ...border, ...font), {
        properties: {
            bind: {
                oneOf: [
                    SpecialField.getRef(),
                    AccountField.getRef(),
                    DatePickerBind.getRef()
                ]
            },
            type: {
                enum: [
                    'datePicker',
                ]
            },
            initialDisplay: {
                enum: [
                    "calendar",
                    "input"
                ],
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
                    labelColor: {
                        type: 'string'
                    },
                    labelText: {
                        type: 'string'
                    },
                },
            }
        }
    }));
