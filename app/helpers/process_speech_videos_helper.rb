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

module ProcessSpeechVideosHelper
  def video_share_title(video)
    "#{video.title} #{t(:about_process)} #{video.process_discussion.priority_process.priority.external_info_1} - #{video.process_discussion.stage_sequence_number}. #{t(:stage_sequence_discussion)}"
  end

  def video_share_description(video)
    "#{video.title} #{t(:about_process)} #{video.process_discussion.priority_process.priority.external_info_1} (#{video.process_discussion.priority_process.priority.external_info_2}) / #{video.process_discussion.priority_process.priority.external_info_3} - #{video.process_discussion.stage_sequence_number}. #{t(:stage_sequence_discussion)}"
  end
end
