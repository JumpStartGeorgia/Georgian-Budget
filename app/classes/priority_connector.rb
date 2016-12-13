class PriorityConnector
  attr_reader :priority_connectable

  def initialize(priority_connectable)
    @priority_connectable = priority_connectable
  end

  def connect(priority_connection_attr)
    PriorityConnection.create!(
      priority_connection_data(priority_connection_attr)
    )
  end

  private

  def priority_connection_data(priority_connection_attr)
    data = priority_connection_attr.clone
    data[:priority_connectable] = priority_connectable
    data
  end
end
