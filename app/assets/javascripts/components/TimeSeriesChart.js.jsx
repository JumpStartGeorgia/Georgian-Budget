var TimeSeriesChart = React.createClass({

  // When the DOM is ready, create the chart.
  componentDidMount: function () {
    var component = this;

    $.getJSON(
      gon.api_path,
      function (response) {

        options = {
          title: {
            text: 'Spent Finances',
            x: -20 //center
          },
          subtitle: {
            text: response.name,
            x: -20
          },
          xAxis: {
            categories: response.time_periods
          },
          yAxis: {
            title: {
              text: 'Amount Spent (lari)'
            },
          },
          series: [{
            data: response.amounts
          }]
        }

        // Set container which the chart should render to.
        this.chart = new Highcharts.Chart(
            component.props.container,
            options
        );
      }
    );
  },

  //Destroy chart before unmount.
  componentWillUnmount: function () {
      this.chart.destroy();
  },

  //Create the div which the chart will be rendered to.
  render: function () {
      return React.createElement('div', { id: this.props.container });
  }
});

// TimeSeriesChart.propTypes = {
//   name: React.PropTypes.string,
//   time_periods: React.PropTypes.array.isRequired,
//
// }
