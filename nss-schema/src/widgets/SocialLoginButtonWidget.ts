import BaseWidget from "./BaseWidget";
import {mergeDeep} from "../common/utils";
import {JSONSchema7} from "json-schema";
import {withStyle} from "../styles";
import WidgetEntity from "./WidgetEntity";
import SocialProvider from "../common/SocialProvider";
import {WithText} from "../common";
import Asset from "../common/Asset";
import {ButtonStyles} from "./ButtonWidget";

export const SocialButtonStyles = ButtonStyles;

export default new WidgetEntity('SocialLoginButton', mergeDeep({},
    BaseWidget,
    WithText,
    withStyle(...SocialButtonStyles), {
        required: [
            'type',
            'provider'
        ],
        properties: {
            type: {
                enum: ['socialLoginButton']
            },
            provider: SocialProvider.getRef(),
            iconEnabled: {
                type: 'boolean'
            },
            iconURL: Asset.getRef()
        }
    } as JSONSchema7));