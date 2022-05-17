import {mergeDeep} from "../common/utils";
import BaseWidget from "./BaseWidget";
import AccountField from "../dynEnums/AccountField";
import SpecialField from "../SpecialField";
import Validations from "./Validations";
import BasicWidget from "./BasicWidget";

export default mergeDeep({}, BasicWidget, {
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

