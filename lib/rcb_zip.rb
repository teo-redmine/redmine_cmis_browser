# Redmine plugin for Document Management System "Features"
#
# Copyright (C) 2011   Vít Jonáš <vit.jonas@gmail.com>
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

require 'zip'

class RcbZip

  attr_reader :files

  def initialize()
    @zip = Tempfile.new(['rcb_zip','.zip'])
    @zip.chmod(0644)
    @zip_file = Zip::OutputStream.new(@zip.path)
    @files = []
  end

  def finish
    @zip_file.close if @zip_file
    @zip.path if @zip
  end

  def close
    @zip_file.close if @zip_file
    @zip.close if @zip
  end

  def add_file(file, member, root_path = nil)
    string_path = file.folder.nil? ? '' : "#{file.folder.rcb_path_str}/"
    string_path = string_path[(root_path.length + 1) .. string_path.length] if root_path    
    string_path += file.formatted_name(member ? member.title_format : nil)
    @zip_file.put_next_entry(string_path)
    File.open(file.last_revision.disk_file, 'rb') do |f|      
      while (buffer = f.read(8192))
        @zip_file.write(buffer)
      end
    end
    @files << file
  end

  def add_file_rca(file, path)
    string_path = ''
    if path != nil && path != ''
      string_path = path
    end
    string_path += file.cmis_name
    @zip_file.put_next_entry(string_path)
    attachment = RedmineRca::Connection.get(file.disk_filename)
    @zip_file.print attachment
    @files << file
  end

  def add_folder(folder, member, root_path = nil)
    string_path = "#{folder.rcb_path_str}/"
    string_path = string_path[(root_path.length + 1) .. string_path.length] if root_path    
    @zip_file.put_next_entry(string_path)
    folder.subfolders.visible.each { |subfolder| self.add_folder(subfolder, root_path) }
    folder.files.visible.each { |file| self.add_file(file, member, root_path) }
  end

  def add_folder_rca(folder, path)
    string_path = ''
    if path != nil && path != ''
      string_path = path
    end
    string_path += folder.title + "/"
    @zip_file.put_next_entry(string_path)
    folder.subfolders.each { |subfolder| self.add_folder_rca(subfolder, string_path) }
    folder.attachments.each { |file| self.add_file_rca(file, string_path) if file }
  end

end
