import SchemaEntity from "./common/SchemaEntity";
import ScreenId from "./dynEnums/ScreenId";

export const routeSegment = 'routes';

const Interruptions = ['onPendingRegistration', 'onPendingEmailVerification', 'onLoginIdentifierExists', 'onError', 'onBack'];
const Success = 'onSuccess';
const RouteEvents = Interruptions.concat([Success]);

export const RouteAction = new SchemaEntity(`${routeSegment}/RouteAction`, {
    description: `The action to be taken from a routing event, e.g ${Success}`,
    anyOf: [
        ScreenId.getRef(),
        {
            description: 'Special actions effecting navigations',
            enum: [
                '_dismiss'
            ]
        }
    ]
});

export const Routing = new SchemaEntity(`${routeSegment}/Routes`, {
    type: 'object',
    additionalProperties: false,
    properties: RouteEvents.reduce((routeEventsSchema, routeEvent) => {
        routeEventsSchema[routeEvent] = RouteAction.getRef();
        return routeEventsSchema;
    }, {}),
});