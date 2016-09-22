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
        budgetItemIds: [6244]
      },
      function (response) {
        component.setState({
          budgetItems: response.budget_items
        })
      }
    )
  },
  render: function() {
    if (this.state.budgetItems.length === 0) {
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
