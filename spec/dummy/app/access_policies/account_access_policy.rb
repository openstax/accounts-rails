class AccountAccessPolicy
  # Contains all the rules for which requestors can do what with which Account objects.

  def self.action_allowed?(action, requestor, account)
    case action
    when :search # Anyone
      true
    end
  end

end
