import {mergeDeep} from "../common/utils";
import {withAccessibility, WithComment} from "../common";

export default mergeDeep({}, WithComment, {
    type: 'object',
    additionalProperties: false,
    required: ['type']
}, withAccessibility);
