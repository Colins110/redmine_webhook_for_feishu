class CreateWebhooks < ActiveRecord::Migration[4.2]
  def change
    create_table :webhooks do |t|
      t.string :gettokenUrl
      t.string :app_id
      t.string :app_secret
      t.string :getidUrl
      t.string :imUrl
      t.integer :project_id
    end
  end
end
