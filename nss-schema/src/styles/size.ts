import {StyleProperty} from "./StyleValues";

export default new StyleProperty('size', {
    type: 'array',
    items: [
        {
            type: 'number',
            description: 'width'
        },
        {
            type: 'number',
            description: 'height'
        },
    ]
});