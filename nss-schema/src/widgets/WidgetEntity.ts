import SchemaEntity from "../common/SchemaEntity";

export const widgetsSegment = 'widgets';

export default class WidgetEntity extends SchemaEntity {
    public get segment() { return widgetsSegment; }
}