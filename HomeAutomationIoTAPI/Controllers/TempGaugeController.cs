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
        //[Route("TempGauge/{sensorName}/{location}/{experiment}/{temp:decimal}/{vccVoltage:decimal}")]
        [Route("TempGauge/{sensorName}/{location}/{experiment}/{temp:decimal}/{vccVoltage:decimal}/{wifiSignalStrength:decimal}/{softwareVersion}")]
        public HttpResponseMessage RecordTemp(string sensorName, string location, string experiment, decimal temp, decimal vccVoltage, decimal wifiSignalStrength, string softwareVersion)
        {
            DateTime start = DateTime.Now;

            var p = new Parameters()
        {
            { "sensorName", sensorName },
            { "location", location },
            { "experiment", experiment },
            { "value", temp },
            { "vccVoltage", vccVoltage },
            { "wifiSignalStrength", wifiSignalStrength },
            { "softwareVersion", softwareVersion }

        };
            int newTimeValue = Connect.Execute("uspDeviceLotValueInsert", p);

            HttpResponseMessage response;
            response = Request.CreateResponse(HttpStatusCode.OK, newTimeValue);
            return response;
        }

        [HttpGet]
        [Route("TempGauge/GetTemps")]
        public HttpResponseMessage GetTemps()
        {
            DataTable results = Connect.GetDataTable("uspDeviceLogValueSelectAll");

            HttpResponseMessage response;
            response = Request.CreateResponse(HttpStatusCode.OK, results);
            return response;
        }

        struct Temps
        {
            public DateTime name { get; set; }
            //public string name { get; set; }
            public double y { get; set; }
        };

        class SeriesTemps
        {
            public string name { get; set; } = "";
            //public string name { get; set; }
            private string[] dataList = new string[500];

            public string[] data
            {
                get
                {
                    return dataList;
                }
                set
                {
                    dataList = value;
                }
            }
        }

        [HttpGet]
        [Route("TempGauge/GetTempsForChart")]
        public HttpResponseMessage GetTempsForChart()
        {
            DataTable results = Connect.GetDataTable("uspDeviceLogValueSelectForChart");
            var resultsArray = new List<SeriesTemps>();

            var sensors = results.AsEnumerable().
                            Select(row => new { Name = row.Field<string>("SensorName") })
                            .Distinct();

            //Dictionary<string, IEnumerable<string>> list = new Dictionary<string, IEnumerable<string>>();
            SeriesTemps[] list = new SeriesTemps[1000];
            int sensorIndex = 0;

            foreach (var sensor in sensors)
            {
                // SeriesTemps seriesTemps = new SeriesTemps();
                // int index = 0;

                var rawDataForSensor = from rawData in results.AsEnumerable()
                                       where rawData.Field<string>("SensorName") == sensor.Name
                                       select rawData;
                SeriesTemps seriesTemp = new SeriesTemps();
                seriesTemp.name = sensor.Name;
                
                List<string> dataList = new List<string>();
                foreach (var rawDataLineItem in rawDataForSensor)
                {
                    //seriesTemps.data.Add("" + "[" + rawDataLineItem.Field<DateTime>("Updated").ToString() + "" + ", " + 
                    //    rawDataLineItem.Field<decimal>("Value").ToString() + "],");

                    //seriesTemps.data.Add(rawDataLineItem.Field<DateTime>("Updated").ToString() + ", " +
                    //    rawDataLineItem.Field<decimal>("Value").ToString());
                    
                    // [[Date.UTC(2017,8,19,14,12,30), 77.1100],
                    DateTime lastUpdated = Convert.ToDateTime(rawDataLineItem.Field<DateTime>("Updated"));
                    //dataList.Add("[Date.UTC(" + lastUpdated.Year + "," + lastUpdated.Month + "," + lastUpdated.Day + "," + lastUpdated.Hour + "," + lastUpdated.Minute + "," + lastUpdated.Second +")" + "," +
                    //    rawDataLineItem.Field<decimal>("Value").ToString() + "]");

                    dataList.Add("Date.UTC(" + lastUpdated.Year + "," + lastUpdated.Month + "," + lastUpdated.Day + "," + lastUpdated.Hour + "," + lastUpdated.Minute + "," + lastUpdated.Second + ")" + "," +
                                rawDataLineItem.Field<decimal>("Value").ToString());
                   // index ++;

                }
                seriesTemp.data = dataList.ToArray();

                list[sensorIndex] = seriesTemp;
                sensorIndex++;
              //  seriesTemps.data = dataList.ToArray();
               // resultsArray.Add(seriesTemps);
            }

            HttpResponseMessage response;
            //response = Request.CreateResponse(HttpStatusCode.OK, JsonConvert.SerializeObject(list));
            var xxx = JsonConvert.SerializeObject(list);
            JArray jarray = new JArray();
            
            foreach(var item in list[0].data)
            {
                jarray.Add(item);
            }


            //response = Request.CreateResponse(HttpStatusCode.OK, JsonConvert.SerializeObject(list));


            //response = Request.CreateResponse(HttpStatusCode.OK, JsonConvert.SerializeObject(jarray)); //same
            response = Request.CreateResponse(HttpStatusCode.OK, jarray);  //same

            return response;

             //[{
             //           "name": "temp1", data: [
             //               ["2017-08-19T12:25:28", 78.8],
             //               ["2017-08-19T12:25:28", 79.8],
             //               ["2017-08-19T12:25:28", 80.8]
             //           ]
             //       }, {
             //           "name": "temp2", data: [
             //               ["2017-08-19T12:25:28", 78.8],
             //               ["2017-08-19T12:25:28", 76.8],
             //               ["2017-08-19T12:25:28", 70.8]
             //           ]
             //       }]
        }

        //[HttpGet]
        //[Route("TempGauge/GetTempsForChart")]
        //public HttpResponseMessage GetTempsForChart()
        //{

        //    DataTable results = Connect.GetDataTable("uspDeviceLogValueSelectForChart");
        //    var resultsArray = new List<Temps>();

        //    foreach (DataRow row in results.Rows)
        //    {
        //        //resultsArray.Add(new Temps { name = row["Updated"].ToString(), y = Convert.ToDouble(row["Value"]) });
        //        resultsArray.Add(new Temps { name = Convert.ToDateTime(row["Updated"].ToString()), y = Convert.ToDouble(row["Value"]) });
        //    }

        //    HttpResponseMessage response;
        //    response = Request.CreateResponse(HttpStatusCode.OK, JsonConvert.SerializeObject(resultsArray));
        //    return response;
        //}

        [HttpGet]
        [Route("TempGauge/GetTempsForChart2")]
        public HttpResponseMessage GetTempsForChart2()
        {

            DataTable results = Connect.GetDataTable("uspDeviceLogValueSelectForChart");
            var resultsArray = new List<Temps>();

            foreach (DataRow row in results.Rows)
            {
                //resultsArray.Add(new Temps { name = row["Updated"].ToString(), y = Convert.ToDouble(row["Value"]) });
                resultsArray.Add(new Temps { name = Convert.ToDateTime(row["Updated"].ToString()), y = Convert.ToDouble(row["Value"]) });
            }

            HttpResponseMessage response;
            response = Request.CreateResponse(HttpStatusCode.OK, JsonConvert.SerializeObject(resultsArray));
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

    }
}
