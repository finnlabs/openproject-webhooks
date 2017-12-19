module ::Webhooks
  module Outgoing
    module Webhooks
      class RowCell < ::RowCell
        include ::IconsHelper

        def webhook
          model
        end

        def name
          link_to webhook.name,
                  { controller: table.target_controller, action: :show, webhook_id: webhook.id }
        end

        def enabled
          if webhook.enabled
            op_icon 'icon-yes'
          else
            op_icon 'icon-no'
          end
        end

        def events
          selected_events = webhook.events
          count = selected_events.count

          if count <= 3
            selected_events.pluck(:name).join(', ')
          else
            content_tag('span', count, class: 'badge -border-only')
          end
        end

        def selected_projects
          selected = webhook.project_ids.count

          if selected.zero?
          "(#{I18n.t(:label_all)})"
          elsif selected <= 3
            webhook.projects.pluck(:name).join(', ')
          else
            content_tag('span', selected, class: 'badge -border-only')
          end
        end

        def row_css_class
          'webhooks--outgoing-webhook-row'.freeze
        end

        ###

        def button_links
          [edit_link, delete_link]
        end

        def edit_link
          link_to I18n.t(:button_edit),
                  { controller: table.target_controller, action: :edit, webhook_id: webhook.id },
                  class: 'button--link'
        end

        def delete_link
          link_to I18n.t(:button_delete),
                  { controller: table.target_controller, action: :destroy, webhook_id: webhook.id },
                  data: { method: 'delete', confirm: I18n.t(:text_are_you_sure) },
                  class: 'button--link'
        end
      end
    end
  end
end
