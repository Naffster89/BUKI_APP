module LanguagesHelper
  def language_display(code)
    name = language_name(code)
    "#{name}"
  end

  def language_name(code)
    {
      'EN' => '🇬🇧 English',
      'EN-US' => '🇺🇸 English (US)',
      'EN-GB' => '🇬🇧 English (UK)',
      'JA' => '🇯🇵 Japanese',
      'ZH' => '🇨🇳 Chinese',
      'ZH-CN' => '🇨🇳 Chinese (Simplified)',
      'ZH-TW' => '🇹🇼 Chinese (Traditional)',
      'KO' => '🇰🇷 Korean',
      'FR' => '🇫🇷 French',
      'DE' => '🇩🇪 German',
      'ES' => '🇪🇸 Spanish',
      'ES-MX' => '🇲🇽 Spanish (Latin America)',
      'ES-LA' => '🇲🇽 Spanish (Latin America)',
      'PT' => '🇵🇹 Portuguese',
      'PT-BR' => '🇧🇷 Portuguese (Brazil)',
      'IT' => '🇮🇹 Italian',
      'RU' => '🇷🇺 Russian',
      'NL' => '🇳🇱 Dutch',
      'PL' => '🇵🇱 Polish',
      'TR' => '🇹🇷 Turkish',
      'CS' => '🇨🇿 Czech',
      'DA' => '🇩🇰 Danish',
      'EL' => '🇬🇷 Greek',
      'FI' => '🇫🇮 Finnish',
      'HU' => '🇭🇺 Hungarian',
      'RO' => '🇷🇴 Romanian',
      'SK' => '🇸🇰 Slovak',
      'SV' => '🇸🇪 Swedish',
      'BG' => '🇧🇬 Bulgarian',
      'UK' => '🇺🇦 Ukrainian',
      'UK-UA' => '🇺🇦 Ukrainian',
      'LT' => '🇱🇹 Lithuanian',
      'LV' => '🇱🇻 Latvian',
      'ET' => '🇪🇪 Estonian',
      'SL' => '🇸🇮 Slovenian',
      'HI' => '🇮🇳 Hindi',
      'ID' => '🇮🇩 Indonesian',
      'TH' => '🇹🇭 Thai',
      'VI' => '🇻🇳 Vietnamese',
      'HE' => '🇮🇱 Hebrew',
      'AR' => '🇸🇦 Arabic',
      'NB' => '🇳🇴 Norwegian',
      'MS' => '🇲🇾 Malay',
      'FA' => '🇮🇷 Persian (Farsi)',
      'SW' => '🇰🇪 Swahili',
      'AF' => '🇿🇦 Afrikaans',
      'UR' => '🇵🇰 Urdu',
      'TL' => '🇵🇭 Tagalog',
      'BN' => '🇧🇩 Bengali'
    }[code.upcase] || code.upcase
  end
end
