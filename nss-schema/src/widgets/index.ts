import SelectWidget from "./SelectWidget";
import InputWidget from "./InputWidget";
import ButtonWidget from "./ButtonWidget";
import ContainerWidget from "./ContainerWidget";
import SchemaEntity from "../common/SchemaEntity";
import LabelWidget from "./LabelWidget";
import CheckboxWidget from "./CheckboxWidget";
import {ChildRef} from "../common/WithChildren";
import SocialLoginButtonWidget from "./SocialLoginButtonWidget";
import SocialLoginGridWidget from "./SocialLoginGridWidget";
import ImageWidget from "./ImageWidget";
import ProfilePhotoWidget from "./ProfilePhotoWidget";
import PhoneWidget from "./PhoneWidget";

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
] as SchemaEntity[];

export const ChildWidget = new SchemaEntity(ChildRef, {
    oneOf: widgets.map(w => w.getRef())
});

export default widgets;