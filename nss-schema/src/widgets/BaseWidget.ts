import {mergeDeep} from "../common/utils";
import {WithComment} from "../common";

export default mergeDeep({}, WithComment, {
    type: 'object',
    additionalProperties: false,
    required: ['type']
});