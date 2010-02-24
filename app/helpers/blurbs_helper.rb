module BlurbsHelper

  def blurb(name)
    if liquid_blurb = Blurb.fetch_liquid(name)
      return '<div id="blurb_' + name + '" class="blurb">' + liquid_blurb.render({"government" => current_government, "user" => current_user, "partner" => current_partner}, :filters => [LiquidFilters]) + '</div>'
    end
  end

end
