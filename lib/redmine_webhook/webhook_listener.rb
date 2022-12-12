module RedmineWebhook
  class WebhookListener < Redmine::Hook::Listener

    def skip_webhooks(context)
      return true unless context[:request]
      return true if context[:request].headers['X-Skip-Webhooks']

      false
    end

    def controller_issues_new_after_save(context = {})
      return if skip_webhooks(context)
      issue = context[:issue]
      controller = context[:controller]
      project = issue.project
      webhooks = Webhook.where(:project_id => project.project.id)
      webhooks = Webhook.where(:project_id => 0) unless webhooks && webhooks.length > 0
      return unless webhooks
      post(webhooks, issue, controller)
    end

    def controller_issues_edit_after_save(context = {})
      return if skip_webhooks(context)
      journal = context[:journal]
      controller = context[:controller]
      issue = context[:issue]
      project = issue.project
      webhooks = Webhook.where(:project_id => project.project.id)
      webhooks = Webhook.where(:project_id => 0) unless webhooks && webhooks.length > 0
      return unless webhooks
      post(webhooks, issue, controller)
    end

    def controller_issues_bulk_edit_after_save(context = {})
      return if skip_webhooks(context)
      journal = context[:journal]
      controller = context[:controller]
      issue = context[:issue]
      project = issue.project
      webhooks = Webhook.where(:project_id => project.project.id)
      webhooks = Webhook.where(:project_id => 0) unless webhooks && webhooks.length > 0
      return unless webhooks
      post(webhooks, issue, controller)
    end

    def model_changeset_scan_commit_for_issue_ids_pre_issue_update(context = {})
      issue = context[:issue]
      journal = issue.current_journal
      webhooks = Webhook.where(:project_id => issue.project.project.id)
      webhooks = Webhook.where(:project_id => 0) unless webhooks && webhooks.length > 0
      return unless webhooks
      post(webhooks, issue, nil)
    end

    private
    def post(webhooks, issue, controller)
      Thread.start do
        webhooks.each do |webhook|
          # get token
          conn = Faraday.new(url: webhook.gettokenUrl, params: {param: "1"}, headers: {"Content-Type" => "application/json; charset=utf-8"}) do |f|
            f.response :json # decode response bodies as JSON
          end

          response = conn.post do |req|
            req.body = {
              app_id: webhook.app_id,
              app_secret: webhook.app_secret
            }.to_json
          end

          token = response.body["tenant_access_token"]
          puts "token" + token

            begin
              notified = [issue.author, issue.assigned_to, issue.previous_assignee].compact.uniq

              emails = notified.collect{|notified_user| notified_user.mail}
              reqBody = {"emails" => []}
              emails.each do |email|
                reqBody['emails'].push(email)
              end

              # get open_id
              conn = Faraday.new(url: webhook.getidUrl, params: {param: "1"}, headers: {"Content-Type" => "application/json; charset=utf-8"}) do |f|
                f.response :json # decode response bodies as JSON
              end
              response = conn.post() do |req|
              req.params['user_id_type'] = 'open_id'
              req.headers['Authorization'] = 'Bearer ' + token
              req.body = reqBody.to_json
              end

            response.body["data"]["user_list"].each do |user|
              if user['user_id'] != nil
                sendMsg(webhook, user["user_id"], token, issue, controller)
              end
            end

            rescue => e
              Rails.logger.error e
            end
        end
      end
    end

    def sendMsg(webhook,open_id,token,issue,controller)
      msg = "{\"zh_cn\":
              {\"title\":\"issue更新:\",
              \"content\":
                  [
                     [{\"tag\":\"text\",\"text\":\"主题: 📄#{issue.subject}\"}],
                     [{\"tag\":\"text\",\"text\":\"由👤 #{issue.author.lastname}#{issue.author.firstname} 添加\"}],
                     [{\"tag\":\"text\",\"text\":\"指派给 👏#{issue.assigned_to.lastname}#{issue.assigned_to.firstname}\"}],
                     [{\"tag\":\"text\",\"text\":\"优先级: 📌#{issue.priority.name}\"}],
                     [{\"tag\":\"text\",\"text\":\"状态: 🔎#{issue.status.name}\"}],
                     [{\"tag\":\"text\",\"text\":\"开始日期: 🕐#{issue.start_date}\"}],
                     [{\"tag\":\"text\",\"text\":\"计划完成日期: 🕐#{issue.due_date}\"}],
                     [{\"tag\":\"a\",\"href\":\"#{controller.nil? ? "": controller.issue_url(issue)}\",\"text\":\"👀点击查看👀\"}]
                  ]}}"

      Faraday.post do |req|
        req.url webhook.imUrl
        req.params["receive_id_type"] = "open_id"
        req.headers["Content-Type"] = "application/json"
        req.headers["Authorization"] = "Bearer " + token
        req.body = {
          receive_id: open_id,
          msg_type: "post",
          content: msg
        }.to_json
      end
    end
  end
end
