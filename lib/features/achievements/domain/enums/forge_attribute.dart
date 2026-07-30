import 'package:reforge/generated/i18n/translations.g.dart';

enum ForgeAttribute {
  kobo,
  kannuki,
  kozuchi,
  sensho,
  kobokai,
}

const forgeAttributesDisplayOrder = <ForgeAttribute>[
  ForgeAttribute.kobo,
  ForgeAttribute.kozuchi,
  ForgeAttribute.sensho,
  ForgeAttribute.kobokai,
  ForgeAttribute.kannuki,
];

extension ForgeAttributeX on ForgeAttribute {
  String title(Translations t) {
    return switch (this) {
      ForgeAttribute.kobo => t.achievements.forgeAttributes.kobo.title,
      ForgeAttribute.kozuchi => t.achievements.forgeAttributes.kozuchi.title,
      ForgeAttribute.sensho => t.achievements.forgeAttributes.sensho.title,
      ForgeAttribute.kobokai => t.achievements.forgeAttributes.kobokai.title,
      ForgeAttribute.kannuki => t.achievements.forgeAttributes.kannuki.title,
    };
  }

  String subtitle(Translations t) {
    return switch (this) {
      ForgeAttribute.kobo => t.achievements.forgeAttributes.kobo.subtitle,
      ForgeAttribute.kozuchi => t.achievements.forgeAttributes.kozuchi.subtitle,
      ForgeAttribute.sensho => t.achievements.forgeAttributes.sensho.subtitle,
      ForgeAttribute.kobokai => t.achievements.forgeAttributes.kobokai.subtitle,
      ForgeAttribute.kannuki => t.achievements.forgeAttributes.kannuki.subtitle,
    };
  }

  String description(Translations t) {
    return switch (this) {
      ForgeAttribute.kobo => t.achievements.forgeAttributes.kobo.description,
      ForgeAttribute.kozuchi => t.achievements.forgeAttributes.kozuchi.description,
      ForgeAttribute.sensho => t.achievements.forgeAttributes.sensho.description,
      ForgeAttribute.kobokai => t.achievements.forgeAttributes.kobokai.description,
      ForgeAttribute.kannuki => t.achievements.forgeAttributes.kannuki.description,
    };
  }
}
