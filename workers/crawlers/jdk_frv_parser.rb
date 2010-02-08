# #RAILS_ENV='production'
# RAILS_ENV='development'
# 
# require '../../config/boot'
# require "#{RAILS_ROOT}/config/environment"
# 
# process_document = ProcessDocument.find(1)
# elements = process_document.process_document_elements
# 
# for element in elements
#   if element.content_type == 12
#     puts element.content_text_only
#     puts "----------------------------------\n\n"
#   end
# end

elements = [
  "     3., 4., 5. og 6. gr. laganna orðast svo:",
  "    1. gr. laganna orðast svo:    Fjármálaráðherra, fyrir hönd ríkissjóðs, er heimilt að veita Tryggingarsjóði innstæðueigenda og fjárfesta ríkisábyrgð vegna skuldbindinga sjóðsins sem stafa af lánum hans frá
  breska og hollenska ríkinu samkvæmt samningum dags. 5. júní 2009 og viðaukasamningum
  19. október sama ár til að standa straum af lágmarksgreiðslum, sbr. 10. gr. laga um innstæðutryggingar og tryggingakerfi fyrir fjárfesta, nr. 98/1999, til innstæðueigenda hjá Landsbanka
  Íslands hf. í Bretlandi og Hollandi. Þessi heimild takmarkast ekki af öðrum ákvæðum laganna. Ábyrgðin, sem í samræmi við lánasamningana gengur í gildi 5. júní 2016, ræðst einvörðungu af ákvæðum samninganna.",
  "    2. gr. laganna orðast svo ásamt fyrirsögn:Lagaleg staða.
      Ekkert í lögum þessum felur í sér viðurkenningu á því að íslenska ríkinu hafi borið skylda
  til að ábyrgjast greiðslu lágmarkstryggingar til innstæðueigenda í útibúum Landsbanka Íslands hf. í Bretlandi og Hollandi.     Fáist síðar úr því skorið, fyrir þar til bærum úrlausnaraðila, og sú úrlausn er í samræmi
  við ráðgefandi álit EFTA-dómstólsins eða eftir atvikum forúrskurð Evrópudómstólsins, að
  á íslenska ríkinu hafi ekki hvílt skylda af þeim toga sem nefnd er í 1. mgr., eða að á öðru aðildarríki EES-samningsins hafi ekki hvílt slík skylda í sambærilegu máli, skal fjármálaráðherra efna til viðræðna við aðra aðila lánasamninganna, og eftir atvikum einnig Evrópusambandið og stofnanir Evrópska efnahagssvæðisins, um það hvaða áhrif slík úrlausn kunni að
  hafa á lánasamningana og skuldbindingar ríkisins samkvæmt þeim.",
  "    3. og 4. gr. laganna falla brott.",
  "    5. gr. laganna orðast svo:    Til að fylgjast með og meta forsendur fyrir endurskoðun á lánasamningunum, sbr. endurskoðunarákvæði þeirra, skal ríkisstjórnin gera ráðstafanir til þess að Alþjóðagjaldeyrissjóðurinn geri í síðasta lagi fyrir 5. júní 2015 IV. greinar úttekt á stöðu þjóðarbúsins, einkum
  með tilliti til skuldastöðu og skuldaþols. Að auki verði í úttektinni lagt mat á þær breytingar
  sem orðið hafa miðað við mat sjóðsins frá 19. nóvember 2008.    Við mat á forsendum til endurskoðunar á samningunum skal einnig tekið tillit til stöðu í
  þjóðarbúskapnum og ríkisfjármálum á hverjum tíma og mats á horfum í þeim efnum þar sem
  m.a. verði sérstaklega litið til gjaldeyrismála, gengisþróunar og viðskiptajafnaðar, hagvaxtar
  og breytinga á landsframleiðslu svo og þróunar fólksfjölda og atvinnuþátttöku.    Ákvörðun um að óska eftir viðræðum um breytingar á lánasamningunum samkvæmt
  endurskoðunarákvæðum þeirra skal tekin með samþykki Alþingis. Meta skal hvort óska skuli
  endurskoðunar eigi síðar en 5. október 2015 og skal niðurstaða þess mats lögð fyrir Alþingi
  fyrir lok þess árs.",
  "    Eftirfarandi breytingar verða á 6. gr. laganna:
  a.      3. málsl. 2. tölul. 4. mgr. orðast svo: Um afla báta sem eingöngu stunda frístundaveiðar gilda ekki ákvæði laga nr. 24/1986, um skiptaverðmæti og greiðslumiðlun innan sjávarútvegsins. 
  b.      2. málsl. 6. mgr. orðast svo: Frístundaveiðiskip, sbr. 2. tölul. 4. mgr., sem jafnframt hafa leyfi til veiða í atvinnuskyni skulu tilkynna Fiskistofu með viku fyrirvara um upphaf og lok tímabils sem skipinu er haldið til veiða í atvinnuskyni. 
  c.      3. málsl. 6. mgr. fellur brott.",
  "Eftirfarandi breytingar verða á 11. gr. laganna:
  a.      Í stað hlutfallstölunnar „33%“ í 3. mgr. kemur: 15%. 
  b.      Við 3. mgr. bætist nýr málsliður sem orðast svo: Ráðherra getur að fenginni umsögn Hafrannsóknastofnunarinnar hækkað fyrrgreint hlutfall aflamarks í einstökum tegundum telji hann slíkt stuðla að betri nýtingu tegundarinnar. 
  c.      Í stað 1. og 2. málsl. 8. mgr. koma þrír nýir málsliðir sem orðast svo: Við línuveiðar dagróðrabáta með línu sem beitt er í landi má landa 20% umfram þann afla í þorski, ýsu og steinbít sem reiknast til aflamarks þeirra. Einnig er heimilt við línuveiðar dagróðrabáta með línu sem stokkuð er upp í landi að landa 15% umfram þann afla í þorski, ýsu og steinbít sem reiknast til aflamarks þeirra. Dagróðrabátur telst bátur sem kemur til hafnar til löndunar innan 24 klukkustunda frá því að hann heldur til veiða. 
  d.      Við bætist ný málsgrein sem orðast svo: 
                 Ráðherra getur í reglugerð ákveðið að skylt sé að vinna einstakar tegundir uppsjávarfisks til manneldis. Hlutfall uppsjávarafla einstakra skipa sem ráðstafað er til vinnslu á því tímabili sem ráðherra ákveður skal ekki vera ákveðið hærra en 70%.",
  "               Eftirfarandi breytingar verða á 15. gr. laganna:
                 a.      1. málsl. 5. mgr. orðast svo: Veiði fiskiskip minna en 50% á fiskveiðiári af úthlutuðu aflamarki sínu og aflamarki sem flutt hefur verið frá fyrra fiskveiðiári, í þorskígildum talið, fellur aflahlutdeild þess niður og skal aflahlutdeild annarra skipa í viðkomandi tegundum hækka sem því nemur. 
                 b.      Við 5. mgr. bætist nýr málsliður sem orðast svo: Hið sama á við þegar skipi er haldið til veiða utan lögsögu á tegundum sem samið hefur verið um veiðistjórn á og ekki teljast til deilistofna. 
                 c.      6. mgr. orðast svo: 
                                Tefjist skip frá veiðum í fimm mánuði samfellt vegna tjóns eða meiri háttar bilana hefur afli þess fiskveiðiárs ekki áhrif til niðurfellingar aflahlutdeildar samkvæmt þessari grein. 
                 d.      7. mgr. orðast svo: 
                                Á hverju fiskveiðiári er heimilt að flytja af fiskiskipi 50% þess aflamarks sem skipi var úthlutað í þorskígildum talið á grundvelli verðmætahlutfalla einstakra tegunda, sbr. 19. gr. Auk þess er heimilt að flytja frá skipi það aflamark í einstökum tegundum sem flutt hefur verið til skips. Heimilt er Fiskistofu að víkja frá þessari takmörkun á heimild til flutnings á aflamarki vegna varanlegra breytinga á skipakosti útgerða eða þegar skip hverfur úr rekstri um lengri tíma vegna alvarlegra bilana eða sjótjóns, samkvæmt nánari reglum sem ráðherra setur.",
  "   Lög þessi taka gildi 1. janúar 2010 að undanskildum ákvæðum c-liðar 2. gr. um línuívilnun sem taka gildi 1. mars 2010, ákvæðum 3. gr. sem taka gildi 1. september 2010 og ákvæði til bráðabirgða I sem tekur gildi 15. febrúar 2010."
]

