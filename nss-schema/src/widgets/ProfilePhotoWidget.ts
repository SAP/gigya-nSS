import BaseWidget from "./BaseWidget";
import {mergeDeep} from "../common/utils";
import {withStyle} from "../styles";
import WidgetEntity from "./WidgetEntity";
import Asset from "../common/Asset";
import {ImageStyles} from "./ImageWidget";

export default new WidgetEntity('ProfilePhoto', mergeDeep({},
    BaseWidget,
    withStyle(...ImageStyles), {
        properties: {
            type: {
                enum: ['profilePhoto']
            },
            default: Asset.getRef(),
            allowUpload: {
                type: 'boolean'
            }
        }
    }));