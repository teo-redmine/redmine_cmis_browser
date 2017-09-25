# encoding: utf-8
# 
# Redmine plugin for Document Management System "Features"
#
# Copyright (C) 2011    Vít Jonáš <vit.jonas@gmail.com>
# Copyright (C) 2012    Daniel Munn <dan.munn@munnster.co.uk>
# Copyright (C) 2011-16 Karel Pičman <karel.picman@kontron.com>
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

require 'redmine'
require 'redmine_rcb'
require 'zip'

Redmine::Plugin.register :redmine_cmis_browser do
  name 'Redmine CMIS Browser'
  author 'Junta de Andalucía - Guadaltel'
  description 'Plugin para visualizar y descargar contenido de repositorio CMIS de Alfresco'
  version '1.0.0'
  url 'https://github.com/teo-redmine/redmine_cmis_browser.git'
  author_url 'http://www.guadaltel.com'
  
  requires_redmine :version_or_higher => '3.0.0'
  
  settings  :partial => 'settings/rcb_settings',
    :default => {
      'rcb_max_file_download' => '0'
    }
  
  menu :project_menu, :rcb, { :controller => 'rcb', :action => 'show' }, :caption => :menu_rcb, :after => :repository, :param => :id
    
  project_module :rcb do
    permission :view_rcb_folders,
      {:rcb => [:show]},
      :read => true
    permission :view_rcb_files, 
      {:rcb => [:entries_operation]}, 
      :read => true
  end

  # Rubyzip configuration
  Zip.unicode_names = true
end
