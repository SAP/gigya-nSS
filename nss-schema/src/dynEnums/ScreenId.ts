import SchemaEntity from "../common/SchemaEntity";

export const ScreenIdPattern = '.*';
export default new SchemaEntity('dynamic/ScreenId', {
    description: 'Available screens to navigate to - populated dynamically according to the json',
    type: 'string',
    // enum: []
});