import SchemaEntity from "./SchemaEntity";

export default new SchemaEntity('SocialProvider', {
    enum: [
        'amazon',
        'apple',
        'facebook',
        'google',
        'line',
        'linkedin',
        'twitter',
        'vkontakte',
        'wechat',
        'yahoo',
        'yahooJapan',
    ]
});
