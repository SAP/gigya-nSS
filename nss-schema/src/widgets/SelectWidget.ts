import {mergeDeep} from "../common/utils";
import {TextKey, withStoreAsArray, WithText} from "../common";
import BoundWidget from "./BoundWidget";
import {withStyle, margin, size, background, font, border, opacity} from "../styles";
import WidgetEntity from "./WidgetEntity";

// TODO: radio without border; dropdown withouot background
export default new WidgetEntity('Select', mergeDeep({},
    BoundWidget,
    withStoreAsArray,
    withStyle(margin, size, background, opacity, ...font, ...border), {
    properties: {
        type: {enum: ['radio', 'dropdown']},
        placeholder: {type: 'string'},
        options: {
            type: 'array',
            items: mergeDeep({}, WithText, {
                type: 'object',
                required: [
                    TextKey,
                    'value'
                ],
                properties: {
                    default: {
                        const: true
                    },
                    value: {
                        type: [
                            'string',
                            'number',
                            'boolean'
                        ]
                    }
                },
                additionalProperties: false
            })
        }
    }
}));
