import BaseWidget from "./BaseWidget";
import {mergeDeep} from "../common/utils";
import {JSONSchema7} from "json-schema";
import {withStyle} from "../styles";
import WidgetEntity from "./WidgetEntity";
import SocialProvider from "../common/SocialProvider";
import {SocialButtonStyles} from "./SocialLoginButtonWidget";

export default new WidgetEntity('SocialLoginGrid', mergeDeep({},
    BaseWidget,
    withStyle(...SocialButtonStyles), {
        required: [
            'type',
            'providers'
        ],
        properties: {
            type: {
                enum: ['socialLoginGrid']
            },
            providers: {
                type: 'array',
                items: SocialProvider.getRef()
            },
            columns: {
                type: 'number'
            },
            rows: {
                type: 'number'
            },
            hideTitles: {
                type: 'boolean'
            }
        }
    } as JSONSchema7));
