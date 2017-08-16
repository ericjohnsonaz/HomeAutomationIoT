<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Default.aspx.cs" Inherits="HomeAutomationIoT.Default" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Eric's IoT Water Temperature Monitor</title>
    <script type="text/javascript" src="Scripts/jquery-3.2.1.min.js"></script>
    <script type="text/javascript" src="Scripts/highcharts.js"></script>
    <script type="text/javascript" src="Scripts/moment.min.js"></script>
</head>
<body>
    <link href="SiteStyles.css" rel="stylesheet" type="text/css" />
    <form id="form1" runat="server">
        <div>
            <h1>GhostRider IoT Water Temperature Monitor</h1>
        </div>
        <div id="container" style="min-width: 310px; height: 400px; margin: 0 auto"></div>
        <div>
            Data Last Updated: <label id="lastUpdated"></label>
            &nbsp;Experiment Filter
            &nbsp;<select id="experimentFilter">
                  <option value="-1" disabled selected style="display:none;">Please select.....</option>
                  </select>
            &nbsp;<input type='submit' value='Ludicrous Mode' onclick='DoStuff()'; />

            <h3>Active Sensors</h3>
            <table id="tableActiveSensors" style="border: 2px; border-color: blue;">
                <thead>
                    <tr>
                        <th>Id</th>
                        <th>Sensor Name</th>
                        <th>Last Check-in</th>
                        <th>Last Check-in Latency</th>
                        <th>Update Seconds</th>
                        <th>Mode</th>
                        <th>Action</th>
                    </tr>
                </thead>
               <!-- <tbody></tbody> -->
            </table>
        </div>
        <br />
        <div>
            <h3>Raw Sensor Data</h3>
            <table id="table" style="border: 2px; border-color: blue;">
                <thead>
                    <tr>
                        <th>Id</th>
                        <th>Sensor Name</th>
                        <th>Location</th>
                        <th>Experiment</th>
                        <th>Temperature</th>
                        <th>VccVoltage</th>
                        <th>Last Updated</th>
                    </tr>
                </thead>
                <tbody></tbody>
            </table>
        </div>
    </form>

    <script>
        var server = '<%=ConfigurationManager.AppSettings["LocalUrl"]%>';
        var urlApiGetTempsForChart = "http://" + server + "HomeAutomationIoTAPI/api/TempGauge/GetTempsForChart";
        var urlApiGetActiveClients = "http://" + server + "HomeAutomationIoTAPI/api/TempGauge/GetActiveClients";
        var urlApiGetTemps = "http://" + server + "HomeAutomationIoTAPI/api/TempGauge/GetTemps";
        var urlApiGetExperiments = "http://" + server + "HomeAutomationIoTAPI/api/TempGauge/GetExperiments";

        function DoStuff() {
            alert("Im not ready yet!!!");
        };

        $(document).ready(function () {
            GetExperiments();

            $("#experimentFilter")
                .change(function () {
                    var str = "";
                    if ($("#experimentFilter option:selected").val() != -1)
                    {
                        alert($("#experimentFilter option:selected").text());
                    }
                })
                .change();

            GetTempsForGrid();
            GetTempsForChart();
            LastUdated();

            var refreshMe = setInterval(RefreshAll, 300000);  // every 5 min
        });

        function RefreshAll() {
            GetExperiments();
            GetTempsForChart();
            GetTempsForGrid();
            LastUdated();
        };

        function GetExperiments() {
            $.getJSON(urlApiGetExperiments,
                function (result) {
                    var options = $("#experimentFilter");
                    $.each(result, function () {
                        options.append($("<option />").val(this.Experiment).text(this.Experiment));
                    });
                });
        };

        function LastUdated() {
            $('#lastUpdated').text(moment(new Date()).format('MM/DD/YYYY h:mm:ss a'));
        };

        function GetTempsForGrid() {
            $.getJSON(urlApiGetTemps,
                function (json) {
                    $('#table tbody tr').remove();
                    var tr;
                    for (var i = 0; i < json.length; i++) {
                        tr = $('<tr/>');
                        tr.append("<td>" + json[i].Id + "</td>");
                        tr.append("<td>" + json[i].SensorName + "</td>");
                        tr.append("<td>" + json[i].Location + "</td>");
                        tr.append("<td>" + json[i].Experiment + "</td>");
                        tr.append("<td style='text-align: right'>" + json[i].Value + "</td>");
                        tr.append("<td style='text-align: right'>" + json[i].VccVoltage + "</td>");
                        tr.append("<td>" + moment(json[i].Updated).format('MM/DD/YYYY h:mm:ss a') + "</td>");
                        $('#table').append(tr);
                    }
                });
        };

        function GetActiveSensors() {
            $.getJSON(urlApiGetActiveClients, function (activeClients) {
                //$.getJSON('http://a250rlover.ddns.me/HomeAutomationIoTAPI/api/TempGauge/GetActiveClients', function (activeClients) {
                $('#tableActiveSensors tbody tr').remove();
                var tr;
                var currentDatetime = new moment();

                for (var i = 0; i < activeClients.length; i++) {
                    tr = $('<tr/>');
                    tr.append("<td>" + activeClients[i].Id + "</td>");
                    tr.append("<td>" + activeClients[i].SensorName + "</td>");
                    tr.append("<td>" + moment(activeClients[i].LastUpdated).format('MM/DD/YYYY h:mm:ss a') + "</td>");
                    var diff = moment(currentDatetime).diff(moment(activeClients[i].LastUpdated));
                    var duration = moment.duration(diff);

                    console.log("duration: " + duration);
                    console.log("duration days: " + duration.days());
                    console.log("duration hours: " + duration.hours());
                    console.log("duration minutes: " + duration.minutes());
                    console.log("duration seconds: " + duration.seconds());
                    console.log("duration as minutes: " + duration.asMinutes());
                    var lastCheckinVariance = "";
                    if (duration.days() > 0)
                        lastCheckinVariance += duration.days() + " Days ";
                    if (duration.hours() > 0)
                        lastCheckinVariance += duration.hours() + " Hours ";
                    if (duration.minutes() > 0)
                        lastCheckinVariance += duration.minutes() + " Minutes ";
                    lastCheckinVariance += duration.seconds() + " Seconds ";
                    var bgColor = "";
                    if (duration.asMinutes() > 15)
                        bgColor = "lightcoral";
                    else
                        bgColor = "lightgreen";

                    tr.append("<td style='background-color: " + bgColor + "'>" + lastCheckinVariance + "</td>");
                    //tr.append("<td>" + duration.days() + " Days " + duration.hours() + " Hours " + duration.minutes() + " Minutes " + duration.seconds() + " Seconds </td>");
                    tr.append("<td>" + activeClients[i].UpdateSeconds + "</td>");
                    tr.append("<td>" + activeClients[i].Mode + "</td>");
                    tr.append("<td>  <input type='submit' value='Delete' onclick='DoStuff()'; /> </td>");
                    $('#tableActiveSensors').append(tr);
                }
            });
        };

        function GetTempsForChart() {
            $.getJSON(urlApiGetTempsForChart, function (data) {
                //$.getJSON('http://a250rlover.ddns.me/HomeAutomationIoTAPI/api/TempGauge/GetTempsForChart', function (data) {

                GetActiveSensors();

                Highcharts.chart('container', {
                    chart: {
                        zoomType: 'x'
                    },
                    title: {
                        text: 'Temperature Readings'
                    },
                    subtitle: {
                        text: document.ontouchstart === undefined ?
                            'Click and drag in the plot area to zoom in' : 'Pinch the chart to zoom in'
                    },
                    xAxis: {
                        type: 'datetime',

                        xAxis: {
                            type: 'datetime',
                            labels: {
                                format: '{value:%Y-%b-%e}'
                            },
                        },
                        //labels: {
                        //    rotation: -45,
                        //    format: '{value:%Y-%b-%e}'

                        //formatter: function () {
                        //    console.log(this.value);
                        //    console.log("moment value");
                        //    console.log(moment(this.value).format('MM/DD/YYYY hh:mm a'));
                        //    return Date.parse(this.value);
                        //}
                        //}
                    },
                    yAxis: {
                        title: {
                            text: 'Temperature F'
                        }
                    },
                    legend: {
                        enabled: false
                    },
                    plotOptions: {
                        area: {
                            fillColor: {
                                linearGradient: {
                                    x1: 0,
                                    y1: 0,
                                    x2: 0,
                                    y2: 1
                                },
                                stops: [
                                    [0, Highcharts.getOptions().colors[0]],
                                    [1, Highcharts.Color(Highcharts.getOptions().colors[0]).setOpacity(0).get('rgba')]
                                ]
                            },
                            marker: {
                                radius: 2
                            },
                            lineWidth: 1,
                            states: {
                                hover: {
                                    lineWidth: 1
                                }
                            },
                            threshold: null
                        }
                    },

                    series: [{
                        type: 'area',
                        name: 'Temp',
                        data: JSON.parse(data)
                    }]
                });
            });
        };

    </script>
</body>
</html>
