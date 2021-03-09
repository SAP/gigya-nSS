import margin from "./margin";
import background from "./background";
import opacity from "./opacity";
import size from "./size";
import {StyleSegment, withStyle} from "./StyleValues";
import borderColor from "./borderColor";
import cornerRadius from "./cornerRadius";
import elevation from "./elevation";
import borderSize from "./borderSize";
import font from './font';
import placeholderColor from './placeholderColor'

const border = [
    borderColor,
    borderSize,
];

export {
    StyleSegment,
    withStyle,
    margin,
    font,
    border,
    opacity,
    size,
    background,
    cornerRadius,
    elevation,
    placeholderColor
};
