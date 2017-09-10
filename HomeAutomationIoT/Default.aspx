<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Default.aspx.cs" Inherits="HomeAutomationIoT.Default" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Eric's IoT Water Temperature Monitor</title>
    <script type="text/javascript" src="Scripts/jquery-3.2.1.min.js"></script>
    <script type="text/javascript" src="Scripts/highcharts.js"></script>
    <script type="text/javascript" src="Scripts/moment.min.js"></script>
    <script type="text/javascript" src="Scripts/jquery-ui-1.12.1.min.js"></script>
    <link href="Styles/SliderStyle.css" rel="stylesheet" />
</head>
<body>
    <link href="SiteStyles.css" rel="stylesheet" type="text/css" />
    <form id="form1" runat="server">
        <div>
            <h1>Eric's IoT Experiments</h1>
        </div>
        <div id="container" style="min-width: 310px; height: 400px; margin: 0 auto"></div>

        <div id="time-range">
            Time Range: <span class="slider-time"></span>&nbsp; To &nbsp; <span class="slider-time2"></span>
            <div class="sliders_step1">
                <div id="slider-range"></div>
            </div>
            <br />
        </div>
        <div>
            Data Last Updated:
            <label id="lastUpdated"></label>
            &nbsp;Experiment Filter
            &nbsp;<select id="experimentFilter">
                <option value="-1" disabled selected style="display: none;">Please select.....</option>
            </select>

            &nbsp;<input type='submit' value='Ludicrous Mode' onclick="return StartLudicrousMode();;" />

            <h3>Active Clients</h3>
            <table id="tableActiveSensors" style="border: 2px; border-color: blue;">
                <thead>
                    <tr>
                        <%--<th>Id</th>--%>
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
                        <th>Software Version</th>
                        <th>Free Heap</th>
                        <th>Last Updated</th>
                    </tr>
                </thead>
                <tbody></tbody>
            </table>
        </div>
    </form>

    <script>
        var server = '<%=ConfigurationManager.AppSettings["LocalUrl"]%>';
        var urlApiGetTempsRawForChart = "http://" + server + "HomeAutomationIoTAPI/api/TempGauge/GetTempsForChart";
        var urlApiGetTempsRawForChartV211 = "http://" + server + "HomeAutomationIoTAPI/api/TempGauge/GetTempsForChart/V211";

        var urlApiGetActiveClients = "http://" + server + "HomeAutomationIoTAPI/api/TempGauge/GetActiveClients";
        var urlApiGetTempsRaw = "http://" + server + "HomeAutomationIoTAPI/api/TempGauge/GetTempsRaw";
        var urlApiGetExperiments = "http://" + server + "HomeAutomationIoTAPI/api/TempGauge/GetExperiments";
        var urlApiStartLudicrousMode = "http://" + server + "HomeAutomationIoTAPI/api/TempGauge/StartLudicrousMode/30";
        var urlApiDeleteDeviceLogSensor = "http://" + server + "HomeAutomationIoTAPI/api/TempGauge/DeleteDeviceLogSensor";

      //  var refreshMilSeconds = 300000; // every ?
        var refreshMilSeconds = 300000; // every 30 sec

        var startTicks;
        var endTicks;

        function DoStuff() {
            alert("Im not ready yet!!!");
        };

        function Converter(input) {
            var allSensors = [];
            for (var i = 0; i < input.length; i++) {
                internalData = {};
                internalData.name = '';
                internalData.data = {};
                var lineItemObj = input[i];
                internalData.name = lineItemObj.name;

                var internaldata = [];
                for (x = 0; x < lineItemObj.data.length; x++) {
                    var lineitem = [];
                    var dateYear = lineItemObj.data[x].Date.substring(0, 4);
                    var dateMonth = lineItemObj.data[x].Date.substring(5, 7);
                    dateMonth--;
                    var dateDay = lineItemObj.data[x].Date.substring(8, 10);
                    var dateHour = lineItemObj.data[x].Date.substring(11, 13);
                    var dateMinute = lineItemObj.data[x].Date.substring(14, 16);
                    var dateSecond = lineItemObj.data[x].Date.substring(17, 19);
                    var converted = Date.UTC(dateYear, dateMonth, dateDay, dateHour, dateMinute, dateSecond);
                    //   debugger;
                    //  (moment(new Date()).format('MM/DD/YYYY h:mm:ss a'));


                    //     var xx = (moment(lineItemObj.data[x].Date).format('MM/DD/YYYY h:mm:ss a'));
                    //   var yyy = moment.utc(lineItemObj.data[x].Date);

                    lineitem.push(converted, lineItemObj.data[x].y);
                    internaldata.push(lineitem);
                }
                internalData.data = internaldata;
                allSensors.push(internalData);

            }
            return allSensors;
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

            return false;
        });
        debugger;
        var dt_from = "2017/07/01 00:00:00";
        var dt_from_slider = new Date();
        //var dt_from_slider = dt_from_slider.setDate(dt_from_slider.getDate() - 2);
        var dt_from_slider = moment().subtract(3, "days").format("YYYY/MM/DD h:mm:ss");
        var dt_to = Date();

        $('.slider-time').html(moment(dt_from_slider).format('MM/DD/YYYY h:mm:ss a'));
        $('.slider-time2').html(moment(dt_to).format('MM/DD/YYYY h:mm:ss a'));

        var min_val = Date.parse(dt_from) / 1000;
        var min_slider_val = Date.parse(dt_from_slider) / 1000;
        var max_val = Date.parse(dt_to) / 1000;
      //  debugger;
        startTicks = new Date(min_slider_val * 1000);
        endTicks = new Date(max_val * 1000);
        console.log("doc init startticks=" + startTicks + " endticks=" + endTicks);

        function zeroPad(num, places) {
            var zero = places - num.toString().length + 1;
            return Array(+(zero > 0 && zero)).join("0") + num;
        }

        function formatDT(__dt) {
            var year = __dt.getFullYear();
            var month = zeroPad(__dt.getMonth() + 1, 2);
            var date = zeroPad(__dt.getDate(), 2);
            var hours = zeroPad(__dt.getHours(), 2);
            var minutes = zeroPad(__dt.getMinutes(), 2);
            var seconds = zeroPad(__dt.getSeconds(), 2);
            return year + '-' + month + '-' + date + ' ' + hours + ':' + minutes + ':' + seconds;
        };

        $("#slider-range").slider({
            range: true,
            min: min_val,
            max: max_val,
            step: 10,
            values: [min_slider_val, max_val],
            slide: function (e, ui) {
                var dt_cur_from = new Date(ui.values[0] * 1000);
                var dt_cur_to = new Date(ui.values[1] * 1000);
                $('.slider-time').html(moment(dt_cur_from).format('MM/DD/YYYY h:mm:ss a'));
                $('.slider-time2').html(moment(dt_cur_to).format('MM/DD/YYYY h:mm:ss a'));
            }
        });

        $("#slider-range").on("slidechange", function (event, ui) {
            //    debugger;
            var dt_cur_from = new Date(ui.values[0] * 1000);
            var dt_cur_to = new Date(ui.values[1] * 1000); 
            startTicks = dt_cur_from;
            endTicks = dt_cur_to;
            console.log("slider change dt_cur_from=" + formatDT(dt_cur_from) + " dt_cur_to=" + formatDT(dt_cur_to));

            $('.slider-time').html(moment(dt_cur_from).format('MM/DD/YYYY h:mm:ss a'));
            $('.slider-time2').html(moment(dt_cur_to).format('MM/DD/YYYY h:mm:ss a'));

            console.log("slider change startDate=" + moment(new Date(startTicks)).format('MM/DD/YYYY h:mm:ss a')
                + " endDate=" + moment(new Date(endTicks)).format('MM/DD/YYYY h:mm:ss a'));
            GetTempsForChart();

           // startTicks = ui.values[0];
           // endTicks = ui.values[1];
           //debugger;
          //  alert(new Date(startTicks * 1000).format("yyyy-mm-dd hh:ii:ss"));
            //alert(moment(new Date(startTicks * 1000).format("yyyy-mm-dd hh:ii:ss"));
            //var endDate = moment(new Date()).format('MM/DD/YYYY h:mm:ss a');
            //var startDate = moment(new Date(startTicks * 1000)).format('MM/DD/YYYY h:mm:ss a');
            //var startDate = moment(new Date(startTicks * 100)).format('MM/DD/YYYY h:mm:ss a');


           // alert(moment(new Date(startTicks * 1000).format('MM/DD/YYYY h:mm:ss a')));

          //  alert(moment.utc(new Date(startTicks * 1000).valueOf));


            //  alert(moment.utc(startTicks / 10000).format('MM/DD/YYYY h:mm:ss a'));
        }
        );


        function RefreshAll() {
            GetExperiments();
            GetActiveSensors();
            GetTempsForChart();
            GetTempsForGridRaw();
            LastUdated();
            console.log("refresh milisec: " + refreshMilSeconds);

            var refreshMe = setInterval(RefreshAll, refreshMilSeconds);
        };

        function GetExperiments() {
            $.getJSON(urlApiGetExperiments,
                function (result) {
                    var options = $("#experimentFilter");
                    options.empty();
                    $.each(result, function () {
                        options.append($("<option />").val(this.Experiment).text(this.Experiment));
                    });
                });
        };

        function LastUdated() {
            $('#lastUpdated').text(moment(new Date()).format('MM/DD/YYYY h:mm:ss a'));
        };

        function GetTempsForGridRaw() {
            console.log("GetTempsForGridRaw");
            $.getJSON(urlApiGetTempsRaw,
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
                        tr.append("<td style='text-align: right'>" + json[i].SoftwareVersion + "</td>");
                        tr.append("<td style='text-align: right'>" + json[i].FreeHeap + "</td>");
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

        function DeleteDeviceLogSensor(deviceLogSensorId) {
            urlApiDeleteDeviceLogSensor
            $.getJSON(urlApiDeleteDeviceLogSensor + '/' + deviceLogSensorId, function () {
                GetActiveSensors();
            });

            //alert(deviceLogSensorId);
            return false;
        };

        function StartLudicrousMode() {
            $.getJSON(urlApiStartLudicrousMode, function (activeClients) {
                //  debugger;
                PopulateActiveClients(activeClients.Table);
                refreshMilSeconds = activeClients.Table1[0].RefreshSeconds * 1000
                RefreshAll();
            });
            return false;
        };

        function PopulateActiveClients(activeClients) {
            $('#tableActiveSensors tbody tr').remove();
            console.log("PopulateActiveClients()");
            var tr;
            var currentDatetime = new moment();

            for (var i = 0; i < activeClients.length; i++) {
                tr = $('<tr/>');
                //tr.append("<td>" + activeClients[i].Id + "</td>");
                tr.append("<td>" + activeClients[i].SensorName + "</td>");
                tr.append("<td>" + moment(activeClients[i].LastUpdated).format('MM/DD/YYYY h:mm:ss a') + "</td>");
                var diff = moment(currentDatetime).diff(moment(activeClients[i].LastUpdated));
                var duration = moment.duration(diff);

                //console.log("duration: " + duration);
                //console.log("duration days: " + duration.days());
                //console.log("duration hours: " + duration.hours());
                //console.log("duration minutes: " + duration.minutes());
                //console.log("duration seconds: " + duration.seconds());
                //console.log("duration as minutes: " + duration.asMinutes());
                var lastCheckinVariance = "";
                if (duration.days() > 0)
                    lastCheckinVariance += duration.days() + " Days ";
                if (duration.hours() > 0)
                    lastCheckinVariance += duration.hours() + " Hours ";
                if (duration.minutes() > 0)
                    lastCheckinVariance += duration.minutes() + " Minutes ";
                lastCheckinVariance += duration.seconds() + " Seconds ";
                var bgColor = "";
                if (duration.asSeconds() > activeClients[i].UpdateSeconds)
                    bgColor = "lightcoral";
                else
                    bgColor = "lightgreen";

                tr.append("<td style='background-color: " + bgColor + "'>" + lastCheckinVariance + "</td>");
                tr.append("<td>" + activeClients[i].UpdateSeconds + "</td>");
                //var modeBgColor = "";
                //if (duration.asSeconds() > activeClients[i].UpdateSeconds)
                //    modeBgColor = "lightcoral";
                //else
                //    modeBgColor = "lightgreen";

                //tr.append("<td style='background-color: " + modeBgColor + "'>" + activeClients[i].Mode + "</td>");
                tr.append("<td>" + activeClients[i].Mode + "</td>");
                tr.append("<td style='text-align: right'>" + activeClients[i].VccVoltage + "</td>");
                tr.append("<td style='text-align: right'>" + activeClients[i].WiFiSignalStrength + "</td>");
                tr.append("<td style='text-align: right'>" + activeClients[i].SoftwareVersion + "</td>");
                tr.append("<td>  <input type='submit' value='Delete' onclick='return DeleteDeviceLogSensor(" + activeClients[i].Id + ")'/> </td>");

                //      &nbsp; <input type='submit' value='Ludicrous Mode' onclick="StartLudicrousMode(); return 'false';" />

                $('#tableActiveSensors').append(tr);
            }
        };

        function GetTempsForChart() {
            console.log("getTempsForChart");

            var startIsoDate = moment(new Date(startTicks)).format();
            var endIsoDate = moment(new Date(endTicks)).format();

            var url = urlApiGetTempsRawForChartV211 + "?startIsoDate=" + startIsoDate + "&endIsoDate=" + endIsoDate;
         //   debugger;

            $.getJSON(url, function (data) {
            //$.getJSON(urlApiGetTempsRawForChart, function (data) {

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

                    //series: data
                    series: Converter(JSON.parse(data))
                    //series: Converter(data) //doesnt work
                    //series: serieseric6c

                });
            });
        };

    </script>
</body>
</html>
