require 'rest-client'

#-- encoding: UTF-8
#-- copyright
# OpenProject is a project management system.
# Copyright (C) 2012-2017 the OpenProject Foundation (OPF)
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License version 3.
#
# OpenProject is a fork of ChiliProject, which is a fork of Redmine. The copyright follows:
# Copyright (C) 2006-2017 Jean-Philippe Lang
# Copyright (C) 2010-2013 the ChiliProject Team
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
#
# See doc/COPYRIGHT.rdoc for more details.
#++

class WorkPackageWebhookJob < WebhookJob
  attr_reader :webhook_id
  attr_reader :journal_id
  attr_reader :event_name

  def initialize(webhook_id, journal_id, event_name)
    @webhook_id = webhook_id
    @journal_id = journal_id
    @event_name = event_name
  end

  def perform
    binding.pry
    body = request_body
    headers = {
      content_type: :json,
      accept: :json
    }

    if signature = request_signature(body)
      headers['HTTP_X_OP_SIGNATURE'] = signature
    end

    response = RestClient.post webhook.url, request_body, headers
  rescue RestClient::Exception => e
    response = e.response

    raise e
  ensure
    ::Webhooks::Log.create(
      webhook: webhook,
      action: event_name,
      url: webhook.url,
      response_code: response.try(:code),
      response_body: response.try(:to_s)
    )
  end

  def request_signature(request_body)
    if secret = OpenProject::Configuration["webhooks_secret"]
      'sha1=' + OpenSSL::HMAC.hexdigest(OpenSSL::Digest.new('sha1'), secret, request_body)
    end
  end

  def request_body
    '{"action":"' + event_name + '","work_package":' + work_package_json + '}'
  end

  def work_package_json
    ::API::V3::WorkPackages::WorkPackageRepresenter
      .create(work_package, current_user: User.admin.first, embed_links: true)
      .to_json
  end

  def work_package
    journal.journable
  end

  def journal
    @journal ||= Journal.find(journal_id)
  end

  def webhook
    @webhook ||= Webhooks::Webhook.find(webhook_id)
  end
end