# def parse_part(match, part)
# end

# Replace those weird little Icelandic characters with ASCII ones

def replace_weird_characters(text)
  pattern1 = ["Á", "á", "Ð", "ð", "É", "é", "Í", "í", "Ó", "ó", "Ú", "ú", "Ý", "ý", "Þ", "þ", "Æ", "æ", "Ö", "ö"]
  pattern2 = ["a", "a", "d", "d", "e", "e", "i", "i", "o", "o", "u", "u", "y", "y", "th", "th", "ae", "ae", "o", "o"]

  pattern1.each_with_index { |char,index| text.gsub!(char, pattern2[index]) }

  text
end

# Search for "x. gr.", "x. og x. gr.", "x. málsl.", "x. tölul.", "x. mgr."

def find_parts(parts, text)
  # Reset everything but "gr."
  parts.each { |key, value| parts.delete(key) if key != :gr }

  # Search for parts:
  # - 1-3 digits (1)
  # - dot (.)
  # - multiple occurrences of whitespace, dot, comma, 1-3 digits, "og" (2., 3. og 4.)
  # - space
  # - one of the follow: "gr.", "málsl.", "tölul.", "mgr."
  text.scan(/(\d{1,3}).((\s|\.|\,|\d{1,3}|og)*) (gr\.|málsl\.|tölul\.|mgr\.)/) { |match|
    values = []
    values << match[0]
    match[1].scan(/(\d{1,3})./) { |smatch| values << smatch[0] }
    parts[replace_weird_characters(match[3]).gsub!(".","").to_sym] = values
  }

  # re_digit = "(\\d{1,3})." # 1-3 digit integer
  # re_single_character = "(.?)" # Single character, optional
  # re_parts = "(gr.|málsl.|tölul.|mgr.)" # Parts
  # re_part_separator_dual = "(.?)og(.?)" # Dual parts
  # re_part_separator_multiple = "" # Multiple parts

  # # Search for a single reference
  # matches = Regexp.new("#{re_digit}#{re_single_character}#{re_parts}", Regexp::IGNORECASE).match(text)
  # if matches
  #   key = matches[3]
  #   value = matches[1]
  #   parts[replace_weird_characters(key).gsub!(".","").to_sym] = value
  # end
  # 
  # # Search for a dual reference
  # matches = Regexp.new("#{re_digit}#{re_part_separator_dual}#{re_digit}#{re_single_character}#{re_parts}", Regexp::IGNORECASE).match(text)
  # if matches
  #   key = matches[6]
  #   value1 = matches[1]
  #   value2 = matches[4]
  #   parts[replace_weird_characters(key).gsub!(".","").to_sym] = [value1, value2]
  # end

