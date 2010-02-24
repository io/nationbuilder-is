class Blurb < ActiveRecord::Base

  # FIXME: Hack to add partner_id to all finds
  # See initializers/partner_hack.rb
  class << self
    alias_method_chain :find, :condition_cleansing
  end

  NAMES = ["intro", "header", "footer", "rules", "warnings", "signup_intro", "invite_intro", "not_verified", "partner_intro", "signup_quick", "privacy", "faq", "about", "textile", "ad_intro", "ad_new", "acquisition_new", "document_new", "docs_needed_intro", "point_new", "point_revision_new", "points_needed_intro", "tags_intro", "your_network_intro", "sorting_instruct", "sorting_instruct_adv", "overview_more", "network_intro", "account_delete", "legislators_intro", "people_you_know_intro", "about_menu_extra"]

  validates_presence_of :name
  validates_uniqueness_of :name, :scope => [:partner_id]

  after_save :clear_cache
  
  def clear_cache
    Rails.cache.delete('blurb-' + name)
    return true
  end

  def Blurb.fetch_liquid(name)
    liquid_blurb = Rails.cache.read("blurb-#{name}#{Partner.current ? Partner.current.id : ''}") # FFJ: Added partner scope
    if not liquid_blurb
      blurb = Blurb.find_by_name(name)
      if blurb
        liquid_blurb = Liquid::Template.parse(blurb.content)
      else
        liquid_blurb = Liquid::Template.parse(Blurb.fetch_default(name))
      end
      Rails.cache.write("blurb-#{name}#{Partner.current ? Partner.current.id : ''}",liquid_blurb) # FFJ: Added partner scope
    end
    return liquid_blurb
  end

  def Blurb.fetch_default(name)
    File.open(RAILS_ROOT + "/app/views/blurbs/defaults/" + name + ".html.liquid", "r").read    
  end

end
