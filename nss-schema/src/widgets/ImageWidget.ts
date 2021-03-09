import BaseWidget from "./BaseWidget";
import {mergeDeep} from "../common/utils";
import {border, cornerRadius, elevation, withStyle} from "../styles";
import WidgetEntity from "./WidgetEntity";
import Asset from "../common/Asset";
import {ContainerStyles} from "./ContainerWidget";

export const ImageStyles = [
    ...ContainerStyles,
    ...border,
    elevation,
    cornerRadius
];

export default new WidgetEntity('Image', mergeDeep({},
    BaseWidget,
    withStyle(...ImageStyles), {
        required: [
            'type',
            'url'
        ],
        properties: {
            type: {
                enum: ['image']
            },
            url: Asset.getRef(),
            fallback: Asset.getRef(),
        }
    }));