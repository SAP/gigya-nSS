import Screen from "./Screen";
import ScreenId, {ScreenIdPattern} from "./dynEnums/ScreenId";
import {Routing} from "./RoutingSchema";
import widgets from './widgets';
import {mergeDeep} from "./common/utils";
import Themes from "./Themes";
import {definitions} from "./common/definitions";
import i18n from "./i18n";

widgets.map(w => w);

export default mergeDeep({}, Themes,  {
    description: 'ScreenSet\'s configuration',
    type: 'object',
    additionalProperties: false,
    required: [
        'screens'
    ],
    properties: {
        useSchemaValidations: {
            type: 'boolean',
            default: false
        },
        platformAware: {
            type: 'boolean',
            default: false
        },
        platformAwareMode: {
            type: 'string',
            default: 'material'
        },
        routing: {
            description: 'General routing definitions',
            additionalProperties: false,
            type: 'object',
            required: [
                'initial'
            ],
            properties: {
                initial: ScreenId.getRef(),
                default: Routing.getRef()
            }
        },
        screens: {
            description: 'Available screens in the set. Each property is the screen\'s id',
            type: 'object',
            additionalProperties: false,
            patternProperties: {
               [ScreenIdPattern]: Screen.getRef()
            }
        },
        i18n: i18n.getRef()
    },
    definitions
});
