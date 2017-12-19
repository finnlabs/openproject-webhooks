class CreateWebhookLogs < ActiveRecord::Migration[5.0]
  def change
    create_table :webhooks_logs do |t|
      t.references :webhooks_webhook, foreign_key: { on_delete: :cascade }
      t.references :webhooks_event, foreign_key: { on_delete: :cascade }
      t.string :action
      t.string :url
      t.integer :response_code
      t.string :response_body

      t.timestamps
    end
  end
end