# re_digit.re_part_separator_dual(\d{1,3}).(.?)(gr.|málsl.|tölul.|mgr.)

  # Search for a single reference
  # text.scan(/(\d{1,3}).(.?)(gr.|málsl.|tölul.|mgr.)/) { |match| parts[replace_weird_characters(match[2]).gsub!(".","").to_sym] = match[0] }

  # # Search for a dual reference
  # text.scan(/(\d{1,3}).(.?)(gr.|málsl.|tölul.|mgr.)/) { |match| parts[replace_weird_characters(match[2]).gsub!(".","").to_sym] = match[0] }

end

def parse_add_new(match, element, parts)
  # MUNA AÐ LEITA EFTIR "ásamt fyrirsögn"
  puts "====================================================================\n"
  puts "ADD NEW\n"
  puts "====================================================================\n"
  puts match.inspect
  find_parts(parts, match)#.inspect
  puts parts.inspect
  puts "\n\n"
end

# def parse_append(match, element, parts)
#   # MUNA AÐ LEITA EFTIR "ásamt fyrirsögn"
#   puts "====================================================================\n"
#   puts "APPEND\n"
#   puts "====================================================================\n"
#   puts match.inspect
#   puts find_parts(parts, match).inspect
#   puts "\n\n"
# end

def parse_change(match, element, parts)
  puts "====================================================================\n"
  puts "CHANGE\n"
  puts "====================================================================\n"
  puts match.inspect
  find_parts(parts, match)#.inspect
  puts parts.inspect
  puts "\n\n"
end

def parse_remove(match, element, parts)
  puts "====================================================================\n"
  puts "REMOVE\n"
  puts "====================================================================\n"
  puts match.inspect
  find_parts(parts, match)#.inspect
  puts parts.inspect
  puts "\n\n"
end

def parse_replace_all(match, element, parts)
  # MUNA AÐ LEITA EFTIR "ásamt fyrirsögn"
  puts "====================================================================\n"
  puts "REPLACE ALL\n"
  puts "====================================================================\n"
  puts match.inspect
  find_parts(parts, match)#.inspect
  puts parts.inspect
  puts "\n\n"
end

# def parse_replace_all_with_new_headline(match, element)
#   puts "[ REPLACE W/HL ] #{match.inspect}"
# end


parts = {}

for element in elements
  # Við 3. mgr. bætist nýr málsliður sem orðast svo:
  element.gsub!(/(.*?)(bætist)(.*?)(orðast svo)(.*?)(:)/) { |match| parse_add_new(match, element, parts) }

  # # Við 3. mgr. bætist nýr málsliður sem orðast svo:
  # element.gsub!(/(.*?)(bætist)(.*?)(við)(.*?)(orðast svo)(.*?)(:)/) { |match| parse_append(match, element) }

  # 1. gr. laganna orðast svo:
  element.gsub!(/(.)(.*?)(orðast svo)(.*?)(:)/) { |match| parse_replace_all(match, element, parts) }

  # 2. gr. laganna orðast svo ásamt fyrirsögn:
  # element.gsub!(/(.)(.*?)(!bætist)(.*?)(orðast svo)(.*?)(ásamt fyrirsögn)(.?)(:)/) { |match| parse_replace_all_with_new_headline(match, element) }

  # # Við 3. mgr. bætist nýr málsliður sem orðast svo ásamt fyrirsögn:
  # element.gsub!(/(.)(.*?)(bætist)(.*?)(orðast svo)(.?)(:)/) { |match| parse_append_with_new_headline(match, element) }

  # 3. og 4 gr. laganna falla brott
  element.gsub!(/(.)(.*?)(fellur brott)(.*?)/) { |match| parse_remove(match, element, parts) }
  element.gsub!(/(.)(.*?)(falla brott)(.*?)/) { |match| parse_remove(match, element, parts) }

  # Eftirfarandi breytingar verða á 6. gr. laganna:
  element.gsub!(/(.*?)(breytingar)(.*?)(gr\.)(.*?)(:)/) { |match| parse_change(match, element, parts) }

  # puts element
  # puts "----------------------------------\n\n"
end



