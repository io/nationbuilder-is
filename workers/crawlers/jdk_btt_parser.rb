require "../../lib/combiner"

#RAILS_ENV='production'
RAILS_ENV='development'

require '../../config/boot'
require "#{RAILS_ROOT}/config/environment"

# Get all objects
# @priority = Priority.find(45)
@law = ProcessDocument.find(264)
@proposal = ProcessDocument.find(142)
@change = ProcessDocument.find(144)

combiner = Combiner.new

@law_elements = combiner.put_law_document_elements_into_array(@law)
#@proposal_elements = combiner.put_proposal_document_elements_into_array(@proposal)
@change_elements = combiner.put_proposal_document_elements_into_array(@change)


puts @law_elements.inspect

puts "\n\n"

# @change_elements = [
# "  Við 3. gr.
# 
# 
# 
#                   a.
# 
#   A-liður orðist svo: 5. mgr. orðast svo:
# 
# 
# 
# 
#       Á hverju fiskveiðiári er einungis heimilt að flytja af fiskiskipi aflamark, umfram
#   aflamark sem flutt er til skips, sem nemur 25% af samanlögðu aflamarki sem fiskiskipi er úthlutað. Í þessu sambandi skal aflamark metið í þorskígildum á grundvelli
#   verðmætahlutfalla einstakra tegunda, sbr. 19. gr. Heimilt er Fiskistofu að víkja frá
#   þessari takmörkun á heimild til flutnings á aflamarki vegna breytinga á skipakosti
#   útgerðar eða þegar skip hverfur úr rekstri um lengri tíma vegna alvarlegra bilana eða
#   sjótjóns, samkvæmt nánari reglum sem ráðherra setur um skilyrði flutningsins. Sé
#   aflahlutdeild flutt á milli skipa í eigu sama aðila skal heimilt að flytja aflamark sem
#   úthlutað hefur verið vegna aflahlutdeildarinnar ásamt aflahlutdeildinni.
# 
# 
# 
#                   b.
# 
#   B-liður falli brott. 
# 
# 
# 
#                   c.
# 
#   C-liður orðist svo: 6. mgr. fellur brott.
# 
# 
# 
#                   d.
# 
#   D-liður orðist svo: 7. mgr. fellur brott.",
# "  Við 4. gr. bætist nýr málsliður sem orðist svo: Þrátt fyrir ákvæði 1. efnismálsl. a-liðar
#   3. gr. skal miða við 42% í stað 25% fiskveiðiárið 2010/2011 og 36% í stað 25%
#   fiskveiðiárið 2011/2012.",
# "  Ákvæði til bráðabirgða I orðist svo:
# 
# 
# 
# 
#           Heimilt er að hluti heildarafla í skötusel hjá skipum sem ekki stunda beinar skötuselsveiðar sé utan aflamarks. Ráðherra útfærir heimildina frekar í reglugerð auk þess að
#   tiltaka nákvæma prósentutölu heimilaðs meðafla."
# ]



# @change_elements = []
# 
# proposal_document.process_document_elements.articles.each { |article|
#   article.children.each { |element|
#     @change_elements << element.content_text_only
#   }
# }


# # puts @change.process_document_elements.all.map { |e| e.content_type }.inspect
# 
# @actions = combiner.generate_actions(@change_elements)
# # @old_text = combiner.render(@law_elements, @actions)
# 
# @actions.each { |action|
#   puts action.inspect
#   puts "\n"
# }
