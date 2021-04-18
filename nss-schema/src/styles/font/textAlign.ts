import {StyleProperty} from "../StyleValues";

export default new StyleProperty('textAlign', {
    enum: [
        'start',
        'end',
        'center',
    ],
    default: 'start'
});
