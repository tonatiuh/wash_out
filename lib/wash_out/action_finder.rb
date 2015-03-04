module WashOut::ActionFinder
  def self.find_in_controller(controller, soap_action)
    controller_action = controller.soap_actions[soap_action]
    return controller_action if controller_action

    soap_action = find_suffixed_soap_action_in(controller, soap_action)
    find_in_controller(controller, soap_action) if soap_action
  end

  def self.find_suffixed_soap_action_in(controller, soap_action, suffix = /Request/)
    match_position = soap_action =~ suffix
    return unless match_position

    soap_action[0, match_position]
  end
end
