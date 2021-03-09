import {StyleProperty} from "./StyleValues";

export default new StyleProperty('margin', {
    oneOf: [
        {
            type: 'number'
        },
        {
            type: 'array',
            items: [
                {
                    type: 'number',
                    description: 'left'
                },
                {
                    type: 'number',
                    description: 'top'
                },
                {
                    type: 'number',
                    description: 'right'
                },
                {
                    type: 'number',
                    description: 'bottom'
                },
            ]
        }
    ]
});