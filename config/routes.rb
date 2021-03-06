# Redmine plugin for Document Management System "Features"
#
# Copyright (C) 2011    Vít Jonáš <vit.jonas@gmail.com>
# Copyright (C) 2012    Daniel Munn <dan.munn@munnster.co.uk>
# Copyright (C) 2011-14 Karel Pičman <karel.picman@kontron.com>
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.

RedmineApp::Application.routes.draw do

  #
  # rcb controller
  #   /projects/<project>/rcb
  #   [As this controller also processes 'folders' it maybe better to branch into a folder route rather than leaving it as is]
  ##
  post '/projects/:id/rcb/entries', :controller => 'rcb', :action => 'entries_operation'
  get '/projects/:id/rcb/entries/download_email_entries', :controller => 'rcb', :action => 'download_email_entries', :as => 'download_email_entries'
  get '/projects/:id/rcb/', :controller => 'rcb', :action => 'show', :as => 'rcb_folder'
end