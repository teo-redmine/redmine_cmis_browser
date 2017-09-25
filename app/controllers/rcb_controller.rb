# encoding: utf-8
#
# Redmine plugin for Document Management System "Features"
#
# Copyright (C) 2011    Vít Jonáš <vit.jonas@gmail.com>
# Copyright (C) 2012    Daniel Munn <dan.munn@munnster.co.uk>
# Copyright (C) 2011-15 Karel Pičman <karel.picman@kontron.com>
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

class RcbController < ApplicationController
  unloadable

  class ZipMaxFilesError < StandardError; end
  class FileNotFound < StandardError; end

  before_filter :find_project
  before_filter :authorize
  before_filter :find_folder
  
  accept_api_auth :show

  helper :all

  def show
    @file_view_allowed = User.current.allowed_to?(:view_rcb_files, @project)

    # stub
    @subfolders = @folder.subfolders
    @files = @folder.attachments
    respond_to do |format|
      format.html {
        render :layout => !request.xhr?
      }
      format.api
    end
    return
    # end stub
  end  

  def entries_operation
    # Download/Email
    selected_folders = params[:subfolders] || []
    selected_files = params[:files] || []

    if selected_folders.blank? && selected_files.blank?
      flash[:warning] = l(:warning_no_entries_selected)
      redirect_to :back
      return
    end
   
    download_entries(selected_folders, selected_files)
  rescue ZipMaxFilesError
    flash[:error] = l(:error_max_files_exceeded, :number => Setting.plugin_redmine_cmis_browser['rcb_max_file_download'])
    redirect_to :back
  rescue FileNotFound
    render_404
  rescue RcbAccessError
    render_403    
  end

  private

  def log_activity(file, action)
    Rails.logger.info "#{Time.now.strftime('%Y-%m-%d %H:%M:%S')} #{User.current.login}@#{request.remote_ip}/#{request.env['HTTP_X_FORWARDED_FOR']}: #{action} rcb://#{file.project.identifier}/#{file.id}"
  end

  def download_entries(selected_folders, selected_files)
    begin
      zip = RcbZip.new
      zip_entries(zip, selected_folders, selected_files)

      send_file(zip.finish,
        :filename => filename_for_content_disposition("#{@project.name}-#{DateTime.now.strftime('%y%m%d%H%M%S')}.zip"),
        :type => 'application/zip',
        :disposition => 'attachment')
    rescue Exception      
      raise
    ensure
      zip.close if zip
    end
  end

  def zip_entries(zip, selected_folders, selected_files)
    member = Member.where(:user_id => User.current.id, :project_id => @project.id).first
    if selected_folders && selected_folders.is_a?(Array)
      selected_folders.each do |selected_folder_id|
        folder = RedmineRca::Folder.new(selected_folder_id)
        
        zip.add_folder_rca(folder, nil) if folder
      end
    end

    if selected_files && selected_files.is_a?(Array)
      selected_files.each do |selected_file_id|
        file = Attachment.find(selected_file_id)

        unless (file.project == @project) || User.current.allowed_to?(:view_rcb_files, file.project)
          raise RcbAccessError
        end

        zip.add_file_rca(file, nil) if file
      end
    end
    max_files = Setting.plugin_redmine_cmis_browser['rcb_max_file_download'].to_i
    if max_files > 0 && zip.files.length > max_files
      raise ZipMaxFilesError, zip.files.length
    end
    zip
  end

  def find_folder
    @folder = RedmineRca::Folder.new(params[:folder_id].present? ? params[:folder_id] : @project.cmis_object_id)
  rescue RcbAccessError
    render_403
  rescue ActiveRecord::RecordNotFound
    render_404    
  end

  private

  def e_params
    params.fetch(:email, {}).permit(
      :to, :zipped_content, :email,
      :cc, :subject, :zipped_content => [], :files => [])
  end
  
end
