require 'redmine'

Redmine::Plugin.register :redmine_ms_projects do
  name 'IPF Issues XML Import'
  author 'Information-technology Promotion Agency, Japan'
  description 'Issue import(Excel) plugin for Redmine.'
  version '1.0.0'
  url 'http://www.ipa.go.jp/'
  author_url 'http://www.ipa.go.jp/'

  project_module :msproject do
    permission :msprojects, {:msprojects => [:index]}
  end
  menu :project_menu, :msprojects, { :controller => 'msprojects', :action => 'index' }, :caption => :msproject, :param => :project_id

end
