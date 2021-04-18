import {StyleProperty} from "../StyleValues";

export default new StyleProperty('fontWeight', {
    oneOf: [
        {
            type: 'number',
            minimum: 1,
            maximum: 9
        },
        {
            enum: ['bold']
        }
    ]
});
