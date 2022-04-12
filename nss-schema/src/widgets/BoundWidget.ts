import {mergeDeep} from "../common/utils";
import BaseWidget from "./BaseWidget";
import AccountField from "../dynEnums/AccountField";
import SpecialField from "../SpecialField";
import Validations from "./Validations";
import Global from "./BasicWidget";

export default mergeDeep({}, Global, {
    required: [
        // 'bind'
    ],
    properties: {
        bind: {
            oneOf: [
                SpecialField.getRef(),
                AccountField.getRef()
            ]
        },
    }
});

