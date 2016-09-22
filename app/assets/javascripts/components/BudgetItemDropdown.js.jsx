var BudgetItemDropdown = React.createClass({
  getInitialState: function() {
    return {
      budgetItemId: '1'
    }
  },
  handleInputChange: function(event) {
    this.setState({
      budgetItemId: event.target.value
    })
  },
  render: function() {
    return (
      <div>
        <p>Value of input: {this.state.budgetItemId}</p>
        <input type='text' value={this.state.budgetItemId} onChange={this.handleInputChange}/>
      </div>
    )
  }
})
