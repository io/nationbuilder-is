# Copyright (C) 2009,2010 Róbert Viðar Bjarnason
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Affero General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

module PortalHelper
  def default_portal_update(portal_html,portal_container, admin)
    page<<"jQuery('#main-portal-div').html('#{portal_html}');"
    page << "setup_columns();"
  end

  def setup_priorities_newest(limit)
    get_cached_priorities("Priority.published.newest.item_limit(#{limit})")
    {:priorities=>@priorities, :endorsements=>get_endorsements, :more=>newest_priorities_url}
  end

  def setup_priorities_top(limit)
    get_cached_priorities("Priority.published.top_rank.item_limit(#{limit})")
    {:priorities=>@priorities, :endorsements=>get_endorsements, :more=>top_priorities_url}
  end

  def setup_priorities_rising(limit)
    get_cached_priorities("Priority.published.rising.item_limit(#{limit})")
    {:priorities=>@priorities, :endorsements=>get_endorsements, :more=>rising_priorities_url}
  end


  def setup_priorities_falling(limit)
    get_cached_priorities("Priority.published.falling.item_limit(#{limit})")
    {:priorities=>@priorities, :endorsements=>get_endorsements, :more=>falling_priorities_url}
  end

  def setup_priorities_controversial(limit)
    get_cached_priorities("Priority.published.controversial.item_limit(#{limit})")
    {:priorities=>@priorities, :endorsements=>get_endorsements, :more=>controversial_priorities_url}
  end

  def setup_priorities_finished(limit)
    get_cached_priorities("Priority.published.finished.by_most_recent_status_change.item_limit(#{limit})")
    {:priorities=>@priorities, :endorsements=>get_endorsements, :more=>finished_priorities_url}
  end

  def setup_priorities_latest_processes(limit)
    get_cached_priorities("PriorityProcess.latest_updated_priorities(#{limit})")
    {:priorities=>@priorities, :endorsements=>get_endorsements, :more=>nil}
  end

  def setup_priorities_random(limit)
    if User.adapter == 'postgresql'
      @priorities = Priority.published.paginate :order => "RANDOM()", :page => 1, :per_page => limit
    else
      @priorities = Priority.published.paginate :order => "rand()", :page => 1, :per_page => limit
    end
    {:more=>random_priorities_url, :priorities=>@priorities, :endorsements=>get_endorsements}
  end
  
  private
  
  def get_cached_priorities(code_function)
    key = code_function.gsub("(","").gsub(")","")
    @priorities = Rails.cache.read(key)
    if not @priorities
      eval("@priorities = #{code_function}")
      Rails.cache.write(key, @priorities, :expires_in => 5.minutes) if @priorities
    end
  end

  def get_endorsements
    endorsements = nil
    if logged_in? # pull all their endorsements on the priorities shown
      endorsements = current_user.endorsements.active.find(:all, :conditions => ["priority_id in (?)", @priorities.collect {|c| c.id}])
    end
    endorsements
  end
end
