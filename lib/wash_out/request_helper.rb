module WashOut::RequestHelper
  def self.find_action_based_on_message_tag(soap_body, controller)
    message_tag = message_tag_from_soap_body(soap_body)

    controller.soap_actions[
      message_tag.sub(/Request$/, '')
    ]
  end

  def self.message_tag_from_soap_body(soap_body)
    soap_body.values_at(:envelope, :Envelope).compact.first
             .values_at(:body, :Body).compact.first
             .keys.first.to_s
  end
end
