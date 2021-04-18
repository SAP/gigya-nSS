import {StyleProperty} from "./StyleValues";
import ColorSchema from "./ColorSchema";
import Asset from "../common/Asset";

export default new StyleProperty('background', {
    oneOf: [
        ColorSchema.getRef(),
        Asset.getRef()
    ]
});