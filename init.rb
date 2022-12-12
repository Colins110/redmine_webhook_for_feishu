if Rails.try(:autoloaders).try(:zeitwerk_enabled?)
  Rails.autoloaders.main.push_dir File.dirname(__FILE__) + '/lib/redmine_webhook'
  RedmineWebhook::ProjectsHelperPatch
  RedmineWebhook::WebhookListener
else
  require "redmine_webhook"
end

Redmine::Plugin.register :redmine_webhook do
  name 'Redmine Webhook plugin for FeiShu'
  author 'colin'
  description 'A Redmine plugin posts webhook to FeiShu on creating and updating tickets'
  version '0.0.5'
  url 'https://github.com/Colins110/redmine_webhook_for_feishu'
  author_url 'https://github.com/Colins110'
  project_module :webhooks do
    permission :manage_hook, {:webhook_settings => [:index, :show, :update, :create, :destroy]}, :require => :member
  end
end
