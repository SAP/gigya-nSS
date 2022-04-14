import SchemaEntity from "../common/SchemaEntity";
import SpecialField from "../SpecialField";
import AccountField from "./AccountField";

export default new SchemaEntity('dynamic/DatePickerBind', {
    type: 'object',
    required: ['day','month', 'year'],
    additionalProperties: false,
    properties: {
        type: {
            enum: [
                'date',
            ]
        },
        day: {
            oneOf: [
                SpecialField.getRef(),
                AccountField.getRef()
            ]
        },
        month: {
            oneOf: [
                SpecialField.getRef(),
                AccountField.getRef()
            ]
        },
        year: {
            oneOf: [
                SpecialField.getRef(),
                AccountField.getRef()
            ]
        },
    },
});