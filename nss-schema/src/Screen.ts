import {mergeDeep} from "./common/utils";
import {WithComment, WithText} from "./common";
import {Routing} from "./RoutingSchema";
import SchemaEntity from "./common/SchemaEntity";
import WithChildren from "./common/WithChildren";

export default new SchemaEntity('Screen', mergeDeep({},
    WithChildren,
    WithComment, {
    description: 'A screen in the set',
    type: 'object',
    additionalProperties: false,
    required: [
        'children'
    ],
    properties: {
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