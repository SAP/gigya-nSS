import SelectWidget from "./SelectWidget";
import InputWidget from "./InputWidget";
import ButtonWidget from "./ButtonWidget";
import ContainerWidget from "./ContainerWidget";
import SchemaEntity from "../common/SchemaEntity";
import LabelWidget from "./LabelWidget";
import CheckboxWidget from "./CheckboxWidget";
import {ChildRef} from "../common/WithChildren";
import {ScreenChildRef} from "../common/WithScreenChildren";
import SocialLoginButtonWidget from "./SocialLoginButtonWidget";
import SocialLoginGridWidget from "./SocialLoginGridWidget";
import ImageWidget from "./ImageWidget";
import ProfilePhotoWidget from "./ProfilePhotoWidget";
import PhoneWidget from "./PhoneWidget";
import DatePickerWidget from "./DatePickerWidget";

const widgets = [
    LabelWidget,
    ButtonWidget,
    InputWidget,
    CheckboxWidget,
    SelectWidget,
    ContainerWidget,
    SocialLoginButtonWidget,
    SocialLoginGridWidget,
    ImageWidget,
    ProfilePhotoWidget,
    PhoneWidget,
    DatePickerWidget
] as SchemaEntity[];

export const ChildWidget = new SchemaEntity(ChildRef, {
    oneOf: widgets.map(w => w.getRef())
});

export const ScreenChildWidget = new SchemaEntity(ScreenChildRef, {
    oneOf: widgets.map(w => w.getRef())
});

export default widgets;