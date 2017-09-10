using Intel.eFactory.DataAccess;
using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Net;
using System.Net.Http;
using System.Web.Http;
using Newtonsoft.Json;
using Newtonsoft.Json.Linq;
using System.Collections.Generic;
using System.Web.Helpers;


namespace HomeAutomationIoTAPI.Controllers
{
    [RoutePrefix("api")]
    public class TempGaugeController : ApiController
    {
        [HttpGet]
        [Route("TempGauge/{sensorName}/{location}/{experiment}/{temp:decimal}/{vccVoltage:decimal}/{wifiSignalStrength:decimal}/{softwareVersion}")]
        //[Route("TempGauge/{sensorName}/{location}/{experiment}/{temp:decimal}/{updateSeconds: int}/{vccVoltage:decimal}/{wifiSignalStrength:decimal}/{softwareVersion}")]
        //public HttpResponseMessage RecordTemp(string sensorName, string location, string experiment, decimal temp, int updateSeconds, decimal vccVoltage, decimal wifiSignalStrength, string softwareVersion)
        public HttpResponseMessage RecordTemp(string sensorName, string location, string experiment, decimal temp, decimal vccVoltage, decimal wifiSignalStrength, string softwareVersion)
        {
            DateTime start = DateTime.Now;

            var p = new Parameters()
        {
            { "sensorName", sensorName },
            { "location", location },
            { "experiment", experiment },
            { "value", temp },
            { "updateSeconds", 300 },
            { "vccVoltage", vccVoltage },
            { "wifiSignalStrength", wifiSignalStrength },
            { "softwareVersion", softwareVersion }

        };
            int newTimeValue = Connect.Execute("uspDeviceLogValueInsert", p);

            HttpResponseMessage response;
            response = Request.CreateResponse(HttpStatusCode.OK, newTimeValue);
            return response;
        }

        //v1.0.6
        [HttpGet]  
        [Route("TempGauge/{sensorName}/{location}/{experiment}/{temp:decimal}/{vccVoltage:decimal}/{wifiSignalStrength:decimal}/{freeHeap:int}/{softwareVersion}")]
        public HttpResponseMessage RecordTemp(string sensorName, string location, string experiment, decimal temp, decimal vccVoltage, decimal wifiSignalStrength, int freeHeap, string softwareVersion)
        {
            DateTime start = DateTime.Now;

            var p = new Parameters()
        {
            { "sensorName", sensorName },
            { "location", location },
            { "experiment", experiment },
            { "value", temp },
            { "updateSeconds", 300 },
            { "vccVoltage", vccVoltage },
            { "wifiSignalStrength", wifiSignalStrength },
            { "freeHeap", freeHeap },
            { "softwareVersion", softwareVersion }

        };
            int newTimeValue = Connect.Execute("uspDeviceLogValueInsert", p);

            HttpResponseMessage response;
            response = Request.CreateResponse(HttpStatusCode.OK, newTimeValue);
            return response;
        }

        [HttpGet]
        [Route("TempGauge/GetTempsRaw")]
        public HttpResponseMessage GetTempsRaw()
        {
            DataTable results = Connect.GetDataTable("uspDeviceLogValueSelectAll");

            HttpResponseMessage response;
            response = Request.CreateResponse(HttpStatusCode.OK, results);
            return response;
        }

        //struct Temps
        //{
        //    public DateTime name { get; set; }
        //    //public string name { get; set; }
        //    public double y { get; set; }
        //};


        class Temp
        {
            public Temp() { }
            public string Date { get; set; }
            public double SensorTemp { get; set; }
        };

        //class SeriesTemps
        //{
        //    public string name { get; set; } = "";
        //    //public string name { get; set; }
        //    public List<List<Temp>> data = new List<List<Temp>>();
        //}
        //class SeriesTempsTuple
        //{
        //    public string name { get; set; } = "";
        //    //public Tuple<string, double>[] data = { new Tuple<string, double>("x", 73.11)};
        //    public List<Tuple<string, double>[]> data = new List<Tuple<string, double>[]>();
        //}
        class Temp2
        {
            //public string Date { get; set; }
            public DateTime Date { get; set; }
            public double y { get; set; }
        };
        class TempsMultiple
        {
            public string name { get; set; }
            public List<Temp2> data { get; set; } = new List<Temp2>();
        };

