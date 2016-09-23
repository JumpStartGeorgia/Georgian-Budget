var DataDisplay = React.createClass({
  getInitialState: function() {
    return {
      budgetItems: []
    }
  },
  componentDidMount: function() {
    var component = this;
    $.getJSON(
      gon.api_path,
      {
        financeType: 'spent_finance',
        budgetItemIds: [1336, 990]
      },
      function (response) {
        component.setState({
          error: response.error,
          budgetItems: response.budget_items
        })
      }
    )
  },
  render: function() {
    if (this.state.error) {
      return (
        <div>
          Error from API: {this.state.error}
        </div>
      )
    } else if (this.state.budgetItems.length === 0) {
      return (
        <div>
          Data loading!
        </div>
      )
    } else {
      return (
        <div>
          {/* <p>this.props.inputValue</p> */}
          {
            this.state.budgetItems.map(
              function(budgetItem, index) {
                var unique_id = 'time-series-chart' + index

                return <TimeSeriesChart
                  key={unique_id}
                  container={unique_id}
                  name={budgetItem.name}
                  timePeriods={budgetItem.time_periods}
                  amounts={budgetItem.amounts}
                />
              }
            )
          }
        </div>
      )
    }
  }
})
