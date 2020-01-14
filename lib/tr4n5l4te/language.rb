# frozen_string_literal: true

module Tr4n5l4te
  # rubocop:disable Metrics/ClassLength
  class Language
    # rubocop:enable Metrics/ClassLength
    TABLE = {
      'af' => 'Afrikaans',
      'sq' => 'Albanian',
      'am' => 'Amharic',
      'ar' => 'Arabic',
      'hy' => 'Armenian',
      'az' => 'Azerbaijani',
      'eu' => 'Basque',
      'be' => 'Belarusian',
      'bn' => 'Bengali',
      'bs' => 'Bosnian',
      'bg' => 'Bulgarian',
      'ca' => 'Catalan',
      'ceb' => 'Cebuano',
      'ny' => 'Chichewa',
      'zh-CN' => 'Chinese',
      'co' => 'Corsican',
      'hr' => 'Croatian',
      'cs' => 'Czech',
      'da' => 'Danish',
      'nl' => 'Dutch',
      'en' => 'English',
      'eo' => 'Esperanto',
      'et' => 'Estonian',
      'tl' => 'Filipino',
      'fi' => 'Finnish',
      'fr' => 'French',
      'fy' => 'Frisian',
      'gl' => 'Galician',
      'ka' => 'Georgian',
      'de' => 'German',
      'el' => 'Greek',
      'gu' => 'Gujarati',
      'ht' => 'Haitian Creole',
      'ha' => 'Hausa',
      'haw' => 'Hawaiian',
      'iw' => 'Hebrew',
      'hi' => 'Hindi',
      'hmn' => 'Hmong',
      'hu' => 'Hungarian',
      'is' => 'Icelandic',
      'ig' => 'Igbo',
      'id' => 'Indonesian',
      'ga' => 'Irish',
      'it' => 'Italian',
      'ja' => 'Japanese',
      'jw' => 'Javanese',
      'kn' => 'Kannada',
      'kk' => 'Kazakh',
      'km' => 'Khmer',
      'ko' => 'Korean',
      'ku' => 'Kurdish (Kurmanji)',
      'ky' => 'Kyrgyz',
      'lo' => 'Lao',
      'la' => 'Latin',
      'lv' => 'Latvian',
      'lt' => 'Lithuanian',
      'lb' => 'Luxembourgish',
      'mk' => 'Macedonian',
      'mg' => 'Malagasy',
      'ms' => 'Malay',
      'ml' => 'Malayalam',
      'mt' => 'Maltese',
      'mi' => 'Maori',
      'mr' => 'Marathi',
      'mn' => 'Mongolian',
      'my' => 'Myanmar (Burmese)',
      'ne' => 'Nepali',
      'no' => 'Norwegian',
      'ps' => 'Pashto',
      'fa' => 'Persian',
      'pl' => 'Polish',
      'pt' => 'Portuguese',
      'pa' => 'Punjabi',
      'ro' => 'Romanian',
      'ru' => 'Russian',
      'sm' => 'Samoan',
      'gd' => 'Scots Gaelic',
      'sr' => 'Serbian',
      'st' => 'Sesotho',
      'sn' => 'Shona',
      'sd' => 'Sindhi',
      'si' => 'Sinhala',
      'sk' => 'Slovak',
      'sl' => 'Slovenian',
      'so' => 'Somali',
      'es' => 'Spanish',
      'su' => 'Sundanese',
      'sw' => 'Swahili',
      'sv' => 'Swedish',
      'tg' => 'Tajik',
      'ta' => 'Tamil',
      'te' => 'Telugu',
      'th' => 'Thai',
      'tr' => 'Turkish',
      'uk' => 'Ukrainian',
      'ur' => 'Urdu',
      'uz' => 'Uzbek',
      'vi' => 'Vietnamese',
      'cy' => 'Welsh',
      'xh' => 'Xhosa',
      'yi' => 'Yiddish',
      'yo' => 'Yoruba',
      'zu' => 'Zulu'
    }.freeze

    class << self
      def code(string)
        TABLE.invert[string]
      end

      def ensure_code(string)
        fail("Invalid language: [#{string}]") unless valid?(string)

        code(string) || string
      end

      def valid?(lang_code)
        code_valid?(lang_code) || string_valid?(lang_code)
      end

      def list
        TABLE.values
      end

      def code_valid?(lang_code)
        !TABLE.fetch(lang_code, nil).nil?
      end

      def string_valid?(string)
        !code(string).nil?
      end
    end
  end
end
