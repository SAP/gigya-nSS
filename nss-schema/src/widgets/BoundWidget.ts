import {mergeDeep} from "../common/utils";
import BaseWidget from "./BaseWidget";
import AccountField from "../dynEnums/AccountField";
import SpecialField from "../SpecialField";
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
        bind: {
            oneOf: [
                SpecialField.getRef(),
                AccountField.getRef()
            ]
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

