class PriorityConnector
  attr_reader :priority_connectable
  attr_reader :priority_connection_attrs

  def initialize(priority_connectable, priority_connection_attrs)
    @priority_connectable = priority_connectable
    @priority_connection_attrs = priority_connection_attrs
  end

  def connect
    connection = PriorityConnection.create!(
      priority_connection_data(priority_connection_attrs))

    make_indirect_connections if connection.persisted? && connection.direct
  end

  private

  def priority_connection_data(priority_connection_attrs)
    priority_connection_attrs.tap do |attrs|
      attrs[:priority_connectable] = priority_connectable
    end
  end

  def make_indirect_connections
    indirectly_connect_ancestors
    indirectly_connect_descendant_programs
  end

  def indirectly_connect_ancestors
    priority_connectable.ancestors.each do |ancestor|
      PriorityConnector.new(
        ancestor,
        indirect_priority_connection_attrs
      ).connect
    end
  end

  def indirectly_connect_descendant_programs
    priority_connectable.all_programs.each do |program|
      PriorityConnector.new(
        program,
        indirect_priority_connection_attrs
      ).connect
    end
  end

  def indirect_priority_connection_attrs
    priority_connection_attrs.tap do |attrs|
      attrs[:direct] = false
    end
  end
end