        [HttpGet]
        [Route("TempGauge/GetTempsForChart")]
        public HttpResponseMessage GetTempsForChart()
        {
            DataTable results = Connect.GetDataTable("uspDeviceLogValueSelectForChart");
            var tempsMultiple = new List<TempsMultiple>();

            var sensors = results.AsEnumerable().
                            Select(row => new { Name = row.Field<string>("SensorName") })
                            .Distinct();

            foreach (var sensor in sensors)
            {
                TempsMultiple tempMultiple = new TempsMultiple();
                var rawDataForSensor = from rawData in results.AsEnumerable()
                                       where rawData.Field<string>("SensorName") == sensor.Name
                                       select rawData;
                tempMultiple.name = sensor.Name;

                foreach (var rawDataLineItem in rawDataForSensor)
                {
                    Temp2 temp2 = new Temp2();
                    DateTime lastUpdated = Convert.ToDateTime(rawDataLineItem.Field<DateTime>("Updated"));
                    //temp2.Date = "Date.UTC(" + lastUpdated.Year + "," + lastUpdated.Month + "," + lastUpdated.Day + "," + lastUpdated.Hour + "," + lastUpdated.Minute + "," + lastUpdated.Second + ")";
                    temp2.Date = lastUpdated;
                    temp2.y = Convert.ToDouble(rawDataLineItem.Field<decimal>("Value"));
                    tempMultiple.data.Add(temp2);
                }
                tempsMultiple.Add(tempMultiple);
            }

            HttpResponseMessage response;
            response = Request.CreateResponse(HttpStatusCode.OK, JsonConvert.SerializeObject(tempsMultiple)); 
            return response;
        }

        [HttpGet]
        //[Route("TempGauge/GetTempsForChart/V211/{startIsoDate:datetime}/{endIsoDate:datetime}")]
        [Route("TempGauge/GetTempsForChart/V211")]
        public HttpResponseMessage GetTempsForChartV211(DateTime? startIsoDate = null, DateTime? endIsoDate = null)
        {
            Parameters parms = new Parameters();
            parms.Add("startDate", startIsoDate);
            parms.Add("endDate", endIsoDate);
            DataTable results = Connect.GetDataTable("uspDeviceLogValueSelectForChart", parms);
            var tempsMultiple = new List<TempsMultiple>();

            var sensors = results.AsEnumerable().
                            Select(row => new { Name = row.Field<string>("SensorName") })
                            .Distinct();

            foreach (var sensor in sensors)
            {
                TempsMultiple tempMultiple = new TempsMultiple();
                var rawDataForSensor = from rawData in results.AsEnumerable()
                                       where rawData.Field<string>("SensorName") == sensor.Name
                                       select rawData;
                tempMultiple.name = sensor.Name;

                foreach (var rawDataLineItem in rawDataForSensor)
                {
                    Temp2 temp2 = new Temp2();
                    DateTime lastUpdated = Convert.ToDateTime(rawDataLineItem.Field<DateTime>("Updated"));
                    //temp2.Date = "Date.UTC(" + lastUpdated.Year + "," + lastUpdated.Month + "," + lastUpdated.Day + "," + lastUpdated.Hour + "," + lastUpdated.Minute + "," + lastUpdated.Second + ")";
                    temp2.Date = lastUpdated;
                    temp2.y = Convert.ToDouble(rawDataLineItem.Field<decimal>("Value"));
                    tempMultiple.data.Add(temp2);
                }
                tempsMultiple.Add(tempMultiple);
            }

            HttpResponseMessage response;
            response = Request.CreateResponse(HttpStatusCode.OK, JsonConvert.SerializeObject(tempsMultiple));
            return response;
        }

        [HttpGet]
        [Route("TempGauge/GetActiveClients")]
        public HttpResponseMessage GetActiveClients()
        {

            DataTable results = Connect.GetDataTable("uspDeviceLogValueGetActiveClients");

            HttpResponseMessage response;
            response = Request.CreateResponse(HttpStatusCode.OK, results);
            return response;
        }

        [HttpGet]
        [Route("TempGauge/GetExperiments")]
        public HttpResponseMessage GetExperiments()
        {

            DataTable results = Connect.GetDataTable("uspDeviceLogValueGetExperiments");

            HttpResponseMessage response;
            response = Request.CreateResponse(HttpStatusCode.OK, results);
            return response;
        }

        [HttpGet]
        [Route("TempGauge/StartLudicrousMode/{seconds}")]
        public HttpResponseMessage StartLudicrousMode(int seconds)
        {
            var p = new Parameters()
            {
                { "seconds", seconds }
            };
            DataSet results = Connect.GetDataSet("uspDeviceLogSensorUpdate", p);

            HttpResponseMessage response;
            response = Request.CreateResponse(HttpStatusCode.OK, results);
            return response;
        }


        [HttpGet]
        [Route("TempGauge/DeleteDeviceLogSensor/{deviceLogSensorId}")]
        public HttpResponseMessage DeleteDeviceLogSensor(int deviceLogSensorId)
        {
            var p = new Parameters()
            {
                { "deviceLogSensorId", deviceLogSensorId }
            };
            DataSet results = Connect.GetDataSet("uspDeviceLogSensorDelete", p);

            HttpResponseMessage response;
            response = Request.CreateResponse(HttpStatusCode.OK, results);
            return response;
        }
    }
}
