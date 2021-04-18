import {JSONSchema7} from "json-schema";
import {addDefinition, getRefTo} from "./definitions";


export default class SchemaEntity {
    constructor(public refKey: string, public schema: JSONSchema7) {
        this.refKey = this.segment ? `${this.segment}/${refKey}` : refKey;
        addDefinition(this.refKey, schema);
    }

    public getRef() {
        return getRefTo(this.refKey);
    }

    public get segment() { return ''; }
}
