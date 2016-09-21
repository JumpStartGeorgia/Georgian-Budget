var TimeSeriesChart = React.createClass({

  // When the DOM is ready, create the chart.
  componentDidMount: function() {
    options = {
      title: {
        text: 'Spent Finances',
        x: -20 //center
      },
      subtitle: {
        text: this.props.name,
        x: -20
      },
      legend: {
        enabled: false
      },
      xAxis: {
        categories: this.props.timePeriods
      },
      yAxis: {
        title: {
          text: 'Amount Spent (lari)'
        },
      },
      series: [{
        data: this.props.amounts
      }]
    }

    // Set container which the chart should render to.
    this.chart = new Highcharts.Chart(
        this.props.container,
        options
    );
  },

  //Destroy chart before unmount.
  componentWillUnmount: function () {
      this.chart.destroy();
  },

  //Create the div which the chart will be rendered to.
  render: function () {
    return <div id={this.props.container}></div>
  }
});

TimeSeriesChart.propTypes = {
  container: React.PropTypes.string.isRequired,
  timePeriods: React.PropTypes.array.isRequired,
  amounts: React.PropTypes.array.isRequired,
  name: React.PropTypes.string
}
