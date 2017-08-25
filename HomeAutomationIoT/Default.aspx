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
            <h1>Eric's IoT Experiments</h1>
        </div>
        <div id="container" style="min-width: 310px; height: 400px; margin: 0 auto"></div>
        <div>
            Data Last Updated: <label id="lastUpdated"></label>
            &nbsp;Experiment Filter
            &nbsp;<select id="experimentFilter">
                  <option value="-1" disabled selected style="display:none;">Please select.....</option>
                  </select>
            &nbsp;<input type='submit' value='Ludicrous Mode' onclick="StartLudicrousMode(); return 'false';" />

            <h3>Active Clients</h3>
            <table id="tableActiveSensors" style="border: 2px; border-color: blue;">
                <thead>
                    <tr>
                        <th>Id</th>
                        <th>Sensor Name</th>
                        <th>Last Check-in</th>
                        <th>Last Check-in Latency</th>
                        <th>Update Seconds</th>
                        <th>Mode</th>
                        <th>Vcc Voltage</th>                                                     
                        <th>WiFi Signal Strength</th>
                        <th>Software Version</th>
                        <th>Action</th>
                    </tr>
                </thead>
               <tbody></tbody>
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
                        <th>WiFi Signal Strength</th>
                        <th>Last Updated</th>
                    </tr>
                </thead>
                <tbody></tbody>
            </table>
        </div>
    </form>

    <script>
        var server = '<%=ConfigurationManager.AppSettings["LocalUrl"]%>';
        var urlApiGetTempsForChart = "http://" + server + "HomeAutomationIoTAPI/api/TempGauge/GetTempsForChart3";
        var urlApiGetActiveClients = "http://" + server + "HomeAutomationIoTAPI/api/TempGauge/GetActiveClients";
        var urlApiGetTemps = "http://" + server + "HomeAutomationIoTAPI/api/TempGauge/GetTemps";
        var urlApiGetExperiments = "http://" + server + "HomeAutomationIoTAPI/api/TempGauge/GetExperiments";
        var urlApiStartLudicrousMode = "http://" + server + "HomeAutomationIoTAPI/api/TempGauge/StartLudicrousMode/30";
        var refreshMilSeconds = 300000; // every ?
        //var refreshMilSeconds = 3000; // every 30 sec

        function DoStuff() {
            alert("Im not ready yet!!!");
        };

        function Converter(input) {
            var newdatacontainer = [];
            for (var i = 0; i < input.length; i++) {
                newdata = {};
                newdata.name = '';
                newdata.data = {};
                var sss = input[i];
                newdata.name = sss.name;

                var internaldata = [];
                for (x = 0; x < sss.data.length; x++) {
                    var lineitem = [];
                  //  debugger;
                    var dateYear = sss.data[x].Date.substring(0, 4);
                    var dateMonth = sss.data[x].Date.substring(5, 7);
                    dateMonth--;
                    var dateDay = sss.data[x].Date.substring(8, 10);
                    var dateHour = sss.data[x].Date.substring(11, 13);
                    var dateMinute = sss.data[x].Date.substring(14, 16);
                    var dateSecond = sss.data[x].Date.substring(17, 19);
                    var converted = Date.UTC(dateYear, dateMonth, dateDay, dateHour, dateMinute, dateSecond);

                    lineitem.push(converted, sss.data[x].y);
                    //lineitem.push(sss.data[x].Date, sss.data[x].y);
                    internaldata.push(lineitem);
                }
                newdata.data = internaldata;
                newdatacontainer.push(newdata);

            }
            return newdatacontainer;
        }

        $(document).ready(function () {
            GetExperiments();

            $("#experimentFilter")
                .change(function () {
                    var str = "";
                    if ($("#experimentFilter option:selected").val() != -1) {
                        alert($("#experimentFilter option:selected").text());
                    }
                })
                .change();

            RefreshAll();
            //GetTempsForGrid();
            //GetTempsForChart();
            //LastUdated();
            return false;
        });

        function RefreshAll() {
            GetExperiments();
            GetActiveSensors();
            GetTempsForChart();
            GetTempsForGrid();
            LastUdated();
            console.log("refresh milisec: " + refreshMilSeconds);

            var refreshMe = setInterval(RefreshAll, refreshMilSeconds);
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
                        tr.append("<td style='text-align: right'>" + json[i].WiFiSignalStrength + "</td>");
                        tr.append("<td>" + moment(json[i].Updated).format('MM/DD/YYYY h:mm:ss a') + "</td>");
                        $('#table').append(tr);
                    }
                });
        };

        function GetActiveSensors() {
            $.getJSON(urlApiGetActiveClients, function (activeClients) {
                PopulateActiveClients(activeClients);

            })
        };

        function StartLudicrousMode() {
            $.getJSON(urlApiStartLudicrousMode, function (activeClients) {
                debugger;
                PopulateActiveClients(activeClients.Table);
                refreshMilSeconds = activeClients.Table1[0].RefreshSeconds * 1000
                RefreshAll();
            });
        };

        function PopulateActiveClients(activeClients) {
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
                var modeBgColor = "";
                if (duration.asSeconds() > activeClients[i].UpdateSeconds)
                    modeBgColor = "lightcoral";
                else
                    modeBgColor = "lightgreen";

                tr.append("<td style='background-color: " + modeBgColor + "'>" + activeClients[i].Mode + "</td>");
                tr.append("<td>" + activeClients[i].VccVoltage + "</td>");
                tr.append("<td>" + activeClients[i].WiFiSignalStrength + "</td>");
                tr.append("<td>" + activeClients[i].SoftwareVersion + "</td>");
                tr.append("<td>  <input type='submit' value='Delete' onclick='DoStuff()'; /> </td>");
                $('#tableActiveSensors').append(tr);
            }
        };

        function GetTempsForChart() {
            $.getJSON(urlApiGetTempsForChart, function (data) {

            //    GetActiveSensors();

                //var serieseric3 =  
                //    [{
                //        "name": "Home_Downstairs_Hall", "data":
                //        [["2017-08-19T12:25:28", 77.1100], ["2017-08-20T12:25:28", 79.7900], ["2017-08-21T12:25:28", 77.7900], ["2017-08-22T12:25:28", 77.9000]]
                //    },
                //    {
                //        "name": "Home_Downstairs_xxx", "data":
                //        [["2017-08-19T12:25:28", 70.1100], ["2017-08-20T12:25:28", 77.7900], ["2017-08-21T12:25:28", 72.7900], ["2017-08-22T12:25:28", 75.9000]]
                //        }];

                //var serieseric4 =
                //    [{
                //        "name": "Home_Downstairs_Hall", "data":
                //        [["8/19/2017 12:30:11 PM", 77.1100], ["8/20/2017 12:30:11 PM", 79.7900], ["8/21/2017 12:30:11 PM", 77.7900], ["8/22/2017 12:30:11 PM", 77.9000]]
                //    },
                //    {
                //        "name": "Home_Downstairs_xxx", "data":
                //        [["8/19/2017 12:30:11 PM", 70.1100], ["8/20/2017 12:30:11 PM", 77.7900], ["8/21/2017 12:30:11 PM", 72.7900], ["8/22/2017 12:30:11 PM", 75.9000]]
                //        }];

                //var serieseric5 =
                //    [{
                //        "name": "Home_Downstairs_Hall", "data":
                //        [[Date.UTC(2017, 8, 19, 14, 12, 30), 77.1100], [Date.UTC(2017, 8, 21, 14, 12, 30), 79.7900], [Date.UTC(2017, 8, 23, 14, 12, 30), 77.7900], [Date.UTC(2017, 8, 25, 14, 12, 30), 77.9000]]
                //    },
                //    {
                //        "name": "Home_Downstairs_xxx", "data":
                //        [[Date.UTC(2017, 8, 20, 14, 12, 30), 70.1100], [Date.UTC(2017, 8, 22, 14, 12, 30), 77.7900], [Date.UTC(2017, 8, 24, 14, 12, 30), 72.7900], [Date.UTC(2017, 8, 26, 14, 12, 30), 75.9000]]
                //    }];

                //var serieseric6 =
                //    [{
                //        "name": "Home_Downstairs_Hall", "data":
                //        [["Date.UTC(2017, 8, 19, 14, 12, 30), 77.1100"], ["Date.UTC(2017, 8, 21, 14, 12, 30), 79.7900"], ["Date.UTC(2017, 8, 23, 14, 12, 30), 77.7900"], ["Date.UTC(2017, 8, 25, 14, 12, 30), 77.9000"]]
                //    },
                //    {
                //        "name": "Home_Downstairs_xxx", "data":
                //        [["Date.UTC(2017, 8, 20, 14, 12, 30), 70.1100"], ["Date.UTC(2017, 8, 22, 14, 12, 30), 77.7900"], ["Date.UTC(2017, 8, 24, 14, 12, 30), 72.7900"], ["Date.UTC(2017, 8, 26, 14, 12, 30), 75.9000"]]
                //    }];

                //var serieseric6b =
                //    [{
                //        "name": "Home_Downstairs_Hall", "data":
                //        [["Date.UTC(2017, 8, 19, 14, 12, 30)", 77.1100], ["Date.UTC(2017, 8, 21, 14, 12, 30)", 79.7900], ["Date.UTC(2017, 8, 23, 14, 12, 30)", 77.7900], ["Date.UTC(2017, 8, 25, 14, 12, 30)", 77.9000]]
                //    },
                //    {
                //        "name": "Home_Downstairs_xxx", "data":
                //        [["Date.UTC(2017, 8, 20, 14, 12, 30)", 70.1100], ["Date.UTC(2017, 8, 22, 14, 12, 30)", 77.7900], ["Date.UTC(2017, 8, 24, 14, 12, 30)", 72.7900], ["Date.UTC(2017, 8, 26, 14, 12, 30)", 75.9000]]
                //    }];


                //var seriesbad =
                //    [{
                //        "data": [[{ "Date": "Date.UTC(2017,8,20,17,45,43),", "SensorTemp": 77.11 }]], "name": "Family_Room"
                //    }];

                //var serieseric7 =  //doesnt work
                //    [{
                //        "name": "Home_Downstairs_Hall", "data":
                //        ["Date.UTC(2017, 8, 19, 14, 12, 30), 77.1100", "Date.UTC(2017, 8, 21, 14, 12, 30), 79.7900", "Date.UTC(2017, 8, 23, 14, 12, 30), 77.7900", "Date.UTC(2017, 8, 25, 14, 12, 30), 77.9000"]
                //    },
                //    {
                //        "name": "Home_Downstairs_xxx", "data":
                //        ["Date.UTC(2017, 8, 20, 14, 12, 30), 70.1100", "Date.UTC(2017, 8, 22, 14, 12, 30), 77.7900", "Date.UTC(2017, 8, 24, 14, 12, 30), 72.7900", "Date.UTC(2017, 8, 26, 14, 12, 30), 75.9000"]
                //    }
                //    ];

                var serieseric8 =  //doesnt work
                    [{
                        "name": "Home_Downstairs_Hall", "data":
                        ["{Date.UTC(2017, 8, 19, 14, 12, 30), 77.1100}", "{Date.UTC(2017, 8, 21, 14, 12, 30), 79.7900}", "{Date.UTC(2017, 8, 23, 14, 12, 30), 77.7900}", "{Date.UTC(2017, 8, 25, 14, 12, 30), 77.9000}"]
                    },
                    {
                        "name": "Home_Downstairs_xxx", "data":
                        ["{Date.UTC(2017, 8, 20, 14, 12, 30), 70.1100}", "{Date.UTC(2017, 8, 22, 14, 12, 30), 77.7900}", "{Date.UTC(2017, 8, 24, 14, 12, 30), 72.7900}", "{Date.UTC(2017, 8, 26, 14, 12, 30), 75.9000}"]
                    }
                    ];

                //var serieseric9 =
                //    [{
                //        "name": "Family_Room",
                //        "data": [["Date.UTC(2017,8,20,14,12,23),78.1200"], ["Date.UTC(2017,8,20,14,17,28),78.3500"], ["Date.UTC(2017,8,20,14,22,31),78.4600"], ["Date.UTC(2017,8,20,14,27,35),78.1200"], ["Date.UTC(2017,8,20,14,32,40),77.9000"], ["Date.UTC(2017,8,20,14,37,44),78.0100"], ["Date.UTC(2017,8,20,14,42,48),78.1200"], ["Date.UTC(2017,8,20,14,47,53),77.9000"], ["Date.UTC(2017,8,20,14,52,58),77.6800"], ["Date.UTC(2017,8,20,15,3,7),77.9000"], ["Date.UTC(2017,8,20,15,8,12),77.5600"]]
                //    },
                //    {
                //        "name": "Home_Downstairs_xxx", "data":
                //        [["Date.UTC(2017, 8, 20, 14, 12, 30), 70.1100"], ["Date.UTC(2017, 8, 22, 14, 12, 30), 77.7900"], ["Date.UTC(2017, 8, 24, 14, 12, 30), 72.7900"], ["Date.UTC(2017, 8, 26, 14, 12, 30), 75.9000"]]

                //    }];
                //debugger;
                //var xx = JSON.parse(data);

                Highcharts.chart('container', {
                    chart: {
                        zoomType: 'x',
                        type: 'spline'
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
                        dateTimeLabelFormats: {
                            day: '%a %m/%d/%y'
                        },
                        labels: { rotation: -45 }
                    },
                    yAxis: {
                        title: {
                            text: 'Temperature F'
                        }
                    },

                    legend: {
                        enabled: true
                    },

                    tooltip: {
                        valueDecimals: 2,
                        valueSuffix: 'F'
                    },

                    //plotOptions: { put back in
                    //    spline: {
                    //        marker: {
                    //            enabled: true
                    //        }
                    //    },
                    //    marker: {
                    //        radius: 1
                    //    },
                    //    lineWidth: 1,
                    //    states: {
                    //        hover: {
                    //            lineWidth: 1
                    //        }
                    //    }
                    //},

                    //series: [{
                    //    name: 'Temp',
                    //    data: JSON.parse(data)
                    //}]
                    //series: [{
                    //name: 'Temp',
                    //data: [{ "name": "2017-08-19T12:24:04", "y": 77.68 }, { "name": "2017-08-19T12:25:28", "y": 78.8 }, { "name": "2017-08-19T12:29:12", "y": 77.34 }, { "name": "2017-08-19T12:30:36", "y": 78.35 }, { "name": "2017-08-19T12:34:20", "y": 77.22 }, { "name": "2017-08-19T12:35:44", "y": 78.46 }, { "name": "2017-08-19T12:39:28", "y": 77.56 }, { "name": "2017-08-19T12:40:52", "y": 78.8 }, { "name": "2017-08-19T12:44:36", "y": 77.56 }, { "name": "2017-08-19T12:45:59", "y": 78.57 }, { "name": "2017-08-19T12:49:44", "y": 77.11 }, { "name": "2017-08-19T12:51:07", "y": 78.12 }]
                    //}]

                    //series: data
                    series: Converter(JSON.parse(data)) 
                    //series: Converter(data) //doesnt work
                    //series: serieseric6c

                    //series: [{
                    //    "name": "temp1", data: [
                    //        ["8/19/2017", 78.8],
                    //        ["8/20/2017", 79.8],
                    //        ["8/21/2017", 80.8]
                    //    ]
                    //}, {
                    //    "name": "temp2", data: [
                    //        ["2017-08-19T12:25:28", 78.8],
                    //        ["2017-08-19T12:25:28", 76.8],
                    //        ["2017-08-19T12:25:28", 70.8]
                    //    ]
                    //    }]

                });
            });
        };

    </script>
</body>
</html>
