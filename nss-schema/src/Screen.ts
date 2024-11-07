import {mergeDeep} from "./common/utils";
import {WithComment, WithText} from "./common";
import {Routing} from "./RoutingSchema";
import SchemaEntity from "./common/SchemaEntity";
import WithScreenChildren from "./common/WithScreenChildren";

export default new SchemaEntity('Screen', mergeDeep({},
    WithScreenChildren,
    WithComment, {
    description: 'A screen in the set',
    type: 'object',
    additionalProperties: false,
    required: [
        'children'
    ],
    properties: {
            screens: {
                enum: [
                    'login',
                    'register',
                    'account-update',
                    'forgot-password',
                    'change-password',
                    'link-account',
                    'otp',
                    'empty'
                ],
                default: 'login'
            },
        action: {
            enum: [
                'login',
                'register',
                'setAccount',
                'forgotPassword',
                'linkAccount',
                'otp',
                'none'
            ],
            default: 'none'
        },
        routing: Routing.getRef(),
        appBar: mergeDeep({}, WithText, {
            type: 'object',
            additionalProperties: false,
            required: [
                'textKey'
            ]
        }),
        onlyShowFields: {
            enum: ['empty']
        }
    }
}));
