import {mergeDeep} from "../common/utils";
import BaseWidget from "./BaseWidget";
import Validations from "./Validations";

export default mergeDeep({}, BaseWidget, {
    required: [
        // 'bind'
    ],
    properties: {
        disabled: {
            type: 'boolean',
            default: false
        },
        sendAs: {
            type: 'string'
        },
        validations: Validations.getRef(),
        parseAs: {
            enum: ['number', 'boolean', 'string']
        }
    }
});

